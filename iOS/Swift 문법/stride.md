# 일정한 간격으로 반복되는 함수 - stride(from:to:by:) & stride(from:through:by:)

[애플 공식문서 stride(from:to:by:)](https://developer.apple.com/documentation/swift/stride(from:to:by:))

> [!ABSTRACT] Apple 공식 설명
Returns a sequence from a starting value to, but not including, an end value, stepping by the specified amount.>
>시작 값부터 끝 값(끝 값은 포함하지 않음)까지 지정된 값만큼씩 증가하는 시퀀스

```swift
func stride<T>(
	from start: T, 
	to end: T, 
	by stride: T.Stride
) -> StrideTo<T> where T : Strideable
```

---
[애플 공식문서 stride(from:through:by:)](https://developer.apple.com/documentation/swift/stride(from:through:by:))

> [!ABSTRACT] Apple 공식 설명
Returns a sequence from a starting value toward, and possibly including, an end value, stepping by the specified amount.
>시작 값부터 끝 값까지 (끝 값을 포함할 수도 있음) 지정된 값만큼 증가하는 시퀀스를 반환합니다.

```swift
func stride<T>(
	from start: T, 
	to end: T, 
	by stride: T.Stride
) -> StrideTo<T> where T : Strideable
```

---

Swift에서는 **"일정한 간격으로 숫자를 건너뛰면서 반복하고 싶을 때"** 사용하는 아주 유용한 함수입니다.

우리가 흔히 쓰는 `for i in 0...5` 같은 반복문은 무조건 **1씩만** 증가하잖아요? `stride`를 쓰면 **2씩 증가**하거나, **거꾸로(-1) 감소**하거나, 심지어 **0.5씩(실수)** 증가하게 만들 수도 있습니다.

크게 두 가지 종류가 있는데, **'도착지점을 포함하느냐 마느냐'**의 차이만 기억하시면 됩니다.

---

### 1. stride(from: to: by:) -> 도착지점 미포함

**"~에서 시작해서(from), ~에 닿기 전까지(to), ~만큼씩(by) 가라"**

이건 우리가 아는 `0..<10` (10 미만)과 똑같은 개념입니다. 마지막 숫자는 포함되지 않습니다.

**예시 코드:** let steps = stride(from: 0, to: 10, by: 2) print(Array(steps))

**결과:** [0, 2, 4, 6, 8] _(10은 포함되지 않습니다!)_

---

### 2. stride(from: through: by:) -> 도착지점 포함

**"~에서 시작해서(from), ~를 통과할 때까지(through), ~만큼씩(by) 가라"**

이건 `0...10` (10 이하)과 똑같은 개념입니다. 마지막 숫자가 조건에 맞으면 포함됩니다.

**예시 코드:** let steps = stride(from: 0, through: 10, by: 2) print(Array(steps))

**결과:** [0, 2, 4, 6, 8, 10] _(10이 포함되었습니다!)_

---

### 코딩 테스트에서 언제 쓰나요?

**1. 배열을 거꾸로 돌 때 (Reverse)** `reversed()`를 써도 되지만, 인덱스를 직접 다뤄야 할 때 `stride`가 편합니다.
-  10부터 1까지 1씩 줄어듦 for i in stride(from: 10, through: 1, by: -1) { print(i) // 10, 9, 8 ... 1 }

**2. 짝수/홀수 인덱스만 건너뛰며 볼 때** 배열의 0, 2, 4, 6... 번째만 확인하고 싶을 때 아주 강력합니다.
- 0부터 끝까지 2칸씩 점프 for i in stride(from: 0, to: array.count, by: 2) { print(array[i]) }

**3. 실수(Float/Double)로 반복할 때** 일반적인 `for`문은 정수만 되지만, `stride`는 소수점도 됩니다.
- 0.0, 0.5, 1.0 ... for i in stride(from: 0.0, through: 3.0, by: 0.5) { ... }

### 요약

- **1씩 증가하는 평범한 반복문이 지겨울 때** 쓴다.
    
- **`to`**: 도착점 **제외** (미만 `<`)
    
- **`through`**: 도착점 **포함** (이하 `<=`)
    
- **`by`**: 보폭 (음수면 뒤로 감)
