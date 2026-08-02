package com.tklaundry.api.common.constants;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum AutoNumberDoc {

	ORDER("접수", "O"),
	DELIVERY("출고", "D"),
	SALES("매출", "S");

	private final String docName;
	private final String prefix;

}
