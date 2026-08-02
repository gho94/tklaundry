package com.tklaundry.api.sales.sales.controller;

import java.time.LocalDate;
import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.tklaundry.api.sales.sales.dto.SalesListResponse;
import com.tklaundry.api.sales.sales.model.SalesDetail;
import com.tklaundry.api.sales.sales.service.ISalesService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/sales")
@RequiredArgsConstructor
public class SalesController {

	private final ISalesService salesService;

	@GetMapping
	public ResponseEntity<SalesListResponse> listSales(
			@RequestParam(value = "startDate", required = false) LocalDate startDate,
			@RequestParam(value = "endDate", required = false) LocalDate endDate,
			@RequestParam(value = "custCode", required = false) String custCode) {
		return ResponseEntity.ok(salesService.listSales(startDate, endDate, custCode));
	}

	@GetMapping("/{salesNo}/details")
	public ResponseEntity<List<SalesDetail>> listSalesDetails(
			@PathVariable("salesNo") String salesNo) {
		return ResponseEntity.ok(salesService.listSalesDetails(salesNo));
	}

}
