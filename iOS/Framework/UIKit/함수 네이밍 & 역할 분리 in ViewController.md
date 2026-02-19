## ✅ 현재 구조의 장점

|항목|설명|
|---|---|
|`// MARK: UI`|✅ 영역 구분이 명확하고, Xcode 네비게이터에서 보기 좋음|
|`setupStyle()` → 하위 함수 분리|✅ 한눈에 UI 설정 흐름을 이해할 수 있음|
|`setupButton()` / `setupTextField()`|✅ 책임 분리가 잘 되어 있음|

---

## 🔍 개선 제안 (선택 사항)

### 1. `setupButton()` → `configureButtons()` 혹은 `updateButtonStates()`

**"Button을 초기 설정"하는 건지, 현재 상태에 따라 동적으로 UI를 업데이트하는 건지**에 따라 이름을 명확히 하면 더 좋습니다.

```swift
private func configureButtons() // 버튼을 처음 구성할 때
private func updateButtonStates() // BLE 상태에 따라 동적으로 버튼 상태를 갱신할 때
```

---

### 2. `setupTextField()` → `configureTextViews()` 추천

`tvVital`, `tvLog`는 실제로는 `UITextView`이므로, `TextView` 혹은 `Logs` 라고 명시하면 오해를 줄일 수 있습니다.

```swift
private func configureTextViews()
private func setupLogView() // 로그 UI만 따로 관리하는 경우
```

---

### 3. 상태 관련 변수명 보완 (명확성)

현재 코드에서 사용되는 조건:

```swift
if isStartBLE == true {
if isBLEConnected == true {
if isStartDiagnose == true {
```

Swift 스타일 가이드에선 **Bool 타입은 `is`, `has`, `can`, `should` 등으로 시작**하되,  
비교 연산은 `== true`를 생략하는 것이 일반적입니다:

```swift
if isStartBLE {
if isBLEConnected {
if isStartDiagnose {
```

또한 `isStartBLE` → `isBLEStarted`, `didStartBLE` 같은 형태도 가독성이 좋아집니다.

---

## ✅ 종합 추천 스타일

```swift
// MARK: - UI Setup
private func setupUI() {
    configureButtons()
    configureTextViews()
}

private func configureButtons() {
    btnBLE.isEnabled = true
    btnBLE.setTitle("1. BLE Connect", for: .normal)

    btnSelectMode.isEnabled = false
    btnStartDiagnose.isEnabled = false
    btnStartDiagnose.setTitle("3. Start Diagnose", for: .normal)
    btnSelectOutput.isEnabled = true
    btnSelectAutogain.isEnabled = true

    if isBLEStarted {
        btnBLE.setTitle("1. BLE Disconnect", for: .normal)
        if isBLEConnected {
            btnSelectMode.isEnabled = true
            btnStartDiagnose.isEnabled = true
        }
    }

    if isDiagnoseStarted {
        btnSelectOutput.isEnabled = false
        btnStartDiagnose.setTitle("3. Stop Diagnose", for: .normal)
        btnSelectAutogain.isEnabled = false
    }
}

private func configureTextViews() {
    tvVital.text = ""
    tvLog.text = "SDK version : \(SKeeperSDK.version())\n"
}
```

---

## 🧠 결론

| 항목      | 현재 코드                          | 추천 방향                                           |
| ------- | ------------------------------ | ----------------------------------------------- |
| 함수 이름   | `setupXxx()`                   | `configureXxx()`, `updateXxx()` 등 의도를 더 드러내는 이름 |
| Bool 비교 | `if xxx == true`               | `if xxx` 로 간결하게                                 |
| 네이밍 명확성 | `TextField`, `TextView` 구분 불명확 | `LogView`, `StatusTextView` 등 용도 명시             |

---

## ✔️ 배운 점 요약
- setupStyle(), setupButton(), setupTextField() 등 목적에 따라 함수를 분리하면:
	- 가독성이 좋고
	- 유지보수에 유리함
- 특히 ViewController의 `viewDidLoad()`에서 UI 구성 로직을 너무 많이 쓰는 대신
	- 역할별 함수로 분리하면 코드를 빠르게 이해할 수 있음

---

## ✔️ 정리 포인트

- 함수 이름은 명확하게 '무엇을 하는지' 나타내야 함
    
- prefix 예: `setup`, `update`, `configure`, `bind`, `fetch`, `save` 등
    
- UI 작업이면 `setup` prefix가 적합
---
## 🧩 관련 참고

- Clean Code의 "작은 함수"
    
- Swift API Design Guidelines의 Naming (https://www.swift.org/documentation/api-design-guidelines/)