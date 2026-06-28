package com.tklaundry.api.common.service;

import java.util.List;

import com.tklaundry.api.common.CommonInfo;
import com.tklaundry.api.common.model.ComMember;

public interface IComMemberService {

	CommonInfo login(String userId, String password);

	List<ComMember> listMembers();

}
