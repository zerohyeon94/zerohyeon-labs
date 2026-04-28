# 정의

> “비즈니스 규칙(도메인)을 가장 중심에 두고, UI·DB·네트워크·프레임워크 같은 것들은 바깥으로 밀어내서, 안쪽 코드가 바깥 것들에 의존하지 않도록 만든 아키텍처 스타일”

- 핵심 키워드 : **의존성 방향**

![[Clean Architecture.png]]
## 1. 이 그림이 말하는 한 줄 요약

> **가운데일수록 “핵심 비즈니스 규칙”,  
> 바깥으로 갈수록 “기술·프레임워크”,  
> **의존성은 항상 바깥 → 안쪽으로만** 흐른다.**

- 동그라미 : “레이어”
- 화살표는 : “소스 코드 의존성 방향”

---

## 2. 각 색/원 설명

### ① 노랑 – **Entities (Enterprise Business Rules)**

- 회사/서비스가 어떤 도메인인지 정의하는 **순수 비즈니스 모델**
    
- 예: `User`, `Order`, `Mission`, `Budget` 같은 도메인 객체
    
- UIKit, DB, 네트워크 **아무것도 몰라야 하는 계층**

👉 “우리 서비스가 무엇을 하는지”를 표현하는 **핵심 개념 레이어**

---

### ② 분홍 – **Use Cases (Application Business Rules)**

- 앱이 “언제, 어떤 상황에서 엔티티들을 어떻게 쓸지”를 정의하는 계층
    
- 예:
    
    - `LoginUseCase`
        
    - `FetchTodayMissionUseCase`
        
    - `CompleteMissionUseCase`
        
- 화면이 바뀌거나 API가 살짝 바뀌어도, **“유저가 로그인 버튼을 누르면 어떤 일이 일어나는가?”** 같은 규칙은 여기서 유지됨

👉 “유저의 액션에 따라 도메인을 어떻게 사용할지”를 정의하는 **앱 비즈니스 로직**

---

### ③ 초록색 – **Interface Adapters (Presenters, Controllers, Gateways)**

- **안쪽 세계(엔티티/유즈케이스)** 와 **바깥 세계(UI, DB, 웹, 디바이스)** 사이를 변환해주는 어댑터층

구체적으로:

- **Presenters**
    
    - Use Case 결과 → View가 쓰기 쉬운 형태로 변환 (ViewModel, formatted text 등)
        
- **Controllers**
    
    - UI/웹 요청 → Use Case 호출로 바꿔주는 역할
        
- **Gateways**
    
    - Use Case에서 쓰는 Repository 인터페이스 ↔ 실제 DB/네트워크 구현 사이를 이어줌
        
    - 여기에서 DTO ↔ Domain Model 변환도 자주 일어남

👉 한 마디로 **“형식 변환기 & 어댑터 레이어”**

---

### ④ 파란색 – **Frameworks & Drivers (외부 인터페이스)**

- **가장 바깥, 기술/플랫폼/도구들이 있는 곳**
    
- 그림에 적힌 것들:
    
    - DB
        
    - Web
        
    - Devices
        
    - UI
        
    - External Interfaces
        
- iOS로 치면:
    
    - UIKit/SwiftUI, URLSession/Alamofire, CoreData/Realm, Firebase, OS SDK 등

👉 “나중에 갈아끼울 수 있는 기술들”이 있는 바깥 껍데기

---

## 3. 화살표의 의미 – **의존성 규칙(Dependency Rule)**

그림에서 화살표는 항상 **바깥 → 안쪽** 으로만 들어가죠?

이게 핵심 규칙이에요:

> **바깥 레이어는 안쪽 레이어를 알 수 있지만,  
> 안쪽 레이어는 바깥 레이어를 모른다.**

- Use Cases는 Entities를 의존할 수 있음 ✅
    
- Presenter는 Use Cases를 의존할 수 있음 ✅
    
- 반대로:
    
    - Entity가 UIKit을 import 한다? ❌
        
    - Use Case가 Alamofire를 직접 쓴다? ❌
        
    - Domain이 CoreData NSManagedObject를 직접 쓴다? ❌

이렇게 해서:

- UI, DB, 네트워크, 프레임워크가 바뀌어도
    
- **안쪽 도메인/유즈케이스 코드는 최대한 그대로 재사용**할 수 있게 만드는 구조.

---

## 4. 오른쪽 작은 박스들 – 호출 흐름(Flow of control)

- Controller → Use Case Input Port
    
- Use Case Interactor → Use Case Output Port → Presenter

흐름 설명:

