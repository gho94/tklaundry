package com.tklaundry.api.common.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tklaundry.api.common.model.ComProduct;

@Mapper
public interface ComProductMapper {

	List<ComProduct> selectComProductList(
			@Param("processCode") String processCode,
			@Param("groupCode") String groupCode);

}
