package com.tklaundry.api.sales.order.service;

import java.time.LocalDate;
import java.util.List;

import com.tklaundry.api.sales.order.dto.OrderListResponse;
import com.tklaundry.api.sales.order.model.OrderDetail;

public interface IOrderService {

	OrderListResponse listOrders(LocalDate startDate, LocalDate endDate, String custCode);

	List<OrderDetail> listOrderDetails(String orderNo);

}
