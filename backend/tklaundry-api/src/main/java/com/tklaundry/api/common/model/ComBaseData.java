package com.tklaundry.api.common.model;

import com.fasterxml.jackson.annotation.JsonInclude;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Getter
@Setter
@SuperBuilder(toBuilder = true)
@NoArgsConstructor
@AllArgsConstructor
public class ComBaseData extends BaseEntity {

	private String codeId;

	@NotBlank(message = "상위 코드를 지정해 주세요.")
	private String pCodeId;

	@NotBlank(message = "코드명을 입력해 주세요.")
	private String codeName;

}
