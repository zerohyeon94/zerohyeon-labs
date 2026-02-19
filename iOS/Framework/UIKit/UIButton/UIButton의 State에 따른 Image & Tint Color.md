## 1. 왜 선택 상태에서 이미지 색상이 자동으로 바뀌었나?

### UIButton, UIImage, tintColor의 관계

#### 1) UIButton의 image(for:)와 상태

- `setImage(_:for:)`로 **버튼의 상태**별(예: `.normal`, `.selected`, `.highlighted` 등)로 이미지를 지정할 수 있음
    
- 각 상태마다 이미지를 지정하지 않으면,  
    지정된 이미지(예: .normal)가 **다른 상태**에서도 기본적으로 사용됨

#### 2) UIImage와 Render Mode

- **UIImage는 2가지 렌더링 모드**가 있음
    
    1. `.alwaysOriginal`: 이미지 원본 색상 사용
        
    2. `.alwaysTemplate`: 이미지의 알파값만 남기고, 색상(tintColor)만 입힘

#### 3) tintColor 동작 방식

- UIButton/UIImageView 등에서 이미지의 renderMode가 `.alwaysTemplate`이면,  
    **뷰의 tintColor로 이미지가 칠해짐**
    
- 만약 UIImage가 `.alwaysTemplate` 모드고, 버튼의 tintColor가 바뀌면  
    이미지가 원본색이 아니라, tintColor 색상으로 보임

---

### [실제 시나리오]

- 내가 `UIImage(named:)`로 이미지를 지정했는데,
    
- 해당 이미지가 **Asset Catalog(에셋)**에서 “Template Image”로 지정되어 있거나,  
    혹은 코드에서 `.withRenderingMode(.alwaysTemplate)`로 세팅되어 있으면
    
- 버튼이 선택됨에 따라 `tintColor`가 바뀌면  
    이미지도 자동으로 그 색으로 칠해져서 “색상 변화”처럼 보임
#### [간단 코드 실험]

```swift
let offImage = UIImage(named: "icCheckButtonOff") // 에셋에서 Template 모드로 설정되어 있음
button.setImage(offImage, for: .normal)
button.tintColor = .gray

button.setImage(offImage, for: .selected)
button.tintColor = .systemBlue // 선택 시 tintColor 변경

// 버튼 이미지는 .selected 상태에서 파란색으로 변함
```

---
## 2. 실무에서는 어떻게 처리하는가?

### (1) 상태별로 **별도의 이미지**를 할당하는 방법

- `.setImage(_:for:)`로 각 상태(.normal, .selected 등)에 이미지 지정
    
- 이미지 파일 자체를 색상별로 만들어 사용

```swift
button.setImage(UIImage(named: "icCheckButtonOff"), for: .normal)
button.setImage(UIImage(named: "icCheckButtonOn"), for: .selected)
```

### (2) **Template 이미지 + tintColor** 방식

- 한 가지 이미지(Template)만 만들어놓고,  
    상태에 따라 tintColor만 변경
    
- 이 방식은 **단색 아이콘**에서 많이 사용 (예: 체크, 별표, 하트 등)

```swift
let checkImage = UIImage(named: "icCheckButton")?.withRenderingMode(.alwaysTemplate)
button.setImage(checkImage, for: .normal)
button.tintColor = .gray

button.setImage(checkImage, for: .selected)
button.tintColor = .systemBlue // 상태 변화에 따라 tintColor만 변경
```

#### [실무 Tip]

- 단색/벡터 이미지(아이콘)는 Template + tintColor 방식이 코드가 간결
    
- 다채로운 컬러 이미지(풀컬러, 그라데이션 등)는 상태별로 별도 이미지를 만드는 것이 안전

### (3) CustomButton 클래스로 캡슐화

- 실무에선 커스텀 UIButton 서브클래스를 만들어,  
    상태별 tintColor, 이미지 처리, 애니메이션 등까지 통합 관리하는 경우가 많음

---

## 3. 결론/정리

- **이미지 색상 자동 변환 현상**은 대부분 "Template 이미지 + tintColor"의 조합 때문
    
- 이미지를 Asset Catalog에서 “Render As: Template Image”로 지정했다면,  
    코드에서 별도 처리하지 않아도 tintColor로 색상 변화가 적용됨
    
- 실무에서는
    
    1. 상태별 별도 이미지 사용
        
    2. Template + tintColor  
        중 UI/UX, 디자인 요구에 맞게 선택

---
## 4. CustomButton 클래스

현업에서는 상태별 이미지/색상/tintColor 변경, 터치 애니메이션 등 여러 버튼 특성을 반복적으로 쓸 때 **CustomButton** 클래스를 자주 만듭니다.

아래 예시는
- `.normal`, `.selected` 상태별 이미지/색상/tintColor 설정
- 상태 변경 시 애니메이션
- 추후 디자인 확장성까지 염두를 포함한 실전 스타일입니다.
### 1) 간단한 커스텀 버튼 예시

```swift
import UIKit

class CustomCheckButton: UIButton {
    // 이미지/색상 프리셋
    private let offImage = UIImage(named: "icCheckButtonOff")?.withRenderingMode(.alwaysTemplate)
    private let onImage = UIImage(named: "icCheckButtonOn")?.withRenderingMode(.alwaysTemplate)
    
    private let offTint: UIColor = .systemGray2
    private let onTint: UIColor = .systemBlue
    
    // 선택 상태 바뀔 때마다 처리
    override var isSelected: Bool {
        didSet {
            updateStyle(animated: true)
        }
    }
    
    // 생성자에서 초기 셋업
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    private func commonInit() {
        setImage(offImage, for: .normal)
        setImage(onImage, for: .selected)
        updateStyle(animated: false)
        
        // 디자인 확장: 라운드/섀도우 등
        layer.cornerRadius = 8
        clipsToBounds = true
    }
    
    // 상태별로 이미지/tintColor 변경
    private func updateStyle(animated: Bool) {
        let targetTint = isSelected ? onTint : offTint
        let changes = {
            self.tintColor = targetTint
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: changes)
        } else {
            changes()
        }
    }
    
    // 버튼 클릭 시 상태 토글
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSelected.toggle()
        super.touchesEnded(touches, with: event)
    }
}
```

---

### 2) 사용 예시

```swift
let checkButton = CustomCheckButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
// 필요하다면 addTarget 등으로 외부 이벤트 연결
view.addSubview(checkButton)
```

---

## 3. 실무 팁/확장

- 버튼의 **상태를 외부에서 관리**(MVVM 등)하고 싶다면,  
    `isSelected`만 바꿔주면 CustomButton이 알아서 스타일링
    
- 애니메이션/효과 커스터마이즈 가능
    
- 여러 디자인 테마(색상, 테두리 등) 확장 시 별도 property 추가해서 제어