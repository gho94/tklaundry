package com.tklaundry.api.sales.delivery.controller;

import java.time.LocalDate;
import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.tklaundry.api.sales.delivery.service.IDeliveryService;
import com.tklaundry.api.sales.order.dto.OrderListResponse;
import com.tklaundry.api.sales.order.model.OrderDetail;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/deliveries")
@RequiredArgsConstructor
public class DeliveryController {

	private final IDeliveryService deliveryService;

	@GetMapping("/orders")
	public ResponseEntity<OrderListResponse> listOrders(
			@RequestParam(value = "startDate", required = false) LocalDate startDate,
			@RequestParam(value = "endDate", required = false) LocalDate endDate,
			@RequestParam(value = "custCode", required = false) String custCode) {
		return ResponseEntity.ok(deliveryService.listOrders(startDate, endDate, custCode));
	}

	@GetMapping("/orders/{orderNo}/details")
	public ResponseEntity<List<OrderDetail>> listOrderDetails(
			@PathVariable("orderNo") String orderNo) {
		return ResponseEntity.ok(deliveryService.listOrderDetails(orderNo));
	}

}
