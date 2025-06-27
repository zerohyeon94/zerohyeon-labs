[Point Free GitHub 주소(https://github.com/pointfreeco/swift-composable-architecture)
## TCA(The Composable Architecture)란?

### 핵심 설명

- **TCA**는 SwiftUI/Combine/RxSwift 기반으로 **상태 관리, 로직 분리, 테스트 용이성**을 강조하는 아키텍처 패턴입니다.
    
- Point-Free라는 개발팀이 만들었고, 오픈소스로 제공됩니다.
    
- **Redux 패턴**에서 영감을 받았고, “애플리케이션을 작은 조각으로 나누고 합치는(Compose) 방식”을 사용합니다.

#### 구성 요소

- **State**: 앱의 상태 데이터(Struct로 정의)
    
- **Action**: 사용자의 입력/이벤트/서버 응답 등 처리해야 하는 모든 “행동”
    
- **Reducer**: Action을 받아서 State를 어떻게 바꿀지 정의하는 순수 함수
    
- **Store**: State, Action, Reducer를 연결해서 실제로 “앱의 상태를 관리”
    
- **Environment**: 외부 의존성(네트워크, DB, 타 라이브러리 등)을 주입

#### 구조 예시

```swift
struct AppState { var count: Int = 0 }
enum AppAction { case increment, decrement }
let appReducer = Reducer<AppState, AppAction, Void> { state, action, _ in
    switch action {
    case .increment: state.count += 1
    case .decrement: state.count -= 1
    }
    return .none
}
```