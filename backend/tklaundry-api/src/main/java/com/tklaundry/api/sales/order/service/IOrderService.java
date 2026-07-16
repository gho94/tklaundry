package com.tklaundry.api.sales.order.service;

import java.time.LocalDate;
import java.util.List;

import com.tklaundry.api.sales.order.dto.OrderListResponse;
import com.tklaundry.api.sales.order.dto.OrderRequest;
import com.tklaundry.api.sales.order.model.OrderDetail;
import com.tklaundry.api.sales.order.model.OrderMaster;

public interface IOrderService {

	OrderListResponse listOrders(LocalDate startDate, LocalDate endDate, String custCode);

	List<OrderDetail> listOrderDetails(String orderNo);

	OrderMaster registerOrder(OrderRequest request);

	void updateOrder(String orderNo, OrderRequest request);

}
