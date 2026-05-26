> [[iOS 인터뷰 인덱스]] | [[iOS 학습 인덱스]]

### [복습] 구조체(Struct)의 메서드에서 내부 프로퍼티를 변경할 때 `mutating` 키워드를 사용하는 이유와 내부 동작 원리에 대해 설명해주세요.

구조체는 값 타입이므로 인스턴스의 상태를 함부로 변경할 수 없습니다. 따라서 프로퍼티를 수정하는 메서드에는 `mutating` 키워드를 붙여 상태 변경 권한이 있음을 명시해야 합니다. 내부적으로는 기존 구조체의 값을 직접 수정하는 것이 아니라, 변경된 값을 가진 새로운 구조체를 생성한 뒤 기존 `self`에 통째로 재할당(Reassignment)하는 방식으로 동작하여 값 타입의 안전성을 유지합니다.

### [복습] 의존성 주입(Dependency Injection)의 개념과, 뷰 컨트롤러에 뷰모델을 주입하는 '생성자 주입' 방식의 장점을 설명해주세요.

의존성 주입은 내부에서 필요한 객체를 직접 생성하지 않고, 외부(주로 프로토콜 타입)에서 생성된 객체를 주입받는 패턴입니다. 이 중 '생성자 주입(Initializer Injection)'은 객체가 생성되는 시점(`init`)에 필수적인 의존성을 전달받으므로, 의존성 누락을 컴파일 시점에 방지할 수 있어 가장 안전합니다. 또한 실제 로직 대신 가짜(Mock) 객체를 쉽게 주입할 수 있어 유닛 테스트 작성이 매우 용이해집니다.

### [Swift] `defer` 구문은 무엇이며, 어떤 상황에서 유용하게 사용되나요?

`defer` 블록 내부에 작성된 코드는 해당 블록이 포함된 현재 스코프(함수 등)가 종료되기 직전에 무조건 실행됨을 보장합니다. 주로 파일 스트림을 닫거나, 데이터베이스 연결을 해제하거나, 임시로 할당된 리소스를 정리하는 등의 마무리 작업을 작성할 때 유용합니다. 함수 중간에 `return`이나 에러가 발생하여 빠져나가더라도 `defer`는 반드시 실행되므로 안전한 리소스 관리가 가능합니다.

### [Concurrency] Swift 5.5에 도입된 `actor`는 무엇이며, 클래스(Class)와 어떤 차이점이 있나요?

`actor`는 클래스와 같은 참조 타입(Reference Type)이지만, 한 번에 하나의 작업(스레드)만 내부 상태에 접근할 수 있도록 자체적인 격리(Isolation) 환경을 제공합니다. 클래스는 여러 스레드에서 동시에 접근할 때 값이 꼬이는 데이터 경합(Data Race)이 발생할 수 있어 개발자가 직접 락(Lock) 처리를 해야 하지만, `actor`는 외부에서 접근할 때 `await` 키워드를 통해 순차적으로 접근하도록 강제하여 동시성 문제를 안전하게 해결해 줍니다.

### [Architecture] 의존성 역전 원칙(DIP, Dependency Inversion Principle)이란 무엇이며, iOS 개발에서 어떻게 적용할 수 있나요?

상위 모듈이 하위 모듈의 구체적인 구현에 의존해서는 안 되며, 둘 다 '추상화'에 의존해야 한다는 원칙입니다. iOS에서는 구체적인 클래스(예: `RealNetworkManager`) 대신 프로토콜(예: `NetworkFetchable`)을 정의하고, 상위 모듈인 뷰모델이 이 프로토콜에 의존하도록 설계하여 적용합니다. 이를 통해 하위 모듈이 변경되더라도 상위 모듈의 코드는 수정할 필요가 없게 됩니다.

### [SwiftUI] SwiftUI에서 `GeometryReader`의 역할은 무엇이며, 사용 시 주의할 점은 무엇인가요?

