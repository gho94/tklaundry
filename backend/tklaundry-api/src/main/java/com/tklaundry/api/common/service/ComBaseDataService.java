package com.tklaundry.api.common.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.tklaundry.api.common.mapper.ComBaseDataMapper;
import com.tklaundry.api.common.model.ComBaseData;
import com.tklaundry.api.common.web.ApiErrorCode;
import com.tklaundry.api.common.web.ApiException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ComBaseDataService implements IComBaseDataService {

	private final ComBaseDataMapper comBaseDataMapper;

	@Override
	public List<ComBaseData> listCodes() {
		return comBaseDataMapper.selectComBaseDataList();
	}

	@Override
	public ComBaseData getCode(String codeId) {
		ComBaseData code = comBaseDataMapper.selectComBaseDataByCodeId(codeId);
		if (code == null) {
			throw new ApiException(ApiErrorCode.NOT_FOUND, "코드를 찾을 수 없습니다.");
		}

		return code;
	}

}
