package com.tklaundry.api.sales.delivery.mapper;

import java.time.LocalDate;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tklaundry.api.sales.order.model.OrderDetail;
import com.tklaundry.api.sales.order.model.OrderMaster;

@Mapper
public interface DeliveryMapper {

	List<OrderMaster> selectOrderMasterList(
			@Param("startDate") LocalDate startDate,
			@Param("endDate") LocalDate endDate,
			@Param("custCode") String custCode);

	List<OrderDetail> selectOrderDetailList(@Param("orderNo") String orderNo);

}
