# AWS 개념 정리

> 분야: Backend / Infra
> 관련 프로젝트: [[개발 Project/Haru Up/2026-06-06 백엔드 서버 업로드 검토 회의]]
> 함께 보기: [[Amazon Lightsail 개념 정리]] / [[Amazon EC2 개념 정리]]

## 한 줄 정의

AWS는 Amazon Web Services의 줄임말로, 서버, 데이터베이스, 저장소, 네트워크, 보안, AI 같은 인프라를 인터넷으로 빌려 쓰는 클라우드 플랫폼이다.

로컬 컴퓨터나 회사 서버실에 직접 서버를 사서 설치하는 대신, AWS 계정 안에서 필요한 서버와 서비스를 만들고 사용한 만큼 비용을 낸다.

## 클라우드란 무엇인가

클라우드는 쉽게 말해 **내가 직접 장비를 사지 않고, 인터넷 너머의 서버 자원을 빌려 쓰는 방식**이다.

전통적인 방식:

```text
서버 구매 -> 서버실 설치 -> OS 설치 -> 네트워크 설정 -> 앱 배포 -> 장애 대응
```

클라우드 방식:

```text
AWS 콘솔/API에서 서버 생성 -> 앱 배포 -> 필요하면 사양 변경/삭제
```

AWS 공식 문서는 클라우드 컴퓨팅을 컴퓨팅 파워, 데이터베이스, 스토리지, 애플리케이션 같은 IT 리소스를 온디맨드로 제공하고 사용량 기반으로 과금하는 방식으로 설명한다.

## AWS를 쓰는 이유

백엔드 배포 관점에서 AWS를 쓰는 이유는 다음과 같다.

| 이유                   | 설명                                                           |
| -------------------- | ------------------------------------------------------------ |
| 서버를 직접 살 필요가 없음      | EC2나 Lightsail 같은 가상 서버를 바로 만들 수 있다.                         |
| 필요할 때 키우거나 줄일 수 있음   | 테스트 서버는 작게, 운영 서버는 크게 시작할 수 있다.                              |
| 여러 관리형 서비스를 쓸 수 있음   | RDS, S3, ElastiCache 같은 서비스를 쓰면 DB/파일/Redis 운영 부담을 줄일 수 있다.  |
| 네트워크와 보안을 세밀하게 설정 가능 | VPC, Security Group, IAM으로 접근 범위를 제어한다.                      |
| 운영 자동화가 가능           | GitHub Actions, CodeDeploy, ECS, CloudFormation 등을 연결할 수 있다. |

단점도 있다.

| 단점 | 설명 |
|---|---|
| 처음 배울 것이 많음 | EC2, VPC, IAM, Security Group, RDS, S3 등 개념이 많다. |
| 비용 구조가 복잡할 수 있음 | 서버, DB, 저장소, 트래픽, 스냅샷, 고정 IP 등이 각각 과금될 수 있다. |
| 직접 관리 책임이 생김 | EC2/Lightsail에 Docker를 직접 올리면 OS 업데이트, 방화벽, 백업도 신경 써야 한다. |

## AWS의 큰 서비스 분류

하루업 백엔드 배포와 연결되는 핵심 분류만 보면 된다.

| 분류 | 대표 서비스 | 하루업과의 연결 |
|---|---|---|
| Compute | EC2, Lightsail, ECS, Lambda | Spring Boot API 서버 실행 |
| Database | RDS, Aurora | PostgreSQL 운영 |
| Cache | ElastiCache | Redis 운영 |
| Storage | S3, EBS, Lightsail Block Storage | 파일 업로드, 서버 디스크 |
| Networking | VPC, Security Group, Route 53, Load Balancer | 도메인, HTTPS, 방화벽, 외부 접근 |
| Monitoring | CloudWatch | 로그, 지표, 알람 |
| Security | IAM, Secrets Manager, Certificate Manager | 권한, 비밀값, SSL 인증서 |

## 기본 용어

### Region

Region은 AWS 데이터센터 묶음이 있는 지리적 지역이다.

예:

```text
ap-northeast-2 = 서울 리전
ap-northeast-1 = 도쿄 리전
us-east-1 = 미국 버지니아 북부 리전
```

한국 사용자가 많은 서비스라면 보통 서울 리전을 먼저 고려한다.

### Availability Zone

