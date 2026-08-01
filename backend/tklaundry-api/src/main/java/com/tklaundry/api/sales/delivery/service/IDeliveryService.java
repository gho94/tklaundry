package com.tklaundry.api.sales.delivery.service;

import java.time.LocalDate;
import java.util.List;

import com.tklaundry.api.sales.delivery.dto.DeliveryListResponse;
import com.tklaundry.api.sales.delivery.dto.DeliveryRequest;
import com.tklaundry.api.sales.delivery.model.DeliveryDetail;
import com.tklaundry.api.sales.delivery.model.DeliveryMaster;
import com.tklaundry.api.sales.order.dto.OrderListResponse;
import com.tklaundry.api.sales.order.model.OrderDetail;

public interface IDeliveryService {

	OrderListResponse listOrders(LocalDate startDate, LocalDate endDate, String custCode);

	List<OrderDetail> listOrderDetails(String orderNo);

	DeliveryListResponse listDeliveries(LocalDate startDate, LocalDate endDate, String custCode);

	List<DeliveryDetail> listDeliveryDetails(String deliveryNo);

	DeliveryMaster registerDelivery(DeliveryRequest request);

}
