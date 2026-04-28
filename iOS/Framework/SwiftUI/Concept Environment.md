# @Environment (환경 변수)

## 1. 정의 및 개념

**`@Environment`**는 뷰 계층 구조(View Hierarchy)의 상위에서 하위로 **데이터나 설정을 '방송(Broadcast)'하는 메커니즘**이다.

- **System Settings:** 시스템이 미리 넣어둔 값들 (예: 다크모드 여부, 화면 닫기 기능, 타임존 등).
    
- **Dependency Injection:** 개발자가 직접 넣어둔 값들을 하위 뷰 어디서든 꺼내 쓸 수 있게 함.

## 2. 작동 원리 (Waterfall 방식)

1. **위에서 뿌리기:** 최상위 뷰(Parent)나 시스템이 환경 변수(Environment Values)를 설정한다.
    
2. **아래로 흐르기:** 이 값은 뷰 계층을 타고 자동으로 **모든 자식 뷰(Children)**에게 전파된다.
    
3. **필요한 사람만 꺼내 쓰기:** 중간에 거쳐가는 뷰들은 이 값을 몰라도 된다. 실제로 필요한 말단 뷰에서 `@Environment`를 선언하면 즉시 값을 가져올 수 있다.

> **비유:**
> 
> 건물 전체에 **'중앙 난방'**을 트는 것과 같다.
> 
> 각 방(View)에서는 보일러를 직접 설치할 필요 없이, 그저 **"온도 조절기(@Environment)"**만 벽에 달면 현재 온도를 알거나 조절할 수 있다.

## 3. 자주 사용하는 예시

### ① 화면 닫기 (`\.dismiss`)

```swift
@Environment(\.dismiss) var dismiss

func close() {
    dismiss() // 내가 모달인지, 네비게이션인지 몰라도 알아서 닫아줌
}
```

### ② 다크모드 감지 (`\.colorScheme`)

```swift
@Environment(\.colorScheme) var colorScheme

var body: some View {
    Text("현재 모드")
        .foregroundStyle(colorScheme == .dark ? .white : .black)
}
```

### ③ Core Data 컨텍스트 (`\.managedObjectContext`)

앱 전체에서 DB를 써야 하므로, 보통 최상위 `App` 파일에서 주입하고 하위 뷰들은 꺼내서 쓴다.

---

## 4. UIKit vs SwiftUI 비교

가장 큰 차이는 **"데이터에 접근하는 경로"**다.

| **구분**      | **UIKit**                                                 | **SwiftUI (@Environment)**                              |
| ----------- | --------------------------------------------------------- | ------------------------------------------------------- |
| **개념**      | **전역 접근 (Global Access)**                                 | **계층적 주입 (Hierarchical Injection)**                     |
| **다크모드 확인** | `traitCollection.userInterfaceStyle`<br>(모든 VC가 가진 속성 조회) | `@Environment(\.colorScheme)`<br>(환경 변수 구독)             |
| **데이터 전달**  | `init`을 통해 부모가 자식에게 직접 전달 <br>`ChildVC(data: ...)`        | 상위에서 `.environment`로 주입하면<br>하위 어디서든 `@Environment`로 획득 |
| **특징**      | 내가 직접 찾으러 가야 함                                            | 시스템이 나에게 꽂아줌                                            |

## 5. 핵심 요약

- **Init Pass-through 제거:** A -> B -> C -> D 뷰가 있을 때, A의 데이터를 D가 쓰려면 UIKit이나 일반적인 방식은 B, C도 그 데이터를 받아서 넘겨줘야 했다. `@Environment`를 쓰면 **A에서 뿌리고 D에서 바로 받는다.**
    
- **자동 업데이트:** 환경 변수 값이 바뀌면(예: 사용자가 설정에서 폰트 크기를 키움), 이를 보고 있는 모든 뷰가 자동으로 다시 그려진다.

---

> [[iOS 학습 인덱스]]