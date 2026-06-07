# Railway 개념 정리

> 분야: Backend / Infra
> 관련 프로젝트: [[개발 Project/Haru Up/2026-06-06 백엔드 서버 업로드 검토 회의]]
> 비교 대상: [[Backend/AWS/AWS 개념 정리]] / [[Backend/AWS/Amazon Lightsail 개념 정리]] / [[Backend/AWS/Amazon EC2 개념 정리]]

## 한 줄 정의

Railway는 GitHub 저장소, Dockerfile, 데이터베이스 템플릿, 환경변수, 배포 로그를 한 화면에서 연결해 백엔드 앱을 빠르게 배포할 수 있게 해주는 클라우드 배포 플랫폼이다.

쉽게 말하면:

```text
Railway = 서버를 직접 관리하지 않고 GitHub 연결로 백엔드를 빠르게 올리는 배포 플랫폼
```

AWS Lightsail/EC2는 서버를 직접 만들고 Docker, 방화벽, 도메인, SSL, 백업을 직접 관리하는 쪽에 가깝다. Railway는 이런 서버 관리 부담을 줄이고, 앱/DB/Redis를 서비스 단위로 만들어 연결하는 쪽에 가깝다.

## Railway를 쓰는 이유

하루업 테스트 서버 관점에서 Railway의 장점은 명확하다.

| 이유 | 설명 |
|---|---|
| GitHub 자동 배포가 쉽다 | GitHub repo를 연결하면 push 기준으로 자동 배포할 수 있다. |
| DB/Redis를 빠르게 붙일 수 있다 | PostgreSQL, Redis 같은 서비스를 템플릿으로 추가할 수 있다. |
| 환경변수 관리가 쉽다 | JWT, DB password, Clova key, Firebase JSON 등을 Railway Variables에 넣는다. |
| 서버 SSH 관리가 필요 없다 | OS 업데이트, Docker 설치, 방화벽 설정을 직접 덜 만진다. |
| 팀 테스트 URL 확보가 빠르다 | Railway domain을 받아 앱 팀이 바로 API base URL로 쓸 수 있다. |
| 로그 확인이 쉽다 | Railway 대시보드에서 배포 로그와 런타임 로그를 볼 수 있다. |

단점도 있다.

| 단점                              | 설명                                                  |
| ------------------------------- | --------------------------------------------------- |
| 비용이 사용량 기반이다                    | 월 $5라고 끝나는 것이 아니라 app/DB/Redis 사용량에 따라 초과 과금될 수 있다. |
| 서버 내부를 자유롭게 만지는 데 한계가 있다        | Lightsail/EC2처럼 OS 레벨을 마음대로 운영하는 방식은 아니다.           |
| Docker Compose를 그대로 올리는 구조와 다르다 | 각 서비스를 Railway service로 나누는 것이 자연스럽다.               |
| 장기 운영 비용 예측은 AWS VPS보다 어려울 수 있다 | 사용량을 보면서 관리해야 한다.                                   |
| 팀 협업 권한은 Pro 이상이 더 적합하다         | 팀원이 Railway 대시보드에 직접 접근해야 하면 Pro 검토가 필요하다.          |

## Railway의 핵심 개념

### Project

Project는 하나의 앱 묶음이다.

하루업 기준:

```text
haruup-staging
  ├─ backend-app
  ├─ postgres
  └─ redis
```

### Service

Service는 Railway에서 실행되는 개별 구성 요소다.

하루업에서는 다음 3개가 기본이다.

| Service | 역할 |
|---|---|
| `backend-app` | Spring Boot 백엔드 API |
| `postgres` | PostgreSQL DB |
| `redis` | Redis 저장소 |

AWS Docker Compose에서는 이들이 한 서버 안의 여러 컨테이너지만, Railway에서는 각각 독립된 service 카드로 관리하는 것이 자연스럽다.

### Environment

Environment는 같은 Project 안에서 설정을 분리하는 단위다.

예:

```text
production
staging
preview
```

하루업은 처음부터 실제 운영 서버가 아니라 테스트 서버가 목적이므로, Railway에서는 `staging` 환경을 따로 두는 것이 좋다.

권장:

```text
production: 나중에 실제 사용자 운영용
staging: 현재 팀 테스트용
```