`GeometryReader`는 상위 뷰가 자신에게 제안한 공간의 크기와 좌표 정보(`GeometryProxy`)를 읽어와서 내부 하위 뷰들의 크기와 위치를 동적으로 배치할 때 사용하는 컨테이너 뷰입니다. 하지만 `GeometryReader`는 주어진 공간을 최대한으로 차지(Expand)하려는 성질이 있고, 뷰의 크기가 변할 때마다 하위 뷰들을 다시 렌더링하기 때문에 남용하면 레이아웃이 꼬이거나 성능 저하를 유발할 수 있어 주의해야 합니다.

### [iOS/CoreML] 카메라 화면이나 기기 센서를 통해 실시간으로 사용자의 상태를 분석하는 무거운 기능을 구현할 때, 기기의 발열이나 배터리 소모를 관리하기 위해 어떤 처리를 할 수 있을까요?

`ProcessInfo.processInfo.thermalState`를 모니터링하여 시스템의 발열 상태를 체크해야 합니다. 발열이 심해지면(`serious` 또는 `critical`) 카메라의 초당 프레임 수(FPS)를 낮추거나, CoreML 모델의 추론 주기를 늘려 연산량을 줄여야 합니다. 또한 백그라운드 스레드에서 무거운 연산을 처리하고, 화면에 그릴 필요가 없는 순간에는 즉각적으로 연산을 일시 정지하여 배터리 소모를 막아야 합니다.

### [Cross-Platform] 네이티브(Swift/UIKit/SwiftUI) 개발과 크로스 플랫폼(React Native 등) 개발의 렌더링 방식이나 성능 측면에서의 차이점은 무엇이라고 생각하시나요?

네이티브 개발은 OS가 제공하는 프레임워크와 GPU를 직접 사용하여 UI를 렌더링하므로 애니메이션이나 화면 전환이 부드럽고 성능이 극대화됩니다. 반면 React Native와 같은 크로스 플랫폼은 자바스크립트 스레드와 네이티브 영역 사이를 이어주는 브릿지(Bridge, 또는 JSI)를 거쳐 렌더링을 지시해야 합니다. 단순한 UI에서는 성능 차이가 체감되지 않지만, 복잡한 애니메이션이나 대량의 데이터를 스크롤할 때는 통신 병목 현상으로 인해 성능 저하가 발생할 수 있습니다

### [Network] 앱 통신 시 액세스 토큰(Token)이 만료되어 401 Unauthorized 에러가 발생했을 때, 이를 갱신(Refresh)하고 기존 요청을 재시도하는 로직은 어떻게 구현하시겠습니까?

Alamofire를 사용한다면 `RequestInterceptor` 프로토콜(특히 `retry` 메서드)을 활용하여 네트워크 계층에서 일괄적으로 처리합니다. URLSession을 사용할 경우, 응답 상태 코드가 401이면 즉시 Refresh Token을 서버로 보내 새로운 Access Token을 발급받습니다. 발급에 성공하면 실패했던 기존의 네트워크 Request 객체에 새로운 토큰을 헤더에 갈아 끼운 뒤, 다시 통신을 재시도(Retry)하도록 비동기 흐름을 구성합니다.

### [iOS] 앱이 켜지는 시간(App Launch Time)을 최적화하기 위해 어떤 작업들을 할 수 있나요?

앱의 초기 구동 속도를 높이기 위해, `AppDelegate`의 `didFinishLaunchingWithOptions`에서 무거운 동기식 작업을 수행하지 않고 백그라운드 큐로 미루거나 지연 로딩(Lazy Loading)을 사용해야 합니다. 또한, 사용하지 않는 외부 라이브러리(프레임워크)를 정리하여 동적 링킹(Dynamic Linking) 시간을 줄이고, 초기 화면을 구성하는 뷰 계층을 최대한 단순화하여 렌더링 속도를 높일 수 있습니다.

---

# Actor의 탄생 목적은 멀티 스레드 환경에서 발생하는 '데이터 경합(Data Race)' 문제를 개발자의 실수 없이 안전하게 막기 위해서 등장

