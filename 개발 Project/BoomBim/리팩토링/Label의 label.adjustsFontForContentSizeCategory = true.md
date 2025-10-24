`label.adjustsFontForContentSizeCategory = true` 는 **Dynamic Type(사용자 글자 크기 설정)**을 지원하도록 `UILabel`을 자동으로 업데이트해 주는 스위치예요.

## 무슨 일이 일어나나요?

- 사용자가 iOS 설정 > 접근성 > **더 큰 텍스트**에서 글자 크기를 바꾸면,
    
- 이 라벨은 **즉시**(앱 재시작 없이) 글꼴 크기를 다시 계산해 적용합니다.
    
- 접근성 크기(AX1~AX5)까지 포함해서 확장 크기도 따라갑니다.

## 언제 효과가 있나요? (중요 전제)

이 속성만 켠다고 다 되는 건 아니고, **라벨의 폰트가 동적 크기 스케일을 사용할 때** 효과가 납니다.

1. **시스템 텍스트 스타일 사용**(가장 간단)

```swift
label.font = .preferredFont(forTextStyle: .body)
label.adjustsFontForContentSizeCategory = true
```

2. **커스텀 폰트 사용**(UIFontMetrics로 스케일)

```swift
let base = UIFont(name: "Pretendard-SemiBold", size: 16)!
label.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: base)
label.adjustsFontForContentSizeCategory = true
```

> 포인트: _scaledFont_ 로 만든 뒤에 `adjustsFontForContentSizeCategory = true` 를 켜야, 사용자가 글자 크기를 바꿀 때 자동 재스케일됩니다.

### Attributed string을 쓰는 경우

- 각 run의 폰트를 `UIFontMetrics(...).scaledFont(for:)`로 만들어 주고,
    
- 라벨에 `adjustsFontForContentSizeCategory = true` 를 켭니다.

## 자주 헷갈리는 것

- `adjustsFontForContentSizeCategory` **≠** `adjustsFontSizeToFitWidth`
    
    - 전자는 **사용자 설정에 맞춰 전체 폰트 크기 변화**
        
    - 후자는 **라벨 폭 안에 맞추려 글꼴을 줄여서 끼워 넣는** 기능(줄바꿈/축소와 관련)
        
- 줄바꿈을 자연스럽게 하려면 `numberOfLines = 0` 도 함께 설정하세요.

## 실무 팁

- 레이아웃이 커진 글꼴도 담을 수 있게 **오토레이아웃 제약에 여유**를 주세요(특히 높이/간격).
    
- 텍스트 스타일 매칭: 제목→`.title2`, 본문→`.body`, 캡션→`.caption1` 처럼 **의미에 맞는 TextStyle**을 고르면 iOS가 다양한 크기에서 균형 잡힌 비율을 유지합니다.
    
- 리스트 셀/스택뷰에선 콘텐츠 크기 변화를 흡수하도록 **hugging/compression** 우선순위를 점검하세요.

## 최소 예시

```swift
let label = UILabel()
label.numberOfLines = 0
// 시스템 스타일
label.font = .preferredFont(forTextStyle: .body)
// 또는 커스텀 폰트
// let base = UIFont(name: "Pretendard-Regular", size: 16)!
// label.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: base)

label.adjustsFontForContentSizeCategory = true
```

요약: 이 속성은 **사용자 글자 크기 변경을 자동 반영**하게 만드는 스위치이고, **텍스트 스타일/UIFontMetrics로 스케일된 폰트**를 사용할 때 제대로 동작합니다.