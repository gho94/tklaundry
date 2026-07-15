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
	private final IComBaseDataService comBaseDataService;
	private final CommonInfo commonInfo;

	@Override
	public CommonInfo login(String userId, String password) {
		ComMember member = comMemberMapper.getTblComMember(userId, password);
		if (member == null) {
			throw new ApiException(ApiErrorCode.UNAUTHORIZED, "아이디 또는 비밀번호가 올바르지 않습니다.");
		}

		comMemberMapper.updateComMemberLoginDate(member.getUserId());
		commonInfo.bindLogin(member, comBaseDataService.listCodes());

		return commonInfo;
	}

	@Override
	public void logout() {
		commonInfo.clear();
	}

	@Override
	public List<ComMember> listMembers() {
		return comMemberMapper.selectComMemberList();
	}

	@Override
	public boolean existsUserId(String userId) {
		return comMemberMapper.countComMemberByUserId(userId) > 0;
	}

	@Override
	public ComMember register(ComMember request) {
		if (existsUserId(request.getUserId())) {
			throw new ApiException(ApiErrorCode.CONFLICT, "이미 사용중인 아이디입니다.");
		}

		String insertUserId = request.getUserId();
		ComMember loginUser = commonInfo.getUser();
		if (loginUser != null) {
			insertUserId = loginUser.getUserId();
		}

		ComMember member = ComMember.builder()
				.userId(request.getUserId())
				.password(request.getPassword())
				.userName(request.getUserName())
				.useYn(request.getUseYn())
				.insertUserId(insertUserId)
				.build();

		comMemberMapper.insertComMember(member);

		ComMember created = ComMember.builder()
				.userId(request.getUserId())
				.userName(request.getUserName())
				.useYn(request.getUseYn())
				.build();
		if (loginUser == null) {
			commonInfo.bindLogin(created, comBaseDataService.listCodes());
			comMemberMapper.updateComMemberLoginDate(created.getUserId());
		}

		return created;
	}

	@Override
	public void updateMember(String userId, ComMember request) {
		String password = request.getPassword();
		if (password != null && password.isBlank()) {
			password = null;
		}

		ComMember member = ComMember.builder()
				.userId(userId)
				.userName(request.getUserName())
				.useYn(request.getUseYn())
				.password(password)
				.updateUserId(commonInfo.getUser().getUserId())
				.build();

		comMemberMapper.updateComMember(member);
	}

	@Override
	public void removeMember(String userId) {
		ComMember loginUser = commonInfo.getUser();
		if (loginUser != null && userId.equals(loginUser.getUserId())) {
			throw new ApiException(ApiErrorCode.CONFLICT, "로그인 중인 계정은 삭제할 수 없습니다.");
		}

		comMemberMapper.deleteComMember(userId);
	}

}
