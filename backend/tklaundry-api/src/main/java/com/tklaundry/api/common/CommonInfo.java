package com.tklaundry.api.common;

import java.util.Collections;
import java.util.List;

import org.springframework.stereotype.Component;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.tklaundry.api.common.model.ComBaseData;
import com.tklaundry.api.common.model.ComMember;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class CommonInfo {

	@JsonIgnore
	private ComMember tblComMember;

	private List<ComBaseData> codes = Collections.emptyList();

	public void bindLogin(ComMember member, List<ComBaseData> codes) {
		this.tblComMember = member;
		this.codes = codes;
		log.info("bindLogin userId={}", member.getUserId());
	}

	public ComMember getUser() {
		return tblComMember;
	}

	public List<ComBaseData> getCodes() {
		return codes;
	}

	@JsonIgnore
	public ComMember getTblComMember() {
		return tblComMember;
	}

	public void clear() {
		this.tblComMember = null;
		this.codes = Collections.emptyList();
	}

}
