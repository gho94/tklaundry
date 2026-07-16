package com.tklaundry.api.common.service;

import com.tklaundry.api.common.AutoNumberDoc;

public interface IAutoNumberService {

	String nextDocumentNo(AutoNumberDoc doc);

}