### 1. 근본적인 문제: 데이터 경합(Data Race)

클래스(Class)는 참조 타입이기 때문에, 여러 스레드(작업)가 동시에 하나의 인스턴스에 접근하여 값을 수정할 수 있습니다. 예를 들어 은행 계좌(클래스)에 10만 원이 있는데, 스레드 A가 5만 원을 출금하는 찰나의 순간에 스레드 B도 5만 원을 출금하려고 접근하면 시스템이 꼬여 잔액이 마이너스가 되거나 앱이 강제 종료될 수 있습니다. 이를 데이터 경합이라고 합니다.

### 2. 기존 클래스(Class)의 한계

기존에는 이 문제를 해결하기 위해 개발자가 직접 자물쇠(Lock)를 걸어야 했습니다.

```Swift
class BankAccount {
    var balance = 100000
    let lock = NSLock()
    
    func withdraw(amount: Int) {
        lock.lock() // 🔒 다른 스레드 접근 금지!
        balance -= amount
        lock.unlock() // 🔓 접근 허용
    }
}
```

- **문제점:** 개발자가 실수로 `unlock()`을 빼먹으면 영원히 락이 풀리지 않아 앱이 멈추는 데드락(Deadlock)에 빠지며, 코드가 복잡해집니다.

---

### 3. Actor의 해결책: 자체 격리(Isolation)

Actor는 클래스처럼 참조 타입(메모리 주소 공유)이지만, **스스로 상태를 보호하는 기능**을 내장하고 있습니다.

여러 스레드가 동시에 `actor`에 접근하려고 하면, `actor`는 내부적으로 큐(우편함)를 만들어 요청들을 한 줄로 세웁니다. 그리고 **반드시 한 번에 하나씩만 순차적으로 처리**합니다. 즉, 개발자가 수동으로 락(Lock)을 걸지 않아도 시스템 차원에서 데이터 경합을 완벽하게 차단해 줍니다.

```Swift
// class 대신 actor 키워드 사용
actor BankAccount {
    var balance = 100000
    
    // Lock 관련 코드가 전혀 필요 없음
    func withdraw(amount: Int) {
        balance -= amount
    }
}
```

---

### 4. 왜 외부에서 접근할 때 `await`가 필수인가요?

이 부분이 면접에서 가장 중요한 포인트입니다.

`actor` 내부에 있는 변수를 외부(다른 구조체나 클래스, 혹은 다른 스레드)에서 읽거나 쓰려고 할 때, 해당 `actor`가 이미 다른 스레드의 작업을 처리하고 있다면 어떻게 될까요? **순서가 올 때까지 기다려야 합니다.**

이 "내 차례가 올 때까지 기다리겠다"고 명시적으로 선언하는 것이 바로 `await` 키워드입니다.

```Swift
let account = BankAccount()

// ❌ 에러 발생: Actor 외부에서 비동기 처리 없이 접근 불가
account.withdraw(amount: 50000) 

// ✅ 정상 동작: 비동기 컨텍스트(Task) 안에서 await로 순서를 기다림
Task {
    await account.withdraw(amount: 50000)
    print(await account.balance)
}
```

### 💡 요약하자면

- **공통점:** 둘 다 참조 타입(Reference Type)입니다.
    
- **차이점:** 클래스는 여러 스레드가 동시 접근 가능하여 위험하지만, Actor는 한 번에 하나의 스레드만 접근하도록 시스템이 강제(격리)하여 안전합니다.
    
- **사용법:** Actor의 데이터에 외부에서 접근하려면 줄을 서서 기다려야 하므로, 반드시 비동기 컨텍스트에서 `await` 키워드를 사용해야 합니다.

---

# 의존성 역전 원칙(DIP, Dependency Inversion Principle)은 객체지향 설계의 핵심 원칙인 SOLID의 마지막에 해당. 의존성 주입(DI)를 하는 근본적인 이유가 DIP를 지키기 위해

