# 하루업 API 점검 및 문서화 계획

> 프로젝트: 하루업
> Daily: [[Daily/2026-06-06]]
> 관련 회의: [[2026-06-06 백엔드 서버 업로드 검토 회의]]
> 기준일: 2026-06-06
> 1차 마감: 2026-06-07

## 목적

Railway Hobby 기반 staging 배포 전에, 현재 백엔드에 존재하는 API들이 실제로 동작하는지 확인하고 앱 팀이 사용할 수 있도록 문서화한다.

동시에 더 이상 필요하지 않거나 목적이 불분명한 API를 식별해 제거 또는 비공개 처리 후보로 분류한다.

## 회의 후 결정

- 1차 배포는 **Railway Hobby**로 진행한다.
- 배포 목적은 실제 운영이 아니라 팀 테스트용 staging 서버 구축이다.
- 운영 서버는 약 한 달 뒤인 **2026-07-06 전후**에 AWS 배포를 다시 시도한다.
- 그 전까지 Railway에서 API 연결, DB/Redis, 환경변수, 배포 로그, 팀 테스트 흐름을 검증한다.

## 2026-06-06 진행 기록

- [x] 테스트 기간 배포 방향을 Railway Hobby 기반 staging으로 정리
- [x] 현재 개발된 API 목록 1차 정리
- [ ] 앱에서 실제 사용하는 API 표시
- [ ] Swagger 노출 API와 실제 Controller 목록 비교
- [ ] 인증 필요 API와 공개 API 분리

## 내일까지 할 일

2026-06-07까지 우선순위는 배포 자체보다 **API 상태 파악과 문서화**다.

- [x] 현재 Controller 기준 API 목록 뽑기
- [ ] Swagger에서 노출되는 API와 실제 Controller 목록 비교
- [ ] 인증 없이 호출 가능한 API와 JWT가 필요한 API 분리
- [ ] 회원/인증 API 동작 확인
- [ ] 프로필/설정 API 동작 확인
- [ ] 미션 API 동작 확인
- [ ] 관심사/추천 API 동작 확인
- [ ] 랭킹/배치 API 동작 확인
- [ ] 알림 API 동작 확인
- [ ] 파일 업로드 API 테스트 범위 결정
- [ ] 앱 팀이 사용할 API 문서 초안 작성
- [ ] 불필요하거나 위험한 API 제거 후보 정리

## API 점검 기준

각 API는 아래 기준으로 확인한다.

| 항목 | 확인 내용 |
|---|---|
| URL | 실제 endpoint path가 맞는가 |
| Method | GET/POST/PUT/DELETE가 의도와 맞는가 |
| 인증 | JWT 필요 여부가 맞는가 |
| Request | request body, query parameter, path variable이 명확한가 |
| Response | 앱에서 바로 사용할 수 있는 응답 형태인가 |
| DB 의존성 | 필요한 schema/seed 데이터가 있는가 |
| 외부 API 의존성 | Clova/Firebase가 필요한가 |
| 실패 케이스 | 잘못된 입력, 인증 실패, 데이터 없음 처리가 되는가 |
| Swagger 노출 | 문서에 남겨도 되는 API인가 |
| 앱 사용 여부 | 실제 앱 화면에서 필요한 API인가 |

## 문서화 산출물

API 문서에는 최소한 아래 항목을 넣는다.

```text
API 이름:
Method:
URL:
인증 필요 여부:
Request:
Response:
사용 화면:
테스트 상태:
비고:
```

예시:

```text
API 이름: SNS 로그인
Method: POST
URL: /api/member/auth/sns-login
인증 필요 여부: 불필요
Request: loginType, providerId, email 등
Response: accessToken, refreshToken, member 정보
사용 화면: 로그인 화면
테스트 상태: 확인 필요
비고: Firebase/소셜 로그인 연동 값 확인 필요
```

## 제거 또는 비공개 후보 기준

아래 조건에 해당하면 제거/비공개 후보로 둔다.

- 앱에서 사용하지 않는 테스트 API
- 임시 디버깅용 API
- 인증 없이 민감 정보를 노출할 수 있는 API
- 수동 배치 실행처럼 운영에서 보호되어야 하는 API
- 이름이 불명확하거나 중복된 API
- 이전 구현의 흔적만 남은 API
- Swagger에 공개되면 안 되는 내부용 API

특히 확인할 후보:

- 랭킹 수동 배치 실행 API
- 테스트 푸시 발송 API
- 회원 통계/엑셀 다운로드 API
- Swagger/Actuator 공개 범위
- QA 또는 로컬 테스트 전용 API

## API 그룹별 점검 순서

### 1. 인증/회원

대표 Controller:

- `MemberAuthController`
- `MemberAccountController`
- `MemberProfileController`
- `MemberSettingController`

확인할 것:

- 로그인 후 JWT 발급
- JWT 인증 요청 성공 여부
- 로그아웃/refresh token 흐름
- 프로필 저장/조회/수정
- 설정 조회/수정

### 2. 미션

대표 Controller:

- `MemberMissionController`
- `MemberCustomMissionController`
- `MemberGoalController`

확인할 것:

- 오늘 미션 조회
- 미션 상태 변경
- 미션 추천
- 미션 선택
- 커스텀 미션 생성/수정/삭제
- 목표 기반 미션 생성 흐름

### 3. 관심사/추천/AI

대표 Controller:

- `InterestController`
- `MissionembeddingController`
- `CurationChatbotController`
- `MemberCurationController`

확인할 것:

- Clova API key 필요 여부
- pgvector/embedding 데이터 필요 여부
- 추천 API 응답 시간
- SSE 큐레이션 동작
- 챗봇 질문/답변 흐름

### 4. 랭킹/알림/기타

대표 Controller:

- `RankingController`
- `NotificationController`
- `JobController`
- `CharacterController`
- `MemberInfoController`

확인할 것:

- 랭킹 조회
- 수동 배치 API 보호 여부
- 푸시 토큰 등록
- 테스트 푸시 API 공개 여부
- 직업/캐릭터 목록 API
- 통계/엑셀 다운로드 API 공개 여부

## Railway 배포 전 확인

API 점검이 끝난 뒤 Railway 배포 전에 확인한다.

- [ ] `RAILWAY_DOCKERFILE_PATH=docker/app/Dockerfile`
- [ ] `SERVER_PORT=${{ PORT }}`
- [ ] `APPS_ENV=staging`
- [ ] PostgreSQL 연결 변수
- [ ] Redis 연결 변수
- [ ] JWT secret
- [ ] Clova API key
- [ ] Firebase service account JSON
- [ ] DB schema/seed
- [ ] pgvector extension
- [ ] CORS origin
- [ ] `/health` endpoint
- [ ] Swagger 접근 범위

## 다음 회의 전 질문

- 앱 팀에서 반드시 필요한 API 목록은 무엇인가?
- 현재 Swagger에 노출된 API 중 실제 앱에서 안 쓰는 것은 무엇인가?
- Clova/Firebase 없이도 테스트 가능한 API와 반드시 필요한 API는 무엇인가?
- Railway staging에 파일 업로드 기능까지 포함할 것인가?
- 수동 배치/테스트 푸시/통계 다운로드 API는 운영에서 어떻게 보호할 것인가?
