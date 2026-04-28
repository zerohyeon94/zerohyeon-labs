## ✅ 제안한 폴더 구조 요약

```pgsql
GagaeApp/
├── App/                  ← 앱의 진입점, 설정
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── LaunchScreen.storyboard
│   └── Info.plist
│
├── Presentation/        ← 화면(ViewController), ViewModel, 뷰 전용 유틸
│   ├── Home/
│   │   ├── HomeViewController.swift
│   │   └── HomeViewModel.swift
│   ├── Setup/
│   │   └── SetupViewController.swift
│   └── Common/
│       └── CustomUI, Extensions 등
│
├── Resources/           ← 정적 자원, CoreData 모델
│   ├── Assets.xcassets
│   ├── Localizable.strings
│   └── GagaeModel.xcdatamodeld

```

---

## 📌 각 폴더에 들어가면 좋은 것들

### 🔹 `App/`

- 앱 초기화 관련 코드:
    - `AppDelegate`, `SceneDelegate`, `LaunchScreen.storyboard`, `Info.plist`
    - `AppRouter`, `DIContainer`, `Environment.swift` 등이 여기에 들어가도 좋습니다.

### 🔹 `Presentation/`

- **UI 계층과 관련된 모든 것**:
    - `UIViewController`, `ViewModel`, `CustomView`, `Storyboard` 또는 `XIB`
    - 폴더는 기능 단위(Home, Setup, Budget 등)로 나누면 유지보수 용이
- `ViewModel`과 `View`는 같은 폴더에 묶어도 좋습니다 (1:1 대응성 높음)

### 🔹 `Resources/`

- `Assets.xcassets`, `Color`, `Fonts`, `Strings`, `CoreData Model`, `.plist` 등  
    = 정적인 리소스 관리 전용
- `CoreData`도 `.xcdatamodeld` 파일이므로 이곳에 두는 것이 깔끔합니다

---

## ✨ 보너스 구조 확장 팁 (규모가 커지면)

|추가 폴더|용도|
|---|---|
|`Domain/`|(선택) 비즈니스 로직, UseCase, Model 정의|
|`Data/`|API 통신, CoreData, Repository|
|`Service/` 또는 `Utils/`|날짜 계산, 금액 포맷 등 헬퍼 클래스|
|`Tests/`|테스트 모듈 (추가 시)|

---

## 📘 예시: 기능별 ViewModel/Model 위치

```pgsql
Presentation/
├── Home/
│   ├── HomeViewController.swift
│   ├── HomeViewModel.swift
│   └── BudgetCell.swift
├── Setup/
│   ├── SetupViewController.swift
│   └── SalaryInputViewModel.swift
```


---

> [[iOS 학습 인덱스]]