package com.tklaundry.api.sales.saleschart.controller;

import java.time.LocalDate;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.tklaundry.api.common.web.ApiErrorCode;
import com.tklaundry.api.common.web.ApiException;
import com.tklaundry.api.sales.saleschart.ChartUnit;
import com.tklaundry.api.sales.saleschart.dto.SalesChartDailyResponse;
import com.tklaundry.api.sales.saleschart.dto.SalesChartResponse;
import com.tklaundry.api.sales.saleschart.service.ISalesChartService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/sales/chart")
@RequiredArgsConstructor
public class SalesChartController {

	private final ISalesChartService salesChartService;

	@GetMapping
	public ResponseEntity<SalesChartResponse> getChart(
			@RequestParam(value = "startDate", required = false) LocalDate startDate,
			@RequestParam(value = "endDate", required = false) LocalDate endDate,
			@RequestParam(value = "unit", defaultValue = "day") String unitParam) {
		final ChartUnit unit;
		try {
			unit = ChartUnit.fromValue(unitParam);
		} catch (IllegalArgumentException ex) {
			throw new ApiException(ApiErrorCode.VALIDATION_ERROR, "집계 단위가 올바르지 않습니다.");
		}
		return ResponseEntity.ok(salesChartService.getChart(startDate, endDate, unit));
	}

	@GetMapping("/daily")
	public ResponseEntity<SalesChartDailyResponse> listDailyItems(
			@RequestParam("salesDate") LocalDate salesDate) {
		return ResponseEntity.ok(salesChartService.listDailyItems(salesDate));
	}

}
