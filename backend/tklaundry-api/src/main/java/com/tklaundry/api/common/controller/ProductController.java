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

import com.tklaundry.api.common.model.ComProduct;
import com.tklaundry.api.common.service.IComProductService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {

	private final IComProductService comProductService;

	@GetMapping
	public ResponseEntity<List<ComProduct>> listProducts(
			@RequestParam String processCode,
			@RequestParam String groupCode) {
		return ResponseEntity.ok(comProductService.listProducts(processCode, groupCode));
	}

	@PostMapping
	public ResponseEntity<ComProduct> registerProduct(@RequestBody ComProduct request) {
		ComProduct created = comProductService.registerProduct(request);
		return ResponseEntity.status(HttpStatus.CREATED).body(created);
	}

	@PutMapping("/{productCode}")
	public ResponseEntity<Void> updateProduct(
			@PathVariable String productCode,
			@RequestBody ComProduct request) {
		comProductService.updateProduct(productCode, request);
		return ResponseEntity.noContent().build();
	}

	@DeleteMapping("/{productCode}")
	public ResponseEntity<Void> removeProduct(@PathVariable String productCode) {
		comProductService.removeProduct(productCode);
		return ResponseEntity.noContent().build();
	}

}
