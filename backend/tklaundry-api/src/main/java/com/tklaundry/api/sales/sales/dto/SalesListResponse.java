package com.tklaundry.api.sales.sales.dto;

import java.util.List;

import com.tklaundry.api.sales.sales.model.SalesMaster;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class SalesListResponse {

	private List<SalesMaster> items;
	private int count;
	private int totalAmount;

}
