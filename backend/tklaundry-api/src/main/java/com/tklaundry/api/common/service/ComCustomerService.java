package com.tklaundry.api.common.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import com.tklaundry.api.common.CommonInfo;
import com.tklaundry.api.common.mapper.ComCustomerMapper;
import com.tklaundry.api.common.model.ComCustomer;
import com.tklaundry.api.common.web.ApiErrorCode;
import com.tklaundry.api.common.web.ApiException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ComCustomerService implements IComCustomerService {

	private final ComCustomerMapper comCustomerMapper;
	private final CommonInfo commonInfo;

	@Override
	public List<ComCustomer> listCustomers(String aptCode) {
		return comCustomerMapper.selectComCustomerList(aptCode);
	}

	@Override
	public ComCustomer registerCustomer(ComCustomer request) {
		if (request.getAptCode() != null
				&& request.getBuildingCode() != null
				&& request.getFloorCode() != null
				&& request.getRoomCode() != null
				&& comCustomerMapper.countComCustomerByLocation(
						request.getAptCode(),
						request.getBuildingCode(),
						request.getFloorCode(),
						request.getRoomCode()) > 0) {
			throw new ApiException(ApiErrorCode.CONFLICT, "이미 등록된 정보입니다.");
		}

		String aptCode = request.getAptCode() != null ? request.getAptCode() : "";
		String buildingCode = request.getBuildingCode() != null ? request.getBuildingCode() : "";
		String floorCode = request.getFloorCode() != null ? request.getFloorCode() : "";
		String roomCode = request.getRoomCode() != null ? request.getRoomCode() : "";

		ComCustomer customer = ComCustomer.builder()
				.custCode(createLastCustCode())
				.custName(request.getCustName() != null ? request.getCustName() : "")
				.aptCode(aptCode)
				.buildingCode(buildingCode)
				.floorCode(floorCode)
				.roomCode(roomCode)
				.custPhone(request.getCustPhone() != null ? request.getCustPhone() : "")
				.insertUserId(commonInfo.getUser().getUserId())
				.build();

		comCustomerMapper.insertComCustomer(customer);

		return customer;
	}

	private String createLastCustCode() {
		String lastCustCode = comCustomerMapper.selectLastCustCode();
		int nextSeq = StringUtils.hasText(lastCustCode) ? Integer.parseInt(lastCustCode.substring(1)) + 1 : 1;
		return "C%04d".formatted(nextSeq);
	}

}
