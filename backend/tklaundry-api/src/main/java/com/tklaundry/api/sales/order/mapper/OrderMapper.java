package com.tklaundry.api.sales.order.mapper;

import java.time.LocalDate;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tklaundry.api.sales.order.model.OrderDetail;
import com.tklaundry.api.sales.order.model.OrderMaster;

@Mapper
public interface OrderMapper {

	List<OrderMaster> selectOrderMasterList(
			@Param("startDate") LocalDate startDate,
			@Param("endDate") LocalDate endDate,
			@Param("custCode") String custCode);

	List<OrderDetail> selectOrderDetailList(@Param("orderNo") String orderNo);

	void insertOrderMaster(OrderMaster orderMaster);

	void updateOrderMaster(OrderMaster orderMaster);

	void insertOrderDetails(@Param("orderDetails") List<OrderDetail> orderDetails);

	void deleteOrderDetails(@Param("orderNo") String orderNo);

	int countCompletedOrderDetail(@Param("orderNo") String orderNo);

}
