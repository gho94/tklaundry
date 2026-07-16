package com.tklaundry.api.sales.order.service;

import java.time.LocalDate;
import java.util.List;

import org.springframework.stereotype.Service;

import com.tklaundry.api.sales.order.dto.OrderListResponse;
import com.tklaundry.api.sales.order.mapper.OrderMapper;
import com.tklaundry.api.sales.order.model.OrderDetail;
import com.tklaundry.api.sales.order.model.OrderMaster;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class OrderService implements IOrderService {

	private final OrderMapper orderMapper;

	@Override
	public OrderListResponse listOrders(LocalDate startDate, LocalDate endDate, String custCode) {
		List<OrderMaster> items = orderMapper.selectOrderMasterList(
				startDate, endDate.plusDays(1), custCode);

		int totalAmount = items.stream()
				.mapToInt(item -> item.getCost() != null ? item.getCost() : 0)
				.sum();

		return new OrderListResponse(items, items.size(), totalAmount);
	}

	@Override
	public List<OrderDetail> listOrderDetails(String orderNo) {
		return orderMapper.selectOrderDetailList(orderNo);
	}

}
