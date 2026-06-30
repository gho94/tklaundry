package com.tklaundry.api.common.service;

import java.util.List;

import com.tklaundry.api.common.model.ComCustomer;

public interface IComCustomerService {

	List<ComCustomer> listCustomers(String aptCode);

	ComCustomer registerCustomer(ComCustomer request);

	void updateCustomer(String custCode, ComCustomer request);

	void removeCustomer(String custCode);

}
