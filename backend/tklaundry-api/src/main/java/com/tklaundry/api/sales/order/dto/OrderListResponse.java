package com.tklaundry.api.sales.order.dto;

import java.util.List;

import com.tklaundry.api.sales.order.model.OrderMaster;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class OrderListResponse {

	private List<OrderMaster> items;
	private int count;
	private int totalAmount;

}
