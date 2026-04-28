## compactMap

`map`과 유사하지만, **옵셔널(nil)을 자동으로 제거(Unwrap)**해주는 기능이 추가된 고차 함수다.

- **동작 원리:**
    
    1. 각 요소에 클로저를 적용한다 (`map`의 기능).
        
    2. 결과가 `nil`인 것은 버리고, 값이 있는 것만 추출한다 (`filter` + `unwrap`).
        
    3. 결과 배열은 옵셔널이 아닌 일반 타입(`[Int]`)이 된다.

### 왜 map 대신 compactMap을 썼을까?

`wholeNumberValue`가 `Int?`를 반환하기 때문이다.

| **메서드**          | **반환 타입**   | **결과 (입력이 "123"일 때)**                     | **비고**    |
| ---------------- | ----------- | ----------------------------------------- | --------- |
| `map`            | `[Int?]`    | `[Optional(1), Optional(2), Optional(3)]` | 덧셈 불가능    |
| **`compactMap`** | **`[Int]`** | **`[1, 2, 3]`**                           | **덧셈 가능** |

---

Instance Method
# compactMap(_:)

Returns an array containing the non-`nil` results of calling the given transformation with each element of this sequence.

iOS 8.0+iPadOS 8.0+Mac Catalyst 13.0+macOS 10.10+tvOS 9.0+visionOS 1.0+watchOS 2.0+

```
func compactMap<ElementOfResult>(_ transform: (Self.Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult]
```

## Parameters

`transform`

A closure that accepts an element of this sequence as its argument and returns an optional value.

## Return Value

An array of the non-`nil` results of calling `transform` with each element of the sequence.

## Discussion

Use this method to receive an array of non-optional values when your transformation produces an optional value.

In this example, note the difference in the result of using `map` and `compactMap` with a transformation that returns an optional `Int` value.

```swift
let possibleNumbers = ["1", "2", "three", "///4///", "5"]


let mapped: [Int?] = possibleNumbers.map { str in Int(str) }
// [1, 2, nil, nil, 5]


let compactMapped: [Int] = possibleNumbers.compactMap { str in Int(str) }
// [1, 2, 5]
```

> [!NOTE] Complexity
> 
> O(_n_), where _n_ is the length of this sequence.


---

> [[iOS 학습 인덱스]]