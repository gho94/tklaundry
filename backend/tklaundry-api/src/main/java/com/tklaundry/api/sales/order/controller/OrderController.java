package com.tklaundry.api.sales.order.controller;

import java.time.LocalDate;
import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.tklaundry.api.sales.order.dto.OrderListResponse;
import com.tklaundry.api.sales.order.model.OrderDetail;
import com.tklaundry.api.sales.order.service.IOrderService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

	private final IOrderService orderService;

	@GetMapping
	public ResponseEntity<OrderListResponse> listOrders(
			@RequestParam(required = false) LocalDate startDate,
			@RequestParam(required = false) LocalDate endDate,
			@RequestParam(required = false) String custCode) {
		return ResponseEntity.ok(orderService.listOrders(startDate, endDate, custCode));
	}

	@GetMapping("/{orderNo}")
	public ResponseEntity<List<OrderDetail>> listOrderDetails(@PathVariable String orderNo) {
		return ResponseEntity.ok(orderService.listOrderDetails(orderNo));
	}

}
