iOS 앱 개발에서 가장 많이 비교되는 **MVC(Model-View-Controller)**와 **MVVM(Model-View-ViewModel)** 패턴의 차이를 명확히 이해하기 위해, **'사용자 프로필(이름과 나이)을 보여주고, 버튼을 누르면 나이가 증가하는 화면'**을 예로 들어 설명해 드리겠습니다.

핵심 차이는 **"비즈니스 로직과 화면 표시 로직을 누가 담당하는가?"**입니다.

---

### 1. 공통 사항: 데이터 모델 (Model)

두 패턴 모두 데이터를 담는 그릇인 Model은 동일합니다.

```Swift
// Model: 단순히 데이터만 가지고 있음
struct User {
    let name: String
    var age: Int
}
```

---

### 2. MVC 패턴 (Apple's MVC)

MVC에서 `UIViewController`는 **View이자 Controller** 역할을 동시에 수행합니다. 모델을 직접 소유하고, 데이터를 가공해서 UI에 직접 넣습니다.

**구조적 특징:**

- Controller(뷰컨트롤러)가 모든 결정을 내립니다.
    
- 코드가 `UIViewController`에 집중되어 파일이 비대해지기 쉽습니다 (Massive View Controller).

```Swift
import UIKit

// Controller (View의 역할도 겸함)
class UserProfileViewController: UIViewController {
    
    // UI 요소 (View)
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    
    // 데이터 (Model) - 컨트롤러가 직접 소유
    var user = User(name: "Gemini", age: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    // 사용자 액션 처리
    @IBAction func increaseAgeButtonTapped(_ sender: Any) {
        // 1. 비즈니스 로직: 나이 계산을 컨트롤러가 직접 함
        user.age += 1
        
        // 2. View 업데이트: 데이터를 가공하여 직접 UI에 할당
        updateUI()
    }
    
    func updateUI() {
        // 데이터 포맷팅 로직이 컨트롤러에 있음
        nameLabel.text = "이름: \(user.name)"
        ageLabel.text = "나이: \(user.age)세"
    }
}
```

---

### 3. MVVM 패턴

MVVM은 View(ViewController)와 Model 사이에 **ViewModel**이라는 중재자를 둡니다.

View는 **"보여주는 것"**만 신경 쓰고, ViewModel은 **"로직과 데이터 가공"**을 담당합니다.

**구조적 특징:**

- **View:** ViewModel의 데이터를 관찰(Binding)하고 있다가, 데이터가 변하면 화면을 갱신합니다. 로직을 전혀 모릅니다.
    
- **ViewModel:** UIKit(UI 관련 프레임워크)을 import 하지 않습니다. 오직 데이터 처리만 담당하여 **테스트가 매우 쉽습니다.**

#### A. ViewModel (로직 담당)

```Swift
import Foundation

// ViewModel: UIKit이 없음 (순수 로직)
class UserProfileViewModel {
    
    private var user: User
    
    // View가 바라볼 데이터 (Closure나 Combine, RxSwift 등으로 바인딩)
    var onInfoUpdate: (() -> Void)?
    
    // View에 보여질 형태로 데이터 가공
    var nameText: String {
        return "이름: \(user.name)"
    }
    
    var ageText: String {
        return "나이: \(user.age)세"
    }
    
    init(user: User) {
        self.user = user
    }
    
    // 사용자 액션에 대한 로직 처리
    func increaseAge() {
        user.age += 1
        // 데이터가 변했음을 View에게 알림
        onInfoUpdate?()
    }
}
```

#### B. View (ViewController - 표시 담당)

```Swift
import UIKit

class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    
    // Model 대신 ViewModel을 소유
    var viewModel = UserProfileViewModel(user: User(name: "Gemini", age: 1))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        updateView()
    }
    
    // 바인딩 설정 (ViewModel이 신호를 주면 화면 갱신)
    func setupBindings() {
        viewModel.onInfoUpdate = { [weak self] in
            self?.updateView()
        }
    }
    
    func updateView() {
        // 로직 없이 ViewModel이 주는 대로 표시만 함
        nameLabel.text = viewModel.nameText
        ageLabel.text = viewModel.ageText
    }
    
    @IBAction func increaseAgeButtonTapped(_ sender: Any) {
        // 직접 계산하지 않고 ViewModel에게 명령만 내림
        viewModel.increaseAge()
    }
}
```

---

### 4. 한눈에 보는 핵심 차이

|**구분**|**MVC (Model-View-Controller)**|**MVVM (Model-View-ViewModel)**|
|---|---|---|
|**View의 역할**|UI 표시 + 데이터 가공 + 사용자 입력 처리|UI 표시 + 사용자 입력을 ViewModel로 전달|
|**비즈니스 로직**|Controller (`UIViewController`)에 포함|ViewModel에 포함|
|**UI 의존성**|Controller가 UIKit에 강하게 의존|**ViewModel은 UIKit을 몰라도 됨** (독립적)|
|**테스트 용이성**|UI와 로직이 섞여 있어 테스트가 어려움|ViewModel만 따로 떼어내어 **단위 테스트(Unit Test) 가능**|
|**코드 복잡도**|초기 구현이 빠르고 단순함|파일이 늘어나고 바인딩(Binding) 코드가 필요함|

### 요약

- **MVC**는 빨리 만들 수 있지만, 화면이 복잡해지면 ViewController가 감당할 수 없을 만큼 커집니다.
    
- **MVVM**은 파일을 나누고 연결하는 작업이 필요하지만, 로직이 분리되어 있어 유지보수와 테스트가 훨씬 유리합니다.