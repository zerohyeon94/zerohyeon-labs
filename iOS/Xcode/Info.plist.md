`Info.plist`는 iOS 개발에서 반드시 이해하고 있어야 하는 **앱의 메타데이터를 담는 핵심 파일**입니다.  

---
## 📘 Info.plist란?

**Info.plist**는:

- **Property List** 형식(XML 기반)으로 작성된 파일이고
- 앱, 프레임워크, Extension 등에 대한 **메타데이터**를 담고 있음
- 이 메타데이터는 **앱 실행 시 시스템이 먼저 읽음**

즉, 시스템(OS)이 앱을 "어떻게 실행할지, 어떤 권한이 필요한지" 등을 판단하기 위한 **설정 파일**입니다.

---

## 🧠 Info.plist의 주요 역할

|역할|설명|
|---|---|
|앱 기본 정보 제공|앱 이름, 번들 ID, 버전 등|
|OS와 인터페이스|카메라, 마이크, 위치 등 권한 요청 메시지 정의|
|런타임 동작 제어|앱이 어떤 화면에서 시작할지, SceneDelegate 사용 여부 등|
|Capabilities 설정 반영|Background Modes, Push Notification 등|

---

## 🔥 iOS 개발자가 반드시 알아야 하는 `Info.plist` 항목

### 1. **`CFBundleIdentifier`** – 앱의 고유 ID

```xml
<key>CFBundleIdentifier</key> <string>com.yourcompany.yourapp</string>
```

- 앱스토어와 시스템이 이 앱을 구분하는 식별자

---

### 2. **`CFBundleDisplayName`** – 홈 화면에 보이는 앱 이름

```xml
<key>CFBundleDisplayName</key> <string>WithAPet</string>
```

---

### 3. **버전 정보**

```xml
<key>CFBundleShortVersionString</key> <!-- 사용자용 표시 버전 -->
<string>1.0.0</string>

<key>CFBundleVersion</key> <!-- 빌드 넘버 -->
<string>42</string>
```

- TestFlight, 앱스토어 배포 시 꼭 구분되어야 함

---

### 4. **권한 요청 메시지** (📌 매우 중요!)

|권한|Key 이름|설명 예시|
|---|---|---|
|카메라|`NSCameraUsageDescription`|이 앱은 프로필 사진을 촬영하기 위해 카메라 접근이 필요합니다|
|마이크|`NSMicrophoneUsageDescription`|청진 소리를 녹음하기 위해 마이크 권한이 필요합니다|
|위치|`NSLocationWhenInUseUsageDescription`|지도에서 현재 위치를 표시하려면 위치 정보가 필요합니다|

👉 이 항목이 없으면 앱이 크래시 나거나 심사에서 거절됩니다.

---

### 5. **Launch screen 설정**
```xml
<key>UILaunchStoryboardName</key> <string>LaunchScreen</string>
```

---

### 6. **SceneDelegate 여부 (`iOS 13+`)**

```xml
<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <false/>
    <key>UISceneConfigurations</key>
    ...
</dict>
```

---

### 7. **배경 작업 관련 설정 (Background Modes)**

```xml
<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
    <string>audio</string>
</array>
```

- BLE, 오디오, 백그라운드 fetch 등을 사용할 때 필요    

---

### 8. **ATS 설정 (App Transport Security)**

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

- 보안되지 않은 HTTP 통신을 허용할 때 사용 (단, 심사 시 주의)

---

### 9. **Main Interface (`UIKit`)**

```xml
<key>UIMainStoryboardFile</key>
<string>Main</string>
```

- 앱 실행 시 처음 보여줄 스토리보드 설정 (`SwiftUI`에서는 안 씀)

---

## 💡 개발자가 자주 실수하는 포인트

|항목|설명|
|---|---|
|권한 키 누락|`NSCameraUsageDescription` 없이 카메라 접근 시 앱 크래시 발생|
|번들 ID 중복|`com.yourcompany.app`이 다른 앱과 같으면 배포 불가|
|버전, 빌드 정보 미변경|앱스토어 업로드 시 이전 빌드와 버전 동일하면 reject|
|LaunchScreen 미설정|검은 화면 또는 심사 거절 가능|

---

## 🛠 실전 팁

- Xcode에서 `Info.plist`는 GUI로도 수정 가능 (에디터 클릭)
- 단, Git 충돌 등으로 **직접 XML 수정이 필요한 경우도 많음**
- Fastlane 등으로 자동화할 때는 이 값을 CLI에서 조작하기도 함

---

## ✅ 요약

|항목|역할|꼭 알아야 하는 이유|
|---|---|---|
|CFBundleIdentifier|앱 고유 ID|앱 구분 및 배포 식별|
|권한 설명 키|사용자 보호|심사 통과 필수 항목|
|버전 & 빌드|앱 업데이트 관리|TestFlight / 앱스토어 구분|
|Launch Screen|앱 시작화면 제어|UX 및 심사 품질에 영향|
|Background Modes|BLE 등 백그라운드 기능|iOS 시스템 정책에 따른 제한 해제|