## 1. 근본적인 차이점

### UIKit (ViewController 중심)

- **객체의 생명:** `ViewController`는 한 번 생성되면 메모리(Heap)에 오래 살아남는다.
    
- **단계:** 로드됨(`viewDidLoad`) -> 나타나기 전(`viewWillAppear`) -> 나타남(`viewDidAppear`) -> 사라짐(`viewDisappear`) 등 아주 세세하게 나뉜다.

### SwiftUI (View 중심)

- **값의 생명:** `View` Struct는 데이터가 변할 때마다 수시로 **파괴되고 다시 생성(Init)**된다.
    
- **단계:** 따라서 "로드(Load)"라는 개념이 희미하다. 대신 **"화면에 보이는가(Appear)?"**와 **"사라지는가(Disappear)?"**가 핵심이다.

---

## 2. 주요 메서드 1:1 매핑

UIKit의 라이프사이클 메서드가 SwiftUI에서는 아래와 같이 대체됩니다.

| **UIKit (UIViewController)**                      | **SwiftUI (Modifier)**     | **설명**                                                                                    |
| ------------------------------------------------- | -------------------------- | ----------------------------------------------------------------------------------------- |
| **viewDidLoad**                                   | **없음 (혹은 init)**           | SwiftUI 뷰는 수시로 다시 만들어지므로, `init`에 무거운 로직을 넣으면 안 된다. 데이터 로딩은 보통 `onAppear`나 `task`에서 수행한다. |
| **viewWillAppear**<br><br>**viewDidAppear**       | **`.onAppear { ... }`**    | 뷰가 화면에 나타나는 시점에 실행된다. (API 호출, 데이터 갱신 등)                                                  |
| **viewWillDisappear**<br><br>**viewDidDisappear** | **`.onDisappear { ... }`** | 뷰가 화면에서 사라지는 시점에 실행된다. (타이머 중지, 데이터 저장 등)                                                 |

### 💡 [참고] viewDidLoad가 없는 이유

SwiftUI에서 `init()`은 뷰가 렌더링될 때마다 호출될 수 있습니다. 만약 `init` 안에 "서버 데이터 다운로드" 코드를 넣으면, 스크롤할 때마다 서버 요청을 보내는 대참사가 일어날 수 있습니다. 따라서 **"한 번만 실행되어야 하는 초기화 로직"은 `onAppear`나 `task`를 사용**해야 합니다.

---

## 3. 최신 SwiftUI 패턴: `.task` (비동기 작업)

iOS 15부터는 `onAppear`보다 더 강력한 **`.task`** 수식어가 도입되었습니다.

```swift
// 사용 예시
.task {
    await loadData() // 비동기 함수 호출 가능
}
```

- **역할:** `onAppear`와 동일하게 뷰가 나타날 때 실행됩니다.
    
- **장점:**
    
    1. **비동기 지원:** `await` 키워드를 바로 쓸 수 있습니다.
        
    2. **자동 취소:** 뷰가 화면에서 사라지면(Disappear), 실행 중이던 비동기 작업(API 호출 등)을 **시스템이 알아서 취소(Cancel)**해줍니다.

---

## 4. 앱 전체의 생명주기 (Background/Foreground)

UIKit의 `AppDelegate`나 `SceneDelegate`에서 처리하던 "앱이 백그라운드로 갔다", "앱이 활성화되었다"는 처리는 **`ScenePhase`**를 사용합니다.

```swift
struct MyApp: App {
    // 시스템의 현재 상태를 감지하는 환경 변수
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onChange(of: scenePhase) { _, newPhase in
                    switch newPhase {
                    case .active:
                        print("앱이 활성화됨 (Foreground)")
                    case .background:
                        print("앱이 백그라운드로 감 (저장 로직 실행)")
                    case .inactive:
                        print("비활성화 (알림센터 내려왔을 때 등)")
                    default: break
                    }
                }
        }
    }
}
```

---

### 요약

1. `viewDidLoad`는 잊어라. (뷰는 계속 새로 태어난다)
    
2. 화면에 나올 때 할 일은 **`.onAppear`** (또는 `.task`).
    
3. 화면에서 사라질 때 할 일은 **`.onDisappear`**.
    
4. 앱 상태 변화는 **`scenePhase`**.