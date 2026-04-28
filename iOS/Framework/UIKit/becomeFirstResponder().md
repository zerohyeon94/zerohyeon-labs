> 첫 화면에 들어왔을 때, TextField 입력창을 띄우고 싶을 때 어떻게 해야할까?

[애플 공식 문서](https://developer.apple.com/documentation/uikit/uiresponder/becomefirstresponder())
## 1. **왜 viewDidAppear에서 해야 할까?**

- **viewDidLoad**:  
    이 시점엔 view가 계층 구조에 올라왔지만,  
    **아직 화면에 "실제로 표시되지 않은 상태"**입니다.  
    여기서 becomeFirstResponder를 호출하면  
    → 키보드가 "뜨는 척 하다가" 바로 사라질 수 있습니다.  
    (특히, navigation/present 애니메이션과 겹치면 100% 확률로 문제)
    
- **viewWillAppear**:  
    역시 아직 화면이 완전히 보이기 전 단계.  
    → 키보드 포커스 유지가 안 될 수 있음.
    
- **viewDidAppear**:  
    **화면 전환(애니메이션 포함)이 "완전히 끝난 뒤"**  
    즉, 사용자가 화면 전체를 볼 수 있는 상태가 된 직후.  
    이 타이밍에서 becomeFirstResponder를 호출해야  
    **키보드가 안정적으로 올라오고, 사용성 버그가 안 생김.**

### **애플 공식 문서 참고**

> "Only call this method on views that are part of the active view hierarchy."  
> (즉, 완전히 보여진 시점이 안전하다!)

---

## 2. **딜레이 또는 바로 띄우는 게 나은지**

- **즉시 띄우기:**
    
    - 입력 화면(로그인, 회원가입, 검색 등)은 대부분 즉시
        
    - 사용자가 "바로 입력"을 원하거나, UX 흐름상 핵심일 때
        
- **딜레이(0.2~0.4초) 주기:**
    
    - 화면 전환 애니메이션이 길거나
        
    - 화면 설명이나 안내 메시지를 먼저 읽고 입력이 필요한 경우
        
    - 여러 요소가 동적으로 로딩되어 UI가 복잡할 때
        
    - 사용자가 갑자기 키보드가 튀어나오는 것에 당황할 수 있는 경우

#### **실무에서는?**

- **“즉시 활성화”가 대부분이지만,**  
    애니메이션이나 UX에 따라 딜레이를 일부러 주는 프로젝트도 많음.
    
- 실제 대형 서비스(카카오, 토스, 쿠팡, 네이버 등)도  
    "즉시"와 "딜레이"를 케이스별로 구분 사용

---

## 3. **실무 예시**

### **A. 즉시 활성화(가장 기본)**

```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    yourTextField.becomeFirstResponder()
}
```

### **B. 아주 짧은 딜레이 후 활성화**

```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        self.yourTextField.becomeFirstResponder()
    }
}
```

- **딜레이는 0.2~0.4초가 자연스러움**
    
- 유저가 안내 메시지를 읽는 시간이 짧게나마 주어짐

### **C. 특정 조건에만 자동 활성화**

- 예: 회원정보 수정에서 이미 입력된 값이 있으면 자동 활성화 X
    
- 비밀번호 입력 등 보안이슈가 있을 때는 자동 활성화 하지 않기도 함

---

## 4. **응용 예시**

### **1) 첫 진입에만 자동 활성화, 이후에는 수동**

```swift
var isFirstAppear = true

override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if isFirstAppear {
        yourTextField.becomeFirstResponder()
        isFirstAppear = false
    }
}
```

### **2) 여러 텍스트필드 중 첫 미입력 필드에 자동 활성화**

```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if nameTextField.text?.isEmpty ?? true {
        nameTextField.becomeFirstResponder()
    } else if emailTextField.text?.isEmpty ?? true {
        emailTextField.becomeFirstResponder()
    }
    // ...
}
```

---

## 5. **실무 Tip/권장사항**

- **사용자 경험(UX)이 가장 중요:**  
    "화면에 진입하자마자 바로 입력할 준비가 돼있어야 할지?"  
    "아니면 먼저 내용을 읽고, 사용자가 터치로 활성화하게 둘지?"  
    → PM/디자이너와 협의 필요할 수 있음
    
- **테스트 해보면서 결정:**
    
    - 여러 기기(특히 구형/저사양)에서  
        키보드가 어색하게 깜빡이거나, UI가 가려지는지 직접 확인
        
- **시스템 화면(앱스토어, 카카오, 네이버 등)에서도 실제로 즉시와 딜레이 방식을 섞어씀**

---

### **요약**

- `viewDidAppear`에서 `becomeFirstResponder()` 호출이 “정석”
    
- 대부분 즉시 활성화(특히 입력 중심 화면)
    
- 안내/애니메이션/자연스러움 필요하면 0.2~0.3초 딜레이도 OK
    
- 필요하다면 조건부 자동 활성화도 고려

---

> [[iOS 학습 인덱스]]