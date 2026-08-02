package com.tklaundry.api.sales.sales.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import com.tklaundry.api.common.constants.AutoNumberDoc;
import com.tklaundry.api.common.CommonInfo;
import com.tklaundry.api.common.service.IAutoNumberService;
import com.tklaundry.api.common.constants.PaymentStatusCodes;
import com.tklaundry.api.sales.delivery.dto.DeliveryRequest;
import com.tklaundry.api.sales.delivery.model.DeliveryDetail;
import com.tklaundry.api.sales.delivery.model.DeliveryMaster;
import com.tklaundry.api.sales.order.model.OrderDetail;
import com.tklaundry.api.sales.order.model.OrderMaster;
import com.tklaundry.api.sales.sales.mapper.SalesMapper;
import com.tklaundry.api.sales.sales.dto.SalesListResponse;
import com.tklaundry.api.sales.sales.model.SalesDetail;
import com.tklaundry.api.sales.sales.model.SalesMaster;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class SalesService implements ISalesService {

	private final SalesMapper salesMapper;
	private final IAutoNumberService autoNumberService;
	private final CommonInfo commonInfo;

	@Override
	public SalesListResponse listSales(LocalDate startDate, LocalDate endDate, String custCode) {
		List<SalesMaster> salesMasters = salesMapper.selectSalesMasterList(
				startDate, endDate.plusDays(1), custCode);

		int totalAmount = salesMasters.stream()
				.mapToInt(salesMaster -> salesMaster.getCost() != null ? salesMaster.getCost() : 0)
				.sum();

		return new SalesListResponse(salesMasters, salesMasters.size(), totalAmount);
	}

	@Override
	public List<SalesDetail> listSalesDetails(String salesNo) {
		return salesMapper.selectSalesDetailList(salesNo);
	}

	@Override
	public void handleOrderStatusChange(OrderMaster orderMaster, List<OrderDetail> orderDetails) {
		if (PaymentStatusCodes.PREPAID.equals(orderMaster.getStatus())) {
			syncPrepaidOrder(orderMaster, orderDetails);
		} else {
			removePrepaidSales(orderMaster.getOrderNo());
		}
	}

	@Override
	public void removePrepaidSales(String orderNo) {
		String salesNo = salesMapper.selectSalesNoByOrderNo(orderNo);
		if (!StringUtils.hasText(salesNo)) {
			return;
		}

		salesMapper.deleteSalesDetailsBySalesNo(salesNo);
		salesMapper.deleteSalesMaster(salesNo);
	}

	private void syncPrepaidOrder(OrderMaster orderMaster, List<OrderDetail> orderDetails) {
		String orderNo = orderMaster.getOrderNo();
		String salesNo = salesMapper.selectSalesNoByOrderNo(orderNo);
		if (!StringUtils.hasText(salesNo)) {
			salesNo = autoNumberService.nextDocumentNo(AutoNumberDoc.SALES);
		}

		String userId = commonInfo.getUser().getUserId();

		SalesMaster salesMaster = SalesMaster.builder()
				.salesNo(salesNo)
				.salesDate(LocalDateTime.now())
				.custCode(orderMaster.getCustCode())
				.qty(orderMaster.getQty())
				.discount(orderMaster.getDiscount())
				.cost(orderMaster.getCost())
				.bankingYn(orderMaster.getBankingYn())
				.status(orderMaster.getStatus())
				.salesYn("Y")
				.insertUserId(userId)
				.updateUserId(userId)
				.build();

		salesMapper.upsertSalesMaster(salesMaster);

		for (OrderDetail orderDetail : orderDetails) {
			salesMapper.upsertSalesDetail(SalesDetail.builder()
					.salesNo(salesNo)
					.salesSeq(orderDetail.getOrderSeq())
					.productCode(orderDetail.getProductCode())
					.processCode(orderDetail.getProcessCode())
					.price(orderDetail.getPrice())
					.qty(orderDetail.getQty())
					.discount(orderDetail.getDiscount())
					.cost(orderDetail.getCost())
					.orderNo(orderNo)
					.orderSeq(orderDetail.getOrderSeq())
					.remark(orderDetail.getRemark())
					.build());
		}

		salesMapper.deleteSalesDetailsByOrderNoAndSeqGreaterThan(orderNo, orderDetails.size());
	}

	@Override
	public void createFromDelivery(
			DeliveryRequest request,
			DeliveryMaster deliveryMaster,
			List<DeliveryDetail> deliveryDetails,
			String resolvedStatus) {
		String orderNo = request.getOrderNo();
		String orderStatus = request.getOrderStatus();
		String comboStatus = request.getStatus();

		String salesNo = resolveSalesNoForDelivery(orderNo, orderStatus);
		LocalDateTime salesDate = resolveSalesDateForDelivery(orderNo, orderStatus, comboStatus);
		String salesYn = PaymentStatusCodes.GENERAL.equals(comboStatus) ? "Y" : "N";
		String userId = commonInfo.getUser().getUserId();

		SalesMaster salesMaster = SalesMaster.builder()
				.salesNo(salesNo)
				.salesDate(salesDate)
				.custCode(deliveryMaster.getCustCode())
				.qty(deliveryMaster.getQty())
				.discount(deliveryMaster.getDiscount())
				.cost(deliveryMaster.getCost())
				.bankingYn(deliveryMaster.getBankingYn())
				.status(resolvedStatus)
				.salesYn(salesYn)
				.insertUserId(userId)
				.updateUserId(userId)
				.build();

		salesMapper.upsertSalesMaster(salesMaster);

		for (DeliveryDetail deliveryDetail : deliveryDetails) {
			salesMapper.upsertSalesDetail(SalesDetail.builder()
					.salesNo(salesNo)
					.salesSeq(deliveryDetail.getDeliverySeq())
					.productCode(deliveryDetail.getProductCode())
					.processCode(deliveryDetail.getProcessCode())
					.price(deliveryDetail.getPrice())
					.qty(deliveryDetail.getQty())
					.discount(deliveryDetail.getDiscount())
					.cost(deliveryDetail.getCost())
					.orderNo(deliveryDetail.getOrderNo())
					.orderSeq(deliveryDetail.getOrderSeq())
					.deliveryNo(deliveryDetail.getDeliveryNo())
					.deliverySeq(deliveryDetail.getDeliverySeq())
					.remark(deliveryDetail.getRemark())
					.build());
		}
	}

	private String resolveSalesNoForDelivery(String orderNo, String orderStatus) {
		if (PaymentStatusCodes.PREPAID.equals(orderStatus)) {
			String salesNo = salesMapper.selectSalesNoByOrderNo(orderNo);
			if (StringUtils.hasText(salesNo)) {
				return salesNo;
			}
		}

		return autoNumberService.nextDocumentNo(AutoNumberDoc.SALES);
	}

	private LocalDateTime resolveSalesDateForDelivery(String orderNo, String orderStatus, String comboStatus) {
		if (!PaymentStatusCodes.GENERAL.equals(comboStatus)) {
			return null;
		}

		if (!PaymentStatusCodes.GENERAL.equals(orderStatus)) {
			String existingSalesNo = salesMapper.selectSalesNoByOrderNo(orderNo);
			if (StringUtils.hasText(existingSalesNo)) {
				LocalDateTime existingSalesDate = salesMapper.selectSalesDateBySalesNo(existingSalesNo);
				if (existingSalesDate != null) {
					return existingSalesDate;
				}
			}
		}

		return LocalDateTime.now();
	}

}
