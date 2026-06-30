package com.tklaundry.api.common.service;

import java.util.List;

import com.tklaundry.api.common.model.ComBaseData;

public interface IComBaseDataService {

	List<ComBaseData> listCodes();

	ComBaseData getCode(String codeId);

	ComBaseData registerCode(ComBaseData request);

}
