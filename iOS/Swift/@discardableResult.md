`@discardableResult`는 **함수(또는 메서드)의 반환값을 사용하지 않아도 컴파일러가 경고하지 않도록** 만들어주는 Swift의 속성입니다.

[공식문서 Attributes 내에 존재](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/attributes/)

---

## 🔎 기본 동작

Swift에서는 반환값이 있는 함수를 호출하고 **그 결과를 사용하지 않으면 컴파일러가 경고를 줍니다**.

```swift
func multiply(_ a: Int, _ b: Int) -> Int {
    return a * b
}

multiply(3, 4) // ⚠️ "Result of call to 'multiply(_:_:)' is unused"
```

---

## ✅ `@discardableResult` 사용

```swift
@discardableResult
func multiply(_ a: Int, _ b: Int) -> Int {
    return a * b
}

multiply(3, 4) // ✅ 이제 경고 없음
```

이제 이 함수는 결과를 사용하지 않아도 괜찮습니다.

---

## 📌 언제 사용하나요?

| 사용 상황              | 예시                                                     |
| ------------------ | ------------------------------------------------------ |
| 메서드 체이닝을 제공하는 경우   | `.configure().build()` 등                               |
| 결과를 보통은 무시해도 되는 경우 | `UIView.setNeedsLayout()` 같이 반환값은 있지만 대부분 사용할 필요 없는 경우 |
| 테스트용 유틸리티에서        | 테스트 함수에서 호출 결과 확인이 중요하지 않은 경우                          |

---

## 💡 예시: 메서드 체이닝

```swift
@discardableResult
func setTitle(_ title: String) -> Self {
    self.title = title
    return self
}

// 사용 시
view.setTitle("Hello") // 사용 or 무시 둘 다 가능
```

---

## 🧠 정리

|항목|설명|
|---|---|
|의미|반환값이 무시되어도 경고하지 않음|
|사용 대상|함수, 메서드|
|사용 이유|메서드 체이닝, 유틸리티 함수 등에서 반환값 무시를 허용하려고|

`@discardableResult`는 **가독성과 유연성을 높여주지만**, 남용하지 않도록 **필요한 함수에만 사용**하는 것이 좋습니다.

---

> [[iOS 학습 인덱스]]