Availability Zone, 줄여서 AZ는 같은 Region 안에 있는 물리적으로 분리된 데이터센터 단위다.

운영 안정성을 높이려면 여러 AZ에 나눠 배포한다. 다만 하루업 초기 배포처럼 작게 시작하는 경우에는 하나의 서버에서 시작하고, 운영 규모가 커질 때 다중 AZ를 검토하는 편이 현실적이다.

### EC2

EC2는 AWS의 대표적인 가상 서버 서비스다.

쉽게 말하면:

```text
EC2 = AWS에서 빌리는 일반 가상 컴퓨터
```

장점:

- 사양 선택 폭이 넓다.
- 네트워크/보안/스토리지 설정이 자유롭다.
- Docker Compose, Nginx, PostgreSQL, Redis 등을 직접 설치할 수 있다.

단점:

- 자유로운 만큼 직접 관리할 것이 많다.
- 초보자에게는 VPC, 보안 그룹, 키페어, EBS 같은 개념이 부담될 수 있다.

자세한 EC2 계산기 입력값과 하루업 적용 기준은 [[Amazon EC2 개념 정리]] 참고.

### Lightsail

Lightsail은 AWS를 더 단순하게 시작할 수 있는 VPS 서비스다.

EC2보다 선택지는 적지만, 서버/스토리지/트래픽/고정 IP/DNS 같은 기능을 단순한 월 비용으로 시작할 수 있다.

하루업처럼 작은 백엔드를 Docker Compose로 직접 올릴 때는 EC2보다 Lightsail이 더 접근하기 쉽다.

자세한 내용은 [[Amazon Lightsail 개념 정리]] 참고.

### RDS

RDS는 관리형 데이터베이스 서비스다.

```text
직접 PostgreSQL 설치 = 서버 안에 DB를 직접 운영
RDS = AWS가 DB 서버 운영 일부를 대신 관리
```

장점:

- 백업, 복구, 패치, 모니터링을 더 쉽게 관리할 수 있다.
- 운영 DB 안정성이 좋아진다.
- PostgreSQL에서 pgvector 확장도 지원된다.

단점:

- Lightsail/EC2 한 서버에 DB를 같이 올리는 것보다 비용이 올라갈 수 있다.
- 초기 설정이 조금 더 복잡하다.

### S3

S3는 파일 저장소다.

하루업에서 파일 업로드가 운영 기능으로 중요해지면, 서버 로컬 `./uploads`에 저장하는 대신 S3로 옮기는 것이 더 안전하다.

왜냐하면 서버 안의 파일은 서버 교체/재배포/장애 시 관리가 까다롭고, S3는 파일 저장을 목적으로 만들어진 서비스이기 때문이다.

### ElastiCache

ElastiCache는 관리형 Redis/Memcached 서비스다.

하루업은 Redis를 refresh token, cache, rate limit에 사용할 수 있으므로 운영 단계에서는 ElastiCache를 검토할 수 있다.

다만 초기에는 비용을 줄이기 위해 Lightsail/EC2 안에 Redis 컨테이너를 같이 띄울 수 있다.

### VPC

VPC는 AWS 안에서 만드는 사설 네트워크다.

쉽게 말하면:

```text
VPC = 내 AWS 리소스들이 들어가는 가상의 네트워크 공간
```

EC2, RDS, Redis 같은 리소스가 이 네트워크 안에 배치되고, 어떤 포트를 외부에 열지 Security Group으로 제한한다.

### Security Group

Security Group은 AWS 서버의 방화벽 규칙이다.

예:

```text
22  -> 내 IP만 허용
80  -> 전체 허용
443 -> 전체 허용
5432 -> 외부 차단
6379 -> 외부 차단
```

하루업에서는 PostgreSQL과 Redis를 외부에 열면 안 된다. 앱 서버 또는 내부 네트워크에서만 접근하도록 해야 한다.

### IAM

IAM은 AWS 권한 관리 시스템이다.

누가 어떤 AWS 리소스를 만들고, 삭제하고, 읽을 수 있는지를 관리한다.

운영에서는 루트 계정을 직접 쓰지 않고, 필요한 권한만 가진 IAM 사용자를 만들어야 한다.

### Route 53

Route 53은 AWS의 DNS 서비스다.

도메인을 API 서버에 연결할 때 사용한다.

예:

```text
api.haruup.com -> Lightsail/EC2 서버 IP
```

### CloudWatch

