## 1. 핵심 개념 설명

### UIKit의 라이프사이클/Delegate 구조

- **UIViewController**: 뷰의 생성/화면 표시/이동/해제 등의 “라이프사이클 메서드”(예: `viewDidLoad`, `viewWillAppear` 등) 제공
    
- **Delegate 패턴**: TableView, CollectionView 등에서 데이터 소스/이벤트 처리를 ViewController가 “대리”해서 처리
    

### MVVM 패턴의 View ↔ ViewModel 관계

- **View**(ex. UIViewController): 화면 표시와 사용자 입력만 처리
    
- **ViewModel**: 데이터, 로직, 상태 관리(서버 통신, 데이터 가공, 상태 업데이트 등)
    
- **View ↔ ViewModel**: Data Binding(옵저버 패턴, RxSwift, Combine 등으로 연결)
    

---

## 2. 실제로 좋은 상황/이유

### (1) **View의 라이프사이클과 비즈니스 로직이 분리된다**

- ViewController에서는 “화면 표시”와 “이벤트 전달”만 신경쓰고,
    
- “실제 데이터 처리/로직”은 ViewModel이 담당
    
- → 코드가 명확하게 분리돼서 테스트/유지보수가 쉬움

### (2) **Delegate 메서드에서 ViewModel로 바로 연결 가능**

예를 들어 TableView의 DataSource/Delegate 메서드에서  
데이터를 ViewModel에 위임하면  
ViewController는 데이터에 거의 관여하지 않아도 됨.

---

## 3. 예제 코드로 이해하기

### 1) **MVC 구조(비추천)**

```swift
class TodoViewController: UIViewController, UITableViewDataSource {
    var todos: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // 네트워크 등 데이터 요청, 파싱, 상태 관리까지 다 여기서 함
        todos = fetchTodosFromServer()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = todos[indexPath.row]
        return cell
    }
}
```

> 문제점: ViewController가 너무 많은 역할(데이터 요청, 파싱, 뷰 표시 등)을 담당

---

### 2) **MVVM 구조**

#### ViewModel

```swift
import RxSwift
import RxCocoa

class TodoViewModel {
    // Output
    let todos: BehaviorRelay<[String]> = BehaviorRelay(value: [])

    // Input
    func fetchTodos() {
        // 네트워크, 로컬 등 데이터 로직
        let loadedTodos = ["과제 제출", "코드 리뷰", "운동"]
        todos.accept(loadedTodos)
    }
}
```

#### ViewController

```swift
class TodoViewController: UIViewController, UITableViewDataSource {
    let viewModel = TodoViewModel()
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.todos
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.fetchTodos()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.todos.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = viewModel.todos.value[indexPath.row]
        return cell
    }
}
```

> **포인트**
> 
> - ViewController는 화면 표시, 입력 이벤트 처리만 담당(“껍데기” 역할)
>     
> - 데이터 로딩, 상태 관리, 비즈니스 로직은 ViewModel이 담당
>     
> - 라이프사이클에 맞춰 `viewDidLoad`에서 ViewModel의 메서드 호출
>     
> - ViewModel의 Output이 바뀔 때마다 View(UI)가 자동으로 업데이트

---

## 4. 실무에서의 장점 정리

- **테스트 용이성**: ViewModel만 테스트하면 UI 없는 단위 테스트 가능
    
- **재사용성**: ViewModel을 여러 View에서 활용 가능
    
- **가독성**: 역할이 명확해져서 협업/유지보수에 강함
    
- **의존성 분리**: 네트워크, DB 등 외부 의존성 주입도 ViewModel에서 처리