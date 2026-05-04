# Kotlin Spring Boot 기초 구조

> 태그: #Kotlin #SpringBoot #Backend #하루업
> 목적: 하루업(haru-up-back-end) 코드베이스를 읽고 파악하기 위한 최소 맥락

---

## 프로젝트 기본 구조

```
src/main/kotlin/com/example/
├── controller/     # HTTP 요청 처리 (라우터)
├── service/        # 비즈니스 로직
├── repository/     # DB 접근 (JPA)
├── model/ (또는 domain/)  # 데이터 클래스 (Entity, DTO)
└── Application.kt  # 진입점 (main 함수)
```

> iOS 대응: Controller = API Route, Service = UseCase, Repository = DataSource/CoreData

---

## 핵심 어노테이션 읽는 법

| 어노테이션 | 의미 | iOS 대응 |
|-----------|------|---------|
| `@RestController` | HTTP 응답을 JSON으로 반환하는 컨트롤러 | Router + Codable |
| `@Service` | 비즈니스 로직 담당 클래스 | UseCase / Interactor |
| `@Repository` | DB 접근 클래스 | DataSource / CoreData |
| `@GetMapping("/path")` | GET 요청 처리 | URLSession GET |
| `@PostMapping("/path")` | POST 요청 처리 | URLSession POST |
| `@RequestBody` | 요청 본문을 Kotlin 객체로 변환 | `Decodable` |
| `@PathVariable` | URL 경로의 변수 추출 `/users/{id}` | Path param |
| `@Autowired` / 생성자 주입 | 의존성 주입 (DI) | `@Injected` / 생성자 주입 |

---

## 로컬 실행 방법

```bash
# Gradle (빌드 도구)
./gradlew bootRun

# 또는 IntelliJ에서 Application.kt → 실행 버튼
```

기본 포트: `http://localhost:8080`

---

## haru-up-back-end 파악 순서

1. `build.gradle.kts` — 의존성 확인 (Spring Boot 버전, JPA, DB 종류)
2. `Application.kt` — 진입점 확인
3. `controller/` 폴더 — API 엔드포인트 목록 파악
4. `mission_chatbot` 관련 파일 검색 — 브랜치: `mission_chatbot_test`
5. `application.yml` 또는 `application.properties` — DB 연결 설정 확인

---

## 로컬 서버 띄우기 전 체크리스트

- [ ] Java 17+ 설치 확인: `java -version`
- [ ] DB 설정 확인 (H2 인메모리? 외부 PostgreSQL?)
- [ ] 환경 변수 또는 `.env` 파일 필요 여부 확인
- [ ] `./gradlew bootRun` 실행 후 `Started Application` 로그 확인

---

## 연결 개념

- [[백엔드 학습 인덱스]] — 전체 백엔드 학습 맥락
- 하루업 mission_chatbot: Claude/GPT API 연동 가능성 → AI 서버 구조와 연결
