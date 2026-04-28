외부에서는 값을 **읽기만(Read-only)** 가능하고, 내부에서는 **수정(Read-write)**도 가능하게 만드는 효율적인 문법 정리.
## 1. 과거의 방식 (Boilerplate)

예전(혹은 다른 언어)에는 '외부 읽기 전용'을 구현하기 위해 변수를 두 개나 만들어야 했다.

1.  **`_name`**: 실제 데이터를 담는 **private 저장 프로퍼티**. (외부 접근 불가)
2.  **`name`**: `_name`을 반환만 해주는 **public 계산(Computed) 프로퍼티**.

```swift
class DataManager {
    // 1. 실제 데이터 (나만 볼 수 있음)
    private var _mlService: MLFocusDetectionService?
    
    // 2. 외부 공개용 (읽기만 가능, _mlService를 리턴)
    var mlService: MLFocusDetectionService? {
        return _mlService
    }
    
    func updateService() {
        _mlService = MLFocusDetectionService() // 내부에서는 수정 가능
    }
}
````

**단점:** 코드가 길어지고, 변수 이름 짓기가 귀찮다 (`_` 언더바 관습 사용).

---

## 2. 권장 방식: private(set)

Swift는 **"설정(Set)만 Private으로 하겠다"**는 의미의 `private(set)` 키워드를 제공한다.
이것을 사용하면 변수 하나로 위 기능을 완벽하게 대체할 수 있다.

```swift
class DataManager {
    // ✅ 읽기는 Internal(기본), 쓰기는 Private
    private(set) var mlService: MLFocusDetectionService?
    
    func updateService() {
        self.mlService = MLFocusDetectionService() // 내부에서는 수정 가능!
    }
}
```

### 작동 원리

| **구분**       | **접근 권한**        | **설명**                         |
| ------------ | ---------------- | ------------------------------ |
| **Get (읽기)** | `Internal` (기본값) | 같은 모듈(프로젝트) 내 어디서든 접근 가능       |
| **Set (쓰기)** | `Private`        | **이 파일(또는 클래스) 내부에서만** 값 변경 가능 |

> [!TIP] 만약 읽기도 Public으로 하고 싶다면?
> 
> `public private(set) var ...` 와 같이 앞에 `public`을 명시해주면 된다.

---

## 3. 왜 private(set)을 쓸까? (장점)

1. **코드 절약:** 변수 두 개를 하나로 줄여준다.
    
2. **안전성 확보:** 외부에서 실수로 `manager.mlService = nil` 처럼 값을 망가뜨리는 것을 컴파일 단계에서 막아준다.
    
3. **명확한 의도:** "이 변수는 밖에서 맘대로 바꾸면 안 돼!"라는 의도를 코드 자체로 보여준다.

### 비교 요약

|**특징**|**계산 프로퍼티 방식 (_var + var)**|**private(set) 방식**|
|---|---|---|
|**코드 라인**|김 (변수 2개 선언)|**짧음 (변수 1개)**|
|**메모리**|저장 프로퍼티 1개 사용|저장 프로퍼티 1개 사용 (동일)|
|**가독성**|`_`가 붙어 지저분할 수 있음|**깔끔함**|

---
### 💡 요약 설명 
질문 주신 변경 사항은 **"불필요한 코드를 줄이는(Boilerplate reduction)"** 아주 좋은 습관입니다. 
* **변경 전:** 실제 저장소(`_mlService`)와 보여주기용 창문(`mlService`)을 따로 만들었습니다. 
* **변경 후:** `mlService`라는 창문에 **"밖에서는 눈으로만 보세요(Read-only), 직원은 안에서 만질 수 있습니다"**라는 팻말(`private(set)`)을 붙인 것과 같습니다.

---

> [[iOS 학습 인덱스]]