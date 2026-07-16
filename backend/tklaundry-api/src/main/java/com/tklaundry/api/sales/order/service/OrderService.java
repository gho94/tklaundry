package com.tklaundry.api.sales.order.service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tklaundry.api.common.AutoNumberDoc;
import com.tklaundry.api.common.CommonInfo;
import com.tklaundry.api.common.service.IAutoNumberService;
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

		List<OrderDetail> orderDetails = new ArrayList<>();
		int totalQty = 0;
		int totalDiscount = 0;
		int totalCost = 0;
		int orderSeq = 1;

		for (OrderDetailRequest orderDetail : request.getDetails()) {
			int cost = orderDetail.getPrice() * orderDetail.getQty() - orderDetail.getDiscount();
			totalQty += orderDetail.getQty();
			totalDiscount += orderDetail.getDiscount();
			totalCost += cost;

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

		OrderMaster orderMaster = OrderMaster.builder()
				.orderNo(orderNo)
				.orderDate(request.getOrderDate())
				.custCode(request.getCustCode())
				.qty(totalQty)
				.discount(totalDiscount)
				.cost(totalCost)
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

}
