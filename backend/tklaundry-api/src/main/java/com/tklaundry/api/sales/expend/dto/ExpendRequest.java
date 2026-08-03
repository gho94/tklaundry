package com.tklaundry.api.sales.expend.dto;

import java.time.LocalDate;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ExpendRequest {

	private LocalDate expendDate;
	private String expendCode;
	private Integer cost;
	private String remark;

}
