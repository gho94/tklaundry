package com.tklaundry.api.sales.saleschart;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;

public enum ChartUnit {

	DAY("day"),
	MONTH("month"),
	YEAR("year");

	private final String value;

	ChartUnit(String value) {
		this.value = value;
	}

	@JsonValue
	public String getValue() {
		return value;
	}

	@JsonCreator
	public static ChartUnit fromValue(String value) {
		if (value == null || value.isBlank()) {
			return DAY;
		}
		for (ChartUnit unit : values()) {
			if (unit.value.equalsIgnoreCase(value.trim())) {
				return unit;
			}
		}
		throw new IllegalArgumentException("Unknown chart unit: " + value);
	}

}
