package com.tklaundry.api.sales.delivery.service;

import java.time.LocalDate;
import java.util.List;

import com.tklaundry.api.sales.order.dto.OrderListResponse;
import com.tklaundry.api.sales.order.model.OrderDetail;

public interface IDeliveryService {

	OrderListResponse listOrders(LocalDate startDate, LocalDate endDate, String custCode);

	List<OrderDetail> listOrderDetails(String orderNo);

}
