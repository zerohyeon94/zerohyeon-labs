[공식문서 - NotificationCenter](https://developer.apple.com/documentation/foundation/notificationcenter)
## ✅ 개념 정리: 무엇이고 왜 쓰는가?

> **NotificationCenter**는 Swift에서 제공하는 **Pub/Sub(발행-구독) 패턴의 구현체**입니다.

즉, 객체 간 직접 연결 없이도 **"A라는 이벤트가 발생했을 때" B, C, D가 반응**할 수 있는 시스템입니다.

---

## 📊 구조 요약

|역할|설명|예시 코드|
|---|---|---|
|**Notification**|알림 자체 (`이름`, `userInfo`, `object`)|`.counterUpdated`, `["value": 5]`|
|**Post**|이벤트를 보냄 (발행자)|`NotificationCenter.default.post(...)`|
|**Observer**|이벤트를 받음 (구독자)|`addObserver(...)`|
|**Name**|이벤트 식별 키|`Notification.Name("userDidLogin")`|
|**UserInfo**|알림에 실어 보낼 데이터|`[String: Any]` 딕셔너리|

---

## 🧠 NotificationCenter의 작동 방식

1. `AViewController`는 어떤 이벤트 발생 시 `.post(name:object:userInfo:)`로 알림을 **전파**
    
2. `BViewController`, `CLogger`, `DManager` 등은 해당 이름에 대해 **Observer 등록**
    
3. 알림이 오면 등록한 `selector` 또는 클로저가 **자동 호출**

> 👉 발신자(post)와 수신자(observer)는 서로를 **몰라도 통신 가능**

---

## 🔁 내부 작동 흐름 (간단 요약)

```swift
// 1. 수신자 등록
NotificationCenter.default.addObserver(self, selector: ..., name: .loginSuccess, object: nil)

// 2. 발신자 알림 전송
NotificationCenter.default.post(name: .loginSuccess, object: nil, userInfo: ["id": "Jo"])

// 3. 수신자에서 자동 호출
@objc func handleLogin(_ notification: Notification) {
    let id = notification.userInfo?["id"] as? String
}
```

---

## 📌 실무에서 자주 쓰는 상황

|상황|설명|
|---|---|
|로그인 성공|모든 뷰컨에서 반응 필요할 때 (`userDidLogin`)|
|BLE 연결 상태 변화|여러 뷰/모듈이 반응해야 할 때|
|테마 변경 (다크모드)|앱 전체에 알림 전파|
|백엔드 응답 공유|`DataManager` → UI 알림 전파|
|RxSwift로 대체 전|가장 보편적인 통신 수단|

---

## ✅ `.object` vs `.userInfo`

|파라미터|역할|사용 예시|
|---|---|---|
|`object:`|발신자 객체|특정 sender만 구독하고 싶을 때|
|`userInfo:`|추가 데이터|`["id": "Jo", "token": "abc"]`|

```swift
// 1. 수신자 등록
NotificationCenter.default.addObserver(self, selector: ..., name: .loginSuccess, object: nil)

// 2. 발신자 알림 전송
NotificationCenter.default.post(name: .loginSuccess, object: nil, userInfo: ["id": "Jo"])

// 3. 수신자에서 자동 호출
@objc func handleLogin(_ notification: Notification) {
    let id = notification.userInfo?["id"] as? String
}
```

---

## 🧼 메모리 주의사항

- `NotificationCenter`는 **강한 참조를 하지 않음**
    
- 하지만 옵저버 등록 후 **명시적으로 해제하지 않으면 selector가 살아있을 수 있음**
    
- 따라서 `deinit` 또는 `viewWillDisappear` 등에서 **반드시 removeObserver 호출** 필요

```swift
deinit {
    NotificationCenter.default.removeObserver(self)
}
```

---

## 🔁 RxSwift와의 관계

`NotificationCenter`는 RxSwift에서 다음처럼 사용됩니다:

```swift
NotificationCenter.default.rx.notification(.someEventName)
    .subscribe(onNext: { notification in
        ...
    })
    .disposed(by: bag)
```

- Rx로 전환하면 옵저버 관리가 자동화되고 체이닝, 필터링이 가능해짐

---

## ✅ 정리

| 장점                                       | 단점                            |
| ---------------------------------------- | ----------------------------- |
| View → View, Manager → VC 등 **간접 통신 가능** | observer 해제 누락 시 의도치 않은 호출 가능 |
| 다양한 모듈/레이어 연결에 유용                        | 이벤트 흐름이 추적하기 어려울 수 있음         |
| RxSwift 없이도 매우 유연하게 구현 가능                | 복잡한 상황에서는 로직 관리 어려움           |

---

> [[iOS 학습 인덱스]]