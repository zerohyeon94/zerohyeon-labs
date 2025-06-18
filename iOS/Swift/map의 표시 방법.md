## ✅ 왜 `map(CarryOverSourceModel.init)`이 가능한가요?

`map`은 클로저를 받는 함수입니다.  
아래 두 코드는 **완전히 같은 동작**을 합니다:

```swift
carryOverSourceEntities.map { CarryOverSourceModel(entity: $0) }   // 일반적인 클로저

carryOverSourceEntities.map(CarryOverSourceModel.init)             // 간결한 축약형
```

Swift에서는 생성자(`init`)도 함수처럼 취급할 수 있고,  
`CarryOverSourceModel.init`은 `(CarryOverSource) -> CarryOverSourceModel` 타입의 함수와 동일하게 간주됩니다.

즉, `map()`에 넘길 수 있는 **함수 타입 클로저**가 되기 때문에 동작합니다.

---

## 📌 어떤 경우에 쓸 수 있나요?

- 매핑 대상 타입이 명확하고
    
- 생성자가 한 개의 파라미터를 받고
    
- 그 파라미터 타입이 `map` 대상의 요소와 동일할 때

```swift
struct User {
    let name: String
    init(name: String) {
        self.name = name
    }
}

let names = ["A", "B", "C"]
let users = names.map(User.init) // == names.map { User(name: $0) }
```

---

## 🔍 주의: 파라미터가 2개 이상이면?

예를 들어, `init(name: String, age: Int)` 같은 생성자는 `map(Type.init)`으로는 사용할 수 없습니다. 이럴 땐 클로저를 직접 써야 합니다.

---

## ✅ 결론

|형태|가능 여부|설명|
|---|---|---|
|`map { CarryOverSourceModel(entity: $0) }`|✅ 일반적 방식||
|`map(CarryOverSourceModel.init)`|✅ 생성자 축약형, 더 간결||

이처럼 `map(Type.init)`은 Swift의 **함수형 문법 축약 표현** 중 하나로 매우 유용합니다.  
코드가 더 읽기 쉽고 간결해지는 장점이 있습니다.