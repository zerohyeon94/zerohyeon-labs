# 큰 지도

- **Observable\<T\>**: 값을(여러 번) 방출하는 “스트림”의 기본형
    
- **ObserverType**: 값을 “받아 처리”하는 쪽 (subscribe한 콜백)
    
- **Subject**: Observable이면서 Observer인 **양면** 타입 (입·출력 둘 다)
    
- **Relay**: Subject에서 **error/completed 없이** next만 내는 안전한 변형 (RxCocoa)
    
- **Traits**: 특정 목적에 맞게 제약을 둔 “규약형” Observable (쓰는 순간 의도가 명확해짐)
    

---

# 1) Observable 계열 (기본기)

- **Observable\<T\>**: 0~N개 `next` + (옵션) `completed`/`error`
    
    - 예: UI 이벤트 스트림, 타이머, 리스트 데이터 바인딩 등
        
- **Cold vs Hot**
    
    - **Cold**: 구독 시 작업 시작(네트워크 요청 새로 발생)
        
    - **Hot**: 이미 흐르는 이벤트를 공유(노티, UI 이벤트)
        

> 언제? “일반 스트림 전반”—대부분의 연산자가 여기에 붙습니다.

---

# 2) Subject (입력도 가능한 Observable)

- **PublishSubject\<T\>**: 구독 **이후** 이벤트만 전달 (초기값 없음)
    
- **BehaviorSubject\<T\>**: **마지막 값 1개**를 보존해 새 구독자에게 즉시 전달(초기값 필요)
    
- **ReplaySubject\<T\>**: **최근 N개** 버퍼 후 재방출 (남발 주의)
    
- **AsyncSubject\<T\>**: complete 시 **마지막 값 1개**만 방출
    

> 언제? 외부에서 이벤트를 **주입**해야 할 때.  
> 단, UI/상태 노출에는 Relay(아래)가 보통 더 안전합니다.

---

# 3) Relay (RxCocoa, error/completed 없음 → UI/상태에 안전)

- **PublishRelay\<T\>**: 초기값 없음, `accept(_:)`로 푸시
    
- **BehaviorRelay\<T\>**: **현재값 보유**(`value`/`accept`), 상태 보관에 많이 사용
    

> 언제? **상태/이벤트를 ViewModel에서 외부로 노출**할 때.  
> “끝나지 않는 스트림”이므로 UI 바인딩에 적합.

---

# 4) Single/Maybe/Completable (1회성 작업용 Traits)

- **Single\<T\>**: **성공 1개 or 에러** (네트워크 요청에 딱 맞음)
    
- **Maybe\<T\>**: **성공 1개 or 완료(값 없음) or 에러**
    
- **Completable**: **완료 or 에러** (결과값 필요 없는 작업—캐시 삭제 등)
    

> 언제? “**한 번만** 결과가 나는 비동기 작업”을 명확히 표현하고 싶을 때.

---

# 5) Driver/Signal (Main + UI 바인딩 친화 Traits, RxCocoa)

**공통 장점**: 기본적으로 **MainScheduler**, **에러 전파 안 함**(UI 깨짐 방지), **shareReplay**로 구독 공유

- **Driver\<T\>**: **상태** 스트림
    
    - 특성: replay(1) 보장(최신 값 유지), UI 바인딩에 최적
        
    - 예: `isLoading: Driver<Bool>`, `items: Driver<[Item]>`, `title: Driver<String>`
        
- **Signal\<T\>**: **이벤트** 스트림
    
    - 특성: replay(0) (과거값 재전달 없음), “순간 이벤트”에 적합
        
    - 예: `route: Signal<Route>`, `toast: Signal<String>`, `haptic: Signal<Void>`
        

> 언제? **ViewModel → View(UI)** 로 값을 안전하게 전달할 때  
> 규칙: **지속 상태는 Driver**, **단발 이벤트는 Signal**.

---

# 6) Control 계열 (UI 전용 Traits, RxCocoa)

- **ControlProperty\<T\>**: UI 속성의 “양방향 바인딩”에 최적화 (Main, no error, replay(1))
    
    - 예: `textField.rx.text`(Optional), `switch.rx.value`
        
