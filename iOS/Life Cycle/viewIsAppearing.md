[공식문서 - viewIsAppearing](https://developer.apple.com/documentation/uikit/uiviewcontroller/viewisappearing(_:))

## 🔍 원문 설명

> **"Notifies the view controller that the system is adding the view controller’s view to a view hierarchy."**

---

## 🧠 해석 & 의미

이 문장은 다음과 같은 뜻입니다:

- **시스템(iOS)**이 뷰 컨트롤러의 **뷰를 뷰 계층(View Hierarchy)**에 추가하고 있다는 것을
- **해당 뷰 컨트롤러에게 알려준다 (Notifies)**

👉 **해당 ViewController의 화면이 실제로 사용자에게 보여지기 직전에 호출되는 메서드**입니다.

---

## 📌 뷰 계층(View Hierarchy)이란?

iOS 앱은 여러 개의 `UIView` 들이 계층 구조(트리 구조)로 구성되어 있어요.

예:
```swift
UIWindow
 └─ UINavigationController.view
     └─ YourViewController.view
         └─ UILabel, UIButton 등
```
`viewIsAppearing(_:)`는 이 계층에 `YourViewController.view`가 **추가될 때** 호출됩니다.

---

## ✅ 용도 예시

```swift
override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)
    print("이 화면이 이제 곧 보입니다.")
}
```

이런 식으로 사용할 수 있고, 다음과 같은 상황에서 유용합니다:

- 뷰가 **실제로 보이기 직전**에 준비작업을 하고 싶을 때
- iOS 17+에서 `UIViewControllerRepresentable` 같은 SwiftUI 인터페이스에서 뷰 전환 시점 제어

---

## 🆕 iOS 17에서 새롭게 도입됨

> `viewIsAppearing(_:)`는 **iOS 17 이상에서만 사용할 수 있는 새로운 라이프사이클 메서드**입니다.

이는 `viewWillAppear`보다도 조금 더 **SwiftUI나 scene 기반 환경에서의 제어를 정교하게** 하기 위한 용도로 등장했습니다.

---

## 📎 요약 정리

|항목|설명|
|---|---|
|메서드 이름|`viewIsAppearing(_:)`|
|iOS 버전|iOS 17 이상|
|호출 시점|View가 뷰 계층에 **추가되기 직전**|
|용도|화면 표시 직전의 작업 처리|
|관련 메서드|`viewWillAppear`, `viewDidAppear`|