### **정의**

- **프로퍼티(property)**란  
    클래스, 구조체, 열거형 등 “타입”이 가지는  
    **값**(데이터, 상태)을 저장하거나 계산해주는  
    **변수(variable)나 상수(constant)**를 의미합니다.
    

---

### **쉽게 말해**

> **프로퍼티 = 어떤 객체/타입이 “가지고 있는 값(속성)”**

---

### **예시**

```swift
class Dog {
    var name: String      // 저장 프로퍼티 (Stored Property)
    var age: Int          // 저장 프로퍼티
    var isPuppy: Bool {   // 계산 프로퍼티 (Computed Property)
        return age < 2
    }
}
```

여기서

- `name`, `age`는 **Dog라는 타입이 가지고 있는 값(프로퍼티)**
    
- `isPuppy`는 나이에 따라 계산되어 반환되는 **계산 프로퍼티**
    

---

## **프로퍼티의 종류**

### 1. **저장 프로퍼티(Stored Property)**

- 실제 데이터를 저장함
    
    - 예: `var name: String`, `let birthYear: Int`
        

### 2. **계산 프로퍼티(Computed Property)**

- 값을 저장하지 않고,  
    다른 값이나 연산을 통해 **계산하여 반환**
    
    - 예:
        
        ```swift
        var age: Int {
		    return currentYear - birthYear
		}
		```

### 3. **타입 프로퍼티(Type Property)**

- 타입 자체(클래스/구조체 전체)가 공유하는 프로퍼티
    
    - 예: `static var count = 0`

---

## **왜 중요한가?**

- 객체가 “자신의 상태/데이터”를 외부에 공개하거나, 내부적으로 관리할 때
    
    - 값을 저장하고
        
    - 필요에 따라 자동으로 계산/변환해줌
        
- Swift, iOS 개발에서 객체지향 프로그래밍(OOP)의 핵심 요소
    

---

## **실제 용도 예시**

```swift
class Car {
    var speed: Double = 0.0            // 현재 속도 (저장 프로퍼티)
    var isMoving: Bool {               // 이동 중인가? (계산 프로퍼티)
        return speed > 0
    }
    static let maxSpeed = 200.0        // 전체 Car가 공유하는 최대 속도 (타입 프로퍼티)
}
```

---

## **한 줄 요약**

> **프로퍼티란**  
> “타입(클래스, 구조체, 열거형)이 가진 값(상태, 속성)”을 의미하며,  
> **저장 프로퍼티**와 **계산 프로퍼티**로 구분할 수 있다.