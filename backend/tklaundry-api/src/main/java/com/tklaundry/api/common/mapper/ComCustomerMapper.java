package com.tklaundry.api.common.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tklaundry.api.common.model.ComCustomer;

@Mapper
public interface ComCustomerMapper {

	List<ComCustomer> selectComCustomerList(@Param("aptCode") String aptCode);

	String selectLastCustCode();

	int countComCustomerByLocation(
			@Param("aptCode") String aptCode,
			@Param("buildingCode") String buildingCode,
			@Param("floorCode") String floorCode,
			@Param("roomCode") String roomCode);

	void insertComCustomer(ComCustomer customer);

	void updateComCustomer(ComCustomer customer);

	void deleteComCustomer(@Param("custCode") String custCode);

}
