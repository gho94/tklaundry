package com.tklaundry.api.common.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
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

	@GetMapping("/exists")
	public ResponseEntity<Boolean> existsUserId(@RequestParam String userId) {
		return ResponseEntity.ok(comMemberService.existsUserId(userId));
	}

	@GetMapping("/{userId}")
	public ResponseEntity<ComMember> getMember(@PathVariable String userId) {
		return ResponseEntity.ok(comMemberService.getMember(userId));
	}

	@PutMapping("/{userId}")
	public ResponseEntity<Void> updateMember(
			@PathVariable String userId,
			@RequestBody ComMember request) {
		comMemberService.updateMember(userId, request);
		return ResponseEntity.noContent().build();
	}

	@DeleteMapping("/{userId}")
	public ResponseEntity<Void> removeMember(@PathVariable String userId) {
		comMemberService.removeMember(userId);
		return ResponseEntity.noContent().build();
	}

}
