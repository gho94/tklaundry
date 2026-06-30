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
| GET | `/api/customers` | 목록 (전체) |
| GET | `/api/customers?aptCode=` | 목록·아파트 필터 (`aptCode` 생략=전체, `=`빈값=기타) |
| POST | `/api/customers` | 등록 |
| PUT | `/api/customers/{custCode}` | 수정 |
| DELETE | `/api/customers/{custCode}` | 삭제 |

- 단건 조회 API 없음 — 앱은 목록 그리드 행으로 수정 다이얼로그 채움 (레거시 `FrmCustomer` 더블클릭과 동일)
- 수정·삭제는 사전 `NOT_FOUND` 조회 없음

**고객 목록** `GET /api/customers` · `GET /api/customers?aptCode=A20001`

```json
[
  {
    "custCode": "C0001",
    "custName": "세교 4-1204",
    "aptCode": "A20001",
    "buildingCode": "A30004",
    "floorCode": "A20012",
    "roomCode": "A20004",
    "custPhone": "010-1234-5678"
  }
]
```

- `aptCode` 쿼리 생략: `WHERE` 없음 (전체)
- `aptCode` 값 지정: `WHERE AptCode = #{aptCode}` (`aptCode=` 빈 문자열이면 기타)

**고객 등록** `POST /api/customers`

```json
// 요청 (미선택 콤보는 null 또는 필드 생략)
{
  "custName": "세교 4-1204",
  "aptCode": "A20001",
  "buildingCode": "A30004",
  "floorCode": "A20012",
  "roomCode": "A20004",
  "custPhone": "010-1234-5678"
}

// 성공 201
{
  "custCode": "C1913",
  "custName": "세교 4-1204",
  "aptCode": "A20001",
  "buildingCode": "A30004",
  "floorCode": "A20012",
  "roomCode": "A20004",
  "custPhone": "010-1234-5678"
}

// 동일 위치 중복 409 (4코드 모두 null이 아닐 때만 검사)
{ "code": "CONFLICT", "message": "이미 등록된 정보입니다.", "traceId": "...", "details": {} }
```

- `custCode`: 서버 채번 (`C` + 4자리, `MAX(CustCode)+1`)
- DB 저장 시 미선택 필드 `null` → `""`

**고객 수정** `PUT /api/customers/{custCode}`

```json
// 요청 (custCode는 path만 사용)
{
  "custName": "세교 4-1205",
  "aptCode": "A20001",
  "buildingCode": "A30004",
  "floorCode": "A20012",
  "roomCode": "A20005",
  "custPhone": ""
}

// 성공 204 (body 없음)
```

- 수정 시 위치 중복 검사 없음 (레거시 수정 모드와 동일)

**고객 삭제** `DELETE /api/customers/{custCode}`

```json
// 성공 204 (body 없음)
```

### 제품

| Method | 경로 | 설명 |
|--------|------|------|
| GET | `/api/products?processCode=&groupCode=` | 목록·공정·그룹 필터 |
| POST | `/api/products` | 등록 |
| PUT | `/api/products/{productCode}` | 수정 |
| DELETE | `/api/products/{productCode}` | 삭제 |

- 단건 조회 API 없음 — 앱은 목록 그리드 행으로 수정 다이얼로그 채움 (레거시 `FrmProduct`와 동일, 표시·편집은 제품명·단가)
- 수정·삭제는 사전 `NOT_FOUND` 조회 없음
- 목록 필터: 공정·그룹 **둘 다 필수** (레거시 상단 콤보와 동일, 「전체」 없음)
- 수정 시 `ProcessCode`·`GroupCode`는 변경하지 않음 (레거시 화면과 동일)

**제품 목록** `GET /api/products?processCode=B20003&groupCode=B30001`

```json
[
  {
    "productCode": "P0001",
    "processCode": "B20003",
    "groupCode": "B30001",
    "productName": "와이셔츠",
    "price": 3000
  }
]
```

- `processCode`, `groupCode` 쿼리 **필수**
- `WHERE ProcessCode = ? AND GroupCode = ?`
- 정렬: `ORDER BY ProductCode`

**제품 등록** `POST /api/products`

```json
// 요청 (productCode는 보내지 않음 — 서버 채번)
{
  "processCode": "B20003",
  "groupCode": "B30001",
  "productName": "와이셔츠",
  "price": 3000
}

// 성공 201
{
  "productCode": "P0461",
  "processCode": "B20003",
  "groupCode": "B30001",
  "productName": "와이셔츠",
  "price": 3000
}
```

- `productCode`: 서버 채번 (`P` + 4자리, `TOP 1 ORDER BY ProductCode DESC` + 1)
- `price` null → `0`, 미입력 문자열 → `""`
- 위치·이름 중복 검사 없음 (레거시와 동일)

**제품 수정** `PUT /api/products/{productCode}`

```json
// 요청 (productCode는 path만 사용 · 공정·그룹 코드 미포함)
{
  "productName": "와이셔츠(수정)",
  "price": 3500
}

// 성공 204 (body 없음)
```

- DB 갱신: `ProductName`, `Price`, 감사필드만 (`ProcessCode`·`GroupCode` 유지)

**제품 삭제** `DELETE /api/products/{productCode}`

```json
// 성공 204 (body 없음)
```

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
