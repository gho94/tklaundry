package com.tklaundry.api.common.controller;

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
	public CommonInfo login(@RequestBody ComMember request) {
		return comMemberService.login(request.getUserId(), request.getPassword());
	}

}
