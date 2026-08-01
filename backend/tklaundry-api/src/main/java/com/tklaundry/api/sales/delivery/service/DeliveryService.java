package com.tklaundry.api.sales.delivery.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tklaundry.api.common.AutoNumberDoc;
import com.tklaundry.api.common.CommonInfo;
import com.tklaundry.api.common.service.IAutoNumberService;
import com.tklaundry.api.common.web.ApiErrorCode;
import com.tklaundry.api.common.web.ApiException;
import com.tklaundry.api.sales.delivery.dto.DeliveryDetailRequest;
import com.tklaundry.api.sales.delivery.dto.DeliveryRequest;
import com.tklaundry.api.sales.delivery.mapper.DeliveryMapper;
import com.tklaundry.api.sales.delivery.model.DeliveryDetail;
import com.tklaundry.api.sales.delivery.model.DeliveryMaster;
import com.tklaundry.api.sales.order.dto.OrderListResponse;
import com.tklaundry.api.sales.order.model.OrderDetail;
import com.tklaundry.api.sales.order.model.OrderMaster;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class DeliveryService implements IDeliveryService {

	private static final String STATUS_GENERAL = "B20001";
	private static final String STATUS_PREPAID = "B20002";
	private static final String STATUS_CREDIT = "B20005";

	private final DeliveryMapper deliveryMapper;
	private final IAutoNumberService autoNumberService;
	private final CommonInfo commonInfo;

	@Override
	public OrderListResponse listOrders(LocalDate startDate, LocalDate endDate, String custCode) {
		List<OrderMaster> orderMasters = deliveryMapper.selectOrderMasterList(
				startDate, endDate.plusDays(1), custCode);

		int totalAmount = orderMasters.stream()
				.mapToInt(orderMaster -> orderMaster.getCost() != null ? orderMaster.getCost() : 0)
				.sum();

		return new OrderListResponse(orderMasters, orderMasters.size(), totalAmount);
	}

	@Override
	public List<OrderDetail> listOrderDetails(String orderNo) {
		return deliveryMapper.selectOrderDetailList(orderNo);
	}

	@Override
	@Transactional
	public DeliveryMaster registerDelivery(DeliveryRequest request) {
		if (STATUS_CREDIT.equals(request.getStatus())
				&& STATUS_PREPAID.equals(request.getOrderStatus())) {
			throw new ApiException(ApiErrorCode.CONFLICT, "선불처리된 제품입니다.");
		}

		String resolvedStatus = STATUS_GENERAL.equals(request.getStatus())
				? request.getOrderStatus()
				: request.getStatus();
		String deliveryNo = autoNumberService.nextDocumentNo(AutoNumberDoc.DELIVERY);

		List<DeliveryDetail> deliveryDetails = new ArrayList<>();
		int totalQty = 0;
		int totalDiscount = 0;
		int totalCost = 0;
		int deliverySeq = 1;

		for (DeliveryDetailRequest detailRequest : request.getDetails()) {
			int discount = detailRequest.getDiscount() != null ? detailRequest.getDiscount() : 0;
			int cost = detailRequest.getCost() != null
					? detailRequest.getCost()
					: detailRequest.getPrice() * detailRequest.getQty() - discount;

			totalQty += detailRequest.getQty();
			totalDiscount += discount;
			totalCost += cost;

			deliveryDetails.add(DeliveryDetail.builder()
					.deliveryNo(deliveryNo)
					.deliverySeq(deliverySeq++)
					.productCode(detailRequest.getProductCode())
					.processCode(detailRequest.getProcessCode())
					.price(detailRequest.getPrice())
					.qty(detailRequest.getQty())
					.discount(discount)
					.cost(cost)
					.orderNo(request.getOrderNo())
					.orderSeq(detailRequest.getOrderSeq())
					.remark(detailRequest.getRemark())
					.build());
		}

		DeliveryMaster deliveryMaster = DeliveryMaster.builder()
				.deliveryNo(deliveryNo)
				.orderDate(request.getOrderDate())
				.custCode(request.getCustCode())
				.qty(totalQty)
				.discount(totalDiscount)
				.cost(totalCost)
				.bankingYn(request.getBankingYn())
				.status(resolvedStatus)
				.deliveryDate(LocalDateTime.now())
				.insertUserId(commonInfo.getUser().getUserId())
				.build();

		deliveryMapper.insertDeliveryMaster(deliveryMaster);
		deliveryMapper.insertDeliveryDetails(deliveryDetails);

		for (DeliveryDetail deliveryDetail : deliveryDetails) {
			deliveryMapper.updateOrderDetailOnDelivery(
					request.getOrderNo(),
					deliveryDetail.getOrderSeq(),
					deliveryDetail.getDiscount(),
					deliveryDetail.getCost());
		}

		List<OrderDetail> orderDetails = deliveryMapper.selectAllOrderDetailsByOrderNo(request.getOrderNo());

		int orderTotalDiscount = orderDetails.stream()
				.mapToInt(detail -> detail.getDiscount() != null ? detail.getDiscount() : 0)
				.sum();
		int orderTotalCost = orderDetails.stream()
				.mapToInt(detail -> detail.getCost() != null ? detail.getCost() : 0)
				.sum();
		deliveryMapper.updateOrderMasterDiscountCost(
				request.getOrderNo(), orderTotalDiscount, orderTotalCost);

		boolean hasIncompleteOrderDetail = orderDetails.stream()
				.anyMatch(detail -> "N".equals(detail.getCompleteYn()));
		if (!hasIncompleteOrderDetail) {
			deliveryMapper.updateOrderMasterOnCompleteDelivery(
					request.getOrderNo(),
					resolvedStatus,
					commonInfo.getUser().getUserId());
		}

		// SalesMaster/Detail 생성 — 매출 단계에서 구현

		return deliveryMaster;
	}

}
