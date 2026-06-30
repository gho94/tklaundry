package com.tklaundry.api.common.web;

import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.dao.DataAccessException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import jakarta.validation.ConstraintViolationException;

@RestControllerAdvice
public class GlobalExceptionHandler {

	private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

	@ExceptionHandler(MethodArgumentNotValidException.class)
	public ResponseEntity<ApiErrorResponse> handleMethodArgumentNotValid(MethodArgumentNotValidException ex) {
		String traceId = resolveTraceId();
		String message = ex.getBindingResult().getFieldErrors().stream()
				.findFirst()
				.map(error -> error.getDefaultMessage() != null ? error.getDefaultMessage() : "입력값이 올바르지 않습니다.")
				.orElse("입력값이 올바르지 않습니다.");
		log.warn("Validation error message={} traceId={}", message, traceId);
		ApiErrorResponse body = new ApiErrorResponse(
				ApiErrorCode.VALIDATION_ERROR.name(),
				message,
				traceId);
		return ResponseEntity.status(ApiErrorCode.VALIDATION_ERROR.getHttpStatus()).body(body);
	}

	@ExceptionHandler(ConstraintViolationException.class)
	public ResponseEntity<ApiErrorResponse> handleConstraintViolation(ConstraintViolationException ex) {
		String traceId = resolveTraceId();
		String message = ex.getConstraintViolations().stream()
				.findFirst()
				.map(violation -> violation.getMessage())
				.orElse("입력값이 올바르지 않습니다.");
		log.warn("Validation error message={} traceId={}", message, traceId);
		ApiErrorResponse body = new ApiErrorResponse(
				ApiErrorCode.VALIDATION_ERROR.name(),
				message,
				traceId);
		return ResponseEntity.status(ApiErrorCode.VALIDATION_ERROR.getHttpStatus()).body(body);
	}

	@ExceptionHandler(ApiException.class)
	public ResponseEntity<ApiErrorResponse> handleApiException(ApiException ex) {
		String traceId = resolveTraceId();
		log.warn("API error code={} message={} traceId={}", ex.getErrorCode(), ex.getMessage(), traceId);
		ApiErrorResponse body = new ApiErrorResponse(
				ex.getErrorCode().name(),
				ex.getMessage(),
				traceId);
		return ResponseEntity.status(ex.getErrorCode().getHttpStatus()).body(body);
	}

	@ExceptionHandler(DataAccessException.class)
	public ResponseEntity<ApiErrorResponse> handleDataAccessException(DataAccessException ex) {
		String traceId = resolveTraceId();
		log.error("DB error traceId={}", traceId, ex);
		ApiErrorResponse body = new ApiErrorResponse(
				ApiErrorCode.DB_ERROR.name(),
				"데이터베이스 오류가 발생했습니다.",
				traceId);
		return ResponseEntity.status(ApiErrorCode.DB_ERROR.getHttpStatus()).body(body);
	}

	@ExceptionHandler(Exception.class)
	public ResponseEntity<ApiErrorResponse> handleException(Exception ex) {
		String traceId = resolveTraceId();
		log.error("Internal error traceId={}", traceId, ex);
		ApiErrorResponse body = new ApiErrorResponse(
				ApiErrorCode.INTERNAL_ERROR.name(),
				"서버 오류가 발생했습니다.",
				traceId);
		return ResponseEntity.status(ApiErrorCode.INTERNAL_ERROR.getHttpStatus()).body(body);
	}

	private String resolveTraceId() {
		String traceId = MDC.get("traceId");
		if (traceId == null || traceId.isBlank()) {
			traceId = UUID.randomUUID().toString();
		}
		return traceId;
	}

}
