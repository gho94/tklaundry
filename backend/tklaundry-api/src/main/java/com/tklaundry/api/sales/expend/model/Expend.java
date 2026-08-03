package com.tklaundry.api.sales.expend.model;

import java.time.LocalDate;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.tklaundry.api.common.model.BaseEntity;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Getter
@Setter
@SuperBuilder(toBuilder = true)
@NoArgsConstructor
@AllArgsConstructor
public class Expend extends BaseEntity {

	private Integer idx;
	private LocalDate expendDate;
	private String expendCode;
	private Integer cost;
	private String remark;

}
