package com.tklaundry.api.sales.delivery.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class DeliveryDetailRequest {

	private Integer orderSeq;
	private String productCode;
	private String processCode;
	private Integer price;
	private Integer qty;
	private Integer discount;
	private Integer cost;
	private String remark;

}
