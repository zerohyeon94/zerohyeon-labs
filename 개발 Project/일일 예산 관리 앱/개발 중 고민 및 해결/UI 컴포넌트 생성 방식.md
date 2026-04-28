**UILabel/UIButton 등 UI 컴포넌트 생성 방식**에는  
(1) **클로저(Closure) 프로퍼티 초기화 방식**과  
(2) **viewDidLoad 등에서 직접 생성/설정 방식**  
두 가지 주요 스타일이 있습니다.

---

## 1. **클로저를 이용한 프로퍼티 초기화 방식**

(질문에서 사용하신 방식)

```swift
private var profileMemoLabel: UILabel = {
    let label = UILabel()
    label.textColor = ...
    label.font = ...
    return label
}()
```

### ✔️ 장점

- **코드가 매우 간결**  
    → 생성과 설정이 한눈에 보임
    
- **뷰 선언부에서 UI 속성까지 한 번에 확인 가능**
    
- **변수(프로퍼티)로 바로 선언**되어,  
    **뷰 생명주기와 상관없이 언제든 사용** 가능 (e.g. addSubview 등)
    
- **초기값만 한 번 지정하고 끝**
    
- **컴포넌트 개수가 많아질수록 가독성↑**
    

### ❌ 단점

- **초기화 이후 속성 재설정이 필요하면** 추가 코드 필요  
    (물론 대부분은 addSubview 전에 초기화만 필요)
    
- view hierarchy(addSubview) 설정 타이밍을 주의해야 함
    
- 일부 복잡한 UI/동적 속성 변화는 viewDidLoad 등에서 분리하는 게 더 명확할 수 있음
    

---

## 2. **viewDidLoad에서 직접 생성/설정 방식**

(예시)

```swift
private var profileMemoLabel: UILabel!

override func viewDidLoad() {
    super.viewDidLoad()
    profileMemoLabel = UILabel()
    profileMemoLabel.textColor = ...
    // 기타 설정
    view.addSubview(profileMemoLabel)
}
```
### ✔️ 장점

- **뷰 생명주기와 연계된 동적 UI 설정이 용이**  
    (예: 네트워크 결과 반영, 레이아웃 조건부 설정 등)
    
- **설정, 레이아웃, addSubview 등**  
    한 군데서 모두 관리 가능 (분리 명확)
    

### ❌ 단점

- **코드가 분산되어 한눈에 파악하기 어려움**
    
- **컴포넌트가 많을수록 코드가 길어지고 복잡**
    
- **viewDidLoad 이전에는 사용할 수 없음**  
    (프로퍼티 옵셔널로 두는 경우도 있음)
    

---

## 3. **실무에서는?**

- **클로저 방식**은
    
    > “**속성이 고정되고, 생성-설정이 명확**한 정적 UI”에 매우 적합  
    > (대부분의 일반 UI, 커스텀 Cell 등에서 자주 사용)
    
- **viewDidLoad 방식**은
    
    > “**동적 UI**나, 런타임 조건/로직에 따라 다르게 세팅해야 하는 경우”에 적합
    

---

## 📝 실전 팁

- **SwiftUI/모던 UIKit 코딩 스타일**에서는
    
    > **클로저 방식이 훨씬 더 널리 쓰입니다.**
    
- 복잡한 UI, 동적 레이아웃이 많아지면
    
    > 각 역할별로 함수(메서드)로 쪼개는 게 더 가독성 좋음
    

---

## ✅ 결론

|방식|장점|단점|주로 추천 상황|
|---|---|---|---|
|클로저 방식|코드 간결/가독성↑|동적/조건부 설정 힘듦|정적 UI, 일반적인 컴포넌트 선언|
|viewDidLoad|동적/조건부 처리 용이|코드 분산, 가독성↓|런타임/조건부 속성, 복잡한 UI|

> **클로저 초기화 방식**은  
> “정적 UI와 가독성이 중요할 때”
> 
> **viewDidLoad** 등에서의 동적 생성은  
> “동적/런타임 설정, 복잡한 초기화가 필요할 때”
> 
> 선택해서 사용하면 좋습니다!

---

## 1. **예시 코드 비교**

### 1-1. **클로저 프로퍼티 초기화 방식**

```swift
class ProfileViewController: UIViewController {
    // 👇 선언과 동시에 설정 (클로저 초기화)
    private let memoLabel: UILabel = {
        let label = UILabel()
        label.text = "메모"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(memoLabel)
        // AutoLayout 등 배치
    }
}
```

