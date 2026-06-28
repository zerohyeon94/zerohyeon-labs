# Jday App Store 심사 트러블슈팅 정리

작성일: 2026-06-12
프로젝트: [[개요|Jday]]
관련 문서: [[스토어 업로드 체크리스트]], [[macOS App Store 검증 오류 - LSApplicationCategoryType와 App Sandbox]]

## 개요

빌드 1(1.0.0) 제출 후 iPad에서 **실행 즉시 크래시**로 반려(Guideline 2.1(a)), 이후 재제출 과정에서 **아카이브 검증 오류**와 **계정/인증서 문제**가 연속으로 발생했다. 이 노트는 그 모든 이슈와 해결 방법을 한곳에 정리한다.

핵심 교훈: **`xcodegen`이 `project.yml`의 `info:` 블록으로 Info.plist를 재생성하므로, Info.plist에 직접 추가한 키는 사라진다. 모든 Info.plist 키는 반드시 `project.yml`에 명시해야 한다.**

---

## 1. 실행 즉시 크래시 (Guideline 2.1(a)) — 가장 중요

### 증상
- 리뷰 기기 iPad Air 11" (M3), iPadOS 26.5에서 실행 즉시 크래시
- 크래시 로그 시그니처:
  ```text
  Thread 0 (com.apple.main-thread)
    _assertionFailure(...)
    swift_unexpectedError
    static App.main()
  EXC_BREAKPOINT (SIGTRAP)
  ```
- 즉 앱 `init()`의 `ModelContainer` 생성에서 throw된 에러가 잡히지 않아 크래시.

### 원인
SwiftData 모델이 **CloudKit과 비호환**이었다. CloudKit 동기화(`cloudKitDatabase: .automatic`)는 모든 비-optional 저장 속성에 **기본값이 반드시 있어야** 한다. 제출 빌드의 모델은 기본값이 없었다.

```swift
// ❌ 크래시 유발 (CloudKit 비호환)
var title: String
var isDone: Bool
var date: Date
var priority: Priority
```

게다가 폴백 코드조차 CloudKit(`.automatic` 기본값)을 사용해 또 throw → 마지막 `try!`에서 크래시했다.

### 해결
1. 모든 모델 속성에 기본값 부여 → CloudKit 호환
   ```swift
   var title: String = ""
   var isDone: Bool = false
   var date: Date = Date()
   var priority: Priority = Priority.medium
   ```
2. `ModelContainer` 폴백을 명시적 단계로 재구성
   - `.automatic`(CloudKit) → 실패 시 `.none`(로컬 전용) → 실패 시 인메모리
   - `try!` 크래시 경로 제거

파일: `Jday/App/JdayApp.swift`, `Jday/Models/*.swift`

### 검증
- iPad Air 11" (M3) 시뮬레이터에 클린 설치 후 실행 → 5초 이상 정상 유지(이전엔 즉시 크래시)

---

## 2. macOS — App Sandbox + iCloud entitlements 분리

iOS와 macOS가 같은 `Jday.entitlements`(iOS용 `aps-environment` 포함)를 공유했는데, **macOS에서 CloudKit을 쓰려면 App Sandbox가 필수**다. 플랫폼별 entitlements를 분리했다.

- `Jday/Resources/Jday-macOS.entitlements` 생성 (app-sandbox + network.client + iCloud)
- `project.yml`에서 플랫폼 조건부로 연결:
  ```yaml
  CODE_SIGN_ENTITLEMENTS[sdk=iphoneos*]: Jday/Resources/Jday.entitlements
  CODE_SIGN_ENTITLEMENTS[sdk=iphonesimulator*]: Jday/Resources/Jday.entitlements
  CODE_SIGN_ENTITLEMENTS[sdk=macosx*]: Jday/Resources/Jday-macOS.entitlements
  ```

> 상세: [[macOS App Store 검증 오류 - LSApplicationCategoryType와 App Sandbox]]

---

## 3. 아카이브 검증 — LSApplicationCategoryType 누락

### 증상
```text
The product archive is invalid. The Info.plist must contain a
LSApplicationCategoryType key, whose value is the UTI for a valid category.
```

### 원인
`xcodegen generate`가 `project.yml`의 `info:` 블록으로 Info.plist를 **재생성**하면서, Info.plist에 직접 넣었던 `LSApplicationCategoryType`가 사라졌다.

### 해결
`project.yml`의 `info.properties`에 직접 명시:
```yaml
info:
  properties:
    LSApplicationCategoryType: public.app-category.productivity
```

---

## 4. 아카이브 검증 — UISupportedInterfaceOrientations 누락

### 증상
```text
Invalid bundle. No orientations were specified in the com.zerohyeon.jday bundle.
To support iPad multitasking, specify the "...Portrait, PortraitUpsideDown,
LandscapeLeft, LandscapeRight" orientations for UISupportedInterfaceOrientations.
```