CloudWatch는 AWS의 로그/지표/알람 서비스다.

처음에는 Docker 로그를 직접 확인해도 되지만, 운영에서는 CloudWatch로 로그와 알람을 모으는 편이 좋다.

## AWS에서 하루업을 배포하는 경우

하루업 백엔드의 현재 구성:

```text
Spring Boot app
PostgreSQL + pgvector
Redis
파일 업로드
Clova API
Firebase Admin SDK
선택적 Prometheus/Grafana/Loki
```

최소 AWS 구성:

```text
Lightsail 또는 EC2 1대
  ├─ Docker Compose
  ├─ Spring Boot app
  ├─ PostgreSQL + pgvector
  ├─ Redis
  └─ Caddy 또는 Nginx
```

운영 안정성을 높인 구성:

```text
App Server: EC2 또는 Lightsail
Database: RDS PostgreSQL
Redis: ElastiCache
File: S3
Domain/DNS: Route 53
Logs/Metrics: CloudWatch
```

처음부터 운영 안정화 구성을 모두 쓰면 비용과 설정 부담이 커진다. 그래서 하루업은 테스트/초기 운영에서는 Lightsail 또는 EC2 한 대에 Docker Compose를 올리고, 사용자 트래픽과 운영 필요성이 생기면 RDS/S3/ElastiCache로 분리하는 흐름이 현실적이다.

## AWS와 Railway의 차이

| 기준           | Railway          | AWS                                  |
| ------------ | ---------------- | ------------------------------------ |
| 시작 난이도       | 낮음               | 높음                                   |
| GitHub 자동 배포 | 쉬움               | 직접 구성 필요                             |
| 서버 관리        | 플랫폼이 많이 해줌       | 직접 관리할 부분이 많음                        |
| 비용 예측        | 사용량에 따라 달라질 수 있음 | Lightsail은 예측 쉬움, EC2/RDS는 설계에 따라 다름 |
| 운영 자유도       | 제한 있음            | 매우 높음                                |
| 하루업 테스트 서버   | 적합               | 가능하지만 준비 시간이 더 듦                     |
| 하루업 운영 서버    | 가능               | 장기 운영 후보로 적합                         |

## 하루업 관점 추천

현재 흐름:

```text
1차 테스트: Railway Hobby
운영 전 검토: AWS Lightsail/EC2 또는 Railway 유지
운영 안정화: RDS/S3/ElastiCache 분리 검토
```

AWS로 간다면 우선순위는 다음과 같다.

1. Lightsail로 Docker Compose 배포를 먼저 이해한다.
2. EC2는 Lightsail보다 자유도가 필요할 때 검토한다.
3. DB 백업과 파일 업로드가 중요해지면 RDS/S3로 분리한다.
4. Redis 장애가 서비스에 큰 영향을 주면 ElastiCache를 검토한다.
5. 사용자 트래픽이 늘면 Load Balancer와 다중 서버 구성을 검토한다.

## 실수하기 쉬운 부분

- 서버를 만들었는데 보안 그룹에서 80/443 포트를 열지 않음
- PostgreSQL 5432 또는 Redis 6379를 외부에 열어버림
- 루트 계정 Access Key를 사용함
- DB 백업 없이 운영 시작
- 서버 안 `./uploads`에 파일을 저장해두고 재배포/교체 때 잃어버림
- JVM 메모리 제한 없이 2GB 서버에 Spring Boot + DB + Redis를 같이 띄움
- 도메인/HTTPS 없이 앱에 임시 IP만 공유함

## 공식 문서 참고

- [What is cloud computing? - AWS](https://docs.aws.amazon.com/whitepapers/latest/aws-overview/what-is-cloud-computing.html)
- [Overview of Amazon Web Services](https://docs.aws.amazon.com/whitepapers/latest/aws-overview/introduction.html)
- [AWS Regions and Availability Zones](https://docs.aws.amazon.com/global-infrastructure/latest/regions/aws-regions-availability-zones.html)
- [What is Amazon EC2?](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html)
- [AWS Shared Responsibility Model](https://docs.aws.amazon.com/whitepapers/latest/aws-risk-and-compliance/aws-risk-and-compliance.pdf)
- [Amazon RDS PostgreSQL extension versions](https://docs.aws.amazon.com/AmazonRDS/latest/PostgreSQLReleaseNotes/postgresql-extensions.html)
