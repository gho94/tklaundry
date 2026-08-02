package com.tklaundry.api.sales.expend.dto;

import java.util.List;

import com.tklaundry.api.sales.expend.model.Expend;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class ExpendListResponse {

	private List<Expend> items;
	private int count;
	private int totalAmount;

}
