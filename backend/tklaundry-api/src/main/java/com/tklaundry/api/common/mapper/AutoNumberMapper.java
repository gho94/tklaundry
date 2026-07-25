package com.tklaundry.api.common.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface AutoNumberMapper {

	int nextAutoNumberSeq(@Param("docName") String docName, @Param("docDate") String docDate);

}
