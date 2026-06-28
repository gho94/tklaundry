package com.tklaundry.api.common.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tklaundry.api.common.CommonInfo;
import com.tklaundry.api.common.model.ComMember;
import com.tklaundry.api.common.service.IComMemberService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

	private final IComMemberService comMemberService;

	@PostMapping("/login")
	public ResponseEntity<CommonInfo> login(@RequestBody ComMember request) {
		CommonInfo result = comMemberService.login(request.getUserId(), request.getPassword());
		return ResponseEntity.ok(result);
	}

	@PostMapping("/register")
	public ResponseEntity<ComMember> register(@RequestBody ComMember request) {
		ComMember created = comMemberService.register(request);
		return ResponseEntity.status(HttpStatus.CREATED).body(created);
	}

	@PostMapping("/logout")
	public ResponseEntity<Void> logout() {
		comMemberService.logout();
		return ResponseEntity.noContent().build();
	}

}
