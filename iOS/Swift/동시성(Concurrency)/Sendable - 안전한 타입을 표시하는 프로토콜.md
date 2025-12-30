## 1. 한 줄 정의

> **Sendable = 여러 스레드 / 여러 actor 사이를 왔다 갔다 해도 안전한 타입이라는 것을 표시하는 프로토콜**

즉, 이 타입의 값을 다른 actor(= 스레드 비슷한 개념)에게 “보내도(send)” 데이터가 꼬이거나, 경쟁 상태(race condition)가 나지 않는 타입

**이름도 “보낼 수 있는(Send-able)”** 입니다.

---

## 2. 왜 이런 게 생겼냐? (배경)

Swift 5.5부터 `async/await`, `actor` 가 생기면서:

- 코드가 여러 actor(= 보호된 실행 컨텍스트)에서 동시에 돌 수 있고
    
- 한 actor에서 다른 actor로 **값을 전달**하는 일이 많아졌어요.

이때 컴파일러가 묻는 거죠:

> “이 타입, 여러 actor 사이에 막 넘겨도 안전한 거 맞아? 아니면 한 actor 안에서만 써야 하는 거야?”

이걸 **컴파일 타임에 체크**하기 위해 등장한 게 `Sendable` 입니다.

---

## 3. 어떤 타입이 Sendable일까?

보통 이런 타입들은 **자동으로 Sendable로 취급**되거나, 쉽게 만들 수 있어요:

1. **값 타입(struct, enum)** 이면서,
    
2. 내부 프로퍼티들도 전부 Sendable 인 타입들
    
    - `Int`, `String`, `Bool`, `Double`, `[Sendable]`, `Dictionary<String, Sendable>` 등

예:

```swift
struct User: Sendable {
    let id: Int
    let name: String
}
```

사실 이렇게 안 써도,

```swift
struct User {
    let id: Int
    let name: String
}
```

처럼 생긴 단순 struct는  
컴파일러가 **암시적으로 Sendable로 취급**해줘요 (조건만 맞으면).

반대로:

- `class` 처럼 **reference 타입**은  
    여러 스레드에서 동시에 수정되면 위험할 수 있어서,
    
    - 직접 `Sendable` 붙이려면 조심해야 함
        
    - 대부분 `actor` 나 `isolated` 로 접근을 제한하는 식으로 설계

---

## 4. Sendable이 언제 튀어나오냐? (에러 상황)

요런 에러 많이 봐요:

- `Type 'X' does not conform to 'Sendable'`
    
- `Main actor-isolated class 'X' cannot conform to 'Sendable'`
    
- `Main actor-isolated conformance of 'Foo' to 'Encodable' cannot satisfy conformance requirement for a 'Sendable' type parameter`

이건 다 이런 의미예요 👇

> “이 타입을 **다른 actor로 보내야 하는 상황**인데, 컴파일러 입장에서 봤을 때 **안전한 Sendable 타입인지 확신을 못 하겠다**”

예를 들어:

- `Task { ... }` 블록 안에서 캡처되는 값
    
- `@Sendable` 클로저 파라미터
    
- Concurrency-safe 라이브러리(요즘 Alamofire 제네릭)에서 `T: Sendable` 을 요구할 때

이때 들어가는 타입들이 Sendable 해야, 컴파일러가 “오케이, 이거 concurrency-safe” 라고 인정해줍니다.

---

## 5. 그럼 “Sendable을 꼭 써야 하나요?”

정리하면:

- **동시성(actors, Task, async/await)을 안 쓰는 코드**라면 → Sendable을 전혀 몰라도 앱은 잘 돌아갑니다.
    
- 하지만 요즘:
    
    - Swift 동시성을 쓰는 코드
        
    - 서드파티 라이브러리가 Concurrency를 고려해서 설계된 경우(Alamofire 최신 버전 등)에서는 제네릭에 `Sendable` 제약이 자주 붙어요.

그래서:

- **DTO, 모델 같은 “순수 데이터 struct”** 들은 → `Sendable` 로 만드는 게 베스트 프랙티스에 가깝고
    
- `Sendable` 에러가 뜬다는 건  → “이 타입이 여러 actor/스레드 사이를 왔다 갔다 할 건데, 구조를 한 번 점검해봐라”라는 컴파일러의 힌트라고 보면 됩니다.

---

## 6. 아주 짧게 요약

- `Sendable` = “**스레드/actor 사이에 안전하게 보낼 수 있는 타입**” 마커
    
- 주로:
    
    - `struct`, `enum` + 값 타입 프로퍼티 → 자동으로 Sendable OK
        
    - Concurrency-aware 코드/라이브러리에서 제네릭 제약으로 자주 등장
        
- DTO처럼 서버 통신용 값 타입 모델들은 → `Encodable/Decodable & Sendable` 로 두는 게 깔끔한 패턴 💡
    

이제 “Sendable 에러”가 뜨면

> “아, 이 타입이 여러 actor 사이를 오갈 건데, 안전한 값 타입인지/메인 액터에 묶여 있진 않은지 확인해보라는 거구나”  