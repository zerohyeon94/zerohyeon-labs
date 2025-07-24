## 1. **MVVM-C란?**

- **MVVM-C** = Model–View–ViewModel + **Coordinator**
    
- **Coordinator(코디네이터)**는  
    **“화면 전환(네비게이션, 프레젠트, 딥링크 등)”을 ViewController나 ViewModel이 직접 담당하지 않고, 별도의 객체(Coordinator)가 관리**하는 패턴입니다.

---

## 2. **왜 Coordinator가 필요한가? (배경)**

- MVVM만 써도 ViewModel에 화면 로직/비즈니스 로직이 분리되지만, **“화면 전환(다음 화면으로 이동)”**은 여전히 ViewController나 ViewModel이 직접 처리하는 경우가 많음
    
- 앱이 커질수록 화면 이동(네비게이션) 로직이 여기저기 흩어지고, ViewController/ViewModel이 화면 전환에 “의존”하게 됨
  → **재사용성, 테스트성 저하 / 의존성 꼬임**

---

## 3. **MVVM-C의 핵심 구조**

- **View**: 화면(UI)
    
- **ViewModel**: 데이터/비즈니스 로직, 상태 관리
    
- **Model**: 데이터 구조/네트워크/DB 등
    
- **Coordinator**:
    
    - 화면 전환(네비게이션)만 담당
        
    - ViewController/ViewModel은 “이동하라”는 신호만 Coordinator에 전달

### **흐름 예시**

1. 사용자가 버튼 클릭(예: “회원가입”)
    
2. ViewModel → Coordinator에게 “회원가입 화면으로 이동 요청” 이벤트 전달
    
3. Coordinator가 ViewController(혹은 Scene)을 생성해서 화면 전환 처리

---

## 4. **MVVM-C의 장점**

- **네비게이션 로직이 한 곳에 집중** →  
    유지보수, 테스트, 재사용, 딥링크, Scene 분기 등 처리 용이
    
- ViewController, ViewModel은 네비게이션 책임이 없어 코드가 깔끔함
    
- Scene/Flow 단위로 앱 구조를 쉽게 나눌 수 있음

---

## 5. **코드 구조 예시**

```swift
// Coordinator 프로토콜
protocol Coordinator {
    func start()
}

// 예시: 회원가입Coordinator
class SignupCoordinator: Coordinator {
    let navigationController: UINavigationController

    func start() {
        let vm = SignupViewModel()
        let vc = SignupViewController(viewModel: vm)
        // vm에서 "회원가입 완료" 신호를 받으면, 다음 화면 전환 로직을 코디네이터가 담당
        navigationController.pushViewController(vc, animated: true)
    }
}
```

- ViewModel에서 네비게이션 이벤트 발생 → Coordinator가 이를 감지해 화면 이동 처리