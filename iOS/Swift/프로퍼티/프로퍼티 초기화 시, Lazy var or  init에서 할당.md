## **1. `lazy var`를 선호하는 경우**

- **해당 프로퍼티가 생성 시점에 반드시 필요하지 않거나,**
    
- **초기화 비용이 크거나,**
    
- **순환 참조(캡처) 또는 self가 필요한 경우**

### **장점**

- 선언이 간결하고, `self`의 다른 멤버에 자유롭게 접근 가능
    
- 필요할 때 실제로 생성되므로, 불필요한 리소스 사용 방지

### **단점**

- 선언적이긴 하지만, **실제 생성 시점이 “처음 접근할 때”라 추적이 어려울 수 있음**
    
- Thread-safe하지 않음(동시성 환경에서 동시 접근 시)

### **예시**

```swift
class MyVC: UIViewController {
    let viewModel = MyViewModel()
    lazy var dataSource = MyDataSource(viewModel: viewModel)
}
```

---

## **2. `init`에서 할당을 선호하는 경우**

- **객체의 생성 과정이 명확하게 드러나야 할 때**  
    (특히, 초기화 순서·의존관계가 중요한 경우)
    
- **불변(immutable) 프로퍼티로 관리하고 싶을 때**
    
- **의존성 주입(DI) 패턴에 맞추고 싶을 때**

### **장점**

- 생성 시점에 모든 프로퍼티가 정확히 할당됨
    
- `let`(상수)로 선언 가능 → 값 변경 방지, 불변성 확보
    
- 테스트, 유지보수, 명확한 의존성 추적에 용이
### **단점**

- `init()`이 길어질 수 있음
    
- 상위 프로퍼티/하위 프로퍼티 간 참조 구조에 따라 복잡해질 수 있음

### **예시**

```swift
class MyVC: UIViewController {
    let viewModel: MyViewModel
    let dataSource: MyDataSource

    init(viewModel: MyViewModel) {
        self.viewModel = viewModel
        self.dataSource = MyDataSource(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
}
```

---

## **3. 실무에서의 선택 기준**

- **불변성이 중요하다, 객체의 초기화 구조를 명확히 하고 싶다 → `init`에서 할당**
    
- **생성 순서·초기화 비용 신경 안 쓰고, 선언적 코드가 더 보기 쉽다 → `lazy var`**
    
- **ViewController, View 등 UIKit 계층에서 self 참조가 필요한 경우 → 대부분 `lazy var`**
    
- **ViewModel, Service, DI 환경 → 대부분 `init` 할당**

---

## **4. 정리: 실무 추천**

- **단순 UI 객체, 셀, 데이터소스 등은 `lazy var` 자주 사용**  
    (특히, 코드 양이 줄고 self 접근이 필요할 때)
    
- **중요 의존성, 불변 객체, 서비스/네트워크 계층 등은 `init`에서 할당**  
    (특히, 테스트나 DI/모킹이 필요하면 무조건 init!)

---

## **5. 실제 현업 스타일**

- **ViewController 내 컬렉션 뷰, 테이블 뷰 등은 `lazy var`가 압도적으로 많음**
    
- **비즈니스/모델 계층, DI 환경에서는 대부분 init 주입**

---

### **요약**

- **UI/뷰컨트롤러 내에서 선언적 관리, self 접근 필요 → `lazy var`**
    
- **명확한 의존성, 불변성, 테스트/DI 중요 → `init` 할당**