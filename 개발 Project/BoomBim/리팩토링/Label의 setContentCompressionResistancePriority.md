`setContentCompressionResistancePriority`는 **이 뷰가 “눌려(작아져)도 되는가”에 대한 우선순위**를 오토레이아웃에 알려줍니다.  
우선순위가 **높을수록 “작아지지 않으려는(=내용이 눌리지 않으려는)” 저항**이 강합니다.

- **Compression Resistance(압축 저항)**: 뷰의 크기를 **줄여야** 하는 상황에서 “나를 줄이지 마”의 정도
    
- **Hugging(허깅)**: 남는 공간이 생겼을 때 **늘어나지 않으려는** 정도 (`setContentHuggingPriority`)

기본적으로(대부분의 뷰)

- **Compression** 기본값: `750`
    
- **Hugging** 기본값: `251`  (값 범위: `1` ~ `1000`; `1000` = `.required`)

---

## 언제/왜 쓰나요?

### 1) 가로 스택에서 라벨이 잘리는 걸 막고 싶을 때

```swift
titleLabel.numberOfLines = 1
iconView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
// → 공간이 부족하면 아이콘이 먼저 줄거나 잘리고, 라벨은 마지막에 잘림
```

### 2) 버튼과 라벨이 경쟁할 때 “라벨을 우선 보호”

```swift
label.setContentCompressionResistancePriority(.required, for: .horizontal)
button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
// → 버튼 타이틀이 줄어들거나 축약되고 라벨은 최대한 유지
```

### 3) 다국어/동적 텍스트에서 특정 라벨만 두 줄 허용

```swift
titleLabel.numberOfLines = 1
subtitleLabel.numberOfLines = 0
subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
// → 가로 공간 부족 시 subtitle이 먼저 줄바꿈/압축을 받아들임
```

### 4) 이미지와 텍스트가 함께 있을 때 텍스트 보존

```swift
imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
label.setContentCompressionResistancePriority(.required, for: .horizontal)
```

---

## 자주 하는 실수 & 팁

- **`numberOfLines = 0`** 라벨은 가로가 줄면 **줄바꿈**으로 버티므로,  
    가로 압축저항을 굳이 `.required`까지 올릴 필요가 없는 경우가 많습니다(상황에 따라 조절).
    
- 잘림(…)을 원한다면 `lineBreakMode = .byTruncatingTail` + 적절한 **compression 우선순위 낮춤**.
    
- **Hugging과 짝**으로 생각하세요:
    
    - “남는 공간은 **누가** 가져갈까?” → **Hugging 낮은 쪽**이 늘어남
        
    - “공간이 부족하면 **누가** 줄어들까?” → **Compression 낮은 쪽**이 줄어듦
        
- 스택뷰라면 보통 `distribution = .fill`로 두고, **우선순위로 의도 표현**이 가장 깔끔합니다.

---

## 한눈 요약(가로 레이아웃 기준)

- **라벨이 줄지 않게 보호**:  
    `label.setContentCompressionResistancePriority(.required, .horizontal)`
    
- **아이콘/보조 라벨이 먼저 줄도록**:  
    `iconOrSubLabel.setContentCompressionResistancePriority(.defaultLow, .horizontal)`
    
- **남는 공간을 특정 뷰가 먹도록(늘어남)**:  
    그 뷰의 **Hugging을 낮추기**