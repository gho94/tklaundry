package com.tklaundry.api.common.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tklaundry.api.common.model.ComCustomer;

@Mapper
public interface ComCustomerMapper {

	List<ComCustomer> selectComCustomerList(@Param("aptCode") String aptCode);

}
