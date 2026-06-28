package com.tklaundry.api.common.service;

import com.tklaundry.api.common.CommonInfo;

public interface IComMemberService {

	CommonInfo login(String userId, String password);

}
