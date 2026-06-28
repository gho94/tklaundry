package com.tklaundry.api.common.model;

import com.fasterxml.jackson.annotation.JsonInclude;

import lombok.Getter;
import lombok.Setter;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Getter
@Setter
public class ComMember {

	private String userId;
	private String password;
	private String userName;
	private String useYn;

}
