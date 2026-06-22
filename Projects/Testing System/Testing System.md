## ✅ Testing System 이란?

iOS 앱의 **기능이 원하는 대로 작동하는지 자동으로 검증**하기 위한 체계입니다.  
Apple은 기본적으로 **XCTest 프레임워크**를 제공합니다.

---

## ✅ 어떤 종류의 테스트가 있나요?

|테스트 종류|설명|예시|
|---|---|---|
|**Unit Test**|함수, ViewModel, 계산 로직 등 **작은 단위 기능 테스트**|"일일 예산 계산 함수가 정확한가?"|
|**UI Test**|실제 화면 전환, 버튼 터치 등 **UI 동작 테스트**|"월급 입력 후 다음 버튼이 작동하는가?"|
|**Integration Test**|여러 기능이 **조합되어 동작하는지 테스트**|"예산 입력 후 홈 화면이 올바르게 계산되었는가?"|

---

## ✅ 프로젝트 생성 시 "Include Tests" 옵션

|옵션|생성되는 파일|
|---|---|
|☑️ 체크함|`GagaeAppTests/`, `GagaeAppUITests/`|
|⛔ 체크 안 함|테스트 폴더 없이 앱 코드만 생성됨|

---

## ✅ 언제 테스트 시스템을 도입하면 좋을까?

|상황|추천 여부|
|---|---|
|초기 개인 앱, 빠른 프로토타입|❌ 생략 가능 (개발 속도 우선)|
|출시 전 기능 검증, 팀 협업|✅ 꼭 도입 (버그 감소, 리팩토링 용이)|
|핵심 로직이 복잡할 때|✅ 예: 예산 이월 계산 등 수식 정확성 필요|

---

## ✅ 예시: 단위 테스트 코드 (예산 계산)

```swift
import XCTest @testable 
import GagaeApp  

class BudgetCalculatorTests: XCTestCase {     
	func testDailyBudgetCalculation() {         
		let salary: Double = 3000000         
		let fixedCosts: Double = 1000000         
		let days: Double = 31          
		let result = BudgetCalculator.calculateDailyBudget(salary: salary, fixedCosts: fixedCosts, days: days)     
		     
		XCTAssertEqual(result, 64516.13, accuracy: 0.01)     
	} 
}
```

---

## ✅ 결론

- 지금은 **체크 안 하고 시작**해도 무방합니다.  
    👉 초기에 빠르게 UI와 기능부터 구현하고,  
    👉 **나중에 필요한 시점에 테스트 타깃 추가** 가능해요.
    

테스트를 추가하고 싶을 때는

> `File > New > Target... > Unit Testing Bundle`  
> 또는 `Command + N > Unit Test Case Class` 로 추가할 수 있어요.

---

> [[Home]]