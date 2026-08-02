package com.tklaundry.api.sales.expend.mapper;

import java.time.LocalDate;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tklaundry.api.sales.expend.model.Expend;

@Mapper
public interface ExpendMapper {

	List<Expend> selectExpendList(
			@Param("startDate") LocalDate startDate,
			@Param("endDate") LocalDate endDate);

	void insertExpend(Expend expend);

	void updateExpend(Expend expend);

}
