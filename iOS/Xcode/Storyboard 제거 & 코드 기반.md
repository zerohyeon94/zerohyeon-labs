## ✅ Step-by-Step: Storyboard 제거 & 코드 기반 화면 구성

---

### 🧱 1. `Main.storyboard` 파일 삭제

1. 프로젝트 탐색기에서 `Main.storyboard` 파일을 **삭제**합니다.
2. 이때 "Move to Trash"를 선택해도 됩니다.

---

### 🧰 2. Info.plist에서 Storyboard 참조 제거

1. `Info.plist` 파일을 열고
2. `Application Scene Manifest` → `Scene Configuration` → `Application Session Role` → `Item 0` → `Storyboard Name` 항목을 **삭제**합니다.

> 즉, `Storyboard Name = Main` 이 항목을 제거해야 App이 storyboard 없이 실행됩니다.

---

### 🔧 3. AppDelegate에서 UIWindow 수동 설정

#### AppDelegate.swift 예시 (UIKit 기반)

```swift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: HomeViewController())
        window?.makeKeyAndVisible()
        return true
    }
}
```

> ✅ 여기서 `UINavigationController`는 선택사항이에요. 필요 없으면 `HomeViewController()`만 넣으셔도 됩니다.

---

### 🗑 4. SceneDelegate.swift 파일 제거 (선택)

- iOS 13 이상 프로젝트는 SceneDelegate가 기본 포함되지만, **AppDelegate 하나로도 충분**합니다.
- `SceneDelegate.swift` 파일을 삭제하고
- `Info.plist`에서 `Application Scene Manifest` 자체를 **삭제**해도 됩니다.

> 📌 단, SceneDelegate 제거는 iOS 13 이상을 타겟으로 할 때 옵션이지만, 초보 학습이나 개인 프로젝트에서는 제거하고 AppDelegate 하나로 관리하는 게 더 간결합니다.

---

### ✅ 최종 확인

- 앱 실행 시 정상적으로 `HomeViewController`가 뜨고
- `Main.storyboard` 없이도 UI가 화면에 표시되면 성공입니다.
---

## 🎁 추가 팁: Storyboard 완전히 제거 후 확인해야 할 것

|항목|체크|
|---|---|
|Main.storyboard 완전 삭제|✅|
|Info.plist에서 Storyboard Name 제거|✅|
|AppDelegate에서 window 설정|✅|
|SceneDelegate 사용 여부 결정 (가능하면 삭제)|✅|
|빌드 & 실행 후 화면 정상 표시 확인||