(UIKit + MVVM‑C + RxSwift 기준, _클로저 기반 프로퍼티 초기화_ 중심)

# 1) 프로젝트 구조 & 네이밍

- **폴더**
    
    - `DesignSystem/` : `Colors.swift`, `Spacing.swift`, `Radius.swift`, `Typography.swift`, `Assets.swift`
        
    - `Presentation/Scenes/<SceneName>/` : `ViewController`, `ViewModel`, `Coordinator`, `Components/`
        
    - `Common/Extensions/`, `Common/Utils/`
        
- **화면 네이밍**: `HomeViewController`, `HomeViewModel`, `HomeCoordinator`
    
- **컴포넌트 네이밍**: 역할+형태 (예: `PrimaryButton`, `TagBadge`, `FormTextField`)
    
- **리소스 네이밍(이미지/색상)**: `img.home.iconBell`, `color.bg.primary` 처럼 **접두사.도메인.의미**

# 2) 코드 스타일(초기화/구성/레이아웃/바인딩 4단계)

- **규칙**: `initUI() → setupLayout() → bind() → configure(with:)`
    
- **클로저 초기화**만 사용해 스타일 지정(폰트/색/간격), 위치는 `setupLayout()`에서만.
    

```swift
final class ExampleVC: UIViewController {
    // MARK: UI
    private let titleLabel: UILabel = {
        let v = UILabel()
        v.font = Typography.title
        v.textColor = Colors.label
        v.text = "제목"
        return v
    }()
    private let actionButton = PrimaryButton(title: "확인")
    private let vStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = Spacing.m
        return v
    }()

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        setupLayout()
        bind()
    }

    private func initUI() {
        view.backgroundColor = Colors.bg
        view.addSubview(vStack)
        [titleLabel, actionButton].forEach(vStack.addArrangedSubview)
    }

    private func setupLayout() {
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Spacing.l),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.l),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.l)
        ])
    }

    private func bind() {
        // Rx 바인딩 자리
    }

    func configure(with model: ExampleViewModel.Output) {
        // 외부 데이터 주입 시 적용
    }
}
```

# 3) 디자인 토큰(수치의 단일 출처)

```swift 
enum Spacing { static let xs: CGFloat = 4;  static let s: CGFloat = 8
               static let m: CGFloat = 12; static let l: CGFloat = 16
               static let xl: CGFloat = 24 }

enum Radius  { static let s: CGFloat = 8;  static let m: CGFloat = 12
               static let l: CGFloat = 16; static let xl: CGFloat = 24 }

enum Typography {
    static let title  = UIFont.systemFont(ofSize: 20, weight: .semibold)
    static let body   = UIFont.systemFont(ofSize: 16, weight: .regular)
    static let small  = UIFont.systemFont(ofSize: 14, weight: .regular)
}

enum Colors {
    static let label = UIColor.label
    static let tint  = UIColor.systemBlue
    static let bg    = UIColor.systemBackground
    static let subtleBg = UIColor.secondarySystemBackground
    static let sep   = UIColor.separator
}
```

- **원칙**: 화면에서 숫자(폰트 크기, 간격, 라운드) **직접 쓰지 말고** 토큰만 사용.

# 4) 스택뷰 & 스크롤뷰 규칙

- **StackView**: 리스트성 UI는 무조건 스택뷰(간격은 `Spacing` 토큰).
    
- **내부 패딩**: 컨테이너 뷰에 인셋 부여(스택뷰는 패딩 개념 없음).
    
- **스크롤이 필요한 화면**
    
    - `scrollView.contentLayoutGuide`에 콘텐츠 고정
        
    - 폭은 `frameLayoutGuide.widthAnchor`에 맞춤
        

```swift
let scroll = UIScrollView()
let content = UIStackView()
content.axis = .vertical; content.spacing = Spacing.m

view.addSubview(scroll)
scroll.addSubview(content)

scroll.translatesAutoresizingMaskIntoConstraints = false
content.translatesAutoresizingMaskIntoConstraints = false

NSLayoutConstraint.activate([
    scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
    scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

    content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: Spacing.l),
    content.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: Spacing.l),
    content.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -Spacing.l),
    content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -Spacing.l),

    content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)
])
```

# 5) 공통 컴포넌트 가이드

