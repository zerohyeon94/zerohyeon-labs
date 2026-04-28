**메모리릭(memory leak)**이란,  
프로그램이 더 이상 필요하지 않은 **메모리(객체, 데이터 등)**를  
해제(정리)하지 못해서,  
계속해서 **메모리에 남아 있게 되는 현상**을 말합니다.

---

## **쉽게 말해**

> **“이미 쓸 일이 없어진 데이터가 계속 메모리에 남아있는 현상”**

---

### **왜 문제일까?**

- 불필요한 데이터가 계속 쌓이면  
    → **앱이 점점 무거워지고,**  
    → **결국 메모리가 부족해져서 앱이 느려지거나, 강제 종료(crash)**  
    → 모바일, 서버 모두에서 심각한 버그/성능 저하의 원인!

---

## **Swift(iOS)에서의 대표적 원인**

1. **순환 참조(Retain Cycle)**
    - 두 객체가 서로를 강하게 참조하고 있을 때
    - 예)
        - ViewController → 클로저(=Rx 구독, delegate 등)
        - 클로저/Delegate가 다시 ViewController를 강하게 잡고 있을 때
    - 결과: 둘 다 “해제되어야 할 타이밍”이 와도  
        → **서로를 참조하고 있어 ARC가 메모리 해제를 못함**
        
2. **타이머, Notification, KVO 등록 후 해제 안 함**
    - Timer, NotificationCenter, KVO 등에서 addObserver/subscribe만 하고 remove를 안 하면 해당 객체가 해제되지 않고 계속 남음
            
3. **잘못된 리소스 관리**
    - 파일, 이미지, 네트워크 연결 등
    - 닫거나 해제하지 않으면 메모리릭

---

## **실무 예시**

### **순환 참조 예시**

```swift
class MyViewController: UIViewController {
    var closure: (() -> Void)?

    func setup() {
        closure = {
            // self를 강하게 참조 (retain cycle 발생)
            self.doSomething()
        }
    }
}
```

- **MyViewController**가 **closure**를 강하게 참조
    
- **closure**가 다시 **self(MyViewController)**를 참조
    
- → 둘 다 해제되지 않고 메모리에 “영원히” 남게 됨(=메모리릭)

---

### **해결방법**

- `[weak self]` 혹은 `[unowned self]`를 캡처리스트에 사용

---

## **Xcode의 Memory Graph 디버거로 확인 가능!**

- **Xcode → Debug → View Memory Graph**
    
- 릭이 발생한 객체가 “해제되지 않고 남아 있는 것”을 시각적으로 볼 수 있음

---

## **정리**

> **메모리릭이란?**  
> “더 이상 필요하지 않은 객체/메모리가 해제되지 않고 남아있는 현상”
> 
> 앱의 성능 저하, 강제 종료 등 문제를 유발
> 
> Swift/iOS에서는 **순환 참조, Observer 미해제, 타이머 등**이 주 원인

---

> [[iOS 학습 인덱스]]