> [[iOS 인터뷰 인덱스]] | [[iOS 학습 인덱스]]

### 1. **Frame과 Bounds의 차이점에 대해 설명해주세요.** **
답변:** Frame은 **상위 뷰(SuperView)의 좌표 시스템**을 기준으로 해당 뷰의 위치와 크기를 나타냅니다. 반면, Bounds는 **자기 자신(Self)의 좌표 시스템**을 기준으로 위치와 크기를 나타내며, 기본적으로 원점은 (0,0)입니다. 뷰를 회전시키거나 스크롤 뷰의 내부를 구현할 때 이 둘의 차이가 중요하게 작용합니다.
[이미지를 통한 비교 블로그](https://velog.io/@o_joon_/Swift-Frame-VS-Bounds)

### 2. **접근 제어자(Access Control)의 종류와 각각의 차이를 설명해주세요.** 
**답변:** Swift의 접근 제어자는 개방성이 높은 순서대로 `open`, `public`, `internal`, `fileprivate`, `private`이 있습니다.

- `open`: 모듈 외부에서도 접근 및 상속/오버라이딩이 가능합니다. (클래스에서만 사용)
	
- `public`: 모듈 외부에서 접근은 가능하지만, 상속/오버라이딩은 불가능합니다.
	
- `internal`: 기본값으로, 같은 모듈 내에서만 접근 가능합니다.
	
- `fileprivate`: 해당 소스 파일(.swift) 내부에서만 접근 가능합니다.
	
- `private`: 정의된 블록 범위(또는 같은 파일 내의 extension) 내에서만 접근 가능합니다.

### 3. **GCD(Grand Central Dispatch)와 OperationQueue의 차이점은 무엇인가요?** 
**답변:** GCD는 C 언어 기반의 저수준 API로 가볍고 성능이 뛰어나며, 블록(Closure) 기반으로 작업을 처리합니다. OperationQueue는 GCD를 기반으로 한 Objective-C 객체 지향 래퍼(Wrapper)입니다. OperationQueue는 무겁지만, 작업 취소(Cancel), 일시 중지(Suspend), 작업 간 의존성(Dependency) 설정 등 복잡한 기능을 더 쉽게 구현할 수 있다는 장점이 있습니다.
[GCD, Operation Queue, Actor 요약 블로그](https://tdcian.tistory.com/408)

### 4. **Delegate 패턴과 NotificationCenter의 차이점과 장단점을 비교해주세요.** 
**답변:** Delegate 패턴은 주로 **1:1 통신**에 사용되며, 프로토콜을 통해 명확한 규격을 가집니다. 코드를 추적하기 쉽지만, 객체 간의 결합도가 생길 수 있습니다. NotificationCenter는 **1:N 통신**이 가능하여 다수의 객체에 동시에 이벤트를 알릴 때 유용합니다. 결합도는 낮지만, 어디서 이벤트가 발생했는지 추적하기 어렵고 디버깅이 까다로울 수 있습니다.
   
### 5. **Escaping Closure(@escaping)란 무엇인가요?** 
**답변:** 함수의 인자로 전달된 클로저가 **함수의 실행이 종료된 후에 실행**되는 경우를 말합니다. 주로 비동기 작업 완료 후 실행되는 Completion Handler나, 클로저를 외부 변수에 저장해 두고 나중에 호출해야 할 때 `@escaping` 키워드를 사용합니다.
   
### 6. **View Controller의 생명 주기(Lifecycle) 메서드들의 호출 순서를 설명해주세요.
**답변:** 일반적인 호출 순서는 `loadView` → `viewDidLoad` → `viewWillAppear` → `viewDidAppear` 순입니다. 뷰가 사라질 때는 `viewWillDisappear` → `viewDidDisappear` 순으로 호출됩니다. `viewDidLoad`는 뷰 로딩이 완료되었을 때 한 번만 호출되므로 초기화 작업에 적합하고, `viewWillAppear`는 화면이 나타날 때마다 호출되므로 데이터를 최신화하는 작업에 적합합니다.

### 7. **Hashable과 Equatable 프로토콜은 각각 어떤 역할을 하나요?** 
**답변:** `Equatable`은 두 인스턴스가 같은지 비교(`==`)할 수 있게 해주는 프로토콜입니다. `Hashable`은 `Equatable`을 상속받으며, 값을 유일한 정수 값(Hash Value)으로 변환할 수 있게 해줍니다. Dictionary의 키(Key)나 Set의 요소(Element)로 사용되려면 반드시 `Hashable`을 준수해야 합니다.
   
### 8. **고차 함수(Higher Order Function)인 map, filter, reduce에 대해 설명해주세요.** 
**답변:**

- `map`: 컬렉션의 데이터를 변형하여 새로운 배열로 반환합니다.
	
- `filter`: 조건에 맞는 데이터만 추출하여 새로운 배열로 반환합니다.
	
- `reduce`: 컬렉션의 모든 데이터를 결합하여 하나의 값으로 만듭니다. 이들은 코드를 간결하게 만들고 불변성을 유지하는 데 도움을 줍니다.
  
### 9. **싱글톤(Singleton) 패턴의 장점과 단점은 무엇인가요?** 
**답변:** 장점은 인스턴스가 하나만 생성됨을 보장하므로 메모리 낭비를 방지하고, 전역적으로 데이터 공유가 쉽다는 점입니다. 단점으로는 여러 곳에서 상태를 공유하므로 의존성이 높아져 테스트(TDD)가 어렵고, 멀티 스레드 환경에서 동기화 처리를 안 하면 데이터 경합(Race Condition) 문제가 발생할 수 있습니다.

### 10. **Copy-on-Write (COW)는 무엇인가요?** 
**답변:** Swift의 컬렉션 타입(Array, Dictionary 등)과 같은 값 타입(Value Type)이 복사될 때, 실제로 데이터가 변경되기 전까지는 메모리 복사를 하지 않고 기존 메모리를 공유하는 최적화 기법입니다. 데이터가 수정되는 순간(Write)에 실제 복사(Copy)가 일어나므로 불필요한 메모리 복사 비용을 줄여줍니다.
[참고 블로그](https://babbab2.tistory.com/18)

특히 **Frame/Bounds**나 **Delegate/Notification** 차이는 매우 빈번하게 나오는 질문