### 원인
3번과 동일. xcodegen 재생성으로 방향 키가 누락. iPad 멀티태스킹은 **4개 방향 전체**를 요구한다.

### 해결
`project.yml`의 `info.properties`에 직접 명시:
```yaml
UISupportedInterfaceOrientations:        # iPhone (3개)
  - UIInterfaceOrientationPortrait
  - UIInterfaceOrientationLandscapeLeft
  - UIInterfaceOrientationLandscapeRight
UISupportedInterfaceOrientations~ipad:   # iPad (4개 전체, 멀티태스킹)
  - UIInterfaceOrientationPortrait
  - UIInterfaceOrientationPortraitUpsideDown
  - UIInterfaceOrientationLandscapeLeft
  - UIInterfaceOrientationLandscapeRight
```

검증: Release 빌드 산출물 `Info.plist`에서 iPhone 3개 / iPad 4개 / 카테고리 키 모두 확인.

---

## 5. 계정 — Distribute App 시 PLA 미동의 + 배포 인증서 없음

### 증상
```text
Unable to process request - PLA Update available
You currently don't have access to this membership resource.
To resolve this issue, agree to the latest Program License Agreement...

No signing certificate "Mac Installer Distribution" found
No signing certificate "Mac App Distribution" found
```

### 원인
- 루트 원인: Apple **Program License Agreement(PLA)** 새 버전 미동의 → 모든 계정 리소스 접근 차단.
- 그 결과 Xcode가 배포 인증서를 자동 발급하지 못해 "인증서 없음"으로 이어짐.
- 키체인에 `Apple Development` 인증서만 있고 배포용(`Apple Distribution` 등)은 없었음.

### 해결
1. developer.apple.com/account → **Account Holder**로 로그인 → 상단 배너 **Review/Agree**로 최신 PLA 동의 (코드/앱 문제 아님)
2. Xcode → Settings → Accounts → Manage Certificates → `+` → **Apple Distribution** 생성
3. Distribute App 재시도

---

## 6. Guideline 2.1 - Information Needed (정보 요청, 반려 아님)

크래시와 별개로, 로그인/결제/민감권한이 없는 앱이라 리뷰어가 동작을 파악할 정보를 요청했다. **코드 수정 불필요** — App Store Connect → App Review Information → Notes에 영문으로 회신 + 실기기 화면 녹화 첨부.

핵심 답변:
- **로그인/계정 없음**, 실행 즉시 사용. 데이터는 SwiftData 로컬 저장 + 사용자 본인 iCloud(CloudKit) 자동 동기화. 데모 계정 불필요.
- **외부 서비스는 Apple CloudKit + UserNotifications 뿐.** 제3자 서버/결제/AI/분석 없음.
- 테스트 기기: iOS는 iPhone 16 Pro Max / iPad Pro (2020), macOS는 MacBook Pro (Apple M3).

---

## 재발 방지 체크리스트 (제출 전)

- [ ] SwiftData 모델의 모든 비-optional 속성에 기본값이 있는가? (CloudKit 호환)
- [ ] `ModelContainer` 생성이 `try!`로 크래시하지 않고 단계적 폴백(.automatic→.none→인메모리)을 갖는가?
- [ ] **Info.plist 키는 Info.plist가 아니라 `project.yml`의 `info.properties`에 있는가?** (xcodegen 재생성 대비)
  - [ ] `LSApplicationCategoryType`
  - [ ] `UISupportedInterfaceOrientations` (iPhone) / `~ipad` (4개 전체)
- [ ] macOS entitlements에 `com.apple.security.app-sandbox` = true
- [ ] 플랫폼별 entitlements가 `CODE_SIGN_ENTITLEMENTS[sdk=...]`로 분리 연결됐는가?
- [ ] 재제출 시 빌드 번호(`CURRENT_PROJECT_VERSION`)를 올렸는가?
- [ ] 수정 후 **Archive를 새로 생성**했는가? (이전 아카이브 재사용 금지)
- [ ] PLA 동의 완료 + 배포 인증서 존재 확인
- [ ] App Review Notes 작성 + 실기기 화면 녹화 첨부

## 한 줄 요약

빌드 1의 iPad 실행 크래시는 **SwiftData 모델의 CloudKit 비호환(기본값 누락)** 때문이었고, 모델 기본값 + 안전한 ModelContainer 폴백으로 해결했다. 이후 아카이브 검증 오류(`LSApplicationCategoryType`, 방향 키)는 모두 **xcodegen이 Info.plist를 재생성하며 키를 덮어쓴** 동일 원인이라 `project.yml`에 직접 명시해 해결했고, 배포 단계의 PLA/인증서 문제는 계정 측 약관 동의로 풀린다.
