## 1️⃣ **UIButton의 스타일 종류**

UIKit의 UIButton은 여러 스타일이 있습니다.

- `.system` (스토리보드/코드의 기본값, iOS 7+에서 추천)
    
- `.custom` (구버전 또는 완전 커스텀)
    
- `.plain`, `.bordered`, `.filled` (iOS 15+ UIButton.Configuration)
    
- **스토리보드에서 Button Type: System/Custom/Detail 등** 선택 가능

---

## 2️⃣ **imageEdgeInsets, titleEdgeInsets, contentEdgeInsets의 적용 방식**

- **System 버튼(.system)**
    
    - iOS 13~15: 기본 스타일(모던, 동적 컬러, etc.)
        
    - `imageEdgeInsets`/`titleEdgeInsets`/`contentEdgeInsets`가 **부분 적용**
        
    - **내부 오토레이아웃, intrinsicContentSize, tintColor, 동적 폰트 등**이 강하게 영향
        
    - 커스텀 inset이 적용되지 않는 현상이 종종 발생  
        (특히 이미지와 타이틀이 동시에 있는 경우!)
        
- **Custom 버튼(.custom)**
    
    - **완전히 커스텀 레이아웃**
        
    - `imageEdgeInsets` 등 모든 inset이 **100% 수동 적용**
        
    - 뷰 계층구조/사이즈 잡는 방식을 직접 지정 가능
        
- **UIButton.Configuration 기반(iOS 15+)**
    
    - `.plain`, `.bordered`, `.filled` 등 스타일 적용
        
    - 이 경우 **inset 속성 대신 configuration의 contentInsets 등**을 써야 함
        
    - (예: `button.configuration?.contentInsets = NSDirectionalEdgeInsets(...)`)

---

## 3️⃣ **실제로 inset이 “안 먹는” 이유**

- **System 스타일 버튼이 내부적으로 자동으로 content를 배치/정렬**  
    (특히 스택뷰, 오토레이아웃, Dynamic Type 등과 같이 쓸 때)
    
- iOS 버전/스토리보드와 코드의 Button Type이 달라질 때  
    → inset 효과가 무시되거나, 예상과 다르게 적용될 수 있음
    
- **StackView 등 상위 뷰의 layout 영향도 받음**  
    (StackView에 있으면 intrinsicContentSize 등이 덮어씌워짐)

---

## 4️⃣ **실전 적용/권장 패턴**

- **inset을 정확히 적용하려면**  
    **Button Type을 “Custom”으로 설정**하거나  
    **UIButton.Configuration을 사용하는 방식으로 통일**하세요.
    
- 코드에서 UIButton 생성 시:
    
    ```swift
    let btn = UIButton(type: .custom) // ← .system이 아닌 .custom
	```
    
- iOS 15+에서 configuration 스타일을 쓴다면:
    
    ```swift
    var config = UIButton.Configuration.filled()
	config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
	button.configuration = config
	```

---

## 5️⃣ **참고: StackView + Button 사용시**

- **StackView 내부 버튼은 intrinsicContentSize가 우선 적용**  
    → insets만으로 간격 조절이 어렵다면 StackView의 spacing, layoutMargins, isLayoutMarginsRelativeArrangement 등도 조정 필요

---

## ✅ **한 줄 정리**

> **버튼의 insets는 스타일에 따라 적용 여부가 달라짐!  
> 정확히 inset을 적용하려면 Button Type을 “Custom”으로 두거나,  
> iOS 15+에서는 Configuration의 contentInsets 사용을 권장!**

---

> [[iOS 학습 인덱스]]