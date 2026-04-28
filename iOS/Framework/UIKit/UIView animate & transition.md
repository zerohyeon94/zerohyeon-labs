UIKit에서 자주 쓰이는 `UIView.transition`과 `UIView.animate`는 둘 다 **애니메이션을 위한 함수**이지만, **역할과 쓰임새가 다릅니다.**

---

## ✅ 핵심 차이 요약

|항목|`UIView.animate`|`UIView.transition`|
|---|---|---|
|🎯 목적|**뷰의 속성 변경 애니메이션** (frame, alpha, transform 등)|**뷰의 교체나 전환 효과** (뷰 전체 바꾸기, flip, curl 등)|
|🔄 애니메이션 대상|UIView 속성 변경 (`alpha`, `frame`, `transform` 등)|뷰 자체의 상태 변경 또는 교체|
|🔧 옵션 종류|`curveEaseIn`, `repeat`, `autoreverse` 등|`transitionFlipFromRight`, `crossDissolve`, `curlUp` 등|
|📦 주로 사용 예|크기/위치 이동, fade in/out, scale 애니메이션|화면 전환, rootViewController 교체 등|
|🎬 대표 예|버튼 눌렀을 때 크기 커지기, 뷰 사라지기|탭 간 화면 전환, 로그인 → 홈 전환 등|

---

## ✅ 사용 예시 비교

### 📌 `UIView.animate` 예제 (속성 변화)

```swift
UIView.animate(withDuration: 0.3) {
    myView.alpha = 0 // 점점 사라짐
    myView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8) // 작아짐
}
```

> 👉 **뷰 자체는 유지하면서 속성만 애니메이션**

---

### 📌 `UIView.transition` 예제 (뷰 교체/전환)

```swift
UIView.transition(with: containerView,
                  duration: 0.3,
                  options: .transitionFlipFromLeft,
                  animations: {
                      oldView.removeFromSuperview()
                      containerView.addSubview(newView)
                  })
```

> 👉 **한 뷰에서 다른 뷰로 전환할 때 사용**

---

## ✅ 실제 사용 시 기준

|상황|어떤 것?|이유|
|---|---|---|
|💫 alpha나 frame 변경|`UIView.animate`|뷰는 유지하고 속성만 바뀜|
|📱 화면 구조 바꾸기 (ex. rootViewController 변경)|`UIView.transition`|전체 화면 교체|
|📖 탭 화면 또는 카드 전환 느낌 주기|`UIView.transition`|flip, curl 등 표현 가능|
|🧼 fade in/out 효과 간단히|`UIView.animate` 또는 `.transitionCrossDissolve`|둘 다 가능, 용도 따라 선택|

---

## ✅ 함께 쓰는 경우도 있음

```swift
UIView.transition(with: someView,
                  duration: 0.5,
                  options: .transitionCrossDissolve,
                  animations: {
                      someView.backgroundColor = .blue
                  })
```

> ✔️ **전환 애니메이션과 속성 변경을 함께 사용할 수도 있음**

---

## ✅ 요약

| 상황                         | 추천 방식                 |
| -------------------------- | --------------------- |
| 뷰의 모양, 투명도, 위치 등을 변화시키고 싶다 | ✅ `UIView.animate`    |
| 뷰 자체를 바꾸거나, 새로운 뷰로 전환하고 싶다 | ✅ `UIView.transition` |

---

> [[iOS 학습 인덱스]]