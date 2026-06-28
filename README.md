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
0단계  프로젝트 뼈대 + 디자인 샘플 화면  ← /dev/design 미구현
1단계  회원(완료) → 공통코드 → 고객 → 제품
2단계  접수 → 출고 → 매출
3단계  일계표·설정 등 (나중에)
```

**1단계 진행**: ① 회원 완료 · ②~④ 미착수

---

## 핵심 규칙 (짧게)

- **Java**: `common.*`(기초) / `sales.*`(영업) — 레거시 BaseForm·SalesForm 대응
- **Java**: `IComMemberService`(인터페이스) → `ComMemberService`(구현)
- **Flutter**: 클린 아키텍처 + Riverpod, 단순한 건 UseCase 생략
- **로그인 후**: `authProvider`에 유저 저장 · 자동 로그인(`shared_preferences`) · 공통코드는 1-2 이후
- **설정**: `application.yml` 하나 (profile 안 씀, 주소는 `localhost`)
- **로그**: 요청마다 traceId, 파일 롤링 — [02_아키텍처.md](docs/02_아키텍처.md) 참고
- **디자인**: [06_디자인_시스템.md](docs/06_디자인_시스템.md) · `/dev/design` 샘플은 미구현

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
