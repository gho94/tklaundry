package com.tklaundry.api.sales.order.service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tklaundry.api.common.AutoNumberDoc;
import com.tklaundry.api.common.CommonInfo;
import com.tklaundry.api.common.service.IAutoNumberService;
import com.tklaundry.api.common.web.ApiErrorCode;
import com.tklaundry.api.common.web.ApiException;
import com.tklaundry.api.sales.order.dto.OrderDetailRequest;
import com.tklaundry.api.sales.order.dto.OrderListResponse;
import com.tklaundry.api.sales.order.dto.OrderRequest;
import com.tklaundry.api.sales.order.mapper.OrderMapper;
import com.tklaundry.api.sales.order.model.OrderDetail;
import com.tklaundry.api.sales.order.model.OrderMaster;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class OrderService implements IOrderService {

	private final OrderMapper orderMapper;
	private final IAutoNumberService autoNumberService;
	private final CommonInfo commonInfo;

	@Override
	public OrderListResponse listOrders(LocalDate startDate, LocalDate endDate, String custCode) {
		List<OrderMaster> orderMasters = orderMapper.selectOrderMasterList(
				startDate, endDate.plusDays(1), custCode);

		int totalAmount = orderMasters.stream()
				.mapToInt(orderMaster -> orderMaster.getCost() != null ? orderMaster.getCost() : 0)
				.sum();

		return new OrderListResponse(orderMasters, orderMasters.size(), totalAmount);
	}

	@Override
	public List<OrderDetail> listOrderDetails(String orderNo) {
		return orderMapper.selectOrderDetailList(orderNo);
	}

	@Override
	@Transactional
	public OrderMaster registerOrder(OrderRequest request) {
		String orderNo = autoNumberService.nextDocumentNo(AutoNumberDoc.ORDER);
		List<OrderDetail> orderDetails = createOrderDetails(orderNo, request.getDetails());

		OrderMaster orderMaster = OrderMaster.builder()
				.orderNo(orderNo)
				.orderDate(request.getOrderDate())
				.custCode(request.getCustCode())
				.qty(orderDetails.stream().mapToInt(OrderDetail::getQty).sum())
				.discount(orderDetails.stream().mapToInt(OrderDetail::getDiscount).sum())
				.cost(orderDetails.stream().mapToInt(OrderDetail::getCost).sum())
				.status(request.getStatus())
				.bankingYn(request.getBankingYn())
				.completeYn("N")
				.insertUserId(commonInfo.getUser().getUserId())
				.build();

		orderMapper.insertOrderMaster(orderMaster);
		orderMapper.insertOrderDetails(orderDetails);

		// 선불 시 SalesMaster/Detail 자동 생성 — 매출 단계에서 구현

		return orderMaster;
	}

	@Override
	@Transactional
	public void updateOrder(String orderNo, OrderRequest request) {
		if (orderMapper.countCompletedOrderDetail(orderNo) > 0) {
			throw new ApiException(ApiErrorCode.CONFLICT, "출고된 내역이 있어서 수정이 불가합니다.");
		}

		List<OrderDetail> orderDetails = createOrderDetails(orderNo, request.getDetails());

		OrderMaster orderMaster = OrderMaster.builder()
				.orderNo(orderNo)
				.orderDate(request.getOrderDate())
				.custCode(request.getCustCode())
				.qty(orderDetails.stream().mapToInt(OrderDetail::getQty).sum())
				.discount(orderDetails.stream().mapToInt(OrderDetail::getDiscount).sum())
				.cost(orderDetails.stream().mapToInt(OrderDetail::getCost).sum())
				.status(request.getStatus())
				.bankingYn(request.getBankingYn())
				.updateUserId(commonInfo.getUser().getUserId())
				.build();

		orderMapper.updateOrderMaster(orderMaster);
		orderMapper.deleteOrderDetails(orderNo);
		orderMapper.insertOrderDetails(orderDetails);

		// 선불 변경 시 SalesMaster/Detail 동기화 — 매출 단계에서 구현
	}

	private List<OrderDetail> createOrderDetails(String orderNo, List<OrderDetailRequest> details) {
		List<OrderDetail> orderDetails = new ArrayList<>();
		int orderSeq = 1;

		for (OrderDetailRequest orderDetail : details) {
			int cost = orderDetail.getPrice() * orderDetail.getQty() - orderDetail.getDiscount();

			orderDetails.add(OrderDetail.builder()
					.orderNo(orderNo)
					.orderSeq(orderSeq++)
					.productCode(orderDetail.getProductCode())
					.processCode(orderDetail.getProcessCode())
					.price(orderDetail.getPrice())
					.qty(orderDetail.getQty())
					.discount(orderDetail.getDiscount())
					.cost(cost)
					.completeYn("N")
					.remark(orderDetail.getRemark())
					.build());
		}

		return orderDetails;
	}

}
