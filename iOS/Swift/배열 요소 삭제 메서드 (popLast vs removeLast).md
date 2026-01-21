https://developer.apple.com/documentation/swift/array/poplast()
## 1. popLast()

배열의 **마지막 요소를 제거하고 그 값을 반환**한다. 가장 큰 특징은 **옵셔널(Optional)**을 반환한다는 점이다.

- **반환 타입:** `Element?` (Optional)
- **동작:**
    - 배열에 요소가 있을 때: 마지막 요소를 삭제하고 반환.
    - **배열이 비어있을 때: 에러가 발생하지 않고 `nil`을 반환.**
- **시간 복잡도:** $O(1)$

### 사용 예시 (안전한 추출)
```swift
var numbers = [1, 2, 3]

// 배열이 비어있지 않으므로 3을 반환하고 numbers는 [1, 2]가 됨
if let lastNumber = numbers.popLast() {
    print("꺼낸 숫자: \(lastNumber)") 
}

// 빈 배열에서 호출해도 안전함
var emptyArray: [Int] = []
let nothing = emptyArray.popLast() // nil 반환, 크래시 없음
```

---

## 2. removeLast()와 비교

`removeLast()`도 마지막 요소를 삭제하고 반환하지만, **빈 배열**일 때의 동작이 다르다.

|**특징**|**popLast()**|**removeLast()**|
|---|---|---|
|**반환 타입**|`Element?` (Optional)|`Element` (Non-Optional)|
|**빈 배열일 때**|**`nil` 반환 (안전)**|**런타임 에러 (Crash)**|
|**사용 권장**|배열이 비어있을 수도 있는 경우|배열이 비어있지 않음이 100% 확실한 경우|

> [!WARNING] 주의
>
> removeLast()를 사용할 때는 반드시 !array.isEmpty를 확인하거나, 로직상 절대 비어있을 수 없는 경우에만 사용해야 한다.

---

## 3. 기타 관련 메서드 정리

코딩 테스트에서 자주 헷갈리는 배열 제거/조회 관련 메서드들.

### A. removeFirst()

- **동작:** 배열의 **첫 번째** 요소를 제거하고 반환.
    
- **주의:** 배열의 모든 요소를 앞으로 한 칸씩 당겨야 하므로 시간 복잡도가 **$O(n)$**이다. (비효율적)
    
- **비고:** 빈 배열에서 호출 시 **에러 발생**.

### B. last (프로퍼티)

- **동작:** 배열의 마지막 요소를 **제거하지 않고 조회만** 함.
    
- **타입:** `Element?` (Optional)
    
- **비고:** `bag.last` 처럼 마지막 값을 확인만 하고 싶을 때 사용.

### C. dropLast()

- **동작:** 마지막 요소를 제외한 **새로운 시퀀스(Subsequence)**를 반환.
    
- **비고:** 원본 배열을 변경(Mutate)하지 않음.

---

## 4. 실전 코드 분석 (크레인 인형 뽑기)

문제 풀이에서 `popLast()`가 적절했던 이유는 **"해당 레인(Column)에 인형이 없을 수도 있기 때문"**이다.

```swift
// lanes[col]은 특정 열의 인형들을 쌓아놓은 스택

// [Good] popLast 사용
// 인형이 있으면 꺼내서 doll에 할당, 없으면 else 블록으로 넘어감 (에러 없음)
if let doll = lanes[col].popLast() {
    // 인형 처리 로직
} else {
    // 인형이 없는 빈 라인 처리
}
```

만약 여기서 `removeLast()`를 썼다면, 빈 라인을 선택했을 때 앱이 죽어버리므로 아래와 같이 방어 코드를 짜야 했을 것이다.

```swift
// [Bad] removeLast 사용 시 필요한 방어 코드
if !lanes[col].isEmpty {
    let doll = lanes[col].removeLast()
    // 처리 로직
}
```

### 💡 요약 및 팁

질문 주신 코드에서 `popLast()`를 사용한 것은 **Swift의 옵셔널 바인딩(`if let`)** 문법을 활용하여, "배열이 비었는지 확인하는 과정"과 "값을 꺼내는 과정"을 한 번에 처리한 매우 **Swifty(스위프트다운)**하고 깔끔한 코드입니다.

- **Stack(스택)** 자료구조의 개념(LIFO: Last In, First Out)을 배열로 구현할 때, `append()`와 `popLast()` 짝꿍을 기억해 두시면 좋습니다.