1. **실행 흐름(flow of control)** 은
    
    - UI Controller가 이벤트를 받아서 Use Case를 호출하고
        
    - Use Case가 로직을 처리한 뒤
        
    - Presenter에게 결과를 넘겨서 화면 갱신을 하게 만든다는 “호출 순서”
        
2. 하지만 **의존성은 인터페이스(Port)를 통해 안쪽으로 향하게** 만든다는 걸 보여줍니다.
    
    - Controller는 `UseCaseInputPort` 인터페이스에 의존
        
    - Use Case는 `UseCaseOutputPort` 인터페이스에 의존
        
    - 실제 Presenter 구현은 바깥에서 그 인터페이스를 채택
        

👉 즉, **실행은 바깥→안→다시 바깥으로 흐르지만,  소스코드 의존성은 항상 바깥→안쪽 한 방향** 이라는 걸 강조하는 그림.

---

## 5. 이 이미지로 한 문장으로 설명해보자면

> “이 그림에서 안쪽 노랑·분홍 원은 서비스의 핵심 비즈니스 규칙(엔티티와 유즈케이스)을 의미하고, 초록과 파란 원은 UI·DB·웹·디바이스 같은 외부 인터페이스와 프레임워크를 의미합니다. 화살표처럼 **의존성은 항상 바깥에서 안쪽으로만** 흐르기 때문에, UI나 DB가 바뀌어도 안쪽 비즈니스 로직은 최대한 영향 없이 유지되도록 설계하는 게 클린 아키텍처의 핵심입니다.”

---

## 6. 클린 아키텍처의 목표

1. **프레임워크로부터 독립**
    
    - UIKit, SwiftUI, CoreData, Firebase 등이 **언제든 교체 가능**하도록
        
    - 도메인 로직이 프레임워크에 붙어 있지 않게
        
2. **UI로부터 독립**
    
    - View를 UIKit → SwiftUI로 바꿔도 비즈니스 로직(UseCase, Domain)은 안 건드리게
        
3. **DB, 네트워크로부터 독립**
    
    - REST → GraphQL, CoreData → Realm 바뀌어도 도메인 쪽은 건들지 않게
        
4. **테스트하기 쉽게**
    
    - 네트워크, DB 없이도 **도메인 로직만 단위 테스트 가능**하게

---

## 7. iOS에서의 개념

- **DTO (Data Transfer Object)**  
    → 보통 **Data / Infrastructure 레이어**  
    → “서버 JSON ↔ 코드” 변환 담당
    
- **Domain Model / Entity**  
    → **가장 안쪽 (Entities)**  
    → 앱의 비즈니스 의미를 갖는 순수 모델 (UIKit, Alamofire 모름)
    
- **Use Case (Interactor)**  
    → **도메인 로직 레이어**  
    → “유저가 로그인 버튼을 눌렀을 때 해야 하는 일”을 정의
    
- **Repository**  
    → **Interface Adapter 레이어**  
    → UseCase에서 “데이터 주세요” 라고 부르는 추상화 계층  
    → 실제 구현은 Network, DB 등에서 처리
    
- **ViewController / ViewModel / Coordinator**  
    → **Presentation / Frameworks 레이어**  
    → UIKit, RxSwift, UIKit navigation, MVVM-C 등
### 간단 예시

```text
[Domain Layer]
- User
- Mission
- LoginUseCase, FetchMissionsUseCase

[Data Layer]
- UserRepositoryProtocol    ← Domain이 아는 건 *이 인터페이스 뿐*
- UserRepositoryImpl (uses APIService, LocalDB)
- UserDTO, MissionDTO
- APIService (Alamofire, URLSession)
- LocalDataSource (CoreData, UserDefaults)

[Presentation Layer]
- HomeViewModel, LoginViewModel
- HomeViewController, LoginViewController
- Coordinator들
```

---

## 8. 결론

```text
클린 아키텍처는 앱의 비즈니스 규칙을 가장 중심에 두고 보호하는 아키텍처라고 이해하고 있습니다.  
안쪽 레이어에는 도메인 모델과 유즈케이스 같은 핵심 로직이 있고,  
바깥 레이어에는 iOS UI, 네트워크, 데이터베이스, 외부 프레임워크들이 위치합니다.  
중요한 규칙은 의존성이 항상 바깥에서 안쪽으로만 흐른다는 것*데요,  
그래서 도메인 코드는 UIKit이나 Alamofire 같은 구체적인 기술을 몰라도 되게 만들고,  
UI나 네트워크 라이브러리를 교체하더라도 도메인 로직은 그대로 유지할 수 있게 하는 게 목적입니다.  
이런 구조 덕분에 유지보수성과 테스트가 좋아지는 것을 목표로 하는 아키텍처라고 설명할 수 있을 것 같습니다.
```

---

> [[iOS 학습 인덱스]]