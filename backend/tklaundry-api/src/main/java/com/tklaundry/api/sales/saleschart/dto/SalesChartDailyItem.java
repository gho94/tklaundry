package com.tklaundry.api.sales.saleschart.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class SalesChartDailyItem {

	private String salesDate;
	private String salesNo;
	private String salesType;
	private String custCode;
	private Integer qty;
	private Integer discount;
	private String expendCode;
	private Integer cost;
	private String status;
	private String bankingYn;

}
