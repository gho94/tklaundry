package com.tklaundry.api.sales.sales.model;

import java.time.LocalDateTime;

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
public class SalesMaster extends BaseEntity {

	private String salesNo;
	private LocalDateTime salesDate;
	private String custCode;
	private Integer qty;
	private Integer discount;
	private Integer cost;
	private String bankingYn;
	private String status;
	private String salesYn;

}
