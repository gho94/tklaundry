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
| DELETE | `/api/members/{userId}` | 회원 삭제 |
| GET | `/api/members/exists?userId=` | 아이디 중복 확인 |

**로그인**

```json
// 요청
{ "userId": "admin", "password": "..." }

// 성공 200
{
  "user": { "userId": "admin", "userName": "관리자" },
  "codes": [
    { "codeId": "A00001", "pCodeId": "Root", "codeName": "고객 관리" }
  ]
}
```

- login 응답 본문 = 서버 `CommonInfo` JSON (`user` + `codes`)
- `codes`: flat 배열 → 앱 `codeProvider` 적재 · `Map<codeId, …>` + `Map<pCodeId, List<…>>` 변환

**회원가입** `POST /api/auth/register`

```json
// 요청
{ "userId": "user01", "password": "...", "userName": "홍길동", "useYn": "Y" }

// 성공 201
{ "userId": "user01", "userName": "홍길동", "useYn": "Y" }

// 중복 아이디 409
{ "code": "CONFLICT", "message": "이미 사용중인 아이디입니다.", "traceId": "...", "details": {} }
```

- `password`는 응답에 **포함하지 않음**
- **비로그인** 가입: 서버 `bindLogin(member, codes)` + `LogInDate` 갱신 → 앱에서 즉시 로그인
- **로그인 중** 관리자 등록: member만 반환, 기존 관리자 세션 유지

**회원 목록** `GET /api/members`

```json
[
  { "userId": "admin", "userName": "관리자", "useYn": "Y" }
]
```

**회원 상세** `GET /api/members/{userId}` · **수정** `PUT /api/members/{userId}`

```json
// 상세 성공 (password 미포함)
{ "userId": "admin", "userName": "관리자", "useYn": "Y" }

// 수정 요청 (password 생략 시 기존 비밀번호 유지)
{ "userName": "관리자", "useYn": "Y", "password": "새비번" }

// 수정 성공 204 (body 없음)
```

**회원 삭제** `DELETE /api/members/{userId}`

```json
// 성공 204 (body 없음)

// 본인 삭제 시도 409
{ "code": "CONFLICT", "message": "로그인 중인 계정은 삭제할 수 없습니다.", "traceId": "...", "details": {} }
```

**아이디 중복 확인** `GET /api/members/exists?userId=`

```json
true
```

`true` = 이미 존재, `false` = 사용 가능

### 공통코드

| Method | 경로 | 설명 |
|--------|------|------|
| GET | `/api/codes` | 전체 flat (캐시 갱신용) |
| POST | `/api/codes` | 등록 |
| PUT | `/api/codes/{codeId}` | 수정 |
| DELETE | `/api/codes/{codeId}` | 삭제 (하위 재귀) |

- 단건 조회 API 없음 — 앱은 login `codes` 또는 `GET /api/codes` flat 캐시 사용

**코드 등록** `POST /api/codes`

요청 (`codeId`는 보내지 않음 — 서버 채번):

```json
// 최상위 (Root 직속)
{ "pCodeId": "Root", "codeName": "분류명" }

// 하위 (부모 codeId)
{ "pCodeId": "A00001", "codeName": "하위명" }
```

- `pCodeId`, `codeName`: `@NotBlank` (누락 시 `400` `VALIDATION_ERROR`)
- 채번: 레거시 `FrmBaseCode`와 동일 — `header`(예 `A0`, `A1`) + 형제 max 일련 +1

```json
// 성공 201
{ "codeId": "A10004", "pCodeId": "A00001", "codeName": "하위명" }

// 필수값 누락 400
{ "code": "VALIDATION_ERROR", "message": "코드명을 입력해 주세요.", "traceId": "...", "details": {} }
```

**코드 수정** `PUT /api/codes/{codeId}`

```json
// 요청 (codeName만)
{ "codeName": "변경된 코드명" }

// 성공 204 (body 없음)
```

**코드 삭제** `DELETE /api/codes/{codeId}`

```json
// 성공 204 (body 없음)
// 선택 노드 + 하위 코드 재귀 삭제
```

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
