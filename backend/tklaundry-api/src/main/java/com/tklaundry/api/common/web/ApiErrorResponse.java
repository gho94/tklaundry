package com.tklaundry.api.common.web;

import java.util.Collections;
import java.util.Map;

import lombok.Getter;

@Getter
public class ApiErrorResponse {

	private final String code;
	private final String message;
	private final String traceId;
	private final Map<String, Object> details;

	public ApiErrorResponse(String code, String message, String traceId) {
		this.code = code;
		this.message = message;
		this.traceId = traceId;
		this.details = Collections.emptyMap();
	}

}
