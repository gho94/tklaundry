package com.tklaundry.api.common.service;

import java.util.List;

import com.tklaundry.api.common.model.ComBaseData;

public interface IComBaseDataService {

	List<ComBaseData> listCodes();

	ComBaseData registerCode(ComBaseData request);

	void updateCode(String codeId, ComBaseData request);

	void deleteCode(String codeId);

}
