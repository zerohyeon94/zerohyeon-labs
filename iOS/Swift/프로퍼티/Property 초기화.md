>[!warning] Error가 발생!!!
> Cannot use instance member 'viewModel' within property initializer; property initializers run before 'self' is available

- 이 에러는 Swift에서 **인스턴스 프로퍼티 초기화 순서** 때문에 발생하는 대표적인 컴파일 에러
## **원인**

- 클래스(혹은 struct)에서  
    **다른 인스턴스 프로퍼티(예: viewModel)를,  
    프로퍼티 선언부에서 직접 사용**하려고 할 때 발생합니다.
- Swift에서는  
    **프로퍼티 초기화(=property initializer)**는  
    아직 `self`(=인스턴스 자신)가 완전히 만들어지기 전에 실행되므로  
    **다른 인스턴스 멤버에 접근할 수 없음**  
    → 그래서 이 에러가 발생!

---

## **예시 코드**

```swift
class MyViewController: UIViewController {
    let viewModel = MyViewModel()
    // 아래처럼 선언하면 에러!
    let dataSource = MyDataSource(viewModel: viewModel) // ❌ 에러!
}
```

- 이 때, `viewModel`은 아직 초기화가 끝나지 않았기 때문에  
    `dataSource = MyDataSource(viewModel: viewModel)`에서  
    **viewModel에 접근이 불가**합니다.

### **왜 초기화가 끝나지 않았다고 할까?**

#### **프로퍼티 선언 = “인스턴스 멤버 선언”이지, “런타임에서 순차 실행”이 아님**

Swift에서 클래스의 프로퍼티들은 **초기화 과정 중에** _동시에_ 초기화되는 것이지,  
**위에서부터 아래로 한 줄씩 실행되는 것이 아닙니다.**

즉,
```swift
class MyViewController: UIViewController {
    let viewModel = MyViewModel()
    let dataSource = MyDataSource(viewModel: viewModel)
}
```

이 코드는 **실제로는**

1. `MyViewController` 인스턴스를 만들 때
2. `viewModel`, `dataSource` **모두**
3. **아직 self가 완전히 생성되기 전에 “동시에”(=실제로는 컴파일 타임에 미리) 초기화될 코드들이 준비**되는 것임

### **Swift의 규칙:**

> **프로퍼티 초기화 시점에는 self(=인스턴스 자신)에 접근할 수 없다!**

이 시점에서

- `let viewModel = MyViewModel()`는  
    "이 인스턴스가 만들어질 때, viewModel이라는 프로퍼티에 MyViewModel() 객체를 할당할 것이다"라고 _정의_만 해놓은 것
    
- 그리고  
    `let dataSource = MyDataSource(viewModel: viewModel)`  
    여기서 사용한 `viewModel`은  
    아직 “self.viewModel”로 접근할 수 있는 상태가 아님(자바/C# 등과는 다름)
    

즉,  
**인스턴스(self)가 아직 메모리에 완성되기 전**이므로,  
다른 프로퍼티(=self의 멤버)에 접근할 수 없음  
(즉, “내가 아직 만들어지기도 전에 내 다른 부품을 참조할 수 없다”)

---

### **정리하자면**

- Swift에서 프로퍼티 선언부의 값은 “생성자에서 동시에 모두 할당되는 값”
- 이 과정에서는 아직 “self.XXX” 참조가 불가능
- `let dataSource = MyDataSource(viewModel: viewModel)`에서의 viewModel은  
    사실상 “self.viewModel”에 접근하는 것과 같으나  
    이 시점에 self가 완성되어 있지 않아 컴파일러가 에러로 막음

---

## **해결 방법**

### 1. **lazy var 사용하기**

- `lazy`는 **self가 모두 생성된 후에** 초기화되므로,  
    다른 인스턴스 멤버에 접근 가능!
- 실제로 “처음 사용될 때(self가 이미 완성된 이후)”에 초기화되기 때문에 안전

```swift
let viewModel = MyViewModel()
lazy var dataSource = MyDataSource(viewModel: viewModel)
```

### 2. **초기화 구문(init)에서 할당하기**

- 생성자에서 명시적으로 할당
- 생성자 내에서는 “self의 다른 멤버”에 접근할 수 있도록 Swift가 허용

```swift
let viewModel = MyViewModel()
let dataSource: MyDataSource

init() {
    self.dataSource = MyDataSource(viewModel: viewModel)
    super.init(nibName: nil, bundle: nil)
}

```

---

## **실무 팁**

- `lazy` var는 “생성 시점에 꼭 필요한 게 아닐 때”,  
    또는 "다른 프로퍼티가 필요할 때" 매우 유용
    
- 만약 의존성이 많거나, 생성자에서 여러 값 조합이 필요하면  
    `init()`에서 할당하는 게 더 명확함

---

## **요약**

- **self(=인스턴스)가 완전히 생성되기 전**에는  
    다른 프로퍼티(특히 인스턴스 프로퍼티)에 접근할 수 없다.
    
- 이럴 땐 **lazy var** 또는 **초기화 구문에서 할당**으로 해결