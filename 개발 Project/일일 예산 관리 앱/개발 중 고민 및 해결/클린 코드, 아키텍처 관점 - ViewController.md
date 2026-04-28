## 1. **함수 배치 순서(실무 권장 스타일)**

> 💡 **일반적으로 ViewController/UIViewController 기반 클래스의 함수 배치는 다음과 같이 권장됩니다:**

### 1. **라이프사이클**

- `init`/`deinit`
    
- `viewDidLoad`, `viewWillAppear` 등

### 2. **UI 세팅/레이아웃**

- `setupLayout()`, `setupViews()`, `setupConstraints()`
    
- 테마, 스타일 적용 함수 등

### 3. **바인딩/액션 연결**

- `setupActions()`
    
- (RxSwift/RxCocoa를 쓴다면 `bindViewModel()`도 이 영역)

### 4. **이벤트 핸들러**

- `@objc` 타겟 함수들 (액션/Delegate/DataSource 등)
    
- 예: `@objc salaryChanged()`, `@objc paydayChanged()` 등

### 5. **UI 상태 업데이트/헬퍼**

- `updateNextButtonState()` 등

### 6. **네비게이션/화면 이동 관련**

- 화면 전환, present/push 관련 함수 등

### 7. **내부 private 함수**

- Helper/Formatter 등

### **SetupSalaryViewController 코드 적용 순서 예시**

```swift
// MARK: - 초기화/라이프사이클
init(...) { ... }
required init?(coder: ...) { ... }
override func viewDidLoad() { ... }

// MARK: - UI 세팅/레이아웃
private func setupLayout() { ... }

// MARK: - 액션/바인딩
private func setupActions() { ... }

// MARK: - 이벤트 핸들러
@objc private func salaryChanged() { ... }
@objc private func paydayChanged() { ... }
@objc private func nextTapped() { ... }

// MARK: - UI 상태 업데이트/헬퍼
private func updateNextButtonState() { ... }
```

**➡️ 실무에서는 실제로 `// MARK: -`로 각 영역을 나눠 가독성을 높입니다.**

---

## 2. **extension 활용/함수 분리**

- **extension 활용:**  
    UI의 역할(Delegate, DataSource, Action 등)에 따라 extension으로 분리하면  
    한눈에 책임/역할이 드러나고 코드 가독성이 높아집니다.

**예시:**

```swift
extension SetupSalaryViewController {
    @objc private func salaryChanged() { ... }
    @objc private func paydayChanged() { ... }
    @objc private func nextTapped() { ... }
}

private extension SetupSalaryViewController {
    func updateNextButtonState() { ... }
}
```

- _Delegate/DataSource 함수는 각각 별도 extension에 모으는 것도 권장(지금은 해당 없음)_
    
- **헬퍼 함수/포매터/비즈니스 로직 등**  
    ViewController 내에서 쓸 필요 없는 것은 ViewModel/Utils로 이동시켜  
    ViewController가 “UI 관리”에 집중하도록 리팩토링

---

## 3. **주석(코멘트) 사용에 대한 실무적 기준**

- **클래스/함수 위, “왜 이렇게 동작하는지”를 설명해야 하는 경우에만**  
    불필요한 한글/영어 주석은 오히려 코드 가독성 저하 유발
    
- **일반적으로 명확한 네이밍과 MARK 사용으로 충분**  
    (예외: 복잡한 알고리즘, 의도 설명 등은 주석 필요)
    

**➡️ 위 예시 코드는 이미 네이밍/구조가 명확해 주석 없이도 가독성이 좋음.  
간결하게 유지하는 것이 베스트!**

---

## 4. **클린아키텍처 관점에서 ViewModel/Model 개선 포인트**

- **ViewModel**
    
    - ViewController에 영향을 주지 않는 “유효성 체크, 임시 상태, 포맷팅, 저장 등”은 ViewModel에 집중
        
    - **ViewModel의 상태 변화 → 바인딩** 구조면 MVVM의 장점이 더 극대화됨
        
    - 예: RxSwift/Combine/Notification 등 활용해 ViewModel 값이 변하면 View 자동 갱신
        
- **Model**
    
    - CoreData 모델을 네트워크/도메인 모델과 분리해서, Model → Entity 변환 책임을 명확히 둘 것
        
    - (지금 구조도 무난, but 스케일업/확장시 명확히 구분 추천)
        

---

## 5. **기타 실무 피드백**

- **ViewModel/Controller init 파라미터**
    
    - 앞으로 테스트/의존성주입 용이하게 항상 init 파라미터로 전달하는 구조 유지
        
- **formatter/입력값 검증 로직**
    
    - FormatterUtils 등은 ViewModel/Utils로 분리하고, ViewController는 화면과 바인딩만 담당하도록 설계
        

---

## 6. **정리: 코드 개선/권장 구조**

- **함수 순서:**  
    MARK로 구분, “라이프사이클 → UI세팅 → 액션바인딩 → 이벤트핸들러 → 헬퍼” 순서 권장
    
- **extension 분리:**  
    역할별로 extension 사용, 가독성/유지보수에 유리
    
- **주석:**  
    코드 자체로 의도가 명확하다면 “불필요하게 남기지 않는다”가 실무 표준
    
- **클린아키텍처:**  
    ViewModel에 “상태, 검증, 저장” 책임 집중,  
    ViewController는 “UI/바인딩/이벤트만 담당”
    

---

### ✅ **실제 실무자용 추천 구조**

```swift
final class SetupSalaryViewController: BaseViewController {
    // MARK: - Properties
    private let viewModel: SetupViewModel
    // ... UI Components

    // MARK: - Initializer
    init(viewModel: SetupViewModel) { ... }
    required init?(coder: NSCoder) { ... }

    // MARK: - Lifecycle
    override func viewDidLoad() { ... }

    // MARK: - UI Setup
    private func setupLayout() { ... }

    // MARK: - Actions/Bindings
    private func setupActions() { ... }

    // MARK: - Event Handlers
    @objc private func salaryChanged() { ... }
    @objc private func paydayChanged() { ... }
    @objc private func nextTapped() { ... }

    // MARK: - Helpers
    private func updateNextButtonState() { ... }
}
```


---

> [[Home]]