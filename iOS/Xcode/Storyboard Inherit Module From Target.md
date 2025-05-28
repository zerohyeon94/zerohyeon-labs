## SoundWave의 AudioVisualizationView에 데이터 표시가 됨.

청진음이 표시가 되어야하는데, 표시되지않는 문제를 파악. 원인을 분석하는데 알 수 없다가, 결국엔 파악하게됨.

---

Storyboard에서 **"Inherit Module From Target"** 체크박스는 **Interface Builder가 해당 ViewController 또는 View 클래스가 어느 모듈에 속해 있는지를 자동으로 추론하도록 설정하는 옵션**입니다.

---

## ✅ 기본 개념 요약

- ✅ **모듈(Module)**: Swift에서 하나의 타겟(Target)이 생성하는 독립적인 코드 집합 (예: 앱 본체, 프레임워크 등)
- ✅ **"Inherit Module From Target"**: 현재 Storyboard를 포함한 **타겟의 모듈 이름을 자동으로 사용**하겠다는 의미

---

## 📌 예제 상황

### 예시: ViewController가 있는 Swift 클래스

```swift
class MyViewController: UIViewController {
    // ...
}
```

Storyboard에서 이 클래스를 연결하려면:

- **Class**: `MyViewController`
    
- **Module**:
    
    - 만약 `Inherit Module From Target` 체크됨 → 자동으로 앱의 모듈 이름 사용
        
    - 체크되지 않음 → 수동으로 모듈을 선택해야 함 (예: `MyFramework`)

---

## 🟡 언제 체크하면 되나요?

| 상황                                                   | 체크 여부                   |
| ---------------------------------------------------- | ----------------------- |
| **ViewController가 앱 내 정의된 클래스일 때**                   | ✅ 체크                    |
| **ViewController가 프레임워크에 정의된 클래스일 때**                | ❌ 체크 해제 후 수동으로 모듈 이름 설정 |
| **프로젝트에 다수의 모듈(프레임워크) 있을 때**                         | ❌ 수동 설정 필요              |
| **SPM이나 CocoaPods으로 import된 외부 ViewController를 쓸 때** | ❌ 수동 설정 필요              |

---

## 🧨 체크하지 않았을 때 발생할 수 있는 문제

- `UIViewController`가 nil로 인식되어 런타임 에러 발생 - `❌ 내가 발생했었던 에러. 애초에 동작하지 않음.`
    
- `Class XYZ is not key value coding-compliant for the key ___`
    
- `Could not cast value of type 'UIViewController'` 에러 등

---

## ✅ 정리

|옵션|설명|
|---|---|
|**체크함 (기본)**|현재 Storyboard가 포함된 타겟의 모듈명을 자동 사용|
|**체크 안함**|다른 모듈에서 정의된 클래스를 수동으로 지정해야 할 때 사용|
|**추천 설정**|앱 내부 클래스 → 체크, 외부 프레임워크 클래스 → 해제 후 모듈 수동 지정|