### Deployment

Deployment는 특정 코드/설정으로 서비스를 빌드하고 실행한 결과다.

GitHub push가 발생하면 Railway가 새 deployment를 만들고, 빌드 로그와 실행 로그를 보여준다.

### Variables

Variables는 환경변수다.

하루업에서 필요한 값:

```text
APPS_ENV
SERVER_PORT
POSTGRES_HOST
POSTGRES_PORT
POSTGRES_DB
POSTGRES_USER
POSTGRES_PASSWORD
REDIS_HOST
REDIS_PORT
REDIS_PASSWORD
JWT_SECRET_KEY
JWT_ISSUER
CLOVA_API_KEY
FIREBASE_SERVICE_ACCOUNT_JSON
RAILWAY_DOCKERFILE_PATH
```

중요:

- `env.properties`를 GitHub에 올리지 않는다.
- Railway Variables에 직접 넣는다.
- Firebase JSON처럼 긴 값은 줄바꿈/이스케이프 문제를 조심한다.

### Domain

Domain은 외부에서 접근할 URL이다.

Railway는 기본 도메인을 제공할 수 있고, 나중에 커스텀 도메인도 연결할 수 있다.

하루업 테스트 서버에서는 처음에는 Railway 기본 도메인으로 충분하다.

```text
https://haruup-staging.up.railway.app
```

운영에서는 다음처럼 커스텀 도메인을 고려한다.

```text
https://api.haruup.com
```

### Volume

Volume은 재배포 후에도 유지되어야 하는 파일 저장소다.

하루업의 현재 파일 업로드 경로는 `./uploads`다. Railway에서 파일 업로드 기능까지 테스트하려면 volume이 필요하다.

다만 운영 관점에서는 서버 volume보다 S3 같은 object storage가 더 안전하다.

## 하루업 Railway 구성안

Railway에서 하루업은 Docker Compose를 그대로 올리기보다 아래처럼 나눈다.

```text
Railway Project: haruup-staging
  ├─ backend-app
  ├─ postgres
  └─ redis
```

### `backend-app`

역할:

- Spring Boot API 서버
- 앱 클라이언트가 호출하는 base URL 제공
- Clova/Firebase/Postgres/Redis와 연결

설정:

```text
Source: GitHub repository
Dockerfile path: docker/app/Dockerfile
RAILWAY_DOCKERFILE_PATH=docker/app/Dockerfile
SERVER_PORT=${{ PORT }}
APPS_ENV=staging
Healthcheck path=/health
```

주의:

- 현재 Dockerfile은 루트가 아니라 `docker/app/Dockerfile`에 있다.
- Railway public networking은 `PORT` 환경변수와 잘 맞춰야 한다.
- 현재 `application.yml`은 `SERVER_PORT`를 보므로 `SERVER_PORT=${{ PORT }}`를 넣는 방식이 좋다.

### `postgres`

역할:

- 회원, 미션, 관심사, 랭킹, 알림, 파일 메타데이터 저장
- pgvector 확장 필요

설정:

```text
Railway PostgreSQL service 추가
POSTGRES_HOST=<Postgres service host>
POSTGRES_PORT=<Postgres service port>
POSTGRES_DB=<Postgres database>
POSTGRES_USER=<Postgres user>
POSTGRES_PASSWORD=<Postgres password>
```

주의:

- 하루업은 `ddl-auto: none`이라 schema를 자동 생성하지 않는다.
- 배포 전 schema SQL 또는 migration 방식이 필요하다.
- pgvector 확장 사용 가능 여부를 확인해야 한다.

### `redis`

역할:

- refresh token
- cache
- rate limit

설정:

```text
Railway Redis service 추가
REDIS_HOST=<Redis service host>
REDIS_PORT=<Redis service port>
REDIS_PASSWORD=<Redis password>
```

주의:

- Redis가 없으면 로그인 유지나 일부 캐시/제한 기능이 깨질 수 있다.
- 팀 테스트 단계에서도 Redis는 포함하는 것이 좋다.

## 왜 Hobby Plan이 필요한가

Railway 공식 문서 기준 플랜은 Free, Hobby, Pro, Enterprise가 있고, Trial도 존재한다.

핵심 가격:

| 플랜 | 월 비용 | 기본 성격 |
|---|---:|---|
| Free | $0 | 작은 앱, 월 $1 free credit |
| Hobby | $5 | 개인 개발자/인디 프로젝트 |
| Pro | $20 | 프로덕션을 배포하는 개발자/팀 |
| Enterprise | Custom | 엔터프라이즈 기능과 SLA 필요 |

Hobby는 월 $5이고, 이 안에 $5 resource usage가 포함된다. 즉 사용량이 $5 이하라면 월 $5만 내고, 사용량이 $7이면 총 $7이 되는 구조다.

### Free/Trial이 하루업에 애매한 이유

하루업 테스트 서버 요구사항:

```text
Spring Boot app 24시간
PostgreSQL 24시간
Redis 24시간
팀원이 언제든 호출할 base URL
GitHub 자동 배포
환경변수/로그/재배포 관리
```

Free/Trial이 애매한 이유:

- Free는 월 $1 credit 수준이라 Spring Boot + DB + Redis 24시간 테스트에 부족할 가능성이 높다.
- Trial은 1회성 $5 credit 성격이라 한 달 테스트 서버로 안정적으로 보기 어렵다.
- Trial 사용자는 Hobby로 업그레이드하지 않으면 추가 credit 구매가 제한된다.
- 서버가 중단되면 팀 앱 연동 테스트가 흔들린다.
- 하루업은 단순 정적 페이지가 아니라 DB/Redis/외부 API를 함께 쓰는 백엔드다.

그래서 하루업 테스트 서버는 Free/Trial이 아니라 Hobby부터 보는 것이 현실적이다.

### Hobby가 하루업에 맞는 이유

| 이유 | 하루업과의 연결 |
|---|---|
| 월 $5로 시작 가능 | AWS보다 초기 진입 비용이 낮고 GitHub 자동 배포가 쉽다. |
| $5 usage 포함 | 아주 작은 사용량이면 추가 resource 비용 없이 시작할 수 있다. |
| app + Postgres + Redis 구성 가능 | 팀 테스트에 필요한 기본 구성 요소를 한 프로젝트에 둘 수 있다. |
| Railway domain 제공 | 앱 팀에 base URL을 빠르게 공유할 수 있다. |
| 변수/로그/재배포 관리 쉬움 | 서버 SSH 없이 배포 오류를 빠르게 확인할 수 있다. |
| 운영 전 검증에 적합 | 한 달 뒤 AWS 또는 Railway 운영 여부를 판단하기 좋다. |

### Hobby의 한계

Hobby도 완벽한 운영 플랜은 아니다.

주의할 점:

- 사용량이 $5를 넘으면 초과 비용이 발생한다.
- 팀원이 Railway 대시보드에 직접 접근해야 하면 Pro가 더 적합할 수 있다.
- 실제 사용자 운영 단계에서는 백업, 장애 대응, 권한 관리, 비용 한도를 다시 봐야 한다.
- 파일 업로드 volume과 pgvector는 배포 전 별도 확인이 필요하다.

### Pro를 고려해야 하는 경우

다음 조건이면 Pro를 검토한다.

- 여러 팀원이 Railway 프로젝트에 직접 접근해야 한다.
- 실제 사용자 운영을 Railway에서 계속할 계획이다.
- staging/production 환경을 더 엄격히 분리해야 한다.
- 비용보다 안정적인 팀 협업과 권한 관리가 중요하다.

하루업 현재 단계에서는 한 명이 Railway를 관리하고 팀원은 API URL만 사용하는 구조라면 Hobby로 충분하다. 팀원 모두가 Railway 로그와 배포를 직접 봐야 한다면 Pro도 검토한다.

## 비용 관리 방법

Railway는 사용량 기반이라 비용 관리가 중요하다.

해야 할 것:

- usage limit 설정
- serverless/sleep 설정을 의도적으로 결정
- app, postgres, redis 메모리 사용량 확인
- 불필요한 preview/PR environment 끄기
- 파일 업로드 volume 사용량 확인
- Railway dashboard에서 usage를 주기적으로 확인

하루업 테스트 서버는 팀원이 언제든 붙어야 하므로 `backend-app`은 sleep 없이 24시간 켜두는 쪽이 맞다. 다만 개인 실험용 dev 환경은 serverless/sleep을 켜서 비용을 줄일 수 있다.

