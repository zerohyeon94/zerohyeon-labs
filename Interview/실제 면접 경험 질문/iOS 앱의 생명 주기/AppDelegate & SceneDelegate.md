iOS 13부터 “앱 생명주기”가 **AppDelegate(앱 단위)** 와 **SceneDelegate(화면/윈도우 단위)** 로 나뉘었어요. 핵심은:

- **AppDelegate = 앱 전체(프로세스) 레벨 이벤트**
    
- **SceneDelegate = 각 UI 인스턴스(윈도우/화면) 레벨 이벤트**

---
## 1) 왜 분리됐나요?

iPadOS에서 **멀티 윈도우**(한 앱을 여러 창으로 띄우기)가 생기면서, “앱은 하나인데 화면(윈도우)은 여러 개”가 될 수 있어요.

그래서 iOS 13+에서는:

- 앱 전체의 시작/종료/푸시/백그라운드 작업 같은 건 **AppDelegate**
    
- 각 창의 표시/숨김/활성화 같은 UI 생명주기는 **SceneDelegate**
---
## 2) AppDelegate 역할 (앱 전체, 프로세스 단위)

AppDelegate는 “앱이 OS에 의해 런칭되고, 시스템 이벤트를 받는 대표자”예요.

주요 책임 예시:

- **앱 런칭 초기 설정**
    
    - `application(_:didFinishLaunchingWithOptions:)` : 앱이 런칭된 직후 호출됩니다. 전역 설정에 사용
        
    - DI 컨테이너 초기화, 로깅/크래시 SDK, 설정 로드 등
        
- **푸시 알림 / APNs 토큰**
    
    - `didRegisterForRemoteNotificationsWithDeviceToken`
        
    - `didReceiveRemoteNotification`
        
- **앱 레벨 백그라운드 처리(일부)**
    
    - (iOS 13 이후엔 UI 전이는 Scene이 주로 담당하지만)
        
    - 백그라운드 fetch, remote notification 핸들링 같은 “앱 단위 이벤트”는 여전히 AppDelegate가 중심인 경우가 많음
        
- **Scene 생성/관리 브릿지**
    
    - `application(_:configurationForConnecting:options:)` : 새로운 Scene을 만들 때 사용할 설정(Configuration)을 반환
        
    - “새 Scene(윈도우)이 필요할 때 어떤 설정을 쓸지” 결정

> 요약: **앱 프로세스가 받는 시스템 이벤트의 관문 + 공통 초기화**

---
## 3) SceneDelegate 역할 (화면 단위, 윈도우/씬)

SceneDelegate는 “각 창(UI 세션)마다 하나씩 존재”할 수 있어요. 
여기서부터가 우리가 흔히 말하는 “포그라운드/백그라운드” 전이 콜백의 중심입니다.

주요 책임 예시:

- **윈도우 생성 + 루트 뷰컨트롤러 설정**
    
    - `scene(_:willConnectTo:options:)` : - UIWindow를 생성하고 화면을 그릴 준비를 합니다. (과거 `AppDelegate`의 런칭 역할 일부를 가져옴)
        
    - 여기서 `window = UIWindow(windowScene: ...)`
        
    - `window?.rootViewController = ...`
        
    - `window?.makeKeyAndVisible()`
        
- **UI 상태 전이(포그라운드/백그라운드)**
    
    - `sceneDidBecomeActive` : (Inactive → Active) : - 앱이 활성화되어 사용자와 상호작용이 가능한 상태
        
    - `sceneWillResignActive` : (Active → Inactive) : 앱이 잠시 비활성화된 상태입니다 (예: 전화가 오거나 알림 센터를 내릴 때).
        
    - `sceneWillEnterForeground` : (Background → Foreground)
        
    - `sceneDidEnterBackground` : (Foreground → Background) : 앱이 화면에서 사라져 백그라운드로 진입한 상태
        
- **상태 복원 / 사용자 활동**
    
    - Handoff, Universal Links, state restoration 등 “UI 세션과 연관된 것”

> 요약: **“창(화면) 생명주기”와 “그 창의 UI 구성” 담당**

---

## 4) 같은 상황을 “누가 받는지” 감으로 정리

### 앱 처음 실행

- AppDelegate: `didFinishLaunchingWithOptions`
    
- SceneDelegate: `willConnectTo` (루트 VC 세팅은 여기서)

### 홈으로 나가서 백그라운드 진입

- (iOS 13+) **SceneDelegate 쪽 콜백이 핵심**
    
    - `sceneWillResignActive` → `sceneDidEnterBackground`

### 다시 앱으로 돌아옴

- `sceneWillEnterForeground` → `sceneDidBecomeActive`

### 푸시 알림 수신/토큰 등록

- 보통 **AppDelegate**가 담당 (UNUserNotificationCenterDelegate와 함께)

---

## 5) “그럼 AppDelegate는 이제 필요 없나요?”

아니요. iOS 13+에서도 AppDelegate는 여전히 중요해요.

- **앱 공통 초기화**
    
- **푸시/백그라운드 이벤트**
    
- **Scene 설정 제공**
    
- **외부 SDK 초기화 지점**

다만 “UI 라이프사이클(포그라운드/백그라운드)”은 대부분 SceneDelegate로 옮겨졌다고 생각하면 정확합니다.

---

## 6) 면접/실무에서 깔끔한 한 줄 정리

- **AppDelegate**: 앱 전체(프로세스) 단위의 생명주기와 시스템 이벤트(푸시/앱 런칭/Scene 구성) 관리
    
- **SceneDelegate**: 각 화면(윈도우/Scene) 단위의 생명주기(Active/Inactive/Background)와 루트 UI 구성 관리

---

### 비교 요약표

| **구분**    | **AppDelegate**                               | **SceneDelegate**                            |
| --------- | --------------------------------------------- | -------------------------------------------- |
| **관리 대상** | 앱 프로세스 (Application Process)                  | 앱 화면 (UI Scene)                              |
| **주요 책임** | 앱 런칭, 종료, 푸시 알림, 씬 세션 관리                      | UI 상태 변화 (Active, Background 등), UIWindow 관리 |
| **비유**    | **회사 대표 (CEO)**: 회사 전체 운영, 부서(Scene) 개설/폐쇄 결정 | **부서장 (Manager)**: 실제 업무(UI) 진행, 업무 시작/휴식 관리 |
| **실행 횟수** | 앱 당 1개 (싱글톤)                                  | 화면(Scene) 개수만큼 생성 (멀티 윈도우 시 여러 개)            |