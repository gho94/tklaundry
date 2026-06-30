package com.tklaundry.api.common.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import com.tklaundry.api.common.CommonInfo;
import com.tklaundry.api.common.mapper.ComProductMapper;
import com.tklaundry.api.common.model.ComProduct;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ComProductService implements IComProductService {

	private final ComProductMapper comProductMapper;
	private final CommonInfo commonInfo;

	@Override
	public List<ComProduct> listProducts(String processCode, String groupCode) {
		return comProductMapper.selectComProductList(processCode, groupCode);
	}

	@Override
	public ComProduct registerProduct(ComProduct request) {
		ComProduct product = ComProduct.builder()
				.productCode(createLastProductCode())
				.processCode(request.getProcessCode() != null ? request.getProcessCode() : "")
				.groupCode(request.getGroupCode() != null ? request.getGroupCode() : "")
				.productName(request.getProductName() != null ? request.getProductName() : "")
				.price(request.getPrice() != null ? request.getPrice() : 0)
				.insertUserId(commonInfo.getUser().getUserId())
				.build();

		comProductMapper.insertComProduct(product);

		return product;
	}

	@Override
	public void updateProduct(String productCode, ComProduct request) {
		ComProduct product = ComProduct.builder()
				.productCode(productCode)
				.productName(request.getProductName() != null ? request.getProductName() : "")
				.price(request.getPrice() != null ? request.getPrice() : 0)
				.updateUserId(commonInfo.getUser().getUserId())
				.build();

		comProductMapper.updateComProduct(product);
	}

	@Override
	public void removeProduct(String productCode) {
		comProductMapper.deleteComProduct(productCode);
	}

	private String createLastProductCode() {
		String lastProductCode = comProductMapper.selectLastProductCode();
		int nextSeq = StringUtils.hasText(lastProductCode) ? Integer.parseInt(lastProductCode.substring(1)) + 1 : 1;
		return "P%04d".formatted(nextSeq);
	}

}
