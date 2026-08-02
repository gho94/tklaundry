package com.tklaundry.api.sales.expend.service;

import java.time.LocalDate;

import com.tklaundry.api.sales.expend.dto.ExpendListResponse;
import com.tklaundry.api.sales.expend.dto.ExpendRequest;
import com.tklaundry.api.sales.expend.model.Expend;

public interface IExpendService {

	ExpendListResponse listExpends(LocalDate startDate, LocalDate endDate);

	Expend registerExpend(ExpendRequest request);

	void updateExpend(int idx, ExpendRequest request);

}
