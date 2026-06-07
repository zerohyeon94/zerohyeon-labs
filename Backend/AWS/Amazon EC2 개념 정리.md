# Amazon EC2 개념 정리

> 분야: Backend / Infra
> 관련 개념: [[AWS 개념 정리]] / [[Amazon Lightsail 개념 정리]]
> 관련 프로젝트: [[개발 Project/Haru Up/2026-06-06 백엔드 서버 업로드 검토 회의]]

## 한 줄 정의

Amazon EC2는 AWS에서 제공하는 범용 가상 서버 서비스다.

쉽게 말하면:

```text
EC2 = AWS에서 빌리는 일반 리눅스/윈도우 서버
```

Lightsail도 가상 서버지만, Lightsail은 쉬운 VPS 번들에 가깝고 EC2는 더 세밀하게 설정할 수 있는 본격적인 AWS 서버다.

## EC2로 할 수 있는 것

하루업 백엔드를 EC2에 올리면 다음처럼 구성할 수 있다.

```text
EC2 Instance
  ├─ Docker
  ├─ Docker Compose
  ├─ Spring Boot app
  ├─ PostgreSQL + pgvector
  ├─ Redis
  └─ Caddy 또는 Nginx
```

앱 흐름:

```text
iOS/Android App
  -> https://api.haruup.com
  -> Caddy/Nginx
  -> Spring Boot app
  -> PostgreSQL / Redis
  -> Clova / Firebase
```

이 구조는 Lightsail에서 하려던 것과 거의 같다. 차이는 서버를 만드는 방식, 네트워크 설정, 디스크/트래픽 비용 계산 방식이 더 세밀해진다는 점이다.

## EC2와 Lightsail의 핵심 차이

| 기준 | Lightsail | EC2 |
|---|---|---|
| 성격 | 단순 VPS 번들 | 범용 클라우드 서버 |
| 시작 난이도 | 낮음 | 높음 |
| 비용 계산 | 월 번들에 CPU/RAM/SSD/전송량이 묶임 | 인스턴스, EBS, 스냅샷, 데이터 전송이 따로 계산됨 |
| 네트워크 | 단순 방화벽 UI | VPC, Subnet, Security Group, Elastic IP 등 세밀한 설정 |
| 디스크 | 번들 SSD 포함 | EBS 볼륨을 별도로 선택 |
| 확장 | 제한적 | Auto Scaling, Load Balancer, RDS, ElastiCache와 자연스럽게 확장 |
| 운영 자유도 | 중간 | 높음 |
| 학습 난이도 | 낮음 | 높음 |
| 하루업 초기 운영 | 적합 | 가능하지만 설정 부담 큼 |
| 하루업 장기 운영 | 가능 | 더 적합 |

정리:

```text
Lightsail = 작고 단순하게 시작하기 좋음
EC2 = AWS식 운영 구조를 제대로 잡기 좋음
```

## 하루업에는 무엇이 더 좋은가

### 지금 단계

현재 하루업은 테스트 서버를 빠르게 만들고, 한 달 뒤 운영 서버를 검토하는 단계다.

지금 우선순위:

```text
1. 팀원이 쓸 base URL 빠르게 확보
2. GitHub 배포 흐름 안정화
3. DB/Redis/환경변수 연결 검증
4. 운영 전에 AWS 전환 여부 판단
```

이 기준에서는 Railway Hobby 또는 Lightsail이 EC2보다 편하다.

### AWS로 바로 간다면

AWS 안에서 바로 운영 후보를 만들고 싶다면 두 선택지가 있다.

| 선택 | 추천 상황 |
|---|---|
| Lightsail | Docker Compose로 작게 시작하고 싶을 때, 서버 관리 부담을 줄이고 싶을 때 |
| EC2 | VPC, Security Group, RDS, S3, ElastiCache, Load Balancer까지 장기 운영 구조를 잡고 싶을 때 |

하루업 기준 추천:

```text
테스트/초기 운영: Lightsail 2GB~4GB
AWS 장기 운영 학습/확장: EC2 t4g.medium 이상
DB/파일 안정화: EC2 + RDS + S3 + ElastiCache
```

현재 판단:

- 지금 바로 AWS를 쓴다면 Lightsail이 더 단순하다.
- EC2는 운영 구조를 더 제대로 가져가고 싶을 때 좋다.
- 한 달 뒤 실제 사용자가 붙는 운영 배포를 준비할 때는 EC2도 충분히 검토할 만하다.

## EC2 인스턴스 타입 선택

하루업은 Spring Boot + PostgreSQL + Redis를 한 서버에 같이 올리는 all-in-one 구조를 먼저 생각하고 있다.

### ARM 기반 추천: `t4g`

`t4g`는 AWS Graviton2 ARM 프로세서를 사용하는 범용 burstable 인스턴스다. AWS 공식 문서 기준 `t4g.small`은 2 vCPU/2 GiB, `t4g.medium`은 2 vCPU/4 GiB다.

