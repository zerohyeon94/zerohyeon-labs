## 정의

- **`NSMutableAttributedString`**: **수정 가능(mutable)** 한 `NSAttributedString`의 서브클래스.
    
- 같은 “서식 있는 문자열”이지만, **추가/삭제/치환/속성 변경**을 **제자리에서(in-place)** 할 수 있어요.
    
- 대상: UIKit/AppKit 전반(`UILabel`, `UIButton`, `UITextView`, `UITextField` 등).

## 관계도

- `NSAttributedString`: **불변(immutable)**. 읽기/표현용.
    
- `NSMutableAttributedString`: **가변(mutable)**. 편집/조작용.
    
- `AttributedString`(Swift, iOS 15+): 값 타입 + 타입 세이프. 마지막엔 `NSAttributedString(...)`으로 **브리징**해서 UIKit에 넣음.

## 언제 쓰나

- 부분 강조를 **여러 구간**에 반복 적용할 때
    
- 텍스트를 만들며 **여러 번** 붙이고 바꾸고 지울 때
    
- **성능**상 불필요한 새 인스턴스 생성 없이 한 객체에서 속성만 바꿔가며 작업하고 싶을 때

---

## 핵심 API(**Application Programming Interface**)

```swift
let attr = NSMutableAttributedString(string: "기본 텍스트")

// 1) 속성 추가/변경
attr.addAttributes([.font: UIFont.boldSystemFont(ofSize: 16),
                    .foregroundColor: UIColor.systemRed],
                   range: NSRange(location: 0, length: 2))

// 2) 특정 속성만 설정
attr.addAttribute(.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSRange(location: 3, length: 2))

// 3) 속성 제거
attr.removeAttribute(.foregroundColor, range: NSRange(location: 0, length: attr.length))

// 4) 문자열 연결/삽입/치환
attr.append(NSAttributedString(string: " 더하기"))
attr.insert(NSAttributedString(string: "앞에 "), at: 0)
attr.replaceCharacters(in: NSRange(location: 0, length: 2), with: "교체")

// 5) 전역 기본 속성 변경(없는 곳만 보충)
attr.setAttributes([.font: UIFont.systemFont(ofSize: 15),
                    .foregroundColor: UIColor.label],
                   range: NSRange(location: 0, length: attr.length))

```

> 팁: **여러 군데** 같은 스타일을 발라야 하면 `NSRegularExpression`으로 범위를 찾아 한 번에 `addAttributes`를 돌리는 게 깔끔합니다.

---

## UILabel/UIButton 적용 예

### 부분 강조(여러 구간)

```swift
let text = "이용약관(필수) 및 개인정보 처리방침(선택)"
let attr = NSMutableAttributedString(string: text,
                                     attributes: [.font: UIFont.systemFont(ofSize: 15),
                                                  .foregroundColor: UIColor.label])

let ns = text as NSString
attr.addAttributes([.font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                    .foregroundColor: UIColor.systemRed],
                   range: ns.range(of: "필수"))

attr.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue],
                   range: ns.range(of: "개인정보 처리방침"))

label.attributedText = attr
```

### 문단 스타일(줄간격/정렬)

```swift
let p = NSMutableParagraphStyle()
p.lineSpacing = 4
p.alignment = .left

let attr = NSMutableAttributedString(string: "줄간격과 정렬 적용",
                                     attributes: [.font: UIFont.systemFont(ofSize: 16),
                                                  .paragraphStyle: p])
label.numberOfLines = 0
label.attributedText = attr
```

### 인라인 아이콘(NSTextAttachment)

```swift
let result = NSMutableAttributedString()

let attach = NSTextAttachment()
attach.image = UIImage(systemName: "checkmark.seal.fill")
result.append(NSAttributedString(attachment: attach))
result.append(NSAttributedString(string: " 인증 완료",
                                 attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .semibold)]))

label.attributedText = result
```

---

## NSAttributedString ↔ AttributedString 브리징

```swift
// Swift 값 타입 → UIKit로
var swiftAttr = AttributedString("로그인 안내")
if let r = swiftAttr.range(of: "로그인") {
    swiftAttr[r].font = .systemFont(ofSize: 17, weight: .semibold)
}
label.attributedText = NSAttributedString(swiftAttr)

// UIKit 객체 편집이 필요하면 다시 mutable로
let mutable = NSMutableAttributedString(attributedString: label.attributedText ?? NSAttributedString())
mutable.addAttribute(.foregroundColor, value: UIColor.systemRed, range: NSRange(location: 0, length: mutable.length))
label.attributedText = mutable
```

---

## 실무 팁(중요)

- **NSRange 계산**은 `NSString`로 캐스팅해 `range(of:)`를 쓰면 안전합니다(유니코드 조합 문자 이슈).
    
- 대량 편집은 `beginEditing()`/`endEditing()` 사이에 수행하면 일부 상황에서 효율적입니다.
    
- `.backgroundColor`는 **문자 영역만** 칠합니다. 전체 배경은 `view.backgroundColor`.
    
- **Thread-safety**: 메인 스레드에서 UI에 최종 적용하세요.
    
- 긴 텍스트는 반드시 `label.numberOfLines = 0`, `lineBreakMode` 등을 함께 고려.

---

## 언제 `NSMutableAttributedString` 대신 Swift `AttributedString`?

- **타입 안정성**과 **문자 경계 안전성**(이모지/조합 문자)을 중시하거나,
    
- 스타일을 **모듈화(`AttributeContainer`)** 해서 합치고 재사용하고 싶을 때.
    
- UIKit 적용 직전에 `NSAttributedString(...)`으로 변환하면 됩니다.

---

### 한 줄 결론

**`NSMutableAttributedString` = “서식 문자열을 제자리에서 편집하는 도구”**.

---

> [[iOS 학습 인덱스]]