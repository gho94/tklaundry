package com.tklaundry.api.common.controller;

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

	@PostMapping
	public ResponseEntity<ComCustomer> registerCustomer(@RequestBody ComCustomer request) {
		ComCustomer created = comCustomerService.registerCustomer(request);
		return ResponseEntity.status(HttpStatus.CREATED).body(created);
	}

	@PutMapping("/{custCode}")
	public ResponseEntity<Void> updateCustomer(
			@PathVariable String custCode,
			@RequestBody ComCustomer request) {
		comCustomerService.updateCustomer(custCode, request);
		return ResponseEntity.noContent().build();
	}

	@DeleteMapping("/{custCode}")
	public ResponseEntity<Void> removeCustomer(@PathVariable String custCode) {
		comCustomerService.removeCustomer(custCode);
		return ResponseEntity.noContent().build();
	}

}