| 인스턴스 | vCPU | 메모리 | 하루업 판단 |
|---|---:|---:|---|
| `t4g.small` | 2 | 2 GiB | 테스트/최소 구성 |
| `t4g.medium` | 2 | 4 GiB | 운영 초반 권장 |
| `t4g.large` | 2 | 8 GiB | 모니터링까지 같은 서버에 올릴 때 |

하루업 Docker 이미지들은 대체로 ARM64에서 동작 가능한 공식 이미지 기반이다.

- `gradle:8.11.1-jdk21`
- `eclipse-temurin:21-jre-jammy`
- `postgres:17.2`
- `redis:7.4-alpine`
- `grafana/loki`
- `prom/prometheus`

그래도 실제 운영 전에는 ARM 서버에서 Docker build/run 검증을 해야 한다.

### x86 대안: `t3`

만약 ARM 호환성이 걱정되면 `t3.small` 또는 `t3.medium`으로 계산한다.

장점:

- x86 호환성이 더 익숙하다.
- 오래된 라이브러리나 바이너리 의존성이 있을 때 안전하다.

단점:

- 같은 성능 기준에서 `t4g`보다 비용 효율이 떨어질 수 있다.

하루업은 특수 네이티브 라이브러리를 많이 쓰는 구조는 아니라서 우선 `t4g.medium`을 후보로 잡아도 괜찮아 보인다.

## AWS Pricing Calculator에서 EC2 추가 방법

스크린샷의 `서비스 추가` 화면에서는 아래 순서로 진행한다.

### 1. 서비스 검색

검색창에 입력:

```text
Amazon EC2
```

그 다음 `Amazon EC2` 카드의 `구성` 버튼을 누른다.

주의:

- `Amazon ECS`가 아니다. ECS는 컨테이너 오케스트레이션 서비스다.
- `AWS Elastic Beanstalk`도 아니다. 앱 배포 플랫폼에 가깝다.
- `Amazon Lightsail`도 아니다. EC2와 별도 서비스다.

### 2. 기본 위치

입력:

```text
Region: Asia Pacific (Seoul)
```

서울 사용자가 많다면 서울 리전이 자연스럽다.

### 3. EC2 인스턴스 설정

하루업 최소 계산:

```text
Operating system: Linux
Tenancy: Shared Instances
Pricing model: On-Demand
Workload: Constant usage
Usage: 730 Hours/Month
Number of instances: 1
Instance type: t4g.small
```

하루업 운영 초반 계산:

```text
Operating system: Linux
Tenancy: Shared Instances
Pricing model: On-Demand
Workload: Constant usage
Usage: 730 Hours/Month
Number of instances: 1
Instance type: t4g.medium
```

모니터링 포함 계산:

```text
Operating system: Linux
Tenancy: Shared Instances
Pricing model: On-Demand
Workload: Constant usage
Usage: 730 Hours/Month
Number of instances: 1
Instance type: t4g.large
```

처음 한 달 운영 전 검증이면 On-Demand가 맞다. Reserved Instance나 Savings Plans는 1년 이상 쓸 확신이 있을 때 검토한다.

### 4. EBS 스토리지 설정

EC2는 Lightsail과 달리 서버 디스크가 번들에 포함되지 않는다. EBS를 따로 잡아야 한다.

하루업 최소:

```text
Storage type: General Purpose SSD (gp3)
Volume size: 30GB 또는 60GB
Number of volumes: 1
```

추천:

| 용도 | EBS 용량 |
|---|---:|
| 테스트/최소 | 30GB |
| 초기 운영 all-in-one | 60GB |
| DB와 업로드 파일이 늘어날 가능성 있음 | 80GB 이상 |

하루업은 PostgreSQL 데이터와 업로드 파일이 서버 내부에 쌓일 수 있으므로 60GB부터 계산하는 편이 현실적이다.

### 5. 데이터 전송

처음 계산에서는 데이터 전송을 보수적으로 작게 잡는다.

```text
Data transfer out to internet: 50GB/month 또는 100GB/month
```

팀 테스트 단계라면 50GB로 충분할 가능성이 높다. 실제 사용자가 붙으면 앱 다운로드/이미지/파일 업로드/응답 크기에 따라 달라진다.

### 6. 추가 서비스는 언제 넣는가

all-in-one EC2 계산에서는 처음에 `Amazon EC2`만 추가해도 된다.

다만 운영 안정화 구성으로 바꾸면 아래 서비스를 별도 추가한다.

| 서비스 | 추가 시점 |
|---|---|
| `Amazon RDS for PostgreSQL` | DB를 EC2 내부 PostgreSQL이 아니라 관리형 DB로 분리할 때 |
| `Amazon ElastiCache` | Redis를 EC2 내부 컨테이너가 아니라 관리형 Redis로 분리할 때 |
| `Amazon S3` | 파일 업로드를 서버 디스크가 아니라 S3에 저장할 때 |
| `Amazon CloudWatch` | 로그/메트릭/알람 비용까지 계산할 때 |
| `Elastic Load Balancing` | 앱 서버를 2대 이상으로 늘릴 때 |
| `Route 53` | 도메인 DNS 비용까지 계산할 때 |

## 하루업 EC2 계산 시나리오

### 시나리오 A: EC2 all-in-one 최소

목적:

