## 1) 정의

- **AttributedTitle**: `NSAttributedString`(iOS 15+는 `AttributedString`도 가능)을 버튼·세그먼트 등 **제목 텍스트로 사용**하여, 글자 단위로 폰트/색/자간/밑줄/배경 등 **세밀한 서식**을 적용하는 방식.

## 2) 적용 우선순위(핵심 규칙)

1. **Attributed 문자열 내부의 속성**이 최우선.
    
2. 해당 속성이 비어 있으면 **기본값으로 보충**:
    
    - 폰트 → `button.titleLabel?.font`
        
    - 전경색 → `button.titleColor(for:)`

3. 같은 상태(.normal 등)에 **`title`과 `attributedTitle`을 동시에 설정**하면, **`attributedTitle`이 사용**됨.
    
4. `NSAttributedString.Key.backgroundColor`는 **글자 뒤 영역만** 칠함. 버튼 전체 배경은 **`button.backgroundColor`** 또는 **`UIButton.Configuration`** 의 `baseBackgroundColor` 사용.

## 3) 자주 쓰는 속성(UIKit, NSAttributedString.Key)

- `.font`: 글꼴
    
- `.foregroundColor`: 글자색
    
- `.backgroundColor`: 글자 배경(글자 영역만)
    
- `.kern`: 자간
    
- `.underlineStyle`, `.underlineColor`: 밑줄
    
- `.strikethroughStyle`, `.strikethroughColor`: 취소선
    
- `.paragraphStyle`: 줄간격, 정렬 등

## 4) 상태별 스타일

- `.normal`, `.highlighted`, `.selected`, `.disabled` 등 상태마다 **별도 `attributedTitle` 지정 가능**.
    
- 상태별로 빠진 속성은 그 **상태의 기본값**으로 보충됨.

## 5) Dynamic Type 대응

- `UIFont.preferredFont(forTextStyle:)` + `UIFontMetrics`로 폰트를 생성하여 속성에 넣고,
    
- `button.titleLabel?.adjustsFontForContentSizeCategory = true`로 크기 변경 대응.
# 실무 예시

## A. UIKit + `NSAttributedString`

```swift
let text = "이용약관(필수) 및 개인정보 처리방침(선택)"
let attr = NSMutableAttributedString(string: text)
let nsText = text as NSString

attr.addAttributes([.font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                    .foregroundColor: UIColor.systemRed],
                   range: nsText.range(of: "필수"))

attr.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue],
                   range: nsText.range(of: "개인정보 처리방침"))

button.setAttributedTitle(attr, for: .normal)
```

## B. iOS 15+ `UIButton.Configuration` + `AttributedString`

```swift
let baseFont = UIFont.preferredFont(forTextStyle: .body)
let scaledFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont)

let attr = NSAttributedString(
    string: "접근성 지원",
    attributes: [.font: scaledFont]
)
button.titleLabel?.adjustsFontForContentSizeCategory = true
button.setAttributedTitle(attr, for: .normal)
```

---

# 체크리스트(빠르게 점검)

-  부분 색/폰트/자간 등 **문자 단위 속성**이 필요한가?
    
-  **동일 상태**에서 `title` 대신 **`attributedTitle`만** 설정했는가?
    
-  글자 뒤만 칠할 건가(배경 속성) vs **버튼 전체 배경**인가?
    
-  상태별(.highlighted/.disabled 등) **별도 속성**을 놓치지 않았는가?
    
-  **Dynamic Type** 대응이 필요한가?

---

# FAQ

**Q1. `setTitleColor`가 안 먹어요.**  
A. `attributedTitle`에 `.foregroundColor`가 있으면 그 색이 **우선**입니다. 필요 없다면 해당 속성을 빼세요.

**Q2. 폰트가 기대와 달라요.**  
A. `attributedTitle`에 `.font`가 있으면 그게 우선입니다. 없으면 `titleLabel.font`가 적용됩니다.

**Q3. 배경을 전부 칠하고 싶어요.**  
A. `.backgroundColor`는 **글자 뒤만** 칠합니다. 전체 배경은 `button.backgroundColor` 또는 `UIButton.Configuration`의 `baseBackgroundColor`를 사용하세요.

---

# 스니펫(자주 쓰는 패턴)

## UIButton - 부분 강조(범위 적용)

```swift
let text = "이용약관(필수) 및 개인정보 처리방침(선택)"
let attr = NSMutableAttributedString(string: text)
let nsText = text as NSString

attr.addAttributes([.font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                    .foregroundColor: UIColor.systemRed],
                   range: nsText.range(of: "필수"))

attr.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue],
                   range: nsText.range(of: "개인정보 처리방침"))

button.setAttributedTitle(attr, for: .normal)
```

## UIButton - Dynamic Type 대응

```swift
let baseFont = UIFont.preferredFont(forTextStyle: .body)
let scaledFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont)

let attr = NSAttributedString(
    string: "접근성 지원",
    attributes: [.font: scaledFont]
)
button.titleLabel?.adjustsFontForContentSizeCategory = true
button.setAttributedTitle(attr, for: .normal)
```

## 1) 부분 강조(색/폰트/밑줄)

