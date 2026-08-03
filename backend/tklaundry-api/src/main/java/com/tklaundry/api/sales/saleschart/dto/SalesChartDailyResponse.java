package com.tklaundry.api.sales.saleschart.dto;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class SalesChartDailyResponse {

	private List<SalesChartDailyItem> items;
	private int count;
	private int totalAmount;

}