- AWS에서 하루업을 가장 단순하게 직접 운영
- Spring Boot, PostgreSQL, Redis를 한 서버에 Docker Compose로 배포

계산기 입력:

```text
Service: Amazon EC2
Region: Asia Pacific (Seoul)
OS: Linux
Tenancy: Shared
Pricing model: On-Demand
Instance: t4g.small
Instances: 1
Usage: 730 Hours/Month
EBS: gp3 30GB~60GB
Data transfer out: 50GB/month
```

판단:

- Lightsail 2GB와 비슷한 최소 후보.
- EC2는 EBS/트래픽을 별도로 계산하므로 Lightsail보다 비용이 직관적이지 않다.
- 운영 학습에는 좋지만 빠른 배포에는 Lightsail보다 번거롭다.

### 시나리오 B: EC2 all-in-one 운영 초반

계산기 입력:

```text
Service: Amazon EC2
Region: Asia Pacific (Seoul)
OS: Linux
Tenancy: Shared
Pricing model: On-Demand
Instance: t4g.medium
Instances: 1
Usage: 730 Hours/Month
EBS: gp3 60GB
Data transfer out: 100GB/month
```

판단:

- 하루업 운영 초반에 더 현실적인 EC2 후보.
- Spring Boot + PostgreSQL + Redis + 배치를 한 서버에 올리려면 4GB가 안정적이다.
- 이 구성에서도 Prometheus/Grafana/Loki까지 올리면 메모리가 빡빡할 수 있다.

### 시나리오 C: EC2 + 관리형 서비스

계산기에 추가할 서비스:

```text
Amazon EC2
Amazon RDS for PostgreSQL
Amazon ElastiCache
Amazon S3
Amazon CloudWatch
```

구성:

```text
EC2: Spring Boot app only
RDS: PostgreSQL + pgvector
ElastiCache: Redis
S3: uploads
CloudWatch: logs/metrics
```

판단:

- 운영 안정성은 가장 좋다.
- 비용은 확실히 올라간다.
- 사용자 수가 늘고 장애 대응/백업이 중요해질 때 검토한다.

## EC2를 선택할 때 추가로 신경 쓸 것

### Security Group

외부 공개:

```text
22  SSH, 내 IP만 허용
80  HTTP
443 HTTPS
```

외부 비공개:

```text
8080 Spring Boot
5432 PostgreSQL
6379 Redis
9090 Prometheus
3000 Grafana
3100 Loki
```

### Elastic IP

EC2 public IP는 인스턴스를 중지/시작하면서 바뀔 수 있다. 운영 base URL을 고정하려면 Elastic IP 또는 Load Balancer가 필요하다.

주의:

- Elastic IP도 조건에 따라 비용이 발생할 수 있다.
- 운영에서는 도메인과 함께 관리해야 한다.

### EBS Snapshot

EBS Snapshot은 EC2 디스크 백업이다.

PostgreSQL을 EC2 안에 같이 둘 경우, snapshot만 믿기보다는 `pg_dump` 같은 DB 백업도 별도로 준비해야 한다.

### IAM Role

EC2에서 S3, CloudWatch, Secrets Manager 등에 접근하려면 Access Key를 서버에 직접 저장하기보다 IAM Role을 붙이는 것이 더 안전하다.

## EC2 vs Lightsail 하루업 결론

| 질문 | 추천 |
|---|---|
| 빠르게 AWS에 Docker Compose를 올리고 싶다 | Lightsail |
| 가격을 단순하게 예측하고 싶다 | Lightsail |
| AWS 운영 구조를 제대로 배우고 싶다 | EC2 |
| RDS/S3/ElastiCache와 자연스럽게 확장하고 싶다 | EC2 |
| 한 달 뒤 초기 운영을 무난하게 시작하고 싶다 | Lightsail 4GB 또는 EC2 t4g.medium |
| 장기적으로 사용자 증가와 운영 안정성을 생각한다 | EC2 + RDS + S3 + ElastiCache |

현재 하루업 추천:

```text
지금 테스트: Railway Hobby
AWS 최소 운영 후보: Lightsail 4GB
AWS 확장 운영 후보: EC2 t4g.medium + gp3 60GB
운영 안정화 후보: EC2 + RDS + ElastiCache + S3
```

즉, EC2가 더 “정석 AWS 운영”에 가깝고, Lightsail은 더 “간단한 AWS VPS 운영”에 가깝다. 하루업이 지금 바로 AWS로 간다면 Lightsail이 더 쉽고, 운영 경험과 확장성까지 같이 가져가려면 EC2가 더 좋다.

## 공식 문서 참고

- [Getting started - AWS Pricing Calculator](https://docs.aws.amazon.com/pricing-calculator/latest/userguide/getting-started.html)
- [Amazon EC2 instance types](https://docs.aws.amazon.com/ec2/latest/instancetypes/gp.html)
- [Amazon EC2 T4g instances](https://aws.amazon.com/ec2/instance-types/t4/)
- [Amazon EC2 On-Demand Pricing](https://aws.amazon.com/ec2/pricing/on-demand/)
- [Amazon EBS Pricing](https://aws.amazon.com/ebs/pricing/)

