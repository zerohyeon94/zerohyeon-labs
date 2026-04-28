Swift 6으로 넘어가면서 개발자가 반드시 **고려해야 할 변경사항**이 여러 가지 있습니다.  
특히 **동시성(concurrency)**, **Sendable**, **access control**, **opaque types**, 그리고 일부 **기존 동작의 변화** 등입니다.

---

## ✅ Swift 6에서 고려해야 할 주요 사항 정리

---

### 1. **엄격한 Concurrency 체크 (Strict Concurrency Checking)**

#### ✅ 변화

- Swift 6에서는 `StrictConcurrency=complete`가 **기본적으로 활성화**됩니다.
    
- 즉, **nonisolated shared mutable state**에 대한 접근은 **컴파일 타임에서 오류**를 냅니다.
    
- `Sendable`, `@MainActor`, `actor`, `@globalActor`에 대한 이해가 필수입니다.
    

#### ✅ 예시

swift

복사편집

`class MyClass {     static var sharedValue = 0 // ❌ Swift 6에서 에러 }`

#### ✅ 해결 방법

- `@MainActor`를 붙이거나
    
- `actor`로 만들거나
    
- `Sendable`을 명시적으로 구현하거나
    
- 값 타입을 thread-safe하게 유지
    

---

### 2. **모든 타입은 `Sendable`을 고려해야 함**

#### ✅ 변화

- `Sendable` 프로토콜은 동시성 환경에서 타입이 **안전하게 전송 가능한지** 명시합니다.
    
- Swift 6에서는 `Sendable`을 구현하지 않은 참조 타입은 **동시성 전송 불가**로 간주되어 경고 또는 오류가 납니다.
    

#### ✅ 해결 방법

- `final class`에 `@unchecked Sendable`을 붙이거나
    
- 값을 actor 내에서만 접근하거나
    
- 구조체로 만들고 `Sendable` 준수하게 변경
    

---

### 3. **`nonisolated` 키워드 사용 강화**

#### ✅ 변화

- `nonisolated`는 actor나 @MainActor로부터 분리된 실행을 허용하는 키워드입니다.
    
- Swift 6에서는 actor 내부에서 정의된 메서드라도 `nonisolated`이 없으면 **await 없이 접근 불가**
    

---

### 4. **opaque result types (`some`)의 변화**

#### ✅ 변화

- Swift 6에서는 `some` 반환 타입이 좀 더 **명확한 타입 추론을 요구**합니다.
    
- 컴파일러가 추론을 실패하면 명시적으로 타입을 지정해야 합니다.
    

---

### 5. **C 코드나 Objective-C와의 상호운용성 제한 강화**

#### ✅ 변화

- Swift 6부터는 `@Sendable`이 붙지 않은 C/Obj-C 콜백을 사용할 때 더 엄격한 제한이 생길 수 있습니다.
    
- 특히 `DispatchQueue`, `NotificationCenter` 관련 코드는 검토 필요
    

---

### 6. **Access Control 및 내부 모듈 관리 강화**

- `internal`, `@usableFromInline`, `@_spi`, `@inlinable`의 의미가 더 중요해집니다.
    
- 모듈 간 사용 범위, 인라인화 등에 대해 더 정확히 명시할 필요가 있습니다.
    

---

### 7. **기존 코드와 호환되지 않는 잠재적 변경점들**

- `if let`, `guard let`의 `shadowing` 제한이 생길 수 있음
    
- 함수 signature의 `@escaping`, `@Sendable` 필요성 증가
    
- `Task`, `async let`의 정적 검사 강화
    

---

## ✅ Swift 6 대응 전략

|대응 항목|설명|
|---|---|
|`Sendable` 명확히 하기|구조체는 기본적으로 Sendable / 클래스는 수동 확인 필요|
|`actor`, `@MainActor` 도입|글로벌 변수, 싱글톤, 뷰모델 등은 actor 또는 MainActor 사용 고려|
|기존 static 변수 검사|`static var`, 전역 변수의 동시성 안전 여부 재검토|
|3rd Party 라이브러리 확인|Swift 6 대응 여부 확인 (특히 RxSwift, Alamofire 등)|
|테스트 강화|동시성 문제는 테스트에서 잡기 어려우므로 병렬 테스트 구조 도입 고려|

---

## ✨ 마이그레이션 팁

1. **Xcode → Build Settings → Strict Concurrency Checking**을  
    우선 `targeted`으로 설정하고 문제를 순차적으로 해결하세요.
    
2. 점진적 마이그레이션을 위해 `@preconcurrency`를 활용하면 Swift 5 코드와의 호환을 유지할 수 있습니다.
    

swift

복사편집

`@preconcurrency import MyOldFramework`

---

## 📌 참고 문서

- Swift 공식 블로그 - Swift 6 Concurrency Model
- https://www.swift.org/blog/swift-6.1-released/
    
- [Apple WWDC - Meet Swift Concurrency](https://developer.apple.com/videos/play/wwdc2021/10134/)

---

> [[iOS 학습 인덱스]]