간단 요약: **두 방식은 의도(소유자 탈락 시 이벤트 무시)와 안전성은 거의 동일**하고,  
`.emit(with:self)`는 그 패턴을 **축약·가독화**한 RxCocoa의 **헬퍼**입니다.

---

## 차이점 요약

### 1) 캡처 방식

- `emit(onNext: { [weak self] value in ... })`
    
    - 직접 `weak` 캡처 → 내부에서 `guard let self else { return }` 같은 처리 필요.
        
- `emit(with: self) { owner, value in ... }`
    
    - **내부가 이미 [weak object] 처리** → 클로저에는 **non-optional `owner`**가 들어옴.
        
    - 소유자(`self`)가 해제되면 **이벤트를 자동 무시**하고 클로저가 호출되지 않음.

### 2) 가독성/보일러플레이트

- `with:` 버전은 `guard let self`/`if let self` 제거 → **짧고 안전**.
    
- 의도가 “소유자 살아있을 때만 처리”임이 더 **명시적**.

### 3) 제약

- `with:`는 **참조 타입(AnyObject)** 만 가능. (구조체는 불가)
    
- `emit(onNext:)`는 어떤 캡처든 자유롭게 가능(여러 객체 weak 캡처 등).

### 4) 안전성

- 둘 다 **순환 참조 방지**에 안전.
    
- 둘 다 **소유자 해제 시 작업 스킵**(with는 자동, onNext는 직접 guard 필요).

### 5) 반환/스케줄러

- 둘 다 `Disposable` 반환 → `disposed(by:)` 필요.
    
- `Signal.emit`/`Driver.drive` 특성(Main 스레드, 에러 전파 없음)은 동일.

---

## 코드로 비교

### 일반형

```swift
output.route
  .emit(onNext: { [weak self] route in
      guard let self else { return }
      self.navigate(route)
  })
  .disposed(by: bag)
```

### 축약형(with:)

```swift
output.route
  .emit(with: self) { owner, route in
      owner.navigate(route)
  }
  .disposed(by: bag)
```

동일한 동작을 더 간결하게 표현한 것뿐입니다.

---

## 언제 무엇을 쓸까?

- **ViewController/Cell 등 소유자 기준으로 처리** → `emit(with:self)` / `drive(with:self)` 권장  
    (읽기 쉽고 실수 적음)
    
- **여러 객체를 weak로 함께 다뤄야** 하거나 **값 타입도 섞여** 있다면  
    → `emit(onNext:)`에 수동 캡처/가드

---

## 한 줄 결론

- 기능상 차이는 거의 없고, **`.emit(with:)`는 “소유자 살아있을 때만 처리” 패턴의 안전한 축약형**입니다.
    
- 가능하면 `with:`/`drive(with:)`를 기본으로 쓰고, 특수한 캡처가 필요할 때만 수동 `weak self`를 쓰세요.

---
# 라이브러리에 있는 코드의 정의
## 일반형

```swift
public func emit(
    onNext: ((Element) -> Void)? = nil,
    onCompleted: (() -> Void)? = nil,
    onDisposed: (() -> Void)? = nil
) -> Disposable {
    self.asObservable().subscribe(onNext: onNext, onCompleted: onCompleted, onDisposed: onDisposed)
}
```

- **역할:** `Signal`에 “이벤트 핸들러(onNext) / 완료 핸들러(onCompleted) / 해제 핸들러(onDisposed)”를 구독 형태로 붙입니다.
    
- **에러 콜백 없음:** `Signal`은 **오류를 방출하지 않는** RxCocoa 트레이트이므로 `onError` 파라미터가 없습니다.
    
- **onCompleted vs onDisposed**
    
    - `onCompleted`: **정상 완료**(graceful termination) 시 1회 호출.
        
    - `onDisposed`: 완료/에러/수동 dispose 등 **어떤 종료든** 호출(= finally 훅).
        
