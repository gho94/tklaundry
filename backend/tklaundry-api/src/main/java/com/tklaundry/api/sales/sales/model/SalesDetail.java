package com.tklaundry.api.sales.sales.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SalesDetail {

	private String salesNo;
	private Integer salesSeq;
	private String productCode;
	private String processCode;
	private Integer price;
	private Integer qty;
	private Integer discount;
	private Integer cost;
	private String orderNo;
	private Integer orderSeq;
	private String deliveryNo;
	private Integer deliverySeq;
	private String remark;

}
