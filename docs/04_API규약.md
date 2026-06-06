# API 규약

---

## 공통 규칙

| 항목 | 값 |
|------|-----|
| 기본 경로 | `/api` |
| 형식 | JSON (`application/json; charset=utf-8`) |
| 추적 ID | `X-Request-Id` (없으면 서버 생성, 응답에도 포함) |

### 오류 응답

```json
{
  "code": "NOT_FOUND",
  "message": "화면에 보여줄 메시지",
  "traceId": "a1b2c3d4-...",
  "details": {}
}
```

| code | 의미 |
|------|------|
| `VALIDATION_ERROR` | 입력값 오류 |
| `UNAUTHORIZED` | 로그인 실패 |
| `NOT_FOUND` | 데이터 없음 |
| `CONFLICT` | 상태 충돌 |
| `DB_ERROR` | DB 오류 |
| `INTERNAL_ERROR` | 서버 오류 |

---

## 1단계 — 기초 마스터

### 회원

| Method | 경로 | 설명 |
|--------|------|------|
| POST | `/api/auth/login` | 로그인 |
| POST | `/api/auth/register` | 회원가입 |
| GET | `/api/members` | 회원 목록 |
| GET | `/api/members/{userId}` | 회원 상세 |
| PUT | `/api/members/{userId}` | 회원 수정 |
| GET | `/api/members/check-id?userId=` | 아이디 중복 확인 |

**로그인**

```json
// 요청
{ "userId": "admin", "password": "..." }

// 성공 200
{
  "user": { "userId": "admin", "userName": "관리자" },
  "codes": [
    { "codeId": "B20001", "pCodeId": "B10001", "codeName": "일반" }
  ]
}
```

- `codes`: flat 배열. 앱에서 `Map<codeId, …>` + `Map<pCodeId, List<…>>` 변환

### 공통코드

| Method | 경로 | 설명 |
|--------|------|------|
| GET | `/api/codes` | 전체 flat |
| GET | `/api/codes/{codeId}` | 단건 |
| POST | `/api/codes` | 등록 |
| PUT | `/api/codes/{codeId}` | 수정 |
| DELETE | `/api/codes/{codeId}` | 삭제 |

### 고객

| Method | 경로 | 설명 |
|--------|------|------|
| GET | `/api/customers?q=` | 목록·검색 |
| GET | `/api/customers/{custCode}` | 상세 |
| POST | `/api/customers` | 등록 |
| PUT | `/api/customers/{custCode}` | 수정 |

### 제품

| Method | 경로 | 설명 |
|--------|------|------|
| GET | `/api/products` | 목록·검색 |
| GET | `/api/products/{productCode}` | 상세 |
| POST | `/api/products` | 등록 |
| PUT | `/api/products/{productCode}` | 수정 |

---

## 2단계 — 접수 · 출고 · 매출

### 접수

| Method | 경로 | 설명 |
|--------|------|------|
| GET | `/api/orders` | 목록 (`from`, `to`, `status`, `q`) |
| GET | `/api/orders/{orderNo}` | 상세 |
| POST | `/api/orders` | 등록 |
| PUT | `/api/orders/{orderNo}` | 수정 |
| POST | `/api/orders/{orderNo}/status` | 상태 변경 |

```json
{ "items": [...], "summary": { "count": 10, "totalAmount": 120000 } }
```

### 출고

| Method | 경로 | 설명 |
|--------|------|------|
| GET | `/api/deliveries` | 목록 |
| GET | `/api/deliveries/{deliveryNo}` | 상세 |
| POST | `/api/deliveries` | 출고 처리 |

### 매출

| Method | 경로 | 설명 |
|--------|------|------|
| GET | `/api/sales` | 목록 |
| GET | `/api/sales/{salesNo}` | 상세 |
| POST | `/api/sales` | 수납·매출 |

---

## 호환성

- 필드 추가 OK, 삭제·타입 변경 금지
