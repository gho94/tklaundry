package com.tklaundry.api.common.service;

import java.util.List;

import com.tklaundry.api.common.model.ComCustomer;

public interface IComCustomerService {

	List<ComCustomer> listCustomers(String aptCode);

}
