Swift에서 사용하는 `.formatted()`는 **숫자나 날짜 등의 값을 사람이 읽기 좋은 문자열로 변환**해주는 **Swift의 Foundation API 기능**입니다.

---

## ✅ `.formatted()`란?

`.formatted()`는 Swift 5.5+ (iOS 15+)부터 제공되는 **Foundation의 `FormatStyle` API**에 기반한 기능입니다.

> 기본 타입(Int, Date 등)에 대해 **국가, 언어 설정에 맞춰 포맷된 문자열로 변환**해줍니다.

---

## ✅ 예시: Int에 사용한 경우

```swift
let amount = 1234567
print(amount.formatted()) // "1,234,567" (한국 로케일 기준)
```

- 숫자에 **천 단위 쉼표**가 들어간 문자열이 자동으로 생성됨
    
- 내부적으로는 `NumberFormatter`와 비슷하지만, 더 **Swift 스타일로 추상화**됨

---

## ✅ 다양한 응용 예

### 1. 기본 숫자 포맷

```swift
let price = 5000
print(price.formatted()) // "5,000"
```

### 2. 날짜 포맷

```swift
let date = Date()
print(date.formatted(date: .abbreviated, time: .omitted)) // "May 27, 2025"
```

### 3. 커스텀 포맷

```swift
let price = 123456
print(price.formatted(.number.precision(.fractionLength(0)))) // "123,456"
```

---

## ✅ 관련 타입

|타입|의미|
|---|---|
|`Int`, `Double`, `Date` 등|`.formatted()` 지원|
|`.formatted()`|기본 또는 명시된 스타일에 따라 포맷|
|`formatted(.number)`, `formatted(.currency(code: \"KRW\"))`|더 정교한 포맷 지정 가능|

---

## ✅ 실제 코드 예 (당신의 경우)

```swift
let total = 32400
availableTodayLabel.text = "오늘 사용할 수 있는 금액: ₩\(total.formatted())"
```

➡️ 이 코드는 `"₩32,400"`처럼 표시되어 사용자에게 **가독성 높은 금액 표시**를 제공합니다.

---

## 📌 참고

- `.formatted()`는 내부적으로 `Locale.current`를 사용하므로, 시스템 설정이 한국어면 자동으로 한국식 포맷을 따릅니다.
    
- iOS 15 이상에서 사용 가능하며, 그 이하에서는 `NumberFormatter`를 사용해야 합니다.

---

## ✅ 결론

> `.formatted()`는 **숫자/날짜를 사람이 읽기 좋은 문자열로 바꾸는 Swift 최신 API**입니다.  
> UIKit에서도 매우 유용하며, UI 가독성을 높이는 데 큰 도움이 됩니다.

---

> [[iOS 학습 인덱스]]