package com.tklaundry.api.sales.delivery.dto;

import java.time.LocalDateTime;
import java.util.List;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class DeliveryRequest {

	private String orderNo;
	private LocalDateTime orderDate;
	private String custCode;
	private String orderStatus;
	private String status;
	private String bankingYn;
	private List<DeliveryDetailRequest> details;

}
