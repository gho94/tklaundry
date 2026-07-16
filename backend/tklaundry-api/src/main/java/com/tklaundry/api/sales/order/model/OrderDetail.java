package com.tklaundry.api.sales.order.model;

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
public class OrderDetail {

	private String orderNo;
	private Integer orderSeq;
	private String productCode;
	private String processCode;
	private Integer price;
	private Integer qty;
	private Integer discount;
	private Integer cost;
	private String completeYn;
	private String remark;

}
