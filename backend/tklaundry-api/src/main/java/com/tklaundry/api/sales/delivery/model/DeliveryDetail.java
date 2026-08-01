package com.tklaundry.api.sales.delivery.model;

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
public class DeliveryDetail {

	private String deliveryNo;
	private Integer deliverySeq;
	private String productCode;
	private String processCode;
	private Integer price;
	private Integer qty;
	private Integer discount;
	private Integer cost;
	private String orderNo;
	private Integer orderSeq;
	private String remark;

}
