# DisposeBag은 언제 동작하나요?

`disposed(by: disposeBag)`를 붙이면 **그 구독(Disposable)을 bag이 파괴될 때 자동으로 dispose** 합니다. 즉, 다음 시점 중 하나에 구독이 해제돼요.

1. **Observable이 종료**될 때 
	- `onCompleted` 또는 `onError`가 오면 그 구독은 **즉시** 해제됩니다.

2. **수동으로 해제**할 때 : 
	- `let d = observable.subscribe(...)` 후 `d.dispose()` 호출.

3. **DisposeBag이 메모리에서 해제**될 때
	- 보통 **`deinit`** 시점(예: ViewController가 사라질 때).
	- 또는 **새 bag으로 교체**해서 기존 bag이 참조에서 끊기는 순간.

4. **연산자로 생명주기 제어**할 때
	- `takeUntil`, `take(until:)`, `takeWhile`, `rx.deallocated` 등으로 스트림을 끊으면 그 시점에 해제.

> 요약: “구독이 끝나거나(because complete/error), 내가 직접 dispose 하거나, bag이 없어질 때” 해제됩니다.

---

# 구독마다 다른 DisposeBag을 써도 되나요?

네. **가능하고, 매우 흔한 패턴**입니다. “수명(scope)이 다른 덩어리”끼리 **서로 다른 bag**을 쓰면 관리가 깔끔합니다.

- **ViewController 전 생명주기용**: `vcBag`
    
- **화면 재구성(예: viewWillAppear마다 리바인딩)용**: `bindingBag`을 매번 새로 재할당
    
- **셀 재사용용**: `cellBag`을 `prepareForReuse()`에서 새로 생성

중요: **하나의 구독(Disposable)을 두 개 bag에 넣을 수는 없습니다.** (한 번만 `disposed(by:)` 하세요.)  
서로 다른 수명으로 관리하고 싶다면 **구독을 각각 따로 만들고** 각기 다른 bag에 넣으세요.  
여러 구독을 묶어 관리하고 싶다면 `CompositeDisposable`을 고려하세요.

---

# 실무 패턴 예시

### 1) ViewController 기본

```swift
final class ProfileViewController: UIViewController {
    private let vm: ProfileViewModel
    private var bag = DisposeBag()          // VC 생존 동안 유지
    private var bindingBag = DisposeBag()   // 바인딩용, 필요 시 교체

    override func viewDidLoad() {
        super.viewDidLoad()

        // 한 번만 연결해도 되는 것들 (Notification, static signals 등)
        vm.userName
            .bind(to: nameLabel.rx.text)
            .disposed(by: bag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 화면 진입마다 최신 바인딩을 다시 묶고 싶다면
        bindingBag = DisposeBag()

        vm.latestPosts
            .bind(to: tableView.rx.items(cellIdentifier: "Cell")) { _, post, cell in
                cell.textLabel?.text = post.title
            }
            .disposed(by: bindingBag)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 화면에서 나갈 때만 끊고 싶으면 bindingBag만 교체/해제
        bindingBag = DisposeBag()
    }
}
```

### 2) UITableViewCell 재사용

```swift
final class PostCell: UITableViewCell {
    var bag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag() // 이전 구독 전부 해제되고 새로 시작
    }

    func bind(_ vm: PostCellViewModel) {
        vm.title
            .bind(to: textLabel!.rx.text)
            .disposed(by: bag)
    }
}
```

### 3) takeUntil로 생명주기 묶기 (bag 없이도 가능)

```swift
observable
    .takeUntil(self.rx.deallocated) // self가 deinit되면 자동 해제
    .bind(to: ...)
    .disposed(by: bag) // 또는 이 줄을 생략하고 takeUntil만 써도 됨
```

### 4) 특정 시점에만 유지하고 끊기

```swift
// 화면이 사라질 때까지 유지
observable
    .takeUntil(rx.viewWillDisappear) // RxCocoa 제공
    .bind(to: ...)
    .disposed(by: bag)
```

---

# 자주 하는 질문 정리

**Q. DisposeBag이 “언제 호출”되나요?**  
A. `disposed(by:)`는 “추후 bag이 파괴될 때 이 구독도 같이 해제하라”는 **등록**입니다. 실제 **해제 동작**은 위 네 가지 경우(완료/에러, 수동 dispose, bag 해제, takeUntil 등) 중 하나일 때 일어납니다.

**Q. 한 구독을 여러 bag에 넣을 수 있나요?**  
A. 아니요. 한 구독은 **한 번만** `disposed(by:)` 하세요. 수명 구분이 필요하면 **구독을 분리**하세요.

**Q. DisposeBag을 갈아끼우면?**  
A. 기존 bag이 **참조를 잃는 순간 deinit** → bag 안의 모든 구독이 **즉시 dispose** 됩니다.

**Q. 완료된 스트림도 bag이 필요하나요?**  
A. 완료/에러로 끝나는 스트림은 자동으로 해제되지만, 일반적으로는 일관성 있게 `disposed(by:)`를 붙여 관리하는 습관이 좋습니다. (완료 안 되는 스트림—예: UI 이벤트—에는 필수)

---

# 안전한 바인딩 체크리스트

- `withUnretained(self)` 또는 `[weak self]`로 **강한 순환 참조 방지**
    
- “화면마다 다시 묶는 바인딩”은 **별도 bag**으로 관리 후 적절한 시점에 교체
    
- 셀/재사용 뷰는 **`prepareForReuse()`에서 bag 교체**
    
- 특정 수명에 종속된 스트림은 **`takeUntil`/`take(until:)`**로 명시

---

> [[iOS 학습 인덱스]]