> [[iOS 학습 인덱스]] > Swift > 동시성
> 작성일: 2026-04-30 | 태그: #Swift #Concurrency #MainActor #SwiftUI

---

## 왜 이걸 알아야 하나?

SwiftUI에서 `@Published` 프로퍼티를 여러 개 연속으로 바꿀 때,
화면 전환(`fullScreenCover`, `NavigationStack`)이 **예상대로 작동하지 않는 경우**가 있다.
ZipJoong의 뽀모도로 버튼 문제가 정확히 이 케이스다.

---

## 문제 상황

```swift
// ❌ 문제 있는 코드
func startPomodoroTimer() {
    pomodoroPhase = .focus      // @Published 변경 1
    pomodoroRound = 1           // @Published 변경 2
    showPomodoroView = true     // @Published 변경 3 — 화면 전환 트리거
    startTimerWithPlan(nil)     // 카메라 세션 시작 (무거운 작업)
}
```

`showPomodoroView = true`로 fullScreenCover가 열리기 **시작하는 동시에**
`startTimerWithPlan(nil)` 이 카메라 세션을 초기화하려 한다.

SwiftUI는 여러 `@Published` 변경을 **한 RunLoop cycle에 묶어서 처리**하려 하는데,
그 사이에 무거운 카메라 초기화가 끼어들면 애니메이션이 완료되기 전에 리소스를 선점해버린다.
결과: fullScreenCover가 열리지 않거나 화면이 멈추는 현상.

---

## 해결: `Task { @MainActor in }` 으로 타이밍 분리

```swift
// ✅ 수정된 코드
func startPomodoroTimer() {
    pomodoroPhase = .focus
    pomodoroRound = 1
    targetDuration = pomodoroFocusDuration
    showPomodoroView = true         // SwiftUI에게 화면 전환 신호
    
    Task { @MainActor in            // 현재 RunLoop cycle 이후로 실행 지연
        startTimerWithPlan(nil)     // fullScreenCover 애니메이션 완료 후 실행
    }
}
```

### 왜 이게 동작하는가?

`Task { }` 는 **새로운 비동기 작업**을 스케줄링한다.
현재 동기 실행 흐름이 끝난 뒤 다음 기회에 실행되므로,
SwiftUI가 `showPomodoroView = true`에 반응해 fullScreenCover 애니메이션을 먼저 완료할 시간을 얻는다.

`@MainActor` 는 이 Task가 **메인 스레드에서 실행**되도록 보장한다.
UI 업데이트는 반드시 메인 스레드여야 하므로 필수.

```
동기 흐름:
  showPomodoroView = true
  → SwiftUI RunLoop: "화면 전환 시작"
  → [현재 동기 실행 종료]

다음 RunLoop:
  Task { @MainActor in startTimerWithPlan(nil) }
  → fullScreenCover 애니메이션 완료된 상태에서 카메라 초기화
```

---

## @MainActor란?

Swift Concurrency에서 **메인 스레드(Main Thread) 실행을 보장하는 Actor**.

```swift
// 클래스 전체를 메인 스레드에서 실행
@MainActor
class MyViewModel: ObservableObject {
    @Published var title = ""
}

// 특정 함수만 메인 스레드에서 실행
@MainActor
func updateUI() {
    title = "업데이트됨"
}

// Task 내에서 메인 스레드 보장
Task { @MainActor in
    self.isLoading = false
}
```

UIKit에서 `DispatchQueue.main.async { }` 로 쓰던 것을 Swift Concurrency에서는 `Task { @MainActor in }` 또는 `await MainActor.run { }` 으로 표현한다.

---

## 언제 쓰는가?

| 상황 | 해결 방법 |
|------|-----------|
| 화면 전환 직후 무거운 작업 실행 | `Task { @MainActor in }` 으로 지연 |
| 백그라운드 작업 완료 후 UI 업데이트 | `await MainActor.run { }` |
| ViewModel 전체를 UI 안전하게 | `@MainActor class ViewModel` |
| 특정 메서드만 메인 스레드 보장 | `@MainActor func updateTitle()` |

---

## 연결 개념

- [[동시성 Concurrency]] — async/await, Task 전체 개념
- [[GCD (Grand Central Dispatch)]] — UIKit 시절의 DispatchQueue.main.async
- [[📘 01.1. 스레드(Thread)]] — 메인 스레드가 왜 중요한가

---

> 연결: [[iOS 학습 인덱스]] | [[CS 학습 인덱스]]