#### ✅ 장점

- 선언과 동시에 속성 설정, 코드가 **간결**
    
- **변수는 non-optional** (항상 값이 있음, ? 붙일 필요 없음)
    
- 어디서든 바로 사용 가능 (addSubview 등)
    
- **테스트시** Mock 뷰 생성 및 확인도 쉽고,  
    ViewController 생성 직후에도 접근 가능

---

### 1-2. **viewDidLoad 등에서 동적 생성/설정 방식**

```swift
class ProfileViewController: UIViewController {
    private var memoLabel: UILabel! // 선언만
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoLabel = UILabel()
        memoLabel.text = "메모"
        memoLabel.textColor = .gray
        memoLabel.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(memoLabel)
        // AutoLayout 등 배치
    }
}
```

#### ✅ 장점

- **런타임 조건**에 따라 생성/설정/속성 분기 가능
    
    - ex) 로그인/비로그인 여부, 서버 값 등
        
- 여러 UI를 반복문 등으로 동적으로 만들 때 편함
    

#### ❌ 단점

- **옵셔널 변수**가 많아질 수 있음 (`!`, `?` 사용)
    
- 선언부와 설정 코드가 분리되어 **가독성↓**
    
- **테스트에서 뷰가 완전히 초기화되기 전까지 nil**일 수 있음

---

## 2. **DI(Dependency Injection)와 테스트 관점 차이**

### **클로저 초기화 방식**

- **의존성 주입이 더 직관적**  
    (예: 커스텀 뷰, 셀 생성시 파라미터나 프로퍼티 인젝션이 명확)
    
- **테스트에서 생성 직후에도 항상 값이 할당**  
    (nil 체크 불필요)
    
- **Mock 뷰 생성, 스냅샷 테스트 등에 유리**
    
- **SwiftUI 스타일의 코딩과 자연스럽게 연결**

### **동적 생성 방식**

- DI/테스트를 위해 별도 초기화 코드가 필요할 수 있음
    
    - ex) `viewDidLoad()` 호출 전에는 변수에 값이 없음
        
    - → 테스트 대상이 코드상 어디서 초기화/사용되는지 더 신경써야 함
        
- 조건부 주입(런타임 분기)에는 유리하나, 테스트 단순화에는 불리

---

## 3. **실무에서는 어떤 기준으로 선택?**

|상황|추천 방식|이유/설명|
|---|---|---|
|**정적 UI, 속성 고정**|클로저 초기화|간결, 비옵셔널, 선언-설정 한눈에|
|**동적 UI, 조건부 분기/생성 필요**|viewDidLoad 등 동적 생성|런타임 값/로직으로 생성, 동적 개수/조건분기 등|
|**테스트 코드, DI, ViewController의 일관성**|클로저 초기화|항상 non-optional, 주입/Mock/테스트에 유리|
|**복잡한 화면, Cell의 반복적 동적 구성**|viewDidLoad 등 동적 생성|Cell, StackView, TableView 등에서 반복문 등 동적 생성 구조에 더 유리|

---

## 4. **코딩 스타일 결론**

- **Swift/SwiftUI 스타일의 현대적 UIKit 개발**  
    → 클로저 초기화 방식 적극 추천  
    (특히 뷰 선언, 커스텀 셀, 컴포넌트 선언 등)
    
- **조건분기/복잡한 동적 생성 필요**  
    → viewDidLoad에서 동적 생성/설정
    
- **코드의 일관성, 테스트, DI가 중요한 팀 프로젝트/규모 있는 앱**  
    → 선언/초기화 방식은 일관되게 사용,  
    (주로 클로저 초기화 방식이 실무 트렌드)
    

---

### 🔍 _실전 팁_

- “**불필요한 옵셔널은 지양**한다”는 Swift 스타일에도  
    클로저 초기화가 더 적합
    
- 커스텀 Cell, 컴포넌트 등 **재사용 컴포넌트**는 클로저 초기화 방식이 유지보수에도 더 좋음

---

## 📢 한줄 요약

> **“정적이고 명확한 UI는 클로저 초기화,  
> 동적/조건부 UI는 viewDidLoad에서 생성”**
> 
> 테스트/DI/스냅샷 검증, 유지보수, SwiftUI 호환성까지 생각하면  
> **클로저 초기화 방식이 현대 UIKit 개발에서 더 널리 쓰입니다!**

---

> [[Home]]