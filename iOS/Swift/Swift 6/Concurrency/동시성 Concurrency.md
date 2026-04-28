Swift 6에서는 **Concurrency(동시성)**에 대해 훨씬 더 엄격해졌기 때문에, 기존에는 문제없던 코드가 **Swift 6에서는 컴파일 에러**를 일으킬 수 있습니다.

---

## ✅ 에러 원인 요약

`Static property 'sampleRateAvg' is not concurrency-safe because it is nonisolated global shared mutable state`

### 의미:

- `sampleRateAvg`라는 `static` 프로퍼티가 **전역(shared mutable state)** 으로 간주되는데,
- 이것이 여러 쓰레드에서 **동시에 접근될 수 있음에도 안전하지 않다(concurrency-safe하지 않다)**는 경고입니다.
- Swift 6의 **Strict Concurrency Checking**으로 인해 이 에러가 발생한 것입니다.
---
## 🔍 왜 Swift 5에서는 괜찮았는데 Swift 6에서는 안 될까?
Swift 5에서는 동시성 체크가 제한적이었고, `@unchecked Sendable`, `@MainActor` 등이 **선택적**이었습니다.  
Swift 6에서는 `-enable-upcoming-feature StrictConcurrency=complete`가 자동으로 활성화되면서,  
동시성 문제 가능성이 있는 **모든 전역 mutable 상태를 제한**합니다.

---

## 💥 예시 코드 (문제 상황)

swift

복사편집

`class AudioAnalyzer {     static var sampleRateAvg: Double = 0.0 }`

이 경우, `sampleRateAvg`는 여러 스레드에서 동시에 접근될 수 있으므로 Swift 6에서는 오류가 납니다.

---

## 🛠 해결 방법 3가지

### 1. `@MainActor` 사용 – 메인 스레드에서만 접근

swift

복사편집

`@MainActor class AudioAnalyzer {     static var sampleRateAvg: Double = 0.0 }`

- UI 관련된 값이라면, `@MainActor`를 붙여서 **항상 메인 스레드에서만 접근**하도록 제한하면 됩니다.
    

---

### 2. `actor` 사용 – 동시성 안전하게 공유

swift

복사편집

`actor AudioAnalyzer {     static var shared = AudioAnalyzer()     var sampleRateAvg: Double = 0.0 }`

- `actor`는 내부 상태를 자동으로 동기화해주므로 동시성 문제가 사라집니다.
    
- 사용할 때는 `await` 키워드와 함께 접근해야 합니다:
    

swift

복사편집

`let avg = await AudioAnalyzer.shared.sampleRateAvg`

---

### 3. `DispatchQueue`나 `NSLock` 등으로 수동 동기화 (비추천, Swift 6 스타일 아님)

swift

복사편집

`private static var lock = NSLock() private static var _sampleRateAvg: Double = 0.0 static var sampleRateAvg: Double {     get {         lock.lock()         defer { lock.unlock() }         return _sampleRateAvg     }     set {         lock.lock()         _sampleRateAvg = newValue         lock.unlock()     } }`

- Swift 6에서는 이런 방식보다 `actor`나 `@MainActor`를 권장합니다.
    

---

## 📝 정리

|해결 방법|설명|사용 예|
|---|---|---|
|`@MainActor`|메인 쓰레드 한정 접근|UI 관련 값일 때|
|`actor`|스레드 안전한 공유 객체|비동기 환경|
|`NSLock`, `DispatchQueue`|수동 락 처리|레거시 대응용 (권장 X)|

---

> [[iOS 학습 인덱스]]