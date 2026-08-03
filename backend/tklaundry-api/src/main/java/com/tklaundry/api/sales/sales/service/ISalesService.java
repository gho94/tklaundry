package com.tklaundry.api.sales.sales.service;

import java.time.LocalDate;
import java.util.List;

import com.tklaundry.api.sales.delivery.dto.DeliveryRequest;
import com.tklaundry.api.sales.delivery.model.DeliveryDetail;
import com.tklaundry.api.sales.delivery.model.DeliveryMaster;
import com.tklaundry.api.sales.order.model.OrderDetail;
import com.tklaundry.api.sales.order.model.OrderMaster;
import com.tklaundry.api.sales.sales.dto.PendingPaymentItem;
import com.tklaundry.api.sales.sales.dto.SalesListResponse;
import com.tklaundry.api.sales.sales.model.SalesDetail;

public interface ISalesService {

	SalesListResponse listSales(LocalDate startDate, LocalDate endDate, String custCode);

	List<SalesDetail> listSalesDetails(String salesNo);

	List<PendingPaymentItem> listPendingPayments(String custCode);

	void registerPayment(String salesNo, String bankingYn);

	void handleOrderStatusChange(OrderMaster orderMaster, List<OrderDetail> orderDetails);

	void removePrepaidSales(String orderNo);

	void createFromDelivery(
			DeliveryRequest request,
			DeliveryMaster deliveryMaster,
			List<DeliveryDetail> deliveryDetails,
			String resolvedStatus);

}
