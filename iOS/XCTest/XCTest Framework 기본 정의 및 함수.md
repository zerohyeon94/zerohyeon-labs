## 1. **XCTest 프레임워크란?**

- **XCTest**는  
    iOS/macOS 개발에서 “테스트 코드(유닛 테스트, UI 테스트)”를 작성할 때 사용하는 **공식 프레임워크**입니다.
    
- 주로 **Xcode 프로젝트에 자동 포함**되어 있고,  
    테스트 전용 타겟(YourAppTests, YourAppUITests)에서 동작합니다.
    
- **테스트를 자동화**하고,  
    **코드 품질을 높이기 위한 핵심 도구**입니다.

---

## 2. **XCTest의 핵심 구조**

### 1) **테스트 케이스 클래스**

- 보통 `XCTestCase`를 상속한 클래스로 정의합니다.

	```swift
	class MyFeatureTests: XCTestCase {     // 여기에 테스트 함수 작성 }
	```

### 2) **테스트 함수**

- 함수명은 보통 `test`로 시작합니다.

	```swift
    func testExample() { ... }
	```

### 3) **테스트 어서션(Assertion) 함수**

- **코드의 결과가 “기대한 대로” 나왔는지 검사**하는 함수들입니다.
    
- “조건이 맞지 않으면 테스트 실패”로 간주됩니다.

---

## 3. **자주 쓰는 XCTAssert 계열 함수와 뜻/사용 이유**

### 1) **XCTAssertTrue(_:)**

- **뜻:**  
    파라미터(조건식)가 “true”이면 테스트 통과,  
    아니면 실패!
    
- **예시:**
    
    ```swift
    XCTAssertTrue(result == 5)
	```
    
    → result가 5이면 성공, 아니면 실패.
    

### 2) **XCTAssertFalse(_:)**

- **뜻:**  
    조건식이 “false”일 때만 통과
    
- **예시:**

	```swift
	XCTAssertFalse(isLoading)
	```

### 3) **XCTAssertNil(_:)**

- **뜻:**  
    값이 nil(값이 없음)이어야 테스트 통과
    
- **예시:**

	```swift
	XCTAssertNil(error)
	```

### 4) **XCTAssertNotNil(_:)**

- **뜻:**  
    값이 “nil이 아니어야”(= 값이 있어야) 통과  
    → 즉, 뭔가 성공적으로 생성/조회되었는지 검증
    
- **예시:**

	```swift
	XCTAssertNotNil(user)
	```
	→ user 객체가 생성/조회에 성공했는지 확인

### 5) **XCTAssertEqual(_:_:)**

- **뜻:**  
    두 값이 “같으면” 통과, 다르면 실패  
    → 결과값, 데이터 비교에 많이 사용
    
- **예시:**

	```swift
	XCTAssertEqual(model.salary, 3000000)
	```

### 6) **XCTAssertNotEqual(_:_:)**

- **뜻:**  
    두 값이 다르면 통과

### 7) **기타**

- `XCTFail()` : 무조건 실패 처리
    
- `XCTAssertThrowsError` : 특정 코드에서 에러가 나야 통과
    
- ...등등

---

## 4. **실무에서 왜 사용하는가?**

- **자동 검증:**  
    내가 예상한 값/상태와 실제 코드 실행 결과가 일치하는지 “자동으로” 확인해줍니다.
    
- **버그 조기 발견:**  
    테스트가 실패하면 “버그가 숨어있다!”고 바로 알 수 있음
    
- **리팩토링/기능 추가 후 영향도 체크:**  
    기존 코드가 잘 동작하는지 빠르게 확인 가능
    
- **코드 신뢰도 향상:**  
    협업/리뷰 시 “테스트 코드까지 통과하면 OK”라는 신뢰 기반이 됨

---

## 5. **예시 코드에 적용된 이유**

```swift
XCTAssertTrue(sut.createBudgetConfig(from: model))
```

- “생성 함수가 true를 반환해야(=성공해야) 한다”는 것을 자동 체크

```swift
XCTAssertNotNil(fetched)
```

- “저장 후 데이터를 읽어왔을 때 값이 nil이 아니어야 한다”(실제로 잘 저장되었는지 확인)

```swift
XCTAssertEqual(fetched?.salary, 3000000)
```

- “수정/저장한 값이 내가 의도한 값과 정확히 일치하는가?”

---

## 6. **정리 - 초보/주니어 개발자를 위한 실무 팁**

- **모든 테스트는 “결과를 자동으로 체크”하는 어서션 함수가 반드시 들어가야 합니다!**
    
    - 아니면 테스트를 돌려도 의미가 없습니다.
        
- **처음엔 assert 종류가 헷갈릴 수 있지만,**
    
    - “이 값이 true/false여야 한다” → XCTAssertTrue/False
        
    - “이 값이 nil/값 있음” → XCTAssertNil/NotNil
        
    - “이 값이 xx여야 한다” → XCTAssertEqual/NotEqual
        
- **실패 시 메시지(message:) 파라미터도 쓸 수 있어, 나중에 실패 원인 추적이 쉽습니다.**

---

## 🔑 **한 줄 요약**

> **XCTAssert 계열 함수들은 “테스트 코드가 실제로 기대한 대로 동작하는지 자동 검증하는 도구”입니다.  
> Unit Test의 가장 핵심적인 구성 요소이며,  
> 실무에서는 assert 없이 작성된 테스트 코드는 인정받지 못합니다!**

---

> [[iOS 학습 인덱스]]