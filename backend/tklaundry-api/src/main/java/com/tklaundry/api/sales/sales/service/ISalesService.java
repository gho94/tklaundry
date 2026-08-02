package com.tklaundry.api.sales.sales.service;

import java.util.List;

import com.tklaundry.api.sales.delivery.dto.DeliveryRequest;
import com.tklaundry.api.sales.delivery.model.DeliveryDetail;
import com.tklaundry.api.sales.delivery.model.DeliveryMaster;
import com.tklaundry.api.sales.order.model.OrderDetail;
import com.tklaundry.api.sales.order.model.OrderMaster;

public interface ISalesService {

	void handleOrderStatusChange(OrderMaster orderMaster, List<OrderDetail> orderDetails);

	void removePrepaidSales(String orderNo);

	void createFromDelivery(
			DeliveryRequest request,
			DeliveryMaster deliveryMaster,
			List<DeliveryDetail> deliveryDetails,
			String resolvedStatus);

}
