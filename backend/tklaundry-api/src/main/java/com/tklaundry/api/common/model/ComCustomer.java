package com.tklaundry.api.common.model;

import com.fasterxml.jackson.annotation.JsonInclude;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Getter
@Setter
@SuperBuilder(toBuilder = true)
@NoArgsConstructor
@AllArgsConstructor
public class ComCustomer extends BaseEntity {

	private String custCode;
	private String custName;
	private String aptCode;
	private String buildingCode;
	private String floorCode;
	private String roomCode;
	private String custPhone;

}
