package com.tklaundry.api.common.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.tklaundry.api.common.mapper.ComBaseDataMapper;
import com.tklaundry.api.common.model.ComBaseData;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ComBaseDataService implements IComBaseDataService {

	private final ComBaseDataMapper comBaseDataMapper;

	@Override
	public List<ComBaseData> listCodes() {
		return comBaseDataMapper.selectComBaseDataList();
	}

}
