package com.tklaundry.api.sales.saleschart.service;

import java.time.LocalDate;

import com.tklaundry.api.sales.saleschart.ChartUnit;
import com.tklaundry.api.sales.saleschart.dto.SalesChartDailyResponse;
import com.tklaundry.api.sales.saleschart.dto.SalesChartResponse;

public interface ISalesChartService {

	SalesChartResponse getChart(LocalDate startDate, LocalDate endDate, ChartUnit unit);

	SalesChartDailyResponse listDailyItems(LocalDate salesDate);

}
