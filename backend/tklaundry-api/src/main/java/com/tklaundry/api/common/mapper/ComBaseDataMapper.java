package com.tklaundry.api.common.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tklaundry.api.common.model.ComBaseData;

@Mapper
public interface ComBaseDataMapper {

	List<ComBaseData> selectComBaseDataList();

	List<ComBaseData> selectComBaseDataListByPCodeId(@Param("pCodeId") String pCodeId);

	String selectLastCodeId();

	String selectLastCodeIdByHeader(@Param("header") String header);

	void insertComBaseData(ComBaseData code);

	void updateComBaseData(ComBaseData code);

	void deleteComBaseData(@Param("codeId") String codeId);

}
