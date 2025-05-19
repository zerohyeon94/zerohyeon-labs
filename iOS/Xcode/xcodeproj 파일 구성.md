Xcode에서 xcodeproj 파일에서 보이는 PROJECT & TARGETS
## 🎯 핵심 개념 요약

| 항목          | 설명                                                             |
| ----------- | -------------------------------------------------------------- |
| **PROJECT** | 전체 프로젝트(워크스페이스 내 모든 타겟)를 포괄하는 **전역 설정 영역**                     |
| **TARGETS** | 각각의 실행 대상(executable, framework, extension 등)에 대한 **개별 설정 영역** |
### 🎯 `PROJECT`는 "틀(설계도)"이고, `TARGET`은 "실제 건물"
- `PROJECT`는 전체 앱/라이브러리/테스트 등 모든 빌드 대상의 **설정 틀**을 정의합니다.
- `TARGET`은 그 틀을 바탕으로 실제로 **빌드 가능한 실행 대상**을 정의합니다.
---

## 🔍 각 항목 상세 설명

### ✅ `PROJECT`
- `.xcodeproj` 전체를 가리킴
- 다수의 타겟(`App`, `Framework`, `Tests` 등)을 포함
- **공통 빌드 설정**을 정의 (예: 전체 소스코드 인코딩, 기본 Swift 버전)
- 설정은 **모든 타겟에 기본적으로 상속**됨 (단, 타겟에서 override 가능)
- 예시:
	- `Organization Name`
	- `Base SDK`
	- `Deployment Target (기본값)`
	- `Swift Compiler Language Version (기본값)`
	- `Source Control ID`
---
### ✅ `TARGETS`
- 실제 빌드 대상(실행파일, 테스트, 위젯 등) 각각을 정의하는 **실행 단위**
- 각 타겟은 고유의 설정, 빌드 단계, Info.plist, 번들 ID 등을 가짐
- 하나의 프로젝트에 여러 개의 타겟이 있을 수 있음
- 예:
	- `앱 실행 파일`
	- `앱 테스트용 Target`
	- `위젯 Target`
	- `watchOS 앱 Target`
	- `iOS 프레임워크 Target`

---
## 🎯 각각에 설정하는 것이 어떤 영향을 미치는가?

| 항목                                | 설정 위치           | 효과                                          |
| --------------------------------- | --------------- | ------------------------------------------- |
| **Deployment Target (최소 iOS 버전)** | TARGET          | 해당 타겟만 영향을 받음 (예: 앱은 iOS 13, 위젯은 iOS 16 가능) |
| **Swift Language Version**        | PROJECT, TARGET | TARGET에 없으면 PROJECT 설정이 적용됨                 |
| **Build Script 단계 추가 (빌드 후 처리)**  | TARGET          | 빌드 단계는 각 타겟에 독립적으로 존재                       |
| **Bundle Identifier**             | TARGET          | 실제 앱/프레임워크를 구분하는 ID. 각 타겟은 고유 ID 필요         |
| **Info.plist 파일**                 | TARGET          | 앱/extension/Test target마다 다르게 필요함           |

---
## 📌 예시로 비교

|설정 항목|PROJECT|TARGET|
|---|---|---|
|Swift Language Version|전체 기본값 설정|각 타겟에서 덮어쓰기 가능|
|Bundle Identifier|❌ 없음|✅ 있음 (예: `com.yourcompany.app`)|
|Info.plist|❌ 없음|✅ 있음|
|Deployment Target|전체 기본 설정|개별 Target에서 override 가능|
|빌드 스크립트 단계|❌ 없음|✅ 있음 (Run Script 단계 등)|
## 📌 실무 예제: 하나의 앱에 여러 TARGET이 있을 때

#### 구조:

|Target 이름|용도|
|---|---|
|`WithAPetApp`|메인 iOS 앱|
|`WithAPetWatch`|watchOS companion 앱|
|`WithAPetWidget`|iOS 위젯|
|`WithAPetTests`|단위 테스트 타겟|
|`WithAPetSDK`|내부 공통 로직을 담은 Framework 타겟|

#### 설정 예시:

| 설정                                         | 위치                          | 이유                        |
| ------------------------------------------ | --------------------------- | ------------------------- |
| Swift 버전 6                                 | `PROJECT`                   | 전체 타겟에서 기본 적용되도록 설정       |
| Swift 버전 5.9                               | `WithAPetSDK` Target만 따로 설정 | 오래된 의존성과 호환성을 위해 override |
| Bundle ID `com.yourcompany.withapet`       | `WithAPetApp` TARGET        | 앱 고유 ID, 배포용              |
| Bundle ID `com.yourcompany.withapet.watch` | `WithAPetWatch` TARGET      | Watch 전용 ID 필요            |
| Build Phase에서 `.ipa` 생성 스크립트               | `WithAPetApp` TARGET        | 배포용 빌드 스크립트는 앱 타겟에만 필요    |

---

## 🧠 정리 비유

> Xcode 프로젝트는 회사(PROJECT),  
> 각 TARGET은 회사 안의 **부서 또는 앱 구성 요소**입니다.
- PROJECT: "회사 정책" – 모든 부서가 기본적으로 따름
- TARGET: "각 부서의 실무" – 자체적으로 필요한 설정 가질 수 있음

| 개념      | 비유                 | 역할                                 |
| ------- | ------------------ | ---------------------------------- |
| PROJECT | 아파트 단지 설계도         | 전체 건물들의 공통 규칙 제공                   |
| TARGET  | 각 동(건물)            | 각 빌드 실행 단위 (앱, 위젯, 테스트 등)          |
| 설정 우선순위 | 동마다 전기/수도 따로 조절 가능 | 개별 TARGET 설정이 PROJECT 설정을 override |

---

## ✅ 실무 팁

- 공통 설정은 `PROJECT`에서 한 번에 관리하는 것이 효율적
- 타겟별로 다른 설정 필요할 때는 `TARGET`에 개별 설정
- `PROJECT` 설정이 `TARGET`에 자동으로 **상속**되지만, 덮어쓰면 `TARGET` 우선

| 목적                  | 해야 할 일                                                   |
| ------------------- | -------------------------------------------------------- |
| 앱 전체 기본 세팅          | PROJECT 수준에서 설정                                          |
| 각 실행 대상마다 다르게 설정 필요 | 해당 TARGET에서 override 설정                                  |
| 타겟 추가 후 설정 일관화      | PROJECT → 기존 타겟 설정 복사해서 적용                               |
| 공통 코드 관리            | Framework 타겟(`MySDK`, `CoreLogic`) 추가 → 다른 타겟에서 임포트하여 사용 |

---
## 🧠 설정 충돌 시 우선순위

|설정 대상|우선순위|
|---|---|
|TARGET에 설정한 값|✅ 항상 우선|
|PROJECT에 설정한 값|기본값으로 사용됨 (TARGET에 없을 때만 적용)|

```swift 
// PROJECT에서 Swift Version: 6 
// TARGET에서 Swift Version: 5.9 → 이 값이 실제로 사용됨
```

---
## ❓실제 사용하는 Swift 버전은 어디서 결정될까요?

- `TARGET → Swift Compiler - Language → Swift Language Version`에서 설정한 값이 **우선**
- 설정 안 돼 있다면 `PROJECT`의 설정을 따름