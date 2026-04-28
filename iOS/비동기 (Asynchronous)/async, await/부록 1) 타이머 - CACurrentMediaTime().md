# CACurrentMediaTime() 
`CACurrentMediaTime()` 는 **“지금 시점의 고해상도 타이머 값”을 돌려주는 함수입니다.

- 출처: `QuartzCore` 프레임워크 (Core Animation 쪽)
    
- 반환 타입: `CFTimeInterval` (사실상 `Double` 타입, **초 단위**)
    
- 용도:
    
    - 어떤 작업을 시작한 시점의 시간 기록
        
    - 나중에 다시 `CACurrentMediaTime()`을 불러서 **경과 시간(Elapsed time)** 계산


예를 들어, 코드에서는 이렇게 쓰고 있었죠:

```swift
let startTime = CACurrentMediaTime()

let image = try await self.loadImage(from: url)

// 로딩이 너무 빨리 끝났을 때를 대비한 최소 연출 시간 계산
let elapsed = CACurrentMediaTime() - startTime
```

여기서 의미는:

- `startTime` : 버튼 눌렀을 때 시점 (초 단위 숫자)
    
- 다시 `CACurrentMediaTime()` 호출해서 빼면 → **그 사이에 흘러간 시간(초)**

> 📌 시스템 시계(Date, 시간대 등)랑 상관없이,  
> **애니메이션·성능 측정용**으로 안정적인 타이머를 쓰고 싶을 때 많이 사용합니다.

---

> [[iOS 학습 인덱스]]