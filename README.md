# TKLaundry 차세대 — 시작 가이드

기존 C# 세탁소 프로그램을 **Flutter Windows + Java API**로 옮기는 프로젝트입니다.  
DB는 기존 MSSQL `TKLaundry`를 그대로 씁니다.

---

## 기술 스택

| 구분 | 기술 |
|------|------|
| 화면 | Flutter Windows + Riverpod |
| API | Java + Spring Boot + MyBatis |
| DB | MSSQL (기존 DB 공유) |
| 설정 | **YAML** (`application.yml`) — properties 파일 안 씀 |

---

## 폴더 구조

### 차세대 (새 git 저장소)

```
tklaundry/
├── docs/                    ← 이 문서들
├── backend/tklaundry-api/   ← Java API (Spring Boot)
└── app/tklaundry_app/       ← Flutter Windows 앱
```

### 레거시 (비교용, 새 레포에 넣지 않음)

```
D:/projects/
├── TKLaundry/   ← C# 소스 (형제 폴더로 보관, bin/obj 제외)
└── tklaundry/   ← 차세대
```

레거시는 **옆에 두고** 화면·SQL 비교할 때 참고합니다. 새 레포에 커밋하지 않습니다.

---

## 문서 목록

| 문서 | 내용 |
|------|------|
| [01_구현순서.md](docs/01_구현순서.md) | 무엇을 언제 만들지 (0~3단계) |
| [02_아키텍처.md](docs/02_아키텍처.md) | 구조, **YAML 설정**, **로그** |
| [03_레거시.md](docs/03_레거시.md) | 레거시 DB·화면·규칙 |
| [04_API규약.md](docs/04_API규약.md) | API 주소·응답 형식 |
| [05_테스트.md](docs/05_테스트.md) | 수동 테스트 |
| [06_디자인_시스템.md](docs/06_디자인_시스템.md) | Flutter 색상·컴포넌트·레이아웃 |

---

## 만들 순서 (한눈에)

```
0단계  프로젝트 뼈대 · 공통 위젯 · 로그  (완료)
1단계  회원 → 공통코드 → 고객 → 제품  (완료)
2단계  접수 → 출고 → 매출  (다음)
3단계  일계표·설정 등 (나중에)
```

**1단계 완료** · **2단계(접수) — 미착수**

---

## 핵심 규칙 (짧게)

- **Java**: `common.*`(기초) / `sales.*`(영업) — 레거시 BaseForm·SalesForm 대응
- **Java**: `I*Service` → `*Service` · login 응답 = `CommonInfo` JSON (`user` + `codes`)
- **Flutter**: Riverpod · 단순 CRUD는 UseCase 생략
- **로그인 후**: `authProvider` + login `codes` → 전역 `codeProvider` · 자동 로그인(`shared_preferences`)
- **공통코드**: flat 캐시 · CRUD 후 `codeProvider.search()` · 단건 API 없음
- **고객**: 아파트 필터 목록 · 단건 GET 없음(그리드 행으로 수정) · 등록·수정·삭제 API
- **제품**: 공정·그룹 필터 목록 · 단건 GET 없음 · 등록·수정·삭제 API
- **셸**: 메뉴 전환 시 dispose (1단계) · 2단계부터 비즈니스만 탭·캐시 검토 — [02_아키텍처.md](docs/02_아키텍처.md)
- **설정**: `application.yml` 하나 (profile 안 씀, `localhost`)
- **로그**: 오류 JSON traceId · 파일 롤링 — [02_아키텍처.md](docs/02_아키텍처.md)
- **디자인**: [06_디자인_시스템.md](docs/06_디자인_시스템.md) · `shared/widgets/Tk*`

---

## 실행 방법

```powershell
# API
cd backend/tklaundry-api
.\gradlew.bat bootRun

# 앱
cd app/tklaundry_app
flutter run -d windows
```

---

## 주의사항

- DB 비밀번호·매장 설정 → **git에 올리지 않음**
- 레거시 `bin/`, `obj/`, `.vs/` → **커밋 금지**
- API 로그 파일 `logs/` → **gitignore**
