`FormatterUtils`를 `struct`로 만들지 `enum`으로 만들지 고민할 때는 **"의도와 사용 방식"**이 기준이 됩니다.

---

## ✅ 결론 먼저

> ✅ `FormatterUtils`처럼 **인스턴스를 생성하지 않고, 오직 정적(static) 유틸 메서드만 가진 경우엔 `enum`을 사용하는 것이 더 명확하고 안전합니다.**

---

## 🔍 왜 `enum`이 적합한가?

### `enum`을 사용하면:

- **생성자 `init()`를 막을 수 있음**
    
- 즉, `FormatterUtils()`처럼 **실수로 인스턴스를 만들 수 없게** 됨
    
- 타입 자체가 "그룹화된 정적 함수 집합"이라는 의도를 코드로 표현

```swift
enum FormatterUtils {
    static func formatCurrencyInput(...) { ... }
}
```

➡️ 이렇게 하면 **유틸리티 전용임을 분명하게 전달**할 수 있습니다.

---

## 🤔 반면 `struct`는?

- `FormatterUtils()`로 **인스턴스를 생성할 수 있음**
    
- 생성하지 않아도 되는데 **실수로 만들어 사용할 여지를 남깁니다**
    
- 유틸 성격의 코드에는 **불필요한 인스턴스 생성 가능성**이 오히려 해롭습니다

```swift
struct FormatterUtils {
    static func formatCurrencyInput(...) { ... }
}

// 실수로 이렇게 쓸 수도 있음
let utils = FormatterUtils()
utils.formatCurrencyInput(...)  // ❌ 안 해도 되는 방식
```

---

## ✅ 실전에서는 언제 struct?

|상황|struct 사용 예시|
|---|---|
|상태를 가진 도구 클래스|`DateFormatterWrapper`, `StringHelper`, `TextStyleBuilder`|
|생성자 주입 필요|`FormatterUtils(config: .init(...))` 처럼 옵션 기반 처리할 때|

---

## ✅ 정리

|기준|enum|struct|
|---|---|---|
|유틸리티 전용 (static만)|✅ 권장|❌ 오해의 여지|
|인스턴스가 필요|❌ 사용 불가|✅ 필요|
|생성 막기 가능|✅ (`init` 없음)|❌ 자동 생성됨|
|코드 의미 전달|"묶음" 느낌 강함|데이터 구조체 느낌|

---

### 🧠 요약

> FormatterUtils는 단순 포맷팅 유틸이므로  
> ✅ `enum FormatterUtils`가 **가장 명확하고 안전한 선택**입니다.