# AVCaptureSession — 세션 생명주기와 성능 최적화

> [[iOS 학습 인덱스]] > AVFoundation
> 작성일: 2026-05-01 | 태그: #iOS #AVFoundation #Camera #성능최적화

---

## 왜 이걸 알아야 하나?

ZipJoong에서 발견된 두 가지 현상이 이 개념과 직결된다:

1. **앱 초기 로딩 지연** — splash 이후 카메라 화면 진입 전 오래 걸림
2. **타이머 종료 후 로딩 지연** — 종료 버튼 누르면 다음 동작이 늦게 반응함

둘 다 `AVCaptureSession`의 `startRunning()` / `stopRunning()` 호출 타이밍 문제일 가능성이 높다.

---

## AVCaptureSession 기본 구조

```
Input (카메라/마이크)
    ↓
AVCaptureSession  ←── 데이터 흐름 관리자
    ↓
Output (영상/사진/데이터)
```

- `AVCaptureDeviceInput` — 카메라 디바이스를 세션에 연결
- `AVCaptureSession` — 입력 → 출력 데이터 흐름 조율
- `AVCaptureVideoDataOutput` — 프레임 단위로 영상 데이터 추출 (CoreML/Vision에 전달)
- `AVCaptureVideoPreviewLayer` — 카메라 화면을 UI에 표시

---

## 핵심 문제: startRunning()은 블로킹 호출이다

```swift
// ❌ 메인 스레드에서 호출 — UI를 블록한다
func setupCamera() {
    session.startRunning()  // 수백ms ~ 수초 소요, 이 동안 UI 멈춤
}

// ✅ 백그라운드 스레드에서 호출
func setupCamera() {
    DispatchQueue.global(qos: .userInitiated).async {
        self.session.startRunning()
    }
}

// ✅ Swift Concurrency 방식
func setupCamera() async {
    await Task.detached(priority: .userInitiated) {
        self.session.startRunning()
    }.value
}
```

`startRunning()`과 `stopRunning()`은 **동기 블로킹 호출**이다.
메인 스레드에서 실행하면 그 시간 동안 UI가 완전히 멈춘다.

---

## 세션 생명주기

```
[앱 시작 or 화면 진입]
        ↓
  beginConfiguration()   ← 변경 사항 묶기 시작
  addInput(cameraInput)
  addOutput(videoOutput)
  commitConfiguration()  ← 변경 사항 반영
        ↓
  startRunning()         ← 백그라운드에서 실행 (블로킹)
        ↓
  [카메라 활성 상태 — 프레임 수신 중]
        ↓
  stopRunning()          ← 백그라운드에서 실행 (블로킹)
        ↓
[화면 이탈 or 앱 백그라운드]
```

---

## ZipJoong 분석 포인트

CameraService를 열었을 때 확인할 것:

| 확인 항목 | 정상 패턴 | 문제 패턴 |
|-----------|-----------|-----------|
| `startRunning()` 호출 스레드 | `DispatchQueue.global` | `DispatchQueue.main` |
| `stopRunning()` 호출 스레드 | `DispatchQueue.global` | `DispatchQueue.main` |
| 세션 초기화 시점 | 화면 진입 직전 or 앱 시작 시 한 번 | 매번 재생성 |
| 세션 재사용 여부 | 한 번 생성 후 start/stop 반복 | 매번 새 세션 생성 |

---

## 최적화 패턴

### 1. 세션을 앱 시작 시 한 번만 초기화

```swift
// CameraService 싱글톤 또는 앱 레벨에서 한 번 초기화
class CameraService {
    static let shared = CameraService()
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session")
    
    func start() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func stop() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
}
```

### 2. 전용 큐(sessionQueue) 사용

AVFoundation 공식 문서에서 권장하는 패턴이다.
세션 관련 모든 작업(설정 변경, start/stop)을 하나의 직렬 큐에서 처리한다.
이렇게 하면 순서 보장 + 메인 스레드 해방이 동시에 해결된다.

---

## 면접 답변으로 쓸 수 있는 한 줄

> "AVCaptureSession의 startRunning()은 동기 블로킹 호출입니다. 메인 스레드에서 호출하면 UI가 멈추기 때문에, 전용 serial queue(sessionQueue)를 만들어 모든 세션 제어를 해당 큐에서 처리하는 것이 Apple 권장 패턴입니다."

---

## 연결 개념

- [[Task & @MainActor - UI 업데이트 타이밍]] — 같은 맥락: 무거운 작업을 메인 스레드 밖으로
- [[GCD (Grand Central Dispatch)]] — DispatchQueue.global 사용 패턴
- [[동시성 Concurrency]] — Swift Concurrency로 전환 시

---

> 연결: [[iOS 학습 인덱스]] | [[Task & @MainActor - UI 업데이트 타이밍]] | [[CS 학습 인덱스]]
