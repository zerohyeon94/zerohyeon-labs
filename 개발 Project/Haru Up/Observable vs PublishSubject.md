## 1. 개념적으로 딱 한 줄 차이

- **`Observable`** → _읽기 전용 스트림 타입_ (이벤트를 **구독만** 할 수 있음)
    
- **`PublishSubject`** → _이벤트를 내보낼 수도(onNext) 있고, 구독도 할 수 있는 구체 타입_  (= Observable + Observer 둘 다 하는 애)

그래서 선언을 이렇게 하면:

```swift
let kakaoLoginTapped: Observable<Void>
let kakaoLoginTapped: PublishSubject<Void>
```

### 공통점

- 둘 다 `.subscribe`, `.bind(to:)`는 가능해요. (둘 다 Observable처럼 동작하니까)

### 차이점

- `PublishSubject` 타입이면 **`onNext`, `onError`, `onCompleted`를 직접 호출할 수 있음**
    
- `Observable` 타입이면 **직접 이벤트를 밀어넣을 수 없음** (그냥 “밖에서 오는 스트림을 받는 입장”)

---

## 2. MVVM에서 보통 어떻게 쓰냐?

### 2-1. ViewModel 내부에서 이벤트를 만들고 싶을 때

예를 들어:

```swift
final class LoginViewModel {
    // Input
    let kakaoLoginTapped = PublishSubject<Void>()
}
```

이렇게 해두면 ViewController에서:

```swift
kakaoButton.rx.tap
    .bind(to: viewModel.kakaoLoginTapped)
    .disposed(by: disposeBag)
```

ViewModel 안에서는:

```swift
kakaoLoginTapped
    .subscribe(onNext: { ... })
    .disposed(by: disposeBag)
```

처럼 “버튼 탭 이벤트가 들어오는 스트림”으로 사용 가능.

여기서 `kakaoLoginTapped`를 `Observable<Void>`로 선언하면?

`let kakaoLoginTapped: Observable<Void>`

- ViewModel **안에서는** 이 Observable에다가 직접 `onNext`를 쏠 수 없기 때문에,
    
- 보통은 **어디선가 만들어진 Subject/Relay를 넘겨받는다**는 의미가 돼버림.
    
    - 예: `Input` struct 안에 `Observable<Void>`로 받은 경우

즉:

> **ViewModel이 ‘이벤트를 받아서 로직만 처리한다’**  → `Observable`로 받는 경우가 많고  
> **ViewModel 안에서 직접 이벤트를 만들거나 중계하고 싶다** → Subject/Relay를 쓰는 경우가 많음.

---

## 3. “외부에 뭘 노출하느냐”가 더 중요해요

실무에서 제일 많이 쓰는 패턴은 이거예요:

```swift
final class ExampleViewModel {

    // 내부에서만 쓰는 Subject
    private let kakaoLoginTappedSubject = PublishSubject<Void>()

    // 외부에는 Observable로만 노출 (읽기 전용)
    var kakaoLoginTapped: Observable<Void> {
        kakaoLoginTappedSubject.asObservable()
    }
}
```

- **ViewModel 내부**: `kakaoLoginTappedSubject.onNext(())` 가능
    
- **View / 다른 객체**: `kakaoLoginTapped`를 구독만 가능, onNext 못 함

이렇게 하면:

- 밖에서 실수로 `onNext` 날려버리는 일을 막고
    
- “이 스트림에 이벤트를 넣을 수 있는 건 ViewModel 내부뿐”이라는 게 보장돼서 구조가 안전해져요.

---

> [[Home]]