# Amazon Lightsail 개념 정리

> 분야: Backend / Infra
> 관련 개념: [[AWS 개념 정리]] / [[Amazon EC2 개념 정리]]
> 관련 프로젝트: [[Projects/Haru Up/2026-06-06 백엔드 서버 업로드 검토 회의]]

## 한 줄 정의

Amazon Lightsail은 AWS를 처음 쓰는 사람이 웹사이트나 웹 애플리케이션을 빠르게 배포할 수 있도록 만든 단순한 VPS 서비스다.

쉽게 말하면:

```text
Lightsail = AWS에서 제공하는 단순한 가상 서버 호스팅
```

EC2보다 선택지는 적지만, 서버 생성, 고정 IP, 방화벽, 스냅샷, DNS, 관리형 DB 같은 기능을 더 간단한 UI와 예측 가능한 월 비용으로 시작할 수 있다.

## VPS란 무엇인가

VPS는 Virtual Private Server의 줄임말이다.

물리 서버 한 대를 여러 사용자가 나눠 쓰되, 각 사용자에게 독립된 가상 서버처럼 제공하는 방식이다.

내가 Lightsail 인스턴스를 만들면 아래처럼 하나의 리눅스 서버를 받는다고 생각하면 된다.

```text
Ubuntu 서버 1대
  ├─ CPU
  ├─ Memory
  ├─ SSD Disk
  ├─ Public IP
  └─ SSH 접속
```

그 서버에 Docker, Docker Compose, Nginx, Spring Boot 앱, PostgreSQL, Redis 등을 직접 설치해서 운영할 수 있다.

## Lightsail이 제공하는 것

AWS 공식 문서 기준 Lightsail은 프로젝트를 빠르게 시작하는 데 필요한 기능을 묶어서 제공한다.

대표 기능:

| 기능 | 설명 | 하루업과의 연결 |
|---|---|---|
| Instance | 리눅스/윈도우 가상 서버 | Spring Boot + Docker Compose 실행 |
| Static IP | 고정 public IP | 앱 base URL 또는 도메인 연결 |
| DNS | 도메인 레코드 관리 | `api.haruup.com` 같은 주소 연결 |
| Snapshot | 서버 백업 이미지 | 장애/실수 복구 |
| Block Storage | 추가 SSD 디스크 | DB/업로드 파일 저장공간 확장 |
| Managed Database | 관리형 MySQL/PostgreSQL | DB를 서버와 분리할 때 검토 |
| Load Balancer | 트래픽 분산 | 서버 여러 대로 확장할 때 |
| Container Service | 컨테이너 배포 서비스 | Docker image 기반 배포 가능 |

하루업 초기 AWS 운영 후보로는 **Lightsail Instance + Docker Compose**가 가장 이해하기 쉽다.

## Lightsail과 EC2의 차이

| 기준         | Lightsail     | EC2                               |
| ---------- | ------------- | --------------------------------- |
| 목적         | 간단한 VPS/웹앱 배포 | 범용 클라우드 서버                        |
| 시작 난이도     | 낮음            | 높음                                |
| 가격         | 번들 기반이라 예측 쉬움 | 인스턴스, EBS, 트래픽 등 조합에 따라 달라짐       |
| 네트워크       | 단순한 방화벽 UI    | VPC, Subnet, Security Group 등 세밀함 |
| 확장성        | 제한적           | 매우 높음                             |
| AWS 서비스 연동 | 상대적으로 단순      | 자유롭고 복잡함                          |
| 하루업 초기 배포  | 적합            | 가능하지만 학습 부담 큼                     |
| 대규모 운영     | 한계 있음         | 더 적합                              |

정리하면:

```text
Lightsail = 작고 단순하게 시작하기 좋음
EC2 = 더 자유롭고 복잡한 운영에 좋음
```

## 하루업에 Lightsail을 쓰면 어떻게 되는가

하루업 백엔드를 Lightsail에 올리는 최소 구조는 다음과 같다.

```text
Lightsail Instance
  ├─ Docker
  ├─ Docker Compose
  ├─ haruup-app
  ├─ haruup-postgres
  ├─ haruup-redis
  └─ caddy 또는 nginx
```

서비스 흐름:

```text
iOS/Android App
  -> https://api.haruup.com
  -> Caddy/Nginx
  -> Spring Boot app
  -> PostgreSQL / Redis
  -> Clova / Firebase
```

여기서 Caddy 또는 Nginx는 외부 HTTPS 요청을 받아 내부 Spring Boot 앱으로 넘겨주는 reverse proxy 역할을 한다.

## Lightsail 서버 크기 선택

2026-06-06 확인 기준, AWS 공식 Lightsail Linux/Unix public IPv4 번들 일부는 다음과 같다.

