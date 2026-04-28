## 1. DTO가 뭐냐?

**DTO = Data Transfer Object** - **“데이터를 전송하기 위한 객체”** 라는 뜻이에요.

조금 더 구체적으로:

> **서버 ↔ 앱 사이에서 오가는 JSON 데이터를 코드로 표현한, ‘옮기기 전용’ 데이터 모델**

즉,
- 이 DTO는 **네트워크 전송용 포맷에 맞춰진 구조체/클래스**
    
- 보통 서버의 API 스펙(JSON 키, 타입)에 **딱 맞게** 설계됨

Swift에서 보통 이런 느낌이 DTO:

```swift
struct LoginResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let userName: String
}
```

여기서 포인트는:

- 이 친구의 역할은 **“받은 JSON을 Swift 코드로 옮기는 용도”**
    
- 앱 내부 비즈니스 로직, 화면 표현, 도메인 규칙을 이 안에 섞지 않는 게 깔끔한 설계

---

## 2. DTO랑 헷갈리기 쉬운 친구들

보통 iOS 클린 아키텍처/레이어드 아키텍처를 이야기하면:

- **DTO**:
    
    - 서버 통신용 데이터 모델
        
    - API 스펙에 1:1 대응
        
    - `snake_case` → `camelCase` 매핑, 옵셔널 처리 등 **전송 포맷 맞추는 역할**
        
- **Domain Model (Entity, Model)**:
    
    - 앱 내부에서 쓰는 **비즈니스 모델**
        
    - 의미적으로 더 깔끔하게 정리된 형태
        
    - 화면/로직에서 쓰기 좋은 타입
        
- **ViewModel에서 쓰는 View용 Model (UI Model)**:
    
    - 화면에 보여주기 좋게 가공된 데이터
        
    - 예: `formattedDate`, `isEnabled`, `buttonTitle` 등

그래서 흔히 이런 흐름으로 갑니다:

```text
서버 JSON  →  DTO  →  Domain Model  →  ViewModel / View
```

Swift 코드로 표현하면 예를 들어:

```swift
struct UserDTO: Decodable {
    let id: Int
    let nickname: String
    let created_at: String
}

struct User {
    let id: Int
    let name: String
    let createdAt: Date
}

extension UserDTO {
    func toDomain() -> User {
        return User(
            id: id,
            name: nickname,
            createdAt: DateFormatter.iso8601.date(from: created_at) ?? Date()
        )
    }
}
```

- `UserDTO` ⇒ **DTO (서버 형식 맞추는 애)**
    
- `User` ⇒ **도메인 모델 (앱 내부에서 쓰기 편하게 바꾼 애)**

---

## 3. “이와 비슷한 개념으로” 생각해보면

DTO랑 비슷하게 들리는 용어들이 몇 개 있어요:

1. **VO (Value Object)**
    
    - “값” 그 자체를 표현하는 객체
        
    - 보통 **불변(immutable)** + **동등성은 값 기준으로 판단**
        
    - DTO는 “전송용”, VO는 “비즈니스에서의 값 개념” 쪽에 더 가까움
        
2. **Entity**
    
    - 고유한 ID를 가진 도메인 객체 (예: User, Post, Order 등)
        
    - 보통 DB / 도메인 레벨에서 이야기할 때 많이 등장
        
    - DTO는 네트워크 / 전송용 포맷에 더 초점
        
3. **Request / Response Model**
    
    - iOS에서 네이밍으로 보통 이렇게 나누기도 함:
        
        - `LoginRequestDTO`
            
        - `LoginResponseDTO`
            

즉, 너가 지금 쓰는 “서버 통신용 Model”을:

> **Request/Response DTO (전송용 모델)**로 생각하면 딱 이해하기 좋고, 설계상 역할도 명확해져.

---

## 4. 정리해서 한 문장으로 말하면

- **DTO**는:
    
    > “서버랑 데이터를 주고받기 위해, JSON 형식에 맞춰 설계한 전송 전용 데이터 모델”
    
- 비슷한 개념으로는:
    
    - 도메인 내부에서 의미를 가지는 **Domain Model / Entity**
        
    - 전송 대신 “값 그 자체”에 집중하는 **Value Object(VO)**같은 친구들이 있고,
        
- 이들을 잘 나누는 게:
    
    - 서버 스펙 바뀌어도 도메인/화면 부분 영향 최소화
        
    - 테스트/유지보수 쉬운 코드로 이어지는 포인트입니다.

---

> [[iOS 학습 인덱스]]