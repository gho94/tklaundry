package com.tklaundry.api.sales.sales.mapper;

import java.time.LocalDateTime;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tklaundry.api.sales.sales.model.SalesDetail;
import com.tklaundry.api.sales.sales.model.SalesMaster;

@Mapper
public interface SalesMapper {

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
