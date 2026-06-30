package com.tklaundry.api.common.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.tklaundry.api.common.mapper.ComCustomerMapper;
import com.tklaundry.api.common.model.ComCustomer;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ComCustomerService implements IComCustomerService {

	private final ComCustomerMapper comCustomerMapper;

	@Override
	public List<ComCustomer> listCustomers(String aptCode) {
		return comCustomerMapper.selectComCustomerList(aptCode);
	}

}
