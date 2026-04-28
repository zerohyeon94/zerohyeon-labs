# init(truncating:)

[공식 홈페이지](https://developer.apple.com/documentation/swift/int/init(truncating:))

```swift
init(truncating number: [`NSNumber`]
```

---

## ✅ 개발 중 경고 메시지 설명

```swift
'init(_:)' is deprecated: replaced by 'init(truncating:)'
```


- `Int(...)`로 `NSDecimalNumber?` 또는 `NSNumber`를 감싸면 내부적으로 **구버전 변환 API**를 사용
    
- Swift 5.7 이상에서는 **명시적으로 `Int(truncating:)` 또는 `Int(exactly:)`를 사용**하라고 안내함

---

## 🔧 해결 방법

### 기존 (⚠️ 경고 발생)

```swift
self.amount = Int(entity.amount ?? 0)
```

### 변경 후 (✅ 권장 방식)

```swift
self.amount = Int(truncating: entity.amount ?? 0)
```

---

## 🎯 `truncating:` vs `exactly:`

|이니셜라이저|설명|실패 가능성|
|---|---|---|
|`Int(truncating:)`|부동소수점 → 정수로 **내림(truncate)**|❌ 항상 성공|
|`Int(exactly:)`|**정확하게 변환 가능한 경우만**|✅ 실패 가능 (nil 반환)|

> 즉, 금액처럼 **반올림/내림이 허용되는 숫자**라면 `truncating:`을 사용하면 됩니다.

---

> [[iOS 학습 인덱스]]