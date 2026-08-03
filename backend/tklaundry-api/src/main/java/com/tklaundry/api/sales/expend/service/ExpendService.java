package com.tklaundry.api.sales.expend.service;

import java.time.LocalDate;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tklaundry.api.common.CommonInfo;
import com.tklaundry.api.sales.expend.dto.ExpendListResponse;
import com.tklaundry.api.sales.expend.dto.ExpendRequest;
import com.tklaundry.api.sales.expend.mapper.ExpendMapper;
import com.tklaundry.api.sales.expend.model.Expend;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ExpendService implements IExpendService {

	private final ExpendMapper expendMapper;
	private final CommonInfo commonInfo;

	@Override
	public ExpendListResponse listExpends(LocalDate startDate, LocalDate endDate) {
		List<Expend> items = expendMapper.selectExpendList(startDate, endDate.plusDays(1));

		int totalAmount = items.stream()
				.mapToInt(expend -> expend.getCost() != null ? expend.getCost() : 0)
				.sum();

		return new ExpendListResponse(items, items.size(), totalAmount);
	}

	@Override
	public Expend getExpend(int idx) {
		return expendMapper.selectExpendByIdx(idx);
	}

	@Override
	@Transactional
	public Expend registerExpend(ExpendRequest request) {
		Expend expend = Expend.builder()
				.expendDate(request.getExpendDate() != null ? request.getExpendDate() : LocalDate.now())
				.expendCode(request.getExpendCode() != null ? request.getExpendCode() : "")
				.cost(request.getCost() != null ? request.getCost() : 0)
				.remark(request.getRemark() != null ? request.getRemark() : "")
				.insertUserId(commonInfo.getUser().getUserId())
				.build();

		expendMapper.insertExpend(expend);

		return expend;
	}

	@Override
	@Transactional
	public void updateExpend(int idx, ExpendRequest request) {
		Expend expend = Expend.builder()
				.idx(idx)
				.expendDate(request.getExpendDate() != null ? request.getExpendDate() : LocalDate.now())
				.expendCode(request.getExpendCode() != null ? request.getExpendCode() : "")
				.cost(request.getCost() != null ? request.getCost() : 0)
				.remark(request.getRemark() != null ? request.getRemark() : "")
				.updateUserId(commonInfo.getUser().getUserId())
				.build();

		expendMapper.updateExpend(expend);
	}

}
