## 🎯 SceneDelegate란?

`SceneDelegate.swift`는 **iOS 13 이상부터 도입된 개념**으로,  
앱에서 **하나 이상의 "화면(Window)"**을 다룰 수 있도록 만든 구조입니다.

즉,
- `AppDelegate`는 **앱 전체**의 진입과 생명주기를 관리하고,
- `SceneDelegate`는 **각 화면(씬, 윈도우)** 단위의 UI 생명주기를 관리합니다.

> 단일 화면 앱에서도 기본적으로 포함되며, 멀티 윈도우(iPad, Mac Catalyst)에서는 필수입니다.

---

## 🧱 기본 SceneDelegate 구조

```swift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // 1. 앱 화면이 처음 연결될 때
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = HomeViewController()
        self.window = window
        window.makeKeyAndVisible()
    }

    // 2. 앱이 백그라운드로 이동될 때
    func sceneDidEnterBackground(_ scene: UIScene) {
        // 예: CoreData 저장 처리 등
    }

    // 그 외 생명주기들 (옵션)
    func sceneDidBecomeActive(_ scene: UIScene) { }
    func sceneWillResignActive(_ scene: UIScene) { }
    func sceneWillEnterForeground(_ scene: UIScene) { }
    func sceneDidDisconnect(_ scene: UIScene) { }
}
```

---

## 🔍 주요 메서드 설명

|함수명|설명|사용 예시|
|---|---|---|
|`willConnectTo`|Scene이 처음 연결될 때 (앱 시작 시 UI 설정)|`window.rootViewController` 설정|
|`sceneDidBecomeActive`|앱이 활성화됨 (포그라운드 진입)|애니메이션 재시작, 위치 트래킹 시작|
|`sceneWillResignActive`|비활성화됨 (전화 수신, 알림 등)|게임 일시정지 등|
|`sceneWillEnterForeground`|백그라운드 → 포그라운드 직전|UI 리프레시 등|
|`sceneDidEnterBackground`|백그라운드 진입|데이터 저장, 작업 정지 등|
|`sceneDidDisconnect`|Scene이 해제됨 (멀티 윈도우 종료)|리소스 해제|

---

## 💡 AppDelegate vs SceneDelegate 차이

|역할|AppDelegate|SceneDelegate|
|---|---|---|
|앱 전체의 생명주기|✅|❌|
|UI 창(Window) 관리|❌|✅|
|초기화 (로그, SDK, 설정 등)|✅|❌|
|루트 뷰컨트롤러 설정|❌ (iOS 13 이상)|✅|
|멀티 윈도우 대응|❌|✅|

---

## ✅ 실전 예시: 코드 기반 앱에서 루트 뷰 설정

```swift
func scene(_ scene: UIScene, willConnectTo session: ..., options: ...) {
    guard let windowScene = scene as? UIWindowScene else { return }

    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = UINavigationController(rootViewController: HomeViewController())
    self.window = window
    window.makeKeyAndVisible()
}
```

> ✅ 이 코드를 수정하지 않으면 앱 실행 시 화면이 뜨지 않습니다.

---

## ❓ SceneDelegate 꼭 써야 하나요?

|상황|사용 권장 여부|
|---|---|
|iOS 12 이하|❌ SceneDelegate 없음, AppDelegate에서 window 설정|
|iOS 13 이상 (기본 앱)|✅ 기본 포함됨|
|코드 기반 앱|✅ 필요 (루트 ViewController 설정 목적)|
|SceneDelegate 제거하고 AppDelegate만 쓰고 싶다면?|가능, Info.plist에서 설정 변경 필요|

---

## 🔧 SceneDelegate 제거하고 AppDelegate만 쓰는 방법 (선택사항)

1. `SceneDelegate.swift` 삭제
2. `Info.plist` → `Application Scene Manifest` 항목 **전체 삭제**
3. AppDelegate에서 직접 window 설정 (iOS 12 방식으로 복귀)

---
## ✍️ 정리 요약

|항목|설명|
|---|---|
|클래스 역할|각 화면(WindowScene)의 생명주기 담당|
|핵심 함수|`scene(_:willConnectTo:)` → 루트 VC 설정|
|도입 버전|iOS 13 이상|
|AppDelegate와의 관계|앱 전체 vs 개별 화면 분담|
