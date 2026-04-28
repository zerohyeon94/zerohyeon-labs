**메서드 체이닝(Method Chaining)**은

> **여러 메서드(함수) 호출을 하나의 “.”(dot)로 이어서 한 줄로 연결하는 코딩 스타일**을 말합니다.

---

## ✅ 메서드 체이닝의 구조

각 메서드가 **자기 자신(Self) 또는 연관 객체를 반환**하도록 구현되어 있어서  
다음 메서드를 계속해서 이어서 호출할 수 있습니다.

### 예시

```swift
let label = UILabel()
    .setText("Hello")
    .setTextColor(.red)
    .setFont(.systemFont(ofSize: 20))
```

여기서 `.setText()`, `.setTextColor()`, `.setFont()`가 **연달아 호출**되고 있습니다.

---

## 🔍 Swift에서의 구현 방식

메서드의 리턴값을 `Self`로 지정하면 됩니다.

```swift
class MyView {
    var text: String = ""
    var color: UIColor = .black

    @discardableResult
    func setText(_ value: String) -> Self {
        self.text = value
        return self
    }

    @discardableResult
    func setColor(_ value: UIColor) -> Self {
        self.color = value
        return self
    }
}
```

### 사용 예:

```swift
let view = MyView()
    .setText("안녕")
    .setColor(.blue)
```

---

## 🎯 장점

- **코드가 더 읽기 쉽고 간결해집니다.**
    
- 여러 속성/설정을 한 번에 처리할 수 있습니다.

---

## 🧠 대표적인 예시들

- **UIKit:** 일부 라이브러리의 확장, 예: SnapKit, Alamofire 등
    
- **SwiftUI:** 뷰 빌더 체이닝
    
- **일반적으로 “빌더 패턴”에서도 많이 사용** (`builder.setA().setB().build()`)

---

## 요약

> **메서드 체이닝**은  
> “한 줄로 여러 동작을 연결해 코드를 더 간결하게 만드는 방법”입니다

---

## ✅ 대표적인 체이닝 패턴 예시

### 1. **Foundation의 String, Array, Dictionary 등 컬렉션 메서드**

```swift
let words = "Hello world! Welcome to Swift."
    .lowercased()
    .split(separator: " ")
    .map { $0.trimmingCharacters(in: .punctuationCharacters) }
    .filter { !$0.isEmpty }
```

- 각 단계가 자기 자신 또는 관련 타입을 반환하므로, **체이닝**이 자연스럽게 이어짐

---

### 2. **SwiftUI에서의 View Modifier 체이닝**

```swift
Text("Hello, Swift!")
    .font(.largeTitle)
    .foregroundColor(.blue)
    .padding()
    .background(Color.yellow)
    .cornerRadius(12)
```

- `Text` 뷰에 여러 속성을 한 줄로 체이닝

---

### 3. **URLRequest, URLComponents 등 구성체 생성**

```swift
var components = URLComponents(string: "https://openai.com")!
components.path = "/api"
components.queryItems = [URLQueryItem(name: "key", value: "value")]
let url = components.url
```

- 일부 프로퍼티는 점체이닝이 아닌 프로퍼티 직접 할당 방식이지만,  
    서브 컴포넌트의 빌더 메서드는 체이닝 구조로 많이 사용됨

---

### 4. **NSMutableAttributedString의 속성 추가**

```swift
let attrString = NSMutableAttributedString(string: "Swift!")
    .bold()
    .color(.red)
    .underline()
```

> (Apple 기본은 아님, 하지만 라이브러리 확장으로 매우 많이 사용됨)

---

### 5. **Alamofire, SnapKit 등 써드파티 공식 확장 예시**

```swift
Alamofire.request("https://openai.com")
    .validate()
    .responseJSON { response in
        // ...
    }
```

```swift
view.snp.makeConstraints {
    $0.top.equalToSuperview().offset(10)
    $0.left.right.equalToSuperview()
}
```

---

### 6. **Core Graphics, Core Animation의 체이닝적 빌더 패턴**

(Apple이 직접 제공하지는 않지만, 여러 오픈소스 프레임워크에서 기본 공식 API와 함께 빌더/체이닝을 제공)

---

## 🧠 결론

Swift, Apple 표준 라이브러리에서 체이닝이 널리 쓰이는 이유는

- **함수형 패러다임의 지원**
    
- **타입 안정성**
    
- **코드 간결성** 때문입니다.

**SwiftUI, 컬렉션, String, URL, 써드파티 프레임워크**에서 체이닝은 코드 스타일의 표준처럼 사용되고 있습니다.

---

> [[iOS 학습 인덱스]]