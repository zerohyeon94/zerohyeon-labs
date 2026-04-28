> RxSwift(혹은 클로저, 비동기 콜백 등)에서  
**`[weak self]` + `guard let self = self else { return }`** 패턴이 필수적으로 쓰이는 이유

## **핵심 요약**

### **1. 클로저 내에서의 self와 메모리 관리**

- **클로저는 self(=ViewController 등)를 캡처(참조)합니다.**
    
- 만약 `[weak self]` 없이 클로저 안에서 self를 쓰면  
    → 클로저가 self(뷰컨 등)를 강하게 잡아 메모리 해제가 안 되는 **retain cycle(순환 참조)** 위험이 생김

---

### **2. [weak self]와 guard let self = self else { return }을 왜 쓰나?**

- `[weak self]`는 self를 “약한 참조”로 클로저에 넘기므로
    
    - ViewController가 화면에서 사라졌거나,
        
    - 해제된 이후에도
        
    - 클로저가 self를 강하게 잡지 않아 메모리릭을 예방
        
- **guard let self = self else { return }**
    
    - self가 nil이 될 수 있으므로(=뷰컨이 사라진 뒤라면)
        
    - 안전하게 unwrapping해서
        
    - nil일 경우 클로저 실행을 빠져나오게

---

### **3. 왜 self.toast(...) 등에서 self를 꼭 써야 할까?**

- 클로저 안에서 self 없이 쓰면, 해당 클로저(=Rx 구독, 콜백 등)가 self 바깥쪽 “지역변수, 상위스코프 등”에서 같은 이름의 변수를 찾으려고 시도
- 하지만, ViewController의 인스턴스 메서드/프로퍼티 등은 self.접근자로 반드시 명시해야 접근 가능

---

### **4. ViewController 내라서 self를 꼭 써야 하는가?**

- **ViewController 내의 메서드라고 해도**
    
    - 클로저 안에서는 “다른 스코프”로 취급
        
    - self 없이 프로퍼티/메서드 접근 불가(특히 Swift에서는 엄격)
        
    - (클로저 캡처의 원리)

---

## **실무 결론/정리**

- **RxSwift 등에서 뷰컨의 프로퍼티/메서드(=self.toast 등)를 쓸 땐**  
    → 반드시 `[weak self]`와 `guard let self = self else { return }`로  
    → **순환참조/메모리릭 방지**와 **nil-safe 안전성**을 확보
    
- self.접근자도 반드시 필요!

---

### **추가 설명:**

- 만약 self.toast 등에서 self를 안 쓰면
    
    - “Unresolved identifier”
        
    - 혹은 다른 스코프의 동일명 변수 접근 시도  
        → 에러 발생

---

## **정리**

> **클로저 안에서는 self를 명시적으로 캡처하고,**  
> **해제 가능성을 항상 염두에 두는 게 실무/Swift의 표준 패턴입니다.**

---

> [[iOS 학습 인덱스]]