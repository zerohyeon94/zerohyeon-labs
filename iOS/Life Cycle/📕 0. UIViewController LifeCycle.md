
## ✅ UIKit의 ViewController 생명주기 핵심 8단계

| 단계  | 메서드                 | 시점 설명                                        |
| --- | ------------------- | -------------------------------------------- |
| ①   | `init`              | 뷰 컨트롤러가 **인스턴스화** 될 때 호출됨 (아직 뷰는 없음)         |
| ②   | `loadView`          | 뷰 컨트롤러가 **뷰를 직접 생성**할 때 사용 (보통 override 안 함) |
| ③   | `viewDidLoad`       | 뷰가 메모리에 로드되고 나서 한 번 호출됨                      |
| ④   | `viewWillAppear`    | 뷰가 **화면에 보이기 직전**에 호출됨 (매번 호출됨)              |
| ⑤   | `viewDidAppear`     | 뷰가 **화면에 완전히 표시된 직후** 호출됨                    |
| ⑥   | `viewWillDisappear` | 뷰가 **다른 화면으로 전환되기 직전** 호출됨                   |
| ⑦   | `viewDidDisappear`  | 뷰가 **완전히 사라진 후** 호출됨                         |
| ⑧   | `deinit`            | 뷰 컨트롤러가 메모리에서 해제될 때 호출됨 (ARC에 의해)            |

---

### 📌 주요 특징

- `init` → **뷰가 생성되기 전** 단계 (데이터나 의존성 주입)
- `viewDidLoad` → **뷰가 메모리에 처음 올라온 후** 초기화 (UI 설정, 초기 네트워크 요청)
- `viewWillAppear`/`viewDidAppear` → **사용자에게 실제 화면이 보이기 전/후**
- `viewWillDisappear`/`viewDidDisappear` → **다른 화면으로 넘어갈 때 작업**
- `deinit` → **메모리 해제 시점**, 리소스 정리(예: Timer, Notification)

---
### ⚠️ 추가로 알면 좋은 메서드들 (iOS 17 이상)

- `viewIsAppearing(_:)`
- `viewIsDisappearing(_:)`  
    → SwiftUI와 연동하거나 비동기 화면 전환 상황에서 더 정교하게 제어할 수 있도록 추가됨

---

### 🧠 정리해서 외우기

```swift
init → loadView → viewDidLoad → viewWillAppear → viewDidAppear  
→ viewWillDisappear → viewDidDisappear → deinit
```

---

## 🔧 언제 무엇을 쓰면 좋을까?

- `viewDidLoad`: UI 구성, 초기 데이터 설정
- `viewWillAppear`: 화면 갱신이 필요한 UI 처리
- `viewDidAppear`: 애니메이션, 트래킹 시작
- `deinit`: 메모리 정리, Notification 해제 등