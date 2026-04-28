## 1) static이 뭔가요? (핵심 정의)

Swift에서 `static`은 **“타입(클래스/구조체/열거형) 자체에 속하는 멤버”**를 만들어요.  
즉, **인스턴스(객체)를 만들어야 접근하는 값/함수**가 아니라, **타입 이름으로 바로 접근하는 값/함수**입니다.

```swift
struct User {
    static let maxNameLength = 20
}

print(User.maxNameLength) // 인스턴스 없이 접근
```

- 인스턴스 프로퍼티: `user.name`
    
- static(타입) 프로퍼티: `User.maxNameLength`

---

## 2) static이 붙을 수 있는 것들

### ✅ 2-1. static stored property (저장 프로퍼티)

구조체/열거형에서는 **저장되는 static 프로퍼티**를 만들 수 있어요.

```swift
struct Counter {
    static var total = 0
}
```

`Counter.total`은 앱 전체에서 “한 벌”만 존재하고 공유됩니다.

> **클래스에서도 `static var` 같은 “저장 타입 프로퍼티”는 가능**합니다.

---

### ✅ 2-2. static computed property (계산 프로퍼티)

값을 저장하지 않고 계산해서 반환.

```swift
struct Env {
    static var apiBaseURL: String {
        "https://api.myservice.com"
    }
}
```

---

### ✅ 2-3. static method (타입 메서드)

인스턴스 없이 호출되는 함수.

```swift
struct Math {
    static func add(_ a: Int, _ b: Int) -> Int { a + b }
}

Math.add(1, 2)
```

---

## 3) 메모리/생명주기 관점 (면접에서 좋아하는 포인트)

- `static`은 **프로그램 실행 중 “공유되는 단일 값(전역처럼)”** 느낌으로 동작합니다.
    
- 보통 **한 번 초기화되면** 앱 종료까지 유지되는 경우가 많아요(정확히는 런타임/모듈 생명주기 동안).
    
- 그래서 **싱글톤, 캐시, 전역 설정값, 상수/유틸**에 자주 씁니다.

---

## 4) class에서 static vs class (오버라이드 가능 여부)

클래스에선 타입 메서드/프로퍼티를 만들 때 `static` 또는 `class`를 쓸 수 있는데 차이가 있어요.

### ✅ static: 오버라이드 불가 (final 느낌)

```swift
class A {
    static func foo() { }
}

class B: A {
    // override static func foo() { }  // ❌ 불가
}
```

### ✅ class: 오버라이드 가능

```swift
class A {
    class func foo() { }
}

class B: A {
    override class func foo() { } // ✅ 가능
}
```

**정리**

- `static` = “이 타입에서 고정. 자식이 바꾸지 마”
    
- `class` = “자식에서 재정의(override) 가능”

---

## 5) 왜 쓰나요? (실전 사용처)

면접에서는 아래 예시를 말하면 설득력이 좋아요.

### 5-1. 네임스페이스(Namespacing)처럼 사용

Swift는 자바처럼 패키지/네임스페이스가 강하지 않아서, `static`으로 그룹핑을 많이 해요.

```swift
enum Strings {
    static let ok = "확인"
    static let cancel = "취소"
}
```

### 5-2. 싱글톤

```swift
final class TokenManager {
    static let shared = TokenManager()
    private init() {}
}
```

### 5-3. 상수/환경 설정값

```swift
enum Config {
    static let timeout: TimeInterval = 10
}
```

---

## 6) 자주 나오는 꼬리질문(실제 면접에서 이어지는 흐름)

면접관이 여기로 이어서 물을 확률이 높아요.

1. **static let / static var 차이**
    
    - `let`은 불변 상수, `var`는 변경 가능.
        
    - `static var`는 공유 상태라서 변경 시 사이드이펙트/동시성 이슈(특히 Concurrency) 얘기 나올 수 있음.
        
2. **struct/enum에서 static 저장 프로퍼티가 가능한 이유**
    
    - 인스턴스와 별개로 “타입”에 붙는 값이라 가능.
        
3. **전역 변수랑 static의 차이**
    
    - 전역은 완전 글로벌 스코프 오염 가능
        
    - static은 `TypeName.` 아래로 묶어서 **범위가 명확**하고 관리가 쉬움(네임스페이스 효과)
        
4. **static이 ARC랑 관계가 있나?**
    
    - static은 강하게 잡고 있을 가능성이 높아서, “전역처럼 남아있는 객체(싱글톤)가 메모리에서 안 내려간다”는 관점에서 연결 가능.

---

## 7) 면접용 20초 답변 템플릿

“Swift에서 static은 인스턴스가 아니라 **타입 자체에 속하는 멤버**를 만들 때 사용합니다. 그래서 인스턴스를 만들지 않고 `TypeName.member`로 접근하고, 앱 전체에서 **공유되는 단일 값/동작**을 정의할 수 있습니다. 주로 상수, 유틸 함수, 네임스페이스처럼 묶기, 그리고 싱글톤 패턴에서 많이 사용합니다. 클래스에서는 `static`은 오버라이드가 불가하고, `class`는 오버라이드가 가능하다는 차이도 있습니다.”
> [[CS 학습 인덱스]]