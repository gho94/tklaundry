package com.tklaundry.api.common.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tklaundry.api.common.model.ComMember;

@Mapper
public interface ComMemberMapper {

	ComMember getTblComMember(@Param("userId") String userId, @Param("password") String password);

	void updateTblComMember(@Param("userId") String userId);

	List<ComMember> selectComMemberList();

}