### 1. 현실 세계의 비유: 콘센트와 플러그

벽에 있는 **콘센트(상위 모듈)**를 생각해 보겠습니다. 콘센트는 전기를 공급하는 역할만 할 뿐, 거기에 TV가 꽂힐지, 드라이기가 꽂힐지, 노트북이 꽂힐지(구체적인 하위 모듈) 알 필요가 없습니다.

단지 **"220V 규격의 플러그(추상화된 프로토콜)"**라는 표준만 맞으면 어떤 기기든 꽂아서 작동시킬 수 있습니다. 만약 콘센트가 특정 TV 선과 아예 일체형으로 만들어져 있다면(강한 결합), TV를 바꿀 때 벽을 다 뜯어내야 할 것입니다.

### 2. 코드 예시: DIP를 위반한 경우 (의존성 정방향)

로그인을 처리하는 뷰모델(상위 모듈)이 카카오 로그인 기능(하위 모듈)을 직접 사용하는 상황입니다.

```Swift
// 하위 모듈 (구체적인 구현체)
class KakaoLoginManager {
    func loginWithKakao() {
        print("카카오로 로그인합니다.")
    }
}

// 상위 모듈
class LoginViewModel {
    // ❌ 뷰모델이 구체적인 KakaoLoginManager에 직접 의존함
    let loginManager = KakaoLoginManager()
    
    func authenticate() {
        loginManager.loginWithKakao()
    }
}
```

**문제점:** 화살표의 방향이 `LoginViewModel -> KakaoLoginManager`로 향합니다. 만약 기획이 변경되어 애플 로그인을 추가하거나 카카오 로그인을 빼야 한다면, 상위 모듈인 `LoginViewModel`의 코드를 직접 뜯어고쳐야 합니다. (벽을 뜯어내는 상황)

---

### 3. 코드 예시: DIP를 적용한 경우 (의존성 역전)

이번에는 둘 사이에 **프로토콜(추상화)**을 두어 규격을 만듭니다.

```Swift
// 1. 추상화 (220V 규격 플러그)
protocol AuthManageable {
    func login()
}

// 2. 하위 모듈들은 이제 추상화(프로토콜)에 의존하여 구현됨
class KakaoLoginManager: AuthManageable {
    func login() {
        print("카카오로 로그인합니다.")
    }
}

class AppleLoginManager: AuthManageable {
    func login() {
        print("애플로 로그인합니다.")
    }
}

// 3. 상위 모듈 역시 추상화(프로토콜)에만 의존함
class LoginViewModel {
    let loginManager: AuthManageable
    
    // 외부에서 의존성을 주입(DI) 받음
    init(loginManager: AuthManageable) {
        self.loginManager = loginManager
    }
    
    func authenticate() {
        loginManager.login()
    }
}
```

### 3-1. 뷰모델을 생성하는 외부, 초기화 단계
### 1. 외부에서 조립하기 (Composition)

보통 앱이 시작되는 곳(`SceneDelegate`)이나 화면 이동을 담당하는 곳(`Coordinator` 또는 이전 `ViewController`)에서 객체들을 입맛에 맞게 '조립'합니다.

```Swift
// 화면을 이동하거나 세팅하는 외부 클래스 (예: AppCoordinator)

func showLoginScreen() {
    // 1. 구체적인 하위 모듈(카카오)을 외부에서 생성합니다.
    let kakaoLogin = KakaoLoginManager()
    
    // 2. 생성한 카카오 객체를 뷰모델의 init을 통해 주입합니다.
    let viewModel = LoginViewModel(loginManager: kakaoLogin)
    
    // 3. 완성된 뷰모델을 뷰 컨트롤러에 넣고 화면을 띄웁니다.
    let loginVC = LoginViewController(viewModel: viewModel)
    navigationController.pushViewController(loginVC, animated: true)
}
```

### 2. 기획이 변경되어 "애플 로그인"으로 바꿔야 한다면?

