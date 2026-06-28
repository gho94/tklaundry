package com.tklaundry.api.common.model;

import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonIgnore;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Getter
@Setter
@SuperBuilder(toBuilder = true)
@NoArgsConstructor
@AllArgsConstructor
public class BaseEntity {

	@JsonIgnore
	private String insertUserId;

	@JsonIgnore
	private LocalDateTime insertDate;

	@JsonIgnore
	private String updateUserId;

	@JsonIgnore
	private LocalDateTime updateDate;

}
