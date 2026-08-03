package com.tklaundry.api.sales.saleschart.service;

import java.time.LocalDate;
import java.util.List;

import org.springframework.stereotype.Service;

import com.tklaundry.api.sales.saleschart.ChartUnit;
import com.tklaundry.api.sales.saleschart.dto.SalesChartItem;
import com.tklaundry.api.sales.saleschart.dto.SalesChartResponse;
import com.tklaundry.api.sales.saleschart.mapper.SalesChartMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class SalesChartService implements ISalesChartService {

	private final SalesChartMapper salesChartMapper;

	@Override
	public SalesChartResponse getChart(LocalDate startDate, LocalDate endDate, ChartUnit unit) {
		LocalDate endExclusive = endDate.plusDays(1);

		List<SalesChartItem> items = switch (unit) {
			case DAY -> salesChartMapper.selectDayChart(startDate, endExclusive);
			case MONTH -> salesChartMapper.selectMonthChart(startDate, endExclusive);
			case YEAR -> salesChartMapper.selectYearChart(startDate, endExclusive);
		};

		int totalAmount = items.stream()
				.mapToInt(item -> item.getCost() != null ? item.getCost() : 0)
				.sum();

		return new SalesChartResponse(items, items.size(), totalAmount);
	}

}
