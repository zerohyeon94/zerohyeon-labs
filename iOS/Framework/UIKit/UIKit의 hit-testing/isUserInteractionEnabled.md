### UIKit의 **히트 테스트(hit-testing)** 규칙상,

- 터치 이벤트는 최상위 뷰에서 아래로 내려가며 “터치를 받을 수 있는 뷰”를 찾습니다.
- **어떤 뷰라도 상위 뷰 체인 중 하나가 `isUserInteractionEnabled = false`이면 그 하위 뷰 전부가 터치 대상에서 제외**돼요.

### 그렇다면 UIImageView 안에 버튼을 넣었을 때는 왜 버튼 터치가 안되었는가?

- `UIImageView`는 **기본이 `false`**라서, 그 안에 버튼(UIButton)을 넣어도 **부모가 막아** 버튼까지 터치가 전달되지 않습니다.

### 주요 포인트

- **UIControl 계열(UIButton, UISwitch 등)** 은 기본이 `true`.
    
- **일반 UIView/UIImageView/UILabel** 은 기본이 `true`(UIView, UILabel)인 것도 있지만, **UIImageView만 특별히 기본 `false`**라서 자주 함정이 됩니다.
    
- 터치가 동작하려면 **다음 조건이 전부 충족**되어야 해요:
    
    - 해당 뷰와 **모든 상위 뷰**가 `isUserInteractionEnabled == true`
        
    - `isHidden == false`
        
    - `alpha > 0.01`
        
    - 프레임/제약으로 **히트 영역** 안에 존재
        
    - 다른 뷰가 **덮고 있지 않음**(특히 제스처/투명 오버레이)

---

> [[iOS 학습 인덱스]]