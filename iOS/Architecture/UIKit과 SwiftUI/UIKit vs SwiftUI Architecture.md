# SwiftUI(Struct) vs UIKit(Class) 아키텍처 비교

SwiftUI가 `View`를 **Struct(구조체)**로, UIKit이 `ViewController`를 **Class(클래스)**로 구현하는 근본적인 이유는 **데이터 관리 방식**과 **성능 최적화 전략**의 차이 때문이다.

## 1. 성능과 메모리 할당 (Performance & Memory)

가장 결정적인 이유는 **생성 비용**이다.

### UIKit (Class)

- **타입:** 참조 타입 (Reference Type).
    
- **메모리:** **힙(Heap)** 영역에 할당.
    
- **비용:**
    
    - 인스턴스 생성과 해제(Allocation/Deallocation) 비용이 비싸다.
        
    - 참조 카운팅(ARC) 오버헤드가 발생한다.
        
    - 상속 구조(`NSObject` -> `UIResponder` -> `UIViewController`)로 인해 객체 자체가 무겁다.
        
- **전략:** 뷰 컨트롤러 하나를 만들면 **오랫동안 유지**하면서 속성만 바꾼다. (예: `label.text = "변경"`)

### SwiftUI (Struct)

- **타입:** 값 타입 (Value Type).
    
- **메모리:** **스택(Stack)** 영역에 할당.
    
- **비용:**
    
    - 생성과 소멸 속도가 **매우 빠르다** (거의 비용이 0에 수렴).
        
    - 상속이 없고, 데이터 사이즈가 작다.
        
- **전략:** 데이터(State)가 바뀔 때마다 기존 뷰를 **폐기하고 새로운 뷰(Struct)를 통째로 다시 만든다.** 비용이 싸기 때문에 수천 번 다시 만들어도 성능 문제가 없다.

---

## 2. 정체성과 렌더링 방식 (Identity & Rendering)

"내가 누구인가?"를 판단하는 기준이 다르다.

### UIKit: "나는 고유한 객체다" (Pointer Identity)

- `UIView`나 `UIViewController`는 메모리 주소를 가진다.
    
- 배경색을 빨간색으로 바꿔도, 텍스트를 바꿔도 **메모리 주소가 같은 동일한 객체**다.
    
- 개발자가 직접 "이 객체의 배경색을 바꿔라"라고 명령한다 (**명령형 프로그래밍**).

### SwiftUI: "나는 설계도일 뿐이다" (Structural Identity)

- SwiftUI의 `View` Struct는 화면에 그려지는 픽셀 그 자체가 아니다. **"화면이 이렇게 생겨야 한다"라고 정의한 데이터 덩어리(설명서/레시피)**일 뿐이다.
    
- **Diffing 알고리즘:**
    
    1. 상태(@State)가 변경된다.
        
    2. 새로운 뷰 Struct(설명서)를 생성한다.
        
    3. 기존 Struct와 새 Struct를 비교(Diff)한다.
        
    4. **변경된 부분만** 실제 화면(Rendered View)에 반영한다.
        
- 뷰는 계속 새로 만들어지기 때문에 고유한 주소값(Identity)을 가질 필요가 없다.

---

## 3. 데이터 의존성 (Inheritance vs Composition)

### UIKit (상속, Inheritance)

- 모든 뷰 컨트롤러는 `UIViewController`라는 거대한 부모 클래스를 상속받는다.
    
- 필요 없는 기능(생명주기 전체 등)까지 모두 물려받아 객체가 무거워진다.

### SwiftUI (구성, Composition)

- `View`는 클래스가 아니라 **프로토콜(Protocol)**이다.
    
- 상속을 받지 않으며, 필요한 기능(Text, Image, VStack 등)을 레고 블록처럼 **조립(Composition)**하여 화면을 구성한다.
    
- 이는 함수형 프로그래밍의 원칙과 잘 맞는다.

---

## 4. 요약 비교표

| **구분**     | **UIKit (ViewController)**                     | **SwiftUI (View)**                                              |
| ---------- | ---------------------------------------------- | --------------------------------------------------------------- |
| **구현 타입**  | `Class` (참조 타입)                                | `Struct` (값 타입)                                                 |
| **메모리 위치** | Heap (무거움)                                     | Stack (가벼움)                                                     |
| **패러다임**   | 명령형 (Imperative)                               | 선언형 (Declarative)                                               |
| **상태 변경**  | 객체 내부 속성 수정 (`mutating`)                       | 뷰 자체를 재생성 (`Re-rendering`)                                      |
| **비유**     | **집 (House)**<br>창문을 바꾸려면 기존 집에서 창문만 뜯어내고 교체함. | **청사진 (Blueprint)**<br>창문을 바꾸려면 기존 청사진을 버리고, 창문이 바뀐 새 청사진을 인쇄함. |

---

## 5. 핵심 결론 (One-Liner)

> "UIKit은 **영속적인 객체(Object)**를 관리하여 화면을 그리고, SwiftUI는 **일시적인 데이터(Value)**를 통해 화면의 상태를 정의한다."

---

> [[iOS 학습 인덱스]]