package com.tklaundry.api.sales.sales.mapper;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tklaundry.api.sales.sales.dto.PendingPaymentItem;
import com.tklaundry.api.sales.sales.model.SalesDetail;
import com.tklaundry.api.sales.sales.model.SalesMaster;

@Mapper
public interface SalesMapper {

	List<SalesMaster> selectSalesMasterList(
			@Param("startDate") LocalDate startDate,
			@Param("endDate") LocalDate endDate,
			@Param("custCode") String custCode);

	List<SalesDetail> selectSalesDetailList(@Param("salesNo") String salesNo);

	List<PendingPaymentItem> selectPendingPaymentList(@Param("custCode") String custCode);

	void updateSalesMasterOnPayment(
			@Param("salesNo") String salesNo,
			@Param("bankingYn") String bankingYn,
			@Param("updateUserId") String updateUserId);

	void updateOrderDetailRemarkOnPayment(
			@Param("orderNo") String orderNo,
			@Param("orderSeq") int orderSeq,
			@Param("remark") String remark);

	String selectSalesNoByOrderNo(@Param("orderNo") String orderNo);

	LocalDateTime selectSalesDateBySalesNo(@Param("salesNo") String salesNo);

	void upsertSalesMaster(SalesMaster salesMaster);

	void upsertSalesDetail(SalesDetail salesDetail);

	void deleteSalesDetailsByOrderNoAndSeqGreaterThan(
			@Param("orderNo") String orderNo,
			@Param("maxSeq") int maxSeq);

	void deleteSalesDetailsBySalesNo(@Param("salesNo") String salesNo);

	void deleteSalesMaster(@Param("salesNo") String salesNo);

}
