## 1) 한 줄 정의

- **중첩 함수**: 함수(또는 메서드) **안에서 선언되어 그 스코프 안에서만 쓰는 지역 헬퍼 함수**. 바깥 스코프의 변수·상태를 **캡처**하여 사용할 수 있다.

## 2) 왜 쓰나 (핵심 장점)

- **재사용**: 함수 내부에서 반복되는 로직을 작은 함수로 묶어 재사용
    
- **캡슐화**: 바깥으로 노출할 필요 없는 헬퍼를 내부에 숨겨 API를 깔끔하게
    
- **가독성**: 의미 단위로 로직을 쪼개 읽기 쉬움
    
- **상태 캡처**: 바깥 변수(설정값, 캐시 등)를 그대로 사용
    
- **함수 생성**: 조건/파라미터에 따라 **함수를 반환**(factory), 커링/부분 적용 가능

## 3) 캡처·탈출(escaping)·ARC 요점

- **캡처**: 중첩 함수는 바깥 스코프의 값과 참조를 **강하게 캡처**한다.
    
- **탈출**: 중첩 함수를 **반환하거나 저장**하면 **escaping** 이 된다. 이때 `self`를 강하게 잡으면 **순환 참조** 위험 → 외부 클로저에서 **[weak self]** 로 약화 후 전달하는 설계 권장.
    
- **캡처 리스트**: 중첩 함수 선언에는 직접 캡처 리스트를 붙일 수 없으므로, **바깥 클로저에서 약한 참조를 만들고 내부에서 사용**한다.

---

## 4) 스니펫 모음 (필수 패턴)

### A) 지역 헬퍼로 검증 로직 재사용

```swift
func validatePassword(_ text: String) -> Bool {
    func isLengthOK(_ s: String) -> Bool { s.count >= 8 }
    func hasNumber(_ s: String) -> Bool { s.contains { $0.isNumber } }
    func hasLetter(_ s: String) -> Bool { s.contains { $0.isLetter } }

    return isLengthOK(text) && hasNumber(text) && hasLetter(text)
}
```

### B) 함수 생성(Factory) — 함수 반환과 캡처

```swift
func makePrefixer(prefix: String) -> (String) -> String {
    func apply(to s: String) -> String { "\(prefix)\(s)" } // prefix 캡처
    return apply // 반환 → escaping
}

let hello = makePrefixer(prefix: "Hello, ")
hello("World") // "Hello, World"
```

### C) 재귀 + 메모이제이션(캐시 숨기기)

```swift
func fib(_ n: Int) -> Int {
    var cache: [Int: Int] = [0: 0, 1: 1] // 로컬 캐시(외부에 숨김)
    func go(_ k: Int) -> Int {
        if let v = cache[k] { return v }
        let v = go(k - 1) + go(k - 2)
        cache[k] = v
        return v
    }
    return go(n)
}
```

### D) UIKit 클로저 안에서의 중첩 함수(weak self)

```swift
final class SampleVC: UIViewController {
    var onComplete: ((Int) -> Void)?

    func loadData() {
        API.fetch { [weak self] values in // self 약화는 바깥 클로저에서
            guard let self else { return }

            func updateUI(_ count: Int) { // 중첩 함수는 self 접근 가능
                self.view.backgroundColor = .systemGreen
                self.onComplete?(count)
            }
            updateUI(values.count)
        }
    }
}
```

---

## 5) 언제 쓰면 좋은가

- 바깥에 공개할 필요 없는 **지역 헬퍼**가 필요할 때
    
- 한 함수 내부에서 **같은 계산/검증/포맷팅**을 여러 번 쓸 때
    
- 재귀 문제를 **메모이제이션**과 함께 깔끔하게 감추고 싶을 때(Top-down DP)
    
- **조건에 따라 다른 동작을 하는 함수**를 만들어 반환하고 싶을 때

## 6) 언제는 분리하는 게 더 낫나

- 여러 곳에서 **공용**으로 쓰이거나
    
- **단위 테스트**가 필요한 로직이라면 → **private 메서드/유틸 타입**으로 분리하는 편이 좋다.

---

## 7) 베스트 프랙티스 체크리스트

-  중첩 함수 이름이 역할을 잘 드러나는가 (ex. `parseToken`, `updateUI`)
    
-  바깥에서 쓸 일 없는가 → 중첩 함수로 캡슐화
    
-  **반환/저장되어 escaping** 되는가 → `self` 강한 캡처 주의(weak로 설계)
    
-  상태(캐시 등) 캡처가 스레드·수명 측면에서 안전한가
    
-  테스트가 필요하면 외부로 분리하는 것이 더 적절한가

---

## 8) 한 줄 결론

- **중첩 함수 = 스코프 내부 전용 헬퍼**  
    재사용·가독성·캡슐화 이점을 주며, 필요하면 **함수 자체를 반환**해 강력한 구성도 가능. 단, **escaping 시 순환 참조**만 주의하면 된다.

---

> [[iOS 학습 인덱스]]