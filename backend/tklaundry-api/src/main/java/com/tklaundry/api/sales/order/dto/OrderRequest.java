package com.tklaundry.api.sales.order.dto;

import java.time.LocalDateTime;
import java.util.List;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class OrderRequest {

	private String custCode;
	private LocalDateTime orderDate;
	private String status;
	private String bankingYn;
	private List<OrderDetailRequest> details;

}