| 번들 | 월 비용 | vCPU | 메모리 | SSD | 전송량 | 하루업 판단 |
|---|---:|---:|---:|---:|---:|---|
| Nano 0.5GB | $5 | 2 | 0.5GB | 20GB | 1TB | Spring Boot + DB 운영 불가 수준 |
| Micro 1GB | $7 | 2 | 1GB | 40GB | 2TB | 부족 |
| Small 2GB | $12 | 2 | 2GB | 60GB | 3TB | 테스트/초기 최소선 |
| Medium 4GB | $24 | 2 | 4GB | 80GB | 4TB | 운영 초반 권장 |
| Large 8GB | $44 | 2 | 8GB | 160GB | 5TB | 모니터링까지 여유 |

하루업 기준 추천:

- 테스트/초기 최소: `Small 2GB`
- 운영 초반 안정성: `Medium 4GB`
- Prometheus/Grafana/Loki까지 한 서버에 같이 올림: `Large 8GB` 검토

2GB에서 가능한 이유:

- Spring Boot 앱 1개
- PostgreSQL 1개
- Redis 1개
- Nginx/Caddy 1개

2GB에서 빡빡한 이유:

- JVM이 메모리를 많이 잡을 수 있음
- PostgreSQL도 캐시 메모리를 사용함
- Redis도 메모리 기반 저장소임
- 배치/AI 호출 중 순간 메모리 사용량이 올라갈 수 있음

그래서 2GB를 쓸 경우 Spring Boot JVM 메모리를 제한해야 한다.

```text
JAVA_OPTS="-Xms256m -Xmx768m"
```

## AWS Pricing Calculator 입력 방법

하루업처럼 Docker Compose로 백엔드를 직접 운영하려는 경우, Pricing Calculator에서는 우선 **Lightsail Virtual Servers만 켜고 계산**한다.

스크린샷처럼 `Lightsail Containers`까지 켜면 별도의 Lightsail Container Service 비용이 같이 계산되어 월 비용이 불필요하게 높게 나온다. 하루업의 현재 AWS 후보는 “컨테이너 서비스”가 아니라 “리눅스 가상 서버 1대에 Docker Compose 설치” 방식이다.

### 1차 계산: 최소 AWS 서버 비용

입력값:

```text
Region: Asia Pacific (Seoul)
Lightsail Virtual Servers: ON
Lightsail Containers: OFF
Lightsail Managed Databases: OFF
Lightsail Object Storage: OFF
Lightsail Block Storage: OFF
Lightsail Load Balancer: OFF
Server count: 1
Operating system: Linux
Bundle: Small 2GB
Usage: 730 Hours/Month
```

예상 결과:

```text
약 $12/month
```

이 구성에 올라가는 것:

```text
Lightsail 2GB 서버 1대
  ├─ Spring Boot app
  ├─ PostgreSQL + pgvector
  ├─ Redis
  └─ Caddy 또는 Nginx
```

판단:

- 테스트/초기 운영의 최소 비용을 확인할 때 사용한다.
- 0.5GB 또는 1GB 번들은 Spring Boot + PostgreSQL + Redis를 같이 올리기에 부족하다.
- 2GB는 가능하지만 JVM 메모리 제한과 모니터링 도구 제외가 필요하다.

### 2차 계산: 운영 초반 권장 비용

입력값:

```text
Region: Asia Pacific (Seoul)
Lightsail Virtual Servers: ON
Lightsail Containers: OFF
Server count: 1
Operating system: Linux
Bundle: Medium 4GB
Usage: 730 Hours/Month
```

예상 결과:

```text
약 $24/month
```

판단:

- 실제 사용자가 붙는 운영 초반에는 4GB가 더 안정적이다.
- Spring Boot 앱, PostgreSQL, Redis, 배치, Clova API 호출까지 고려하면 2GB보다 여유가 있다.
- 그래도 Prometheus/Grafana/Loki까지 모두 같은 서버에 올리기에는 상황에 따라 빡빡할 수 있다.

### 3차 계산: 모니터링까지 포함한 서버

입력값:

```text
Region: Asia Pacific (Seoul)
Lightsail Virtual Servers: ON
Lightsail Containers: OFF
Server count: 1
Operating system: Linux
Bundle: Large 8GB
Usage: 730 Hours/Month
```

예상 결과:

```text
약 $44/month
```

판단:

- Prometheus, Grafana, Loki까지 한 서버에 같이 올릴 때 검토한다.
- 하루업 초기에는 과한 구성이므로 운영 안정화 이후에 고려한다.

### 언제 다른 기능을 켜는가