- **ControlEvent\<T\>**: UI 이벤트(단발)에 최적화 (Main, no error, no replay)
    
    - 예: `button.rx.tap`, `view.rx.didAppear`
        

> 언제? UIKit 컴포넌트와 바인딩할 때 **가장 안전한 타입**.

---

# 7) 선택 가이드 (무엇을 써야 할까?)

|상황|추천 타입|이유/메모|
|---|---|---|
|네트워크 요청 (1회성)|**Single<T>**|성공 1개 or 에러, 의도 명확|
|값 없어도 되는 비동기 작업|**Completable**|성공/실패만 중요|
|옵션 결과의 1회성|**Maybe<T>**|값 없을 수도 있음|
|UI 상태 노출 (현재값 유지)|**Driver<T>** 또는 **BehaviorRelay<T>**|Main, 에러 비전파, 최신값 유지|
|UI 이벤트(토스트/라우팅)|**Signal<T>** 또는 **PublishRelay<T>**|단발, 재전달 불필요|
|외부에서 이벤트 주입 필요|**PublishSubject/Relay**|입력구멍이 필요한 경우|
|현재 상태 보관 + 주입|**BehaviorRelay<T>**|`value` 보유 + 변경 푸시|
|UI 바인딩(컨트롤 값)|**ControlProperty<T>**|Main, no error, replay(1)|
|UI 바인딩(컨트롤 이벤트)|**ControlEvent<T>**|Main, no error, no replay|

---

# 8) 스레드/스케줄러와 함께 쓰는 법 (핵심 패턴)

```swift
api.getUser()                     // Single<User>
  .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated)) // 시작은 BG
  .observe(on: MainScheduler.instance)                                   // UI는 메인
  .asDriver(onErrorJustReturn: User.empty) // UI 바인딩용 Driver로 변환
  .drive(nameLabel.rx.text)
  .disposed(by: bag)
```

- **UI 바인딩 전에는 항상 Main**으로 옮기기
    
- ViewModel 내부 상태/출력은 **Driver/Signal**로 노출 → VC에서는 `.drive/.emit` 사용

---

# 9) 작은 안티패턴 & 팁

- **Subject 남발 금지**: 가능하면 `map/scan/withLatestFrom` 등 **연산자**로 해결, 정말 필요할 때만 Subject/Relay
    
- **Driver/Signal로 에러 삼키기 주의**: 화면 바인딩은 좋지만, 에러 로깅/처리는 따로(예: `ErrorTracker` + `errorMessage: Signal<String>`)
    
- **Relay로 무한 상태 끌어올리기 주의**: 도메인 상태는 VM 내부에서 캡슐화, 외부엔 Driver/Signal만 노출
    
- **Driver vs Signal 혼동**: “지속 상태면 Driver, 단발 이벤트면 Signal”을 기본 규칙으로

---

# 10) 미니 예시 (실전 MVVM 출력 타입)

```swift
struct Output {
  let isLoading: Driver<Bool>       // 상태
  let items: Driver<[ItemVM]>       // 상태
  let errorMessage: Signal<String>  // 이벤트(토스트)
  let route: Signal<Route>          // 이벤트(화면전환)
}

func transform(input: Input) -> Output {
  let loading = ActivityIndicator()
  let errors = ErrorTracker()

  let items = input.reloadTap
    .asSignal()
    .flatMapLatest {
      api.fetchItems()                 // Single<[Item]>
        .trackActivity(loading)
        .trackError(errors)
        .asSignal(onErrorSignalWith: .empty())
    }
    .map { $0.map(ItemVM.init) }
    .asDriver(onErrorDriveWith: .empty())

  let errorMessage = errors.asSignal().map(\.localizedDescription)

  return Output(
    isLoading: loading.asDriver(),
    items: items,
    errorMessage: errorMessage,
    route: routeRelay.asSignal()
  )
}
```

---

## 한 줄 요약

- **상태는 Driver, 이벤트는 Signal, 1회성 작업은 Single/Completable/Maybe**,
    
- 외부 주입이 필요하면 **Relay/Subject**,
    
- UI 바인딩은 **ControlProperty/ControlEvent**.
    
- 스레드는 **subscribe(on: BG) → observe(on: Main)**가 기본기.