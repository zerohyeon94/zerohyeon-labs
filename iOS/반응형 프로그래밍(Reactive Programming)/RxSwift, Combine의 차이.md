반응형 프로그래밍(Reactive Programming)은 데이터의 흐름(Stream)과 변화의 전파에 초점을 맞춘 프로그래밍 패러다임입니다. 데이터가 변경될 때마다 이를 관찰(Observe)하고 있던 구성 요소들이 자동으로 반응하여 연산을 수행하거나 UI를 업데이트하는 방식으로 동작합니다. 비동기 작업(네트워크 요청, 사용자 입력 등)을 처리할 때 콜백 지옥을 피하고 코드를 선언적으로 깔끔하게 작성할 수 있다는 큰 장점이 있습니다.

iOS 생태계에서 이 반응형 패러다임을 구현하는 대표적인 두 가지 프레임워크가 바로 **RxSwift**와 **Combine**입니다.

---

## 1. RxSwift

RxSwift는 다양한 언어에서 지원하는 ReactiveX(Rx)의 Swift 버전입니다. 오픈 소스 서드파티 라이브러리이며, 오랜 기간 동안 iOS 개발 표준처럼 사용되어 왔기 때문에 방대한 커뮤니티와 참고 자료, 그리고 수많은 오퍼레이터(Operator)를 자랑합니다.

- **핵심 개념:** `Observable`(데이터 스트림 생성)과 `Observer`(데이터 스트림 구독)로 구성되며, 구독을 관리하기 위해 `DisposeBag`을 사용합니다.
    
- **장점:** 하위 버전의 iOS(iOS 13 미만)에서도 완벽하게 동작하며, 기존 Rx 생태계에 익숙한 개발자가 쉽게 적응할 수 있습니다.

### RxSwift 예시

배열의 숫자를 발행하고, 짝수만 걸러내어 10을 곱한 뒤 출력하는 간단한 코드입니다.

```Swift
import RxSwift

let disposeBag = DisposeBag()

Observable.of(1, 2, 3, 4, 5)
    .filter { $0 % 2 == 0 }
    .map { $0 * 10 }
    .subscribe(onNext: { value in
        print("RxSwift 출력: \(value)") // 20, 40 출력
    })
    .disposed(by: disposeBag)
```

---

## 2. Combine

Combine은 Apple이 2019년(iOS 13)에 공식적으로 발표한 네이티브 반응형 프레임워크입니다. RxSwift와 매우 유사한 개념을 공유하지만, Apple 생태계(특히 SwiftUI)에 최적화되어 설계되었습니다.

- **핵심 개념:** `Publisher`(데이터 스트림 생성)와 `Subscriber`(데이터 스트림 구독)로 구성되며, 메모리 관리를 위해 `AnyCancellable`을 사용합니다.
    
- **장점:** 서드파티 라이브러리 의존성을 줄일 수 있으며, Apple이 직접 성능을 최적화하여 RxSwift보다 가볍고 빠릅니다. SwiftUI와의 궁합이 매우 좋습니다.

### Combine 예시

RxSwift 예시와 완전히 동일한 동작을 하는 Combine 코드입니다.

```Swift
import Combine

var cancellables = Set<AnyCancellable>()

[1, 2, 3, 4, 5].publisher
    .filter { $0 % 2 == 0 }
    .map { $0 * 10 }
    .sink(receiveValue: { value in
        print("Combine 출력: \(value)") // 20, 40 출력
    })
    .store(in: &cancellables)
```

---

## 3. RxSwift vs Combine 핵심 용어 비교

두 프레임워크는 이름만 다를 뿐 1:1로 매칭되는 개념이 많습니다.

|**개념**|**RxSwift**|**Combine**|
|---|---|---|
|**데이터 생산자**|`Observable`|`Publisher`|
|**데이터 소비자**|`Observer`|`Subscriber`|
|**구독 및 실행**|`subscribe`|`sink`, `assign`|
|**메모리 관리 (구독 해제)**|`DisposeBag`|`AnyCancellable` (`Set<AnyCancellable>`)|
|**에러 없는 단일 데이터**|`Relay` (RxRelay)|`CurrentValueSubject`, `PassthroughSubject`|

> **요약:** 현재 유지보수 중인 레거시 프로젝트나 iOS 13 미만을 지원해야 한다면 **RxSwift**가 필수적입니다. 반면, 최소 타겟이 iOS 13 이상이고 SwiftUI를 주력으로 사용하는 새로운 프로젝트라면 Apple의 네이티브 프레임워크인 **Combine**을 선택하는 것이 더 효율적인 방향입니다.

---

> [[iOS 학습 인덱스]]