package com.tklaundry.api.sales.delivery.mapper;

import java.time.LocalDate;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tklaundry.api.sales.delivery.model.DeliveryDetail;
import com.tklaundry.api.sales.delivery.model.DeliveryMaster;
import com.tklaundry.api.sales.order.model.OrderDetail;
import com.tklaundry.api.sales.order.model.OrderMaster;

@Mapper
public interface DeliveryMapper {

	List<OrderMaster> selectOrderMasterList(
			@Param("startDate") LocalDate startDate,
			@Param("endDate") LocalDate endDate,
			@Param("custCode") String custCode);

	List<OrderDetail> selectOrderDetailList(@Param("orderNo") String orderNo);

	List<OrderDetail> selectAllOrderDetailsByOrderNo(@Param("orderNo") String orderNo);

	void insertDeliveryMaster(DeliveryMaster deliveryMaster);

	void insertDeliveryDetails(@Param("deliveryDetails") List<DeliveryDetail> deliveryDetails);

	void updateOrderDetailOnDelivery(
			@Param("orderNo") String orderNo,
			@Param("orderSeq") Integer orderSeq,
			@Param("discount") Integer discount,
			@Param("cost") Integer cost);

	void updateOrderMasterDiscountCost(
			@Param("orderNo") String orderNo,
			@Param("discount") Integer discount,
			@Param("cost") Integer cost);

	void updateOrderMasterOnCompleteDelivery(
			@Param("orderNo") String orderNo,
			@Param("status") String status,
			@Param("updateUserId") String updateUserId);

}