- **반환값:** 구독을 해제할 수 있는 `Disposable`을 돌려줍니다.

---
### 배울 수 있는 포인트

1. **`public` 접근 제어자**  
    라이브러리 외부(앱 코드)에서 사용할 수 있게 공개.
    
2. **제네릭 `Element`**  
    `Signal<Element>`의 요소 타입을 그대로 받습니다. (`emit`은 **제네릭 함수**가 아니라, 제네릭 타입의 **인스턴스 메서드**)
    
3. **옵셔널 클로저 + 기본값 `= nil`**
    
    - 필요 없는 콜백은 생략 가능(예: `.emit(onNext:)`만 쓴다).
        
    - 호출 측 가독성↑, 오버로드 폭발 방지.
        
4. **외부 파라미터 라벨**  
    `onNext:`, `onCompleted:`, `onDisposed:`로 **의도가 바로 드러남**.
    
5. **`asObservable()` 브리지**
    
    - `Signal` → **`Observable`로 일시 변환** 후, 표준 `subscribe(...)`를 호출.
        
    - 구현을 재사용하여 중복을 줄임.
        
    - 주의: `Signal` 자체의 성질(메인 스케줄러, no error, 공유 등)은 **`Signal`이 만들어질 때 보장**되고, 여기서는 **그 결과를 Observable 인터페이스로 구독**하는 패턴.
        
6. **`subscribe(...)`로 실제 구독 생성**  
    반환된 `Disposable`을 `.disposed(by:)`로 관리해야 **메모리/수명**이 정리됩니다.
    
7. **에러 파라미터가 없는 이유(디자인 철학)**
    
    - `Signal`은 RxCocoa의 **UI 바인딩 친화** 트레이트:
        
        - **메인 스레드 보장**,
            
        - **에러 방출 안 함**(UI 바인딩이 에러로 끊기는 문제 예방),
            
        - **share(replay: 0)** 로 멀티구독 공유.
            
    - 그래서 `emit`엔 `onError`가 설계상 없습니다.

---
## 축약형

```swift
public func emit<Object: AnyObject>(
    with object: Object,
    onNext: ((Object, Element) -> Void)? = nil,
    onCompleted: ((Object) -> Void)? = nil,
    onDisposed: ((Object) -> Void)? = nil
) -> Disposable {
    self.asObservable().subscribe(
        with: object,
        onNext: onNext,
        onCompleted: onCompleted,
        onDisposed: onDisposed
    )
}
```

- **목적:** `Signal<Element>`를 구독하면서 **소유자 `object`를 약하게(weak) 참조**하고, 그 객체가 **존재할 때만** 콜백을 실행.
    
- **“unretained, safe to use”**: 내부적으로 `object`를 **weak**로 캡처하고, **nil이 아닐 때만** 콜백을 호출합니다. 그래서 콜백에서는 `owner`가 **비옵셔널(Object)** 로 안전하게 전달되어 `guard let self`가 필요 없습니다.
    
    - _unretained = 강하게 잡지 않음(순환 참조 방지),_
        
    - _safe = nil이면 아예 콜백을 호출하지 않아 크래시가 없음 (`unowned`와 다름)._
        
- **에러 콜백이 없는 이유:** `Signal`은 설계상 **에러를 방출하지 않는** RxCocoa 트레이트라 `onError`가 없습니다.
    
- **Note의 의미:** `object`를 잡고 있을 수 없으면(= 이미 해제되어 **retain되지 않으면**) **다른 클로저(onNext/onCompleted/onDisposed)도 호출되지 않습니다.**
    
    - 즉, **소유자가 없으면 모든 이벤트를 무시**합니다. UI 바인딩에 매우 안전한 기본값.

---

### 배울 수 있는 포인트
- **제네릭 + 클래스 제약 (`Object: AnyObject`)**
    
    - `with`에 넘길 수 있는 타입은 **클래스 인스턴스(참조 타입)** 만.
        
    - 이유: 내부에서 **weak** 캡처를 사용해야 하므로 값 타입(Struct/Enum)은 불가.
        