- **버튼**
```swift
final class PrimaryButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        var cfg = UIButton.Configuration.filled()
        cfg.title = title
        cfg.baseBackgroundColor = Colors.tint
        cfg.cornerStyle = .large
        cfg.contentInsets = .init(top: 12, leading: 16, bottom: 12, trailing: 16)
        configuration = cfg
        layer.cornerRadius = Radius.m
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    @available(*, unavailable) required init?(coder: NSCoder) { fatalError() }
}
```

- **라벨 팩토리**
```swift
enum LabelFactory {
    static func body(_ text: String? = nil, color: UIColor = Colors.label) -> UILabel {
        let l = UILabel()
        l.font = Typography.body
        l.textColor = color
        l.numberOfLines = 0
        l.text = text
        return l
    }
}
```

# 6) 오토레이아웃 유틸

```swift
extension UIView {
    func pinEdges(to guide: UILayoutGuide, inset: CGFloat = Spacing.l) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: guide.topAnchor, constant: inset),
            leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: inset),
            trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -inset),
            bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -inset)
        ])
    }
}

func makeSeparator() -> UIView {
    let v = UIView()
    v.backgroundColor = Colors.sep
    v.translatesAutoresizingMaskIntoConstraints = false
    v.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
    return v
}
```

# 7) MVVM‑C 입력/출력 & 바인딩

- **원칙**: VC는 입력 이벤트 전달/출력 구독만. 상태 가공은 ViewModel.
```swift
struct Input {
    let viewDidAppear: Observable<Void>
    let tapOK: Observable<Void>
}
struct Output {
    let title: Driver<String>
    let isOKEnabled: Driver<Bool>
}
```

- **바인딩 위치**: `bind()`에서만. DisposeBag은 VC/VM 각각 보유.
    

# 8) 접근성/다이나믹 타입/다크모드

- **Dynamic Type**: `UIFont.preferredFont` 사용, `adjustsFontForContentSizeCategory = true`
    
- **VoiceOver**: `accessibilityLabel`, `accessibilityTraits` 지정
    
- **다크모드**: 시스템 색상(또는 Asset Catalog “Any, Dark”) 사용
    

# 9) 로컬라이제이션

- **원칙**: 소스에서는 항상 키만 사용 (`"home_register_doctor_list".localized`)
    
- **문장 조합**: 문자열 보간 금지, `String.localizedStringWithFormat` 사용
    
- **문자열 길이 변화** 고려하여 오토레이아웃 여유
    

# 10) 상태/로딩/에러 공통 처리

- **빈 상태(Empty), 로딩, 에러**는 각 Scene에 공통 슬롯 확보
    
- `LoadingOverlayView`, `EmptyStateView`, `ErrorToast` 등 공통 컴포넌트로
    

# 11) 성능 & 스크롤 최적화

- 셀/컴포넌트는 **지연 생성**(필요 시점에 addSubview)
    
- 이미지 로딩은 캐시 적용(썸네일/원본 분기)
    
- 복잡한 그림자/마스크는 최소화(특히 스크롤 영역)
    

# 12) 커밋 메시지 규칙(UI 퍼블리싱)

- **feat(ui):** 새로운 화면/컴포넌트 추가
    
- **style(ui):** 토큰/여백/색상 등 비기능 스타일 변경
    
- **refactor(ui):** 레이아웃 구조/컴포넌트 분리
    
- **fix(ui):** 오토레이아웃 깨짐/다크모드/접근성 버그
    
- 예)
    
    - `feat(ui): Home 화면 스택 구성 및 PrimaryButton 적용`
        
    - `style(ui): Typography.title 크기 18→20으로 상향`
        
    - `fix(ui): ScrollView contentLayoutGuide 제약 누락 수정`
        

# 13) 코드 리뷰 체크리스트

-  숫자/색/폰트가 전부 토큰으로 통일되었는가
    
-  `initUI / setupLayout / bind` 단계가 분리되었는가
    
-  스크롤뷰 제약이 올바른가(content vs frame)
    
-  다크모드/다이나믹 타입/VoiceOver 확인했는가
    
-  빈/로딩/에러 상태가 준비되어 있는가
    
-  컴포넌트가 재사용 가능하게 설계되었는가