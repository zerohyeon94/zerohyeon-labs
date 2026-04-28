## 🖼 `contentMode`란?

> `UIView.ContentMode`는 이미지나 콘텐츠가 **UIView 크기와 어떻게 맞춰져야 하는지를 지정하는 속성**입니다.

그중에서 많이 사용하는 건 **3개 (`scaleToFill`, `scaleAspectFit`, `scaleAspectFill`)**이고, 나머지는 주로 **고정된 콘텐츠의 정렬 방향**을 지정할 때 사용합니다.

---

## 🧾 전체 `UIView.ContentMode` 목록 (총 13개)

|enum case|설명|
|---|---|
|`.scaleToFill`|콘텐츠를 뷰에 정확히 맞춤 (비율 무시)|
|`.scaleAspectFit`|비율 유지하며 콘텐츠 전체 표시 (여백 생김)|
|`.scaleAspectFill`|비율 유지하며 뷰를 꽉 채움 (일부 잘림)|
|`.redraw`|뷰의 크기가 바뀌면 다시 그려야 할 때 사용 (CALayer 관련)|
|`.center`|콘텐츠를 가운데 정렬 (크기 그대로)|
|`.top`|콘텐츠를 위 중앙에 정렬|
|`.bottom`|콘텐츠를 아래 중앙에 정렬|
|`.left`|콘텐츠를 왼쪽 중앙에 정렬|
|`.right`|콘텐츠를 오른쪽 중앙에 정렬|
|`.topLeft`|좌상단 정렬|
|`.topRight`|우상단 정렬|
|`.bottomLeft`|좌하단 정렬|
|`.bottomRight`|우하단 정렬|

---

## 🧠 시니어 관점 정리

|용도|대표 contentMode|
|---|---|
|**이미지 콘텐츠를 뷰에 맞게 조절**|`scaleToFill`, `scaleAspectFit`, `scaleAspectFill` ✅|
|**이미지를 원본 크기 그대로 정렬**|`center`, `top`, `bottom`, `left`, `right` 등|
|**CALayer의 커스텀 드로잉 컨트롤**|`redraw` (사용 빈도 낮음)|

---

## 🧠 시니어 팁

|상황|추천 contentMode|
|---|---|
|아바타, 썸네일|`.scaleAspectFill` + `clipsToBounds = true`|
|전체 이미지를 모두 보여줘야 할 때 (예: 포스터)|`.scaleAspectFit`|
|이미지의 정확한 위치가 중요하지 않은 배경|`.scaleAspectFill`|

---

## 📸 시각 정렬 예

- `center` → 이미지 중앙에 배치 (크기 조절 없음)
- `topLeft` → 좌상단 고정
- `bottomRight` → 우하단 고정
    

> 보통 `.scaleAspectFill`을 기본으로 많이 쓰고, 정렬 계열은 **아이콘, 배경 없는 로고, 정적인 이미지**에 씁니다.

---

## 주요 속성
- `.scaleToFill`: 뷰에 정확히 맞춤, 비율 무시 → 찌그러질 수 있음
- `.scaleAspectFit`: 비율 유지 + 축소 → 여백 발생 가능
- `.scaleAspectFill`: 비율 유지 + 확대 → 뷰를 채움 (일부 잘림)

## 실전 팁
- `.scaleAspectFill` + `clipsToBounds = true`는 세트
- `.scaleAspectFit`은 전체 이미지가 잘리지 않아야 하는 경우 적합 (프로필 사진, 썸네일, 배경 이미지)
- 아이콘이나 로고 뷰는 .center나 .top 등 정렬 속성 사용

---

> [[iOS 학습 인덱스]]