- **옵셔널 클로저 + 기본값 `= nil`**
    
    - `onNext`/`onCompleted`/`onDisposed` 모두 **선택적**. 필요한 것만 넘기면 됩니다.
        
    - 오버로드를 늘리지 않고 **호출 가독성**을 높이는 패턴.
        
- **파라미터 라벨링**
    
    - `with object:` 로 **소유자 전달의 의도**가 드러남.
        
    - 뒤 콜백들은 `Object`(owner)와 `Element`(이벤트 값)를 **튜플이 아닌 개별 파라미터**로 받아 사용성↑.
        
- **`asObservable()` 브리지 + 재사용**
    
    - `Signal` → `Observable`로 **일시 변환** 후, 이미 구현된 `subscribe(with:)`를 호출해 **중복 구현을 줄임**.
        
    - `Signal` 특성(메인 스케줄러/에러 없음/공유)은 **트레이트 초기화 시 보장**되고, 여기서는 **구독 인터페이스만 위임**.
        
- **반환형 `Disposable`**
    
    - 구독을 나타내는 핸들. 반드시 `.disposed(by:)` 등으로 **수명 관리**하세요.
        
- **클로저는 @escaping**
    
    - 명시는 없지만, 구독 중 나중에 실행되므로 **탈출 클로저**입니다(스위프트가 암묵 적용).
        
- **스레드 보장(트레이트의 성질)**
    
    - `Signal`은 RxCocoa 규약상 **MainScheduler**에서 방출(바인딩 친화).
        
    - 별도 `observe(on:)`를 바꾸지 않았다면 **UI 작업이 안전**합니다.

---

### `.emit(onNext:)`와의 차이 (개발 경험 관점)

- 수동 패턴
    ```swift
    signal.emit(onNext: { [weak self] value in
	    guard let self else { return }
	    self.handle(value)
	})
    ```
    
    - 직접 `weak` 캡처 + 가드가 필요.
        
- 축약/안전 패턴
    ```swift
    signal.emit(with: self) { owner, value in
	    owner.handle(value)
	}
    ```
    
    - 내부가 **자동 weak & 존재 확인** → 콜백은 **non-optional owner**를 받음.
        
    - **가독성↑, 실수↓** (특히 VC/셀 바인딩에서 표준 패턴)

> 기능 차이는 거의 없고, **`with:`가 코드 의도(“소유자 살아있을 때만”)를 더 명확히** 표현합니다.

---

# 언제 `onCompleted`와 `onDisposed`가 불리나요?

- **onCompleted**: 스트림이 **정상 종료**될 때 (예: 내부적으로 `completed` 이벤트가 방출될 때)
    
- **onDisposed**:
    
    - 정상 완료 뒤 **디스포즈**될 때,
        
    - 수동으로 `dispose()`를 호출했을 때,
        
    - 에러로 종료된 경우(※ `Signal`은 원칙상 에러 X이지만, 브리지 체인 상에서 dispose는 발생할 수 있음) 등 **모든 종료 케이스**.
### 사용 예시

```swift
// 단순 onNext만
output.route   // Signal<Route>
  .emit(onNext: { [weak self] route in
      self?.navigate(route)
  })
  .disposed(by: bag)

// 완료/정리 훅도 필요할 때
timerSignal // Signal<Int>
  .emit(
    onNext: { print($0) },
    onCompleted: { print("completed") },
    onDisposed: { print("disposed") }
  )
  .disposed(by: bag)
```

- 소유자 생존 시에만 처리하고 싶을 때 .emit(with: ) 사용
``` swift
output.toast // Signal<String>
  .emit(with: self) { owner, msg in  // 내부에서 weak 캡처
      owner.showToast(msg)
  }
  .disposed(by: bag)
```
