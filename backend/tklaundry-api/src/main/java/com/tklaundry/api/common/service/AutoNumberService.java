package com.tklaundry.api.common.service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import org.springframework.stereotype.Service;

import com.tklaundry.api.common.constants.AutoNumberDoc;
import com.tklaundry.api.common.mapper.AutoNumberMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AutoNumberService implements IAutoNumberService {

	private static final DateTimeFormatter DOC_DATE_FORMAT = DateTimeFormatter.ofPattern("yyMMdd");

	private final AutoNumberMapper autoNumberMapper;

	@Override
	public String nextDocumentNo(AutoNumberDoc doc) {
		String docDate = LocalDate.now().format(DOC_DATE_FORMAT);
		int seq = autoNumberMapper.nextAutoNumberSeq(doc.getDocName(), docDate);
		return doc.getPrefix() + docDate + "-" + "%03d".formatted(seq);
	}

}
