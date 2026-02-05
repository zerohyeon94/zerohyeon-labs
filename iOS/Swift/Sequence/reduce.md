## reduce(0, +)

배열의 모든 요소를 하나로 합치는 고차 함수다.

- **기본 형태:** `reduce(초기값, 결합클로저)`
    
- **`0`**: 초기값(Initial Result). 합계이므로 0부터 시작.
    
- **`+`**: 연산자 함수. Swift에서는 연산자도 함수이므로 클로저 대신 `+` 기호만 넘길 수 있다.

```swift
// 아래 세 코드는 모두 같은 동작을 함
nums.reduce(0, { (res, next) in res + next }) // 정석
nums.reduce(0) { $0 + $1 }                    // 후행 클로저 + 단축 인자
nums.reduce(0, +)                             // 연산자 파라미터 (가장 간결)
```

---

Instance Method
# reduce(_:_:)

Returns the result of combining the elements of the sequence using the given closure.

iOS 8.0+ | iPadOS 8.0+ | Mac Catalyst 13.0+ | macOS 10.10+ | tvOS 9.0+ | visionOS 1.0+ | watchOS 2.0+

```swift
func reduce<Result>(
    _ initialResult: Result,
    _ nextPartialResult: (Result, Self.Element) throws -> Result
) rethrows -> Result
```

## Parameters

`initialResult`

The value to use as the initial accumulating value. `initialResult` is passed to `nextPartialResult` the first time the closure is executed.

`nextPartialResult`

A closure that combines an accumulating value and an element of the sequence into a new accumulating value, to be used in the next call of the `nextPartialResult` closure or returned to the caller.

## Return Value

The final accumulated value. If the sequence has no elements, the result is `initialResult`.

## Discussion

Use the `reduce(_:_:)` method to produce a single value from the elements of an entire sequence. For example, you can use this method on an array of numbers to find their sum or product.

The `nextPartialResult` closure is called sequentially with an accumulating value initialized to `initialResult` and each element of the sequence. This example shows how to find the sum of an array of numbers.

```
let numbers = [1, 2, 3, 4]
let numberSum = numbers.reduce(0, { x, y in
    x + y
})
// numberSum == 10
```

When `numbers.reduce(_:_:)` is called, the following steps occur:

1. The `nextPartialResult` closure is called with `initialResult`—`0` in this case—and the first element of `numbers`, returning the sum: `1`.
    
2. The closure is called again repeatedly with the previous call’s return value and each element of the sequence.
    
3. When the sequence is exhausted, the last value returned from the closure is returned to the caller.

If the sequence has no elements, `nextPartialResult` is never executed and `initialResult` is the result of the call to `reduce(_:_:)`.

> [!NOTE] Complexity
> 
> O(_n_), where _n_ is the length of the sequence.