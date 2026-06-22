# Jday macOS App Store 검증 오류 원인 정리

작성일: 2026-06-08
프로젝트: [[개요|Jday]]
관련 문서: [[스토어 업로드 체크리스트]]

## 상황

macOS 앱 아카이브를 App Store Connect에 검증할 때 아래 오류가 발생했다.

```text
Validation failed
The product archive is invalid. The Info.plist must contain a LSApplicationCategoryType key,
whose value is the UTI for a valid category.
```

```text
Validation failed
App sandbox not enabled. The following executables must include the
"com.apple.security.app-sandbox" entitlement with a Boolean value of true
in the entitlements property list.
```

## 원인

두 오류 모두 앱 기능 구현 문제가 아니라 macOS App Store 제출에 필요한 메타데이터와 권한 설정이 빠져서 발생한 문제다.

### 1. LSApplicationCategoryType 누락

macOS App Store에 제출하는 앱은 `Info.plist`에 앱 카테고리를 나타내는 `LSApplicationCategoryType` 값을 포함해야 한다.

Jday의 `Info.plist`에는 iOS 관련 키와 알림 설명은 있었지만, macOS App Store 카테고리 키가 없었다. 그래서 App Store Connect 검증 단계에서 "유효한 카테고리 UTI가 없다"고 판단했다.

Jday는 할 일, 일정, 이슈를 관리하는 업무 관리 앱이므로 생산성 카테고리로 지정하는 것이 자연스럽다.

```xml
<key>LSApplicationCategoryType</key>
<string>public.app-category.productivity</string>
```

### 2. App Sandbox entitlement 누락

Mac App Store에 제출하는 macOS 앱은 기본적으로 App Sandbox가 활성화되어 있어야 한다.

Jday의 `Jday.entitlements`에는 CloudKit 관련 권한만 있었고, 샌드박스 권한인 `com.apple.security.app-sandbox`가 없었다. 그래서 검증 단계에서 실행 파일 `Jday.app/Contents/MacOS/Jday`가 sandbox entitlement를 포함하지 않는다고 판단했다.

필요한 설정은 다음과 같다.

```xml
<key>com.apple.security.app-sandbox</key>
<true/>
```

Jday는 SwiftData + CloudKit 동기화를 사용하므로, 샌드박스 안에서 네트워크로 iCloud/CloudKit 통신이 가능하도록 outgoing network 권한도 함께 두는 것이 안전하다.

```xml
<key>com.apple.security.network.client</key>
<true/>
```

## 적용한 수정

### Info.plist

파일: `Jday/Resources/Info.plist`

```xml
<key>LSApplicationCategoryType</key>
<string>public.app-category.productivity</string>
```

### Entitlements

파일: `Jday/Resources/Jday.entitlements`

```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.network.client</key>
<true/>
```

## 검증 결과

로컬에서 아래 항목을 확인했다.

- `plutil -lint Jday/Resources/Info.plist Jday/Resources/Jday.entitlements` 통과
- `Jday_macOS` Release 빌드 성공
- 빌드 로그의 최종 서명 entitlements에 `com.apple.security.app-sandbox = 1` 포함 확인
- 빌드 로그의 최종 서명 entitlements에 `com.apple.security.network.client = 1` 포함 확인

## 재발 방지 체크리스트

macOS App Store 제출 전에 아래 항목을 확인한다.

- [ ] `Info.plist`에 `LSApplicationCategoryType`이 있는가?
- [ ] Jday 카테고리가 `public.app-category.productivity`로 설정되어 있는가?
- [ ] macOS 타깃의 entitlements에 `com.apple.security.app-sandbox`가 `true`로 들어가 있는가?
- [ ] CloudKit/iCloud 동기화를 사용한다면 `com.apple.security.network.client`가 `true`로 들어가 있는가?
- [ ] Xcode Archive 이후 Validate App을 다시 실행했는가?
- [ ] App Store Connect 업로드용 아카이브가 Debug가 아니라 Release/Distribution 설정으로 만들어졌는가?

## 참고 링크

- Apple Developer Documentation: LSApplicationCategoryType  
  https://developer.apple.com/documentation/bundleresources/information-property-list/lsapplicationcategorytype
- Apple Developer Documentation: App Sandbox Entitlement  
  https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.app-sandbox
- Apple Developer Documentation: Protecting user data with App Sandbox  
  https://developer.apple.com/documentation/security/protecting-user-data-with-app-sandbox

## 한 줄 요약

이번 오류는 Jday macOS 앱에 App Store용 카테고리 메타데이터와 Mac App Store 필수 샌드박스 권한이 빠져서 발생했다. `LSApplicationCategoryType`, `com.apple.security.app-sandbox`, `com.apple.security.network.client`를 추가한 뒤 Release 빌드에서 반영 여부를 확인했다.
