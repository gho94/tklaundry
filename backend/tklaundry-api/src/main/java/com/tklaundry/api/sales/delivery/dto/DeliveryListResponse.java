package com.tklaundry.api.sales.delivery.dto;

import java.util.List;

import com.tklaundry.api.sales.delivery.model.DeliveryMaster;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class DeliveryListResponse {

	private List<DeliveryMaster> items;
	private int count;
	private int totalAmount;

}
