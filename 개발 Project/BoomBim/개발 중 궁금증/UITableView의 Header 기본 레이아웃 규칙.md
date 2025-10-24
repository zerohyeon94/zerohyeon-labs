1. **iOS 15+의 기본 섹션 헤더 상단 패딩**
    
    - `UITableView.sectionHeaderTopPadding`의 기본값이 **22pt** 입니다.
        
    - 특히 첫 섹션 위쪽에 여백이 생겨 “맨 위가 뜨는” 것처럼 보입니다. (스타일이 `.grouped`/`.insetGrouped`면 더 도드라짐)
        
2. **Grouped 스타일의 고유 여백**
    
    - `.grouped` / `.insetGrouped`는 디자인 특성상 **섹션 위·아래에 여백**이 기본 포함돼요.
        
    - 테이블 전체 헤더(`tableHeaderView`)가 없을 때 첫 섹션 위에 공간이 더 생기는 느낌이 납니다.
        
3. **추정(estimated) 헤더 높이의 영향**
    
    - `estimatedSectionHeaderHeight`가 기본 활성화되어 있으면, 초기 레이아웃에 **잠깐 여백**이 보이기도 합니다.

---
## 내가 해결했던 방안

```swift
tableView.tableHeaderView = UIView(
  frame: .init(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude)
)
```

이건 “**테이블 상단에 아주 얇은 헤더를 명시적으로 둬서**” 시스템이 추가하려는 기본 상단 여백을 **실질적으로 무력화**하는 흔한 우회책입니다.

# 더 정석적인 해결 방법 (상황별)

가장 안전한 순서대로 제시합니다.

1. **iOS 15+**: 섹션 헤더 상단 패딩 없애기
    
```swift
if #available(iOS 15.0, *) {
    tableView.sectionHeaderTopPadding = 0
}
```

2. **섹션 헤더 자체를 0으로 만들기**(섹션 헤더를 쓰지 않거나, 공간을 없애고 싶을 때)

```swift
// 만약 delegate를 쓰고 있다면
func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return .leastNonzeroMagnitude // 또는 0.001
}
func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return UIView() // 빈 뷰
}
```

3. **Estimated 높이 끄기 (필요할 때만)** : 초기 레이아웃이 흔들리면 끄거나 명시값을 주면 안정적입니다.

```swift
tableView.estimatedSectionHeaderHeight = 0
tableView.sectionHeaderHeight = 0 // 0이면 자동 치수 해제 느낌이 아님에 유의; 상황 따라 조정
```

4. **스타일 점검** : 가능하면 `.plain`이 필요한 디자인인지, `.grouped`/`.insetGrouped`가 맞는지 확인하세요. Grouped 류는 의도적 여백이 있습니다.
    
5. **당신이 쓴 우회책(테이블 헤더 얇은 뷰)**  
    이미 효과를 봤듯이 빠르고 무난한 방법입니다. 다만 1)과 2)가 가능하면 그쪽이 더 “의도를 명시”합니다.
    

# 추천 조합(한 번에 깔끔하게)

```swift
if #available(iOS 15.0, *) {
    tableView.sectionHeaderTopPadding = 0
}
tableView.estimatedSectionHeaderHeight = 0
// 섹션 헤더를 사용하지 않는 화면이라면:
tableView.sectionHeaderHeight = .leastNonzeroMagnitude
// 또는 delegate에서 0.001 반환 + 빈 헤더뷰 반환
```

**요약**: 여백은 iOS의 기본 패딩/스타일/estimated 높이 때문입니다.