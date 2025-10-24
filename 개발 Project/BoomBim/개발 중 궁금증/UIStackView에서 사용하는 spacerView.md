# 왜 spacerView를 쓰나요?

1. **남는 공간을 한쪽으로 몰아주기 (푸시 효과)**

	- 예: 상단에 타이틀들, 하단에 버튼을 두고 가운데는 비워두고 싶을 때  
	    → `vertical` 스택에서 `title들 → spacerView → 버튼` 순으로 넣으면 버튼이 자동으로 **맨 아래**로 밀립니다.

2. **동적 높이/가로 길이에 유연하게 대응**

	- 기기 크기/다크모드/다국어/Dynamic Type로 내용 크기가 변할 때  
	    → spacer가 남는 영역을 **유연하게 늘었다 줄었다** 하며 레이아웃이 깨지지 않습니다.

3. **제약 난립을 줄이고 선언적으로 배치**

	- 개별 뷰를 superview에 따로 앵커링하는 대신  
	    → “스택의 흐름 + spacer 한 장”으로 레이아웃 의도를 명확히 표현.

4. **보이기/숨기기 애니메이션이 자연스러움**

	- `arrangedSubview.isHidden = true`면 스택뷰가 자동으로 공간을 재배분.  
	    → spacer가 있으면 숨긴 영역을 spacer가 흡수해 **튀지 않는 전환**이 됩니다.

5. **키보드, 안전영역 변화에 강함**

	- 키보드가 올라오면 하단 버튼을 올리고 싶다?  
	    → `… → spacer → 버튼` 구조라면 spacer가 줄어들며 버튼이 알아서 올라옵니다(특히 `keyboardLayoutGuide`와 궁합 좋음).

# 어떻게 만드는 게 좋나요?

### 1) “탄성” spacer (남는 공간을 모두 먹게)

```swift
let spacer = UIView()
spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
spacer.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, spacer, actionButton])
stack.axis = .vertical
stack.alignment = .fill
stack.distribution = .fill   // 기본값: 다른 뷰 크기를 유지하고 남는 건 spacer가 흡수
```

- 핵심: **hugging / compressionResistance를 낮춰** spacer가 가장 먼저 늘고 줄게 합니다.

### 2) “고정 간격” spacer (정해진 여백을 만들고 싶을 때)

```swift
let fixedSpacer = UIView()
fixedSpacer.heightAnchor.constraint(equalToConstant: 16).isActive = true
```

- iOS 11+라면 **고정 간격**은 `setCustomSpacing(_:after:)`가 더 간단합니다.

```swift
stack.setCustomSpacing(16, after: subtitleLabel)
```

### 3) 가로 정렬에서의 푸시

- 오른쪽 정렬이 목적이면 `horizontal` 스택에서  `icon, title, spacer, trailingButton` 처럼 배치하면 trailingButton이 오른쪽으로 밀립니다.

# 자주 묻는 포인트

- **arrangedSubviews vs subviews**  
    spacer는 반드시 **`addArrangedSubview`**(생성 시 배열로 넣으면 자동)로 넣어야 스택의 분배에 참여합니다.
    
- **distribution은 뭘 써요?**  
    보통 `fill`(기본). 모든 뷰가 고유 크기를 유지하고 **남는 공간만 spacer**가 흡수.  
    `fillEqually`는 모든 항목을 **같은 크기**로 만들어 버리니 spacer 목적과 다릅니다.
    
- **layoutMargins로 대체 가능?**  
    일정한 가장자리 여백만 필요하면 `isLayoutMarginsRelativeArrangement = true` + `layoutMargins`로 충분합니다.  
    하지만 **중간을 유연하게 비워야 할 때**는 spacer가 필요합니다.
    
- **UILayoutGuide로 해도 돼?**  
    네, 가능하지만 스택뷰는 arrangedSubview 기반이 직관적입니다. 간단할수록 좋습니다.
    

# 언제 특히 유용한가요?

- “상단 설명 + (중간 여백) + 하단 버튼” 구조
    
- 로그인/온보딩 화면, 폼 입력 화면에서 **버튼을 항상 바닥에 붙이고** 내용이 적으면 중간을 비워야 할 때
    
- 반응형(다국어/가변 콘텐츠) 레이아웃