```swift
// 기본 라벨 세팅
let label = UILabel()
label.font = .systemFont(ofSize: {{baseFontSize:16}})
label.textColor = .label
label.numberOfLines = 0

// 원본 문자열
let text = "{{fullText:이용약관(필수) 및 개인정보 처리방침(선택)}}"
let attr = NSMutableAttributedString(string: text)
let ns = text as NSString

// 강조1: 색 + 두께
attr.addAttributes([
    .font: UIFont.systemFont(ofSize: {{boldFontSize:16}}, weight: .semibold),
    .foregroundColor: UIColor.systemRed
], range: ns.range(of: "{{highlight1:필수}}"))

// 강조2: 밑줄
attr.addAttributes([
    .underlineStyle: NSUnderlineStyle.single.rawValue
], range: ns.range(of: "{{highlight2:개인정보 처리방침}}"))

label.attributedText = attr
```

---

## 2) 줄간격(LineSpacing) · 정렬(ParagraphStyle)

```swift
let paragraph = NSMutableParagraphStyle()
paragraph.lineSpacing = {{lineSpacing:4}}
paragraph.alignment = .{{alignment:left}} // left, center, right, justified 등

let attr = NSAttributedString(
    string: "{{text:줄간격과 정렬을 적용한 문장입니다.}}",
    attributes: [
        .font: UIFont.systemFont(ofSize: {{fontSize:16}}),
        .foregroundColor: UIColor.label,
        .paragraphStyle: paragraph
    ]
)

let label = UILabel()
label.numberOfLines = 0
label.attributedText = attr
```

---

## 3) 자간(Kern) · 글자 배경색

```swift
let attr = NSAttributedString(
    string: "{{text:K e r n + 배경}}",
    attributes: [
        .font: UIFont.systemFont(ofSize: {{fontSize:16}}),
        .kern: {{kern:0.8}}, // 양수면 자간 넓힘
        .backgroundColor: UIColor.systemYellow // 글자 영역만 칠함
    ]
)

let label = UILabel()
label.attributedText = attr
```

---

## 4) Dynamic Type 대응(접근성 글자 크기)

```swift
let base = UIFont.preferredFont(forTextStyle: .{{textStyle:body}})
let scaled = UIFontMetrics(forTextStyle: .{{textStyle:body}}).scaledFont(for: base)

let attr = NSAttributedString(
    string: "{{text:접근성 대응 텍스트}}",
    attributes: [.font: scaled]
)

let label = UILabel()
label.adjustsFontForContentSizeCategory = true
label.numberOfLines = 0
label.attributedText = attr
```

---

## 5) iOS 15+ Swift `AttributedString` 사용

```swift
var title = AttributedString("text:로그인 안내")
title.font = .system(size: 16, weight: .semibold)
title.foregroundColor = .label

let label = UILabel()
// UILabel은 NSAttributedString이 필요
label.attributedText = NSAttributedString(title)
```

### 특정 범위 시 `AttributedString` 사용

```swift
var title = AttributedString("로그인 안내")
if let range = title.range(of: "로그인") {
    var attrs = AttributeContainer()
    attrs.font = .systemFont(ofSize: 17, weight: .semibold)
    attrs.foregroundColor = .systemRed
    title[range].setAttributes(attrs)
}
label.attributedText = NSAttributedString(title)
```

---

## 6) 특정 범위 강조를 돕는 헬퍼

```swift
extension NSMutableAttributedString {
    func apply(_ attrs: [NSAttributedString.Key: Any], to target: String) {
        let ns = (string as NSString)
        let range = ns.range(of: target)
        if range.location != NSNotFound { addAttributes(attrs, range: range) }
    }
}

// 사용 예
let attr = NSMutableAttributedString(string: "{{text:코어데이터 성능 최적화 가이드}}")
attr.apply([.foregroundColor: UIColor.systemBlue], to: "{{target:코어데이터}}")

let label = UILabel()
label.attributedText = attr
```

---

## 7) 링크 스타일(파란색+밑줄) — 탭은 직접 처리(간단 버전)

```swift
let label = UILabel()
label.numberOfLines = 0
label.isUserInteractionEnabled = true

let text = "{{fullText:개인정보 처리방침 보기}}"
let target = "{{linkText:개인정보 처리방침}}"

let attr = NSMutableAttributedString(string: text)
let ns = text as NSString

attr.addAttributes([
    .foregroundColor: UIColor.systemBlue,
    .underlineStyle: NSUnderlineStyle.single.rawValue
], range: ns.range(of: target))

label.attributedText = attr

let tap = UITapGestureRecognizer(target: self, action: #selector(openPolicy))
label.addGestureRecognizer(tap)

@objc func openPolicy() {
    guard let url = URL(string: "{{url:https://example.com/privacy}}") else { return }
    // UIApplication.shared.open(url) 또는 SFSafariViewController로 열기
}
```

---

## 8) 인라인 아이콘(NSTextAttachment)

```swift
let attachment = NSTextAttachment()
attachment.image = UIImage(systemName: "{{sfSymbol:checkmark.seal.fill}}")

let icon = NSAttributedString(attachment: attachment)
let space = NSAttributedString(string: " ")

let text = NSAttributedString(
    string: "{{text:인증 완료}}",
    attributes: [.font: UIFont.systemFont(ofSize: {{fontSize:16}}, weight: .semibold)]
)

let result = NSMutableAttributedString()
result.append(icon)
result.append(space)
result.append(text)

let label = UILabel()
label.attributedText = result
```

---

# 한 줄 결론

- **있으면 덮어쓰고, 없으면 기본값으로 보충** — `AttributedTitle` 내부 속성이 항상 **최우선**, 배경 전체는 **버튼(뷰) 배경**으로 처리.

---

> [[iOS 학습 인덱스]]