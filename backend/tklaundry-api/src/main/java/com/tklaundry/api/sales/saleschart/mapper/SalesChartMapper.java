package com.tklaundry.api.sales.saleschart.mapper;

import java.time.LocalDate;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tklaundry.api.sales.saleschart.dto.SalesChartItem;

@Mapper
public interface SalesChartMapper {

	List<SalesChartItem> selectDayChart(
			@Param("startDate") LocalDate startDate,
			@Param("endDate") LocalDate endDate);

	List<SalesChartItem> selectMonthChart(
			@Param("startDate") LocalDate startDate,
			@Param("endDate") LocalDate endDate);

	List<SalesChartItem> selectYearChart(
			@Param("startDate") LocalDate startDate,
			@Param("endDate") LocalDate endDate);

}
