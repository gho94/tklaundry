package com.tklaundry.api.common.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tklaundry.api.common.model.ComBaseData;

@Mapper
public interface ComBaseDataMapper {

	List<ComBaseData> selectComBaseDataList();

	ComBaseData selectComBaseDataByCodeId(@Param("codeId") String codeId);

}