## Railway에서 하루업 배포 순서

1. Railway Hobby로 업그레이드
2. Project 생성: `haruup-staging`
3. GitHub repo 연결
4. `backend-app` 서비스 생성
5. `RAILWAY_DOCKERFILE_PATH=docker/app/Dockerfile` 설정
6. `SERVER_PORT=${{ PORT }}` 설정
7. PostgreSQL service 추가
8. Redis service 추가
9. DB/Redis 환경변수 매핑
10. JWT/Clova/Firebase 환경변수 입력
11. `/health` 응답 확인
12. Swagger 접속 확인
13. 앱 팀에 Railway domain 공유
14. usage limit과 로그 확인

## 하루업 Railway 환경변수 초안

```text
APPS_ENV=staging
SERVER_PORT=${{ PORT }}

POSTGRES_HOST=<Railway PostgreSQL host>
POSTGRES_PORT=<Railway PostgreSQL port>
POSTGRES_DB=<Railway PostgreSQL database>
POSTGRES_USER=<Railway PostgreSQL user>
POSTGRES_PASSWORD=<Railway PostgreSQL password>

REDIS_HOST=<Railway Redis host>
REDIS_PORT=<Railway Redis port>
REDIS_PASSWORD=<Railway Redis password>

JWT_SECRET_KEY=<staging jwt secret>
JWT_ISSUER=haruup-staging
CLOVA_API_KEY=<Naver Clova Studio key>
FIREBASE_SERVICE_ACCOUNT_JSON=<Firebase service account JSON>

RAILWAY_DOCKERFILE_PATH=docker/app/Dockerfile
```

## Railway와 AWS 비교

| 기준 | Railway Hobby | AWS Lightsail | AWS EC2 |
|---|---|---|---|
| 시작 난이도 | 낮음 | 중간 | 높음 |
| GitHub 자동 배포 | 쉬움 | 직접 구성 | 직접 구성 |
| 서버 관리 | 적음 | 직접 관리 | 직접 관리 |
| 비용 예측 | 사용량 기반 | 번들 기반 | 세부 항목 기반 |
| DB/Redis | 서비스로 추가 | 컨테이너 또는 별도 서비스 | 컨테이너 또는 RDS/ElastiCache |
| 도메인/HTTPS | 쉽게 제공 | 직접 구성 | 직접 구성 |
| 운영 자유도 | 제한 있음 | 중간 | 높음 |
| 하루업 현재 단계 | 가장 적합 | 운영 후보 | 확장 운영 후보 |

현재 하루업 추천:

```text
1차 팀 테스트: Railway Hobby
운영 전 검토: Lightsail 4GB 또는 Railway 유지
장기 확장: EC2 + RDS + S3 + ElastiCache
```

## 운영 전 꼭 확인할 것

- [ ] Hobby 사용량 한도 설정
- [ ] Postgres pgvector 사용 가능 여부 확인
- [ ] DB schema 생성 방식 준비
- [ ] 초기 데이터 seed 준비
- [ ] Redis 연결 확인
- [ ] Firebase JSON 변수 주입 확인
- [ ] Clova API key 변수 주입 확인
- [ ] CORS에 Railway domain 또는 앱 origin 반영
- [ ] 파일 업로드 테스트 범위 결정
- [ ] `/health` 응답 확인
- [ ] Swagger 공개 범위 결정
- [ ] Railway 로그에서 DB/Redis/Firebase/Clova 오류 확인
- [ ] 한 달 뒤 운영 배포 위치 재검토

## 공식 문서 참고

- [Railway Pricing Plans](https://docs.railway.com/pricing/plans)
- [Railway Cost Control](https://docs.railway.com/pricing/cost-control)
- [Railway Serverless](https://docs.railway.com/deployments/serverless)
- [Railway Build & Deploy](https://docs.railway.com/build-deploy)
- [Railway Docker Compose Guide](https://docs.railway.com/guides/docker-compose)
- [Railway Variables Reference](https://docs.railway.com/reference/variables)
- [Railway PostgreSQL](https://docs.railway.com/databases/postgresql)
- [Railway Databases Reference](https://docs.railway.com/databases/reference)

