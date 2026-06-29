package com.tklaundry.api.common.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tklaundry.api.common.model.ComBaseData;
import com.tklaundry.api.common.service.IComBaseDataService;

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

}
