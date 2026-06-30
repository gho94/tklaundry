package com.tklaundry.api.common.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tklaundry.api.common.model.ComBaseData;
import com.tklaundry.api.common.service.IComBaseDataService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/codes")
@RequiredArgsConstructor
public class CodeController {

	private final IComBaseDataService comBaseDataService;

	@GetMapping
	public ResponseEntity<List<ComBaseData>> listCodes() {
		return ResponseEntity.ok(comBaseDataService.listCodes());
	}

	@GetMapping("/{codeId}")
	public ResponseEntity<ComBaseData> getCode(@PathVariable String codeId) {
		return ResponseEntity.ok(comBaseDataService.getCode(codeId));
	}

	@PostMapping
	public ResponseEntity<ComBaseData> registerCode(@Valid @RequestBody ComBaseData request) {
		ComBaseData created = comBaseDataService.registerCode(request);
		return ResponseEntity.status(HttpStatus.CREATED).body(created);
	}

}
