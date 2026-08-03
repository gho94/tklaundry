package com.tklaundry.api.sales.expend.controller;

import java.time.LocalDate;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.tklaundry.api.sales.expend.dto.ExpendListResponse;
import com.tklaundry.api.sales.expend.dto.ExpendRequest;
import com.tklaundry.api.sales.expend.model.Expend;
import com.tklaundry.api.sales.expend.service.IExpendService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/expends")
@RequiredArgsConstructor
public class ExpendController {

	private final IExpendService expendService;

	@GetMapping
	public ResponseEntity<ExpendListResponse> listExpends(
			@RequestParam(value = "startDate", required = false) LocalDate startDate,
			@RequestParam(value = "endDate", required = false) LocalDate endDate) {
		return ResponseEntity.ok(expendService.listExpends(startDate, endDate));
	}

	@GetMapping("/{idx}")
	public ResponseEntity<Expend> getExpend(@PathVariable("idx") int idx) {
		return ResponseEntity.ok(expendService.getExpend(idx));
	}

	@PostMapping
	public ResponseEntity<Expend> registerExpend(@RequestBody ExpendRequest request) {
		Expend created = expendService.registerExpend(request);
		return ResponseEntity.status(HttpStatus.CREATED).body(created);
	}

	@PutMapping("/{idx}")
	public ResponseEntity<Void> updateExpend(
			@PathVariable("idx") int idx,
			@RequestBody ExpendRequest request) {
		expendService.updateExpend(idx, request);
		return ResponseEntity.noContent().build();
	}

}
