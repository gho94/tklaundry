package com.tklaundry.api.sales.sales.dto;

import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonInclude;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PendingPaymentItem {

	private String salesNo;
	private LocalDateTime deliveryDate;
	private String custCode;
	private Integer qty;
	private Integer discount;
	private Integer cost;
	private String bankingYn;
	private String status;

}
