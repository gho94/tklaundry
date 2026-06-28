package com.tklaundry.api.common.service;

import java.util.List;

import com.tklaundry.api.common.CommonInfo;
import com.tklaundry.api.common.model.ComMember;

public interface IComMemberService {

	CommonInfo login(String userId, String password);

	void logout();

	List<ComMember> listMembers();

	boolean existsUserId(String userId);

	ComMember register(ComMember request);

	ComMember getMember(String userId);

	void updateMember(String userId, ComMember request);

	void removeMember(String userId);

}
