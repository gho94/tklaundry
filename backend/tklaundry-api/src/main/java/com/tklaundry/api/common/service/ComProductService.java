package com.tklaundry.api.common.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.tklaundry.api.common.mapper.ComProductMapper;
import com.tklaundry.api.common.model.ComProduct;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ComProductService implements IComProductService {

	private final ComProductMapper comProductMapper;

	@Override
	public List<ComProduct> listProducts(String processCode, String groupCode) {
		return comProductMapper.selectComProductList(processCode, groupCode);
	}

}
