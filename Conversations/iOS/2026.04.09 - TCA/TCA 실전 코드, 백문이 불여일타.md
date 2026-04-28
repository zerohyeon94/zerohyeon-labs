가볍게 시작하기: 단방향으로 흐르는 집중 타이머 TCA의 핵심은 "화면(View)은 스스로 아무것도 판단하지 않고 버튼이 눌렸다는 사실만 전달하며, 모든 뇌 역할(상태 변경, 타이머 실행)은 Feature라는 하나의 거대한 상자 안에서 처리한다"는 것입니다.

1단계: 앱의 뇌와 상태 정의하기 (Feature) TCA에서는 상태, 행동, 로직을 'Feature'라는 하나의 구조체로 묶습니다. 최신 매크로를 사용하면 코드가 아주 간결해집니다.

```swift
import ComposableArchitecture import SwiftUI

@Reducer struct FocusTimerFeature {

	// 1. 상태 (State)
	// 화면에 그려질 데이터들입니다. 값이 바뀌면 뷰가 알아서 다시 그려집니다.
	@ObservableState
	struct State: Equatable {
	    var score: Int = 0
	    var isTimerRunning: Bool = false
	}
	
	// 2. 행동 (Action)
	// 화면에서 발생할 수 있는 모든 사건을 나열합니다.
	enum Action {
	    case toggleTimerButtonTapped // 시작/정지 버튼 누름
	    case timerTicked             // 1초마다 타이머 동작
	}
	
	// 3. 의존성 (Dependency)
	// 시계(Clock)를 주입받습니다. DI 컨테이너 역할이 프레임워크에 내장되어 있습니다.
	@Dependency(\.continuousClock) var clock
	
	// 4. 로직 (Reducer)
	// Action이 들어왔을 때 State를 어떻게 바꿀지 정하는 핵심 구역입니다.
	var body: some ReducerOf<Self> {
	    Reduce { state, action in
	        switch action {
	        
	        case .toggleTimerButtonTapped:
	            state.isTimerRunning.toggle()
	            
	            if state.isTimerRunning {
	                // 타이머 시작: 1초마다 timerTicked 액션을 무한히 발생시킵니다.
	                return .run { send in
	                    for await _ in self.clock.timer(interval: .seconds(1)) {
	                        await send(.timerTicked)
	                    }
	                }
	                .cancellable(id: "TimerID") // 정지를 위해 이름표를 붙여둡니다.
	                
	            } else {
	                // 타이머 정지: 아까 붙여둔 이름표를 찾아서 작업을 취소합니다.
	                return .cancel(id: "TimerID")
	            }
	            
	        case .timerTicked:
	            // 타이머가 동작할 때마다 점수를 1점씩 올립니다.
	            state.score += 1
	            return .none
	        }
	    }
	}
}
```

2단계: 화면(View) 그리기 이제 이 거대한 뇌(Feature)를 화면에 붙여줍니다. 뷰는 스스로 판단하지 않고 뇌에게 Action만 던집니다.

```swift
struct FocusTimerView: View { // Store: Feature를 담아두는 상자입니다. 뷰는 무조건 이 상자를 통해서만 통신합니다. let store: StoreOf
	var body: some View {
	    VStack(spacing: 20) {
	        Text("현재 집중 점수: \(store.score)")
	            .font(.largeTitle)
	
	        Button(store.isTimerRunning ? "집중 정지" : "집중 시작") {
	            // 유저가 버튼을 누르면 뇌(Store)에게 "버튼 눌림!" 하고 보고합니다.
	            store.send(.toggleTimerButtonTapped)
	        }
	    }
	}
}
```


3단계: 앱 시작점에서 뇌(Store) 주입하기 가장 바깥쪽인 App 껍데기에서 이 뷰를 띄울 때, 초기 상태를 세팅해서 주입해 주면 모든 조립이 끝납니다.

```swift
@main 
struct FocusSenseApp: App { 
	var body: some Scene { 
		WindowGroup { 
			FocusTimerView( 
				// 시작할 때 점수는 0, 타이머는 멈춤 상태로 세팅해서 뇌를 가동시킵니다. 
				store: Store(initialState: FocusTimerFeature.State()) { 
					FocusTimerFeature() 
				} 
			) 
		} 
	} 
}
```


오늘의 요약 이렇게 완성된 TCA 코드를 보면, 상태를 바꾸는 로직과 비동기 타이머 작업이 Reducer라는 한 공간에 완벽하게 통제되어 있다는 것을 알 수 있습니다. 화면(View)은 정말 UI만 그리는 순수한 껍데기가 되었죠
---

> [[iOS 학습 인덱스]]
