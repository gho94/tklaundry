package com.tklaundry.api.common.service;

import java.util.List;

import com.tklaundry.api.common.model.ComProduct;

public interface IComProductService {

	List<ComProduct> listProducts(String processCode, String groupCode);

}
