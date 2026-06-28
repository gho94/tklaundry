package com.tklaundry.api.common;

import org.springframework.stereotype.Component;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.tklaundry.api.common.model.ComMember;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class CommonInfo {

	@JsonIgnore
	private ComMember tblComMember;

	public void bindLogin(ComMember member) {
		this.tblComMember = member;
		log.info("bindLogin userId={}", member.getUserId());
	}

	public ComMember getUser() {
		return tblComMember;
	}

	@JsonIgnore
	public ComMember getTblComMember() {
		return tblComMember;
	}

	public void clear() {
		this.tblComMember = null;
	}

}
