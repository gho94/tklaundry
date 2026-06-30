package com.tklaundry.api.common.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import com.tklaundry.api.common.CommonInfo;
import com.tklaundry.api.common.mapper.ComBaseDataMapper;
import com.tklaundry.api.common.model.ComBaseData;
import com.tklaundry.api.common.web.ApiErrorCode;
import com.tklaundry.api.common.web.ApiException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ComBaseDataService implements IComBaseDataService {

	private final ComBaseDataMapper comBaseDataMapper;
	private final CommonInfo commonInfo;

	@Override
	public List<ComBaseData> listCodes() {
		return comBaseDataMapper.selectComBaseDataList();
	}

	@Override
	public ComBaseData getCode(String codeId) {
		ComBaseData code = comBaseDataMapper.selectComBaseDataByCodeId(codeId);
		if (code == null) {
			throw new ApiException(ApiErrorCode.NOT_FOUND, "코드를 찾을 수 없습니다.");
		}

		return code;
	}

	@Override
	public ComBaseData registerCode(ComBaseData request) {
		String pCodeId = request.getPCodeId();
		String header = createHeader(pCodeId);
		String codeId = createLastCodeId(header);

		ComBaseData code = ComBaseData.builder()
				.codeId(codeId)
				.pCodeId(pCodeId)
				.codeName(request.getCodeName())
				.insertUserId(commonInfo.getUser().getUserId())
				.build();

		comBaseDataMapper.insertComBaseData(code);

		return code;
	}

	private String createHeader(String pCodeId) {
		if (!"ROOT".equals(pCodeId.toUpperCase())) {
			char letter = pCodeId.charAt(0);
			int grade = Character.digit(pCodeId.charAt(1), 10);
			return letter + String.valueOf(grade + 1);
		}

		String lastCodeId = comBaseDataMapper.selectLastCodeId();
		return "%c0".formatted(StringUtils.hasText(lastCodeId) ? lastCodeId.charAt(0) + 1 : 'A');
	}

	private String createLastCodeId(String header) {
		String lastCodeId = comBaseDataMapper.selectLastCodeIdByHeader(header);
		int nextSeq = StringUtils.hasText(lastCodeId) ? Integer.parseInt(lastCodeId.substring(2)) + 1 : 1;
		return header + "%04d".formatted(nextSeq);
	}

	@Override
	public void updateCode(String codeId, ComBaseData request) {
		ComBaseData code = ComBaseData.builder()
				.codeId(codeId)
				.codeName(request.getCodeName())
				.updateUserId(commonInfo.getUser().getUserId())
				.build();

		comBaseDataMapper.updateComBaseData(code);
	}

	@Override
	public void deleteCode(String codeId) {
		deleteCodeRecursive(codeId);
	}

	private void deleteCodeRecursive(String codeId) {
		for (ComBaseData child : comBaseDataMapper.selectComBaseDataListByPCodeId(codeId)) {
			deleteCodeRecursive(child.getCodeId());
		}
		comBaseDataMapper.deleteComBaseData(codeId);
	}

}
