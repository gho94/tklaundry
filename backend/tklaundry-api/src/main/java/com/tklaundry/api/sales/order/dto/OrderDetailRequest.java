package com.tklaundry.api.sales.order.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class OrderDetailRequest {

	private String productCode;
	private String processCode;
	private Integer price;
	private Integer qty;
	private Integer discount;
	private String remark;

}
