package com.tklaundry.api.sales.delivery.service;

import java.time.LocalDate;
import java.util.List;

import org.springframework.stereotype.Service;

import com.tklaundry.api.sales.delivery.mapper.DeliveryMapper;
import com.tklaundry.api.sales.order.dto.OrderListResponse;
import com.tklaundry.api.sales.order.model.OrderDetail;
import com.tklaundry.api.sales.order.model.OrderMaster;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class DeliveryService implements IDeliveryService {

	private final DeliveryMapper deliveryMapper;

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

}
