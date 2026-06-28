package com.tklaundry.api.common.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.tklaundry.api.common.CommonInfo;
import com.tklaundry.api.common.mapper.ComMemberMapper;
import com.tklaundry.api.common.model.ComMember;
import com.tklaundry.api.common.web.ApiErrorCode;
import com.tklaundry.api.common.web.ApiException;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class ComMemberService implements IComMemberService {

	private final ComMemberMapper comMemberMapper;
	private final CommonInfo commonInfo;

	@Override
	public CommonInfo login(String userId, String password) {
		if (userId == null || userId.isBlank() || password == null || password.isBlank()) {
			throw new ApiException(ApiErrorCode.VALIDATION_ERROR, "아이디와 비밀번호를 입력해 주세요.");
		}

		ComMember member = comMemberMapper.getTblComMember(userId.trim(), password);
		if (member == null) {
			throw new ApiException(ApiErrorCode.UNAUTHORIZED, "아이디 또는 비밀번호가 올바르지 않습니다.");
		}

		comMemberMapper.updateTblComMember(member.getUserId());
		commonInfo.bindLogin(member);

		return commonInfo;
	}

	@Override
	public List<ComMember> listMembers() {
		return comMemberMapper.selectComMemberList();
	}

}