| Calculator 기능 | 하루업에서 켜는 시점 |
|---|---|
| `Lightsail Virtual Servers` | 기본으로 켠다. Docker Compose를 올릴 서버다. |
| `Lightsail Containers` | 현재는 끈다. Docker Compose 방식과 다르다. |
| `Lightsail Managed Databases` | DB를 서버 내부 PostgreSQL이 아니라 Lightsail 관리형 DB로 분리할 때 켠다. |
| `Lightsail Object Storage` | 파일 업로드를 서버 volume이 아니라 object storage에 저장할 때 켠다. |
| `Lightsail Block Storage` | 서버 기본 SSD가 부족해서 추가 디스크를 붙일 때 켠다. |
| `Lightsail Load Balancer` | 앱 서버를 2대 이상으로 늘릴 때 켠다. |
| `Lightsail CDN` | 이미지/static 파일을 전 세계에 빠르게 배포할 때 켠다. |
| `Lightsail Data Transfer` | 기본 번들 전송량을 초과할 가능성이 있을 때 별도 계산한다. |

### 하루업 현재 추천 계산값

지금 계산기에서 확인할 값:

```text
Virtual Servers ON
Containers OFF
Bundle Small 2GB
730 Hours/Month
```

운영 전 다시 확인할 값:

```text
Virtual Servers ON
Containers OFF
Bundle Medium 4GB
730 Hours/Month
```

현재 스크린샷에서 고쳐야 할 점:

- `Lightsail Containers`를 끈다.
- `Bundle:0.5GB`를 `Bundle:2GB` 또는 `Bundle:4GB`로 바꾼다.
- `730 Hours/Month`는 24시간 서버 기준으로 그대로 둔다.

## Lightsail로 배포할 때 필요한 최소 설정

### 1. 인스턴스 생성

권장:

```text
Region: Seoul(ap-northeast-2)
OS: Ubuntu LTS 또는 Amazon Linux
Plan: Small 2GB 또는 Medium 4GB
```

서울 사용자가 많다면 서울 리전이 응답속도 측면에서 자연스럽다.

### 2. Static IP 연결

Lightsail 인스턴스를 중지/재생성하거나 설정을 바꿀 때 public IP가 바뀌면 앱 base URL 관리가 어렵다.

그래서 운영/테스트 서버에는 Static IP를 붙이는 것이 좋다.

```text
Static IP -> Lightsail Instance
```

### 3. 방화벽 설정

외부에 열 포트:

| 포트 | 용도 | 공개 범위 |
|---:|---|---|
| 22 | SSH 접속 | 가능하면 본인 IP만 |
| 80 | HTTP, 인증서 발급 | 전체 |
| 443 | HTTPS API | 전체 |

외부에 열면 안 되는 포트:

| 포트 | 용도 | 이유 |
|---:|---|---|
| 8080 | Spring Boot 앱 | reverse proxy 내부에서만 접근 |
| 5432 | PostgreSQL | DB 외부 노출 위험 |
| 6379 | Redis | Redis 외부 노출 위험 |
| 9090 | Prometheus | 운영 초반 불필요 |
| 3000 | Grafana | 인증/보안 설정 전 외부 공개 위험 |
| 3100 | Loki | 로그 저장소 외부 노출 위험 |

### 4. Docker 설치

서버에 접속한 뒤 Docker와 Docker Compose를 설치한다.

```text
ssh ubuntu@<server-ip>
install docker
install docker compose plugin
```

### 5. 환경변수 준비

서버에 `.env` 파일 또는 compose용 env 파일을 둔다.

```text
APPS_ENV=prod
SERVER_PORT=8080
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=haruup
POSTGRES_USER=haruup_user
POSTGRES_PASSWORD=<strong-password>
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=<strong-password>
JWT_SECRET_KEY=<production-jwt-secret>
JWT_ISSUER=haruup
CLOVA_API_KEY=<Naver Clova Studio key>
FIREBASE_SERVICE_ACCOUNT_JSON=<Firebase service account JSON>
```

주의:

- `.env`는 GitHub에 올리면 안 된다.
- JWT secret, DB password, Firebase JSON은 팀에서 접근 권한을 정해야 한다.

### 6. Docker Compose 구성

최소 compose는 다음 4개만 포함하면 된다.

```text
app
postgres
redis
caddy 또는 nginx
```

처음에는 아래를 제외한다.

```text
app-qa
redis-qa
prometheus
grafana
loki
```

### 7. 도메인/HTTPS 연결

권장 흐름:

```text
api.haruup.com
  -> Lightsail Static IP
  -> Caddy/Nginx
  -> app:8080
```

Caddy를 쓰면 HTTPS 인증서 발급과 갱신이 비교적 단순하다. Nginx를 쓰면 Certbot을 따로 붙이는 경우가 많다.

### 8. DB 백업

초기에는 최소한 PostgreSQL dump를 스케줄로 남겨야 한다.

예:

```text
매일 새벽 pg_dump 실행
백업 파일을 서버 디스크 또는 S3에 저장
오래된 백업 삭제
```

운영에서는 로컬 서버 안에만 백업을 두면 서버 자체 장애에 취약하다. S3나 외부 저장소로 복사하는 편이 안전하다.

## Lightsail에서 하루업 최소 구성

```text
Lightsail Small 2GB 또는 Medium 4GB
  ├─ Docker Compose
  │   ├─ app
  │   ├─ postgres
  │   ├─ redis
  │   └─ caddy
  ├─ Volume
  │   ├─ postgres_data
  │   ├─ redis_data
  │   └─ uploads
  ├─ Firewall
  │   ├─ 22
  │   ├─ 80
  │   └─ 443
  └─ Static IP
```

## 장점

- AWS 안에서 시작하지만 EC2보다 단순하다.
- 월 비용을 예측하기 쉽다.
- Docker Compose 기반 배포와 잘 맞는다.
- 하루업처럼 작은 팀의 초기 운영 서버에 적합하다.
- 추후 EC2/RDS/S3로 확장할 수 있다.

## 단점

- 서버 OS, Docker, 보안, 백업은 직접 관리해야 한다.
- RDS/S3/ElastiCache 같은 관리형 서비스보다 운영 책임이 크다.
- 서버 한 대에 app/DB/Redis를 모두 올리면 단일 장애점이 된다.
- 트래픽이 늘거나 운영 안정성이 중요해지면 분리 구조로 넘어가야 한다.

## Railway와 비교

| 기준 | Railway Hobby | Lightsail |
|---|---|---|
| 배포 방식 | GitHub 연결 자동 배포가 쉬움 | 직접 SSH 접속, Docker Compose 운영 |
| 운영 부담 | 낮음 | 중간 |
| 비용 예측 | 사용량에 따라 달라질 수 있음 | 번들 가격이라 비교적 예측 쉬움 |
| 24시간 테스트 서버 | 가능 | 가능 |
| DB/Redis | 플랫폼 서비스로 붙임 | 서버 내부 컨테이너 또는 별도 서비스 |
| 도메인/HTTPS | 플랫폼에서 쉽게 제공 | 직접 설정 |
| 운영 학습 효과 | 낮음 | 높음 |
| 하루업 현재 단계 | 테스트용으로 적합 | 운영 후보로 적합 |

## 하루업 기준 의사결정

현재 추천:

```text
지금: Railway Hobby로 staging 배포
운영 전: Lightsail 4GB 또는 Railway 유지 비교
운영 안정화: RDS/S3/ElastiCache 분리 검토
```

Lightsail을 바로 쓰지 않는 이유:

- 지금은 팀 테스트용 URL 확보가 더 급하다.
- GitHub 자동 배포가 Railway가 더 쉽다.
- Lightsail은 서버 관리, Docker Compose, SSL, 백업까지 직접 잡아야 한다.

그래도 Lightsail을 운영 후보로 남기는 이유:

- 비용 예측이 쉽다.
- Docker Compose 구조를 살리기 좋다.
- AWS 운영 경험을 쌓기 좋다.
- 한 달 뒤 운영 서버로 전환할 때 현실적인 선택지다.

## Lightsail 배포 전 체크리스트

- [ ] Lightsail 인스턴스 사양 결정: 2GB 또는 4GB
- [ ] 서울 리전 선택
- [ ] Static IP 생성 및 연결
- [ ] 방화벽에서 22/80/443만 외부 공개
- [ ] Docker/Docker Compose 설치
- [ ] 서버 `.env` 파일 준비
- [ ] PostgreSQL volume 설정
- [ ] Redis volume 또는 maxmemory 설정
- [ ] uploads volume 설정
- [ ] Caddy/Nginx reverse proxy 설정
- [ ] 도메인 연결
- [ ] HTTPS 확인
- [ ] `/health` 응답 확인
- [ ] DB schema 생성
- [ ] pgvector 확장 활성화
- [ ] DB 백업 스크립트 준비
- [ ] GitHub Actions 자동 배포 여부 결정

## 공식 문서 참고

- [What is Amazon Lightsail?](https://docs.aws.amazon.com/lightsail/latest/userguide/what-is-amazon-lightsail.html)
- [Amazon Lightsail Documentation](https://docs.aws.amazon.com/lightsail/)
- [Lightsail instance bundles](https://docs.aws.amazon.com/lightsail/latest/userguide/amazon-lightsail-bundles.html)
- [Lightsail virtual private server instances](https://docs.aws.amazon.com/lightsail/latest/userguide/understanding-instances-virtual-private-servers-in-amazon-lightsail.html)
- [Lightsail container services](https://docs.aws.amazon.com/lightsail/latest/userguide/amazon-lightsail-container-services.html)
