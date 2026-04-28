## 1. **ViewController를 띄우는(화면 전환) 다양한 방법**

### (1) **NavigationController (Push/Pop)**

- 네비게이션 스택(계단식) 구조로, “뒤로 가기” 버튼이 자동 생성
    
- `navigationController?.pushViewController(_:animated:)`
    
- 보통 “상세화면”, “다음 단계”로 이동할 때 사용

### (2) **Modal (Present/Dismiss)**

- 현재 화면 위에 새로운 화면을 **덮어 씌움**
    
- `present(_:animated:completion:)`
    
- 예시: 설정창, 팝업, 전체화면, 일부 시트 등

### (3) **TabBarController**

- 하단 탭바를 이용해서 여러 화면을 수평적으로 전환
    
- 각 탭마다 별도의 네비게이션 스택을 가질 수 있음

### (4) **Child ViewController (컨테이너 뷰컨트롤러)**

- 한 ViewController 안에 다른 ViewController를 **서브 뷰**로 삽입
    
- 예: 페이지 전환, 슬라이드 메뉴, 커스텀 컨테이너 UI
    
- 코드:
    ```swift
    addChild(childVC)
	view.addSubview(childVC.view)
	childVC.didMove(toParent: self)
	```

### (5) **Custom Transition / Animation**

- iOS 7부터는 커스텀 애니메이션으로 화면 전환 가능
    
- 예: 화면 슬라이드, 페이드, 드래그-투-디스미스 등

### (6) **Segue (스토리보드)**

- 스토리보드에서 "화살표"로 연결
    
- Show (Push), Modal, Custom 등 다양한 전환 방식 지정 가능

---

## 2. **present로 띄운 창에서 Navigation 동작 가능?**

### 결론부터 말하면,

**present로 띄운 ViewController에서 네비게이션 동작(즉, push/pop 등 스택 구조)도 구현할 수 있습니다.**

### 방법:

- **present할 때 NavigationController를 래핑해서 띄우면 됨!**

```swift
let newVC = MyViewController()
let nav = UINavigationController(rootViewController: newVC)
present(nav, animated: true)
```

- 이렇게 하면, 모달로 띄운 창에서도 네비게이션 바와 push/pop이 가능
    
- 실제로 “회원가입”, “설정”처럼 모달로 여러 단계 진행해야 할 때 자주 씁니다.

---

### [예시 상황]

- Modal로 “회원가입” → 중간에 “약관 보기” 등 여러 단계를 push/pop 해야 할 때  
    → NavigationController로 감싼 뒤 present

---

## **정리**

- 화면 전환 방법은 Push, Present 외에도 TabBar, ChildVC, Segue, Custom Transition 등 다양
    
- **Modal(present)에서도 NavigationController로 감싸주면 네비게이션 가능**

---

> [[iOS 학습 인덱스]]