만약 회사에서 "오늘부터 카카오 로그인 빼고 애플 로그인만 씁시다!"라고 정책을 바꿨다고 가정해 보겠습니다.

DIP와 DI가 적용되어 있기 때문에, 핵심 로직이 들어있는 `LoginViewModel` 코드는 **단 한 줄도 건드릴 필요가 없습니다.** 외부에서 조립하는 부품만 쓱 갈아 끼워주면 끝납니다.

```Swift
func showLoginScreen() {
    // 부품만 AppleLoginManager로 교체!
    let appleLogin = AppleLoginManager() 
    let viewModel = LoginViewModel(loginManager: appleLogin) // 뷰모델은 변경 없음
    
    let loginVC = LoginViewController(viewModel: viewModel)
    navigationController.pushViewController(loginVC, animated: true)
}
```

### 3. (실무 심화) 한 화면에 버튼이 여러 개인 경우는요?

면접관이나 실무자가 _"로그인 화면에는 보통 카카오 버튼, 애플 버튼이 둘 다 있는데, `init`으로 하나만 주입받으면 어떻게 처리하나요?"_ 라고 꼬리 질문을 던질 수 있습니다.

이럴 때는 `init`으로 주입받는 **생성자 주입** 대신, 버튼을 누를 때마다 뷰모델의 함수로 각각 다른 매니저를 던져주는 **메서드 주입(Method Injection)**을 사용하면 깔끔하게 해결됩니다.

```Swift
// 뷰모델
class LoginViewModel {
    // init 주입을 없애고, 함수를 호출할 때 프로토콜 타입을 받습니다.
    func authenticate(using manager: AuthManageable) {
        manager.login()
    }
}

// 뷰 컨트롤러 내부
class LoginViewController: UIViewController {
    let viewModel = LoginViewModel()
    
    @objc func didTapKakaoButton() {
        // 카카오 버튼을 누르면 카카오 매니저를 던져줌
        viewModel.authenticate(using: KakaoLoginManager())
    }
    
    @objc func didTapAppleButton() {
        // 애플 버튼을 누르면 애플 매니저를 던져줌
        viewModel.authenticate(using: AppleLoginManager())
    }
}
```
### 💡 요약

- **누가 결정하나요?** `LoginViewModel`을 생성하고 사용하는 **외부(조립하는 곳)**에서 결정합니다.
    
- **왜 이렇게 하나요?** 뷰모델이 특정 로그인 방식에 얽매이지 않고, 외부에서 주입해 주는 대로 유연하게 동작하도록 만들기 위해서입니다. (레고 블록을 조립하는 것과 같습니다.)

### 4. 왜 "역전(Inversion)"이라고 부를까요?

가장 헷갈리기 쉬운 부분입니다. 제어의 흐름이나 화살표의 방향이 뒤집히기 때문입니다.

- **기존 (정방향):** 상위 모듈 ➔ 하위 모듈
    
- **DIP 적용 후:** 상위 모듈 ➔ **프로토콜** ⬅️ 하위 모듈

하위 모듈(`KakaoLoginManager`)이 기존에는 독립적으로 존재하다가, 이제는 상위 모듈이 요구하는 규격(`AuthManageable`)에 맞춰서 구현되도록 방향이 거꾸로(역전) 바뀌었기 때문에 '의존성 역전'이라고 부릅니다.

### 💡 면접 요약 포인트

이 질문에 대해서는 딱 두 문장으로 핵심을 찌르는 것이 좋습니다.

> "DIP는 상위 모듈이 하위 모듈에 직접 의존하지 않고, 양쪽 모두 **프로토콜과 같은 추상화에 의존**하도록 설계하는 원칙입니다. 이를 통해 하위 모듈인 네트워크 라이브러리나 로그인 모듈이 완전히 다른 것으로 교체되더라도, 상위 모듈인 뷰모델의 코드는 단 한 줄도 수정할 필요가 없게 되어 유지보수성과 확장성이 극대화됩니다."
> [[iOS 학습 인덱스#아키텍처]]