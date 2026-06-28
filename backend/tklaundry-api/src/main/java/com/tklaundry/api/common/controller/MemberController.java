package com.tklaundry.api.common.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tklaundry.api.common.model.ComMember;
import com.tklaundry.api.common.service.IComMemberService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/members")
@RequiredArgsConstructor
public class MemberController {

	private final IComMemberService comMemberService;

	@GetMapping
	public ResponseEntity<List<ComMember>> listMembers() {
		return ResponseEntity.ok(comMemberService.listMembers());
	}

}
