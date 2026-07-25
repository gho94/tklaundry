package com.tklaundry.api.sales.order.controller;

import java.time.LocalDate;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.tklaundry.api.sales.order.dto.OrderListResponse;
import com.tklaundry.api.sales.order.dto.OrderRequest;
import com.tklaundry.api.sales.order.model.OrderDetail;
import com.tklaundry.api.sales.order.model.OrderMaster;
import com.tklaundry.api.sales.order.service.IOrderService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

	private final IOrderService orderService;

	@GetMapping
	public ResponseEntity<OrderListResponse> listOrders(
			@RequestParam(value = "startDate", required = false) LocalDate startDate,
			@RequestParam(value = "endDate", required = false) LocalDate endDate,
			@RequestParam(value = "custCode", required = false) String custCode) {
		return ResponseEntity.ok(orderService.listOrders(startDate, endDate, custCode));
	}

	@GetMapping("/{orderNo}")
	public ResponseEntity<List<OrderDetail>> listOrderDetails(@PathVariable("orderNo") String orderNo) {
		return ResponseEntity.ok(orderService.listOrderDetails(orderNo));
	}

	@PostMapping
	public ResponseEntity<OrderMaster> registerOrder(@RequestBody OrderRequest request) {
		OrderMaster created = orderService.registerOrder(request);
		return ResponseEntity.status(HttpStatus.CREATED).body(created);
	}

	@PutMapping("/{orderNo}")
	public ResponseEntity<Void> updateOrder(
			@PathVariable("orderNo") String orderNo,
			@RequestBody OrderRequest request) {
		orderService.updateOrder(orderNo, request);
		return ResponseEntity.noContent().build();
	}

	@DeleteMapping("/{orderNo}")
	public ResponseEntity<Void> removeOrder(@PathVariable("orderNo") String orderNo) {
		orderService.removeOrder(orderNo);
		return ResponseEntity.noContent().build();
	}

}
