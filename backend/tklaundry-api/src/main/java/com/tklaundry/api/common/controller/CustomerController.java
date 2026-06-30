package com.tklaundry.api.common.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.tklaundry.api.common.model.ComCustomer;
import com.tklaundry.api.common.service.IComCustomerService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/customers")
@RequiredArgsConstructor
public class CustomerController {

	private final IComCustomerService comCustomerService;

	@GetMapping
	public ResponseEntity<List<ComCustomer>> listCustomers(
			@RequestParam(required = false) String aptCode) {
		return ResponseEntity.ok(comCustomerService.listCustomers(aptCode));
	}

}
