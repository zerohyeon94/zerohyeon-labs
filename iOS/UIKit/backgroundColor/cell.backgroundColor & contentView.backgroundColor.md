## 1) 뭐가 어디를 칠하냐?

### `cell.backgroundColor`

- **셀 전체(컨테이너) 배경**을 칠합니다.
    
- `contentView` 뒤쪽까지 포함한 “바깥 껍데기” 느낌.
    
- 셀의 `backgroundView` / `selectedBackgroundView` 같은 것들과 **겹쳐서 동작**할 수 있어요.

### `contentView.backgroundColor`

- **실제 컨텐츠가 올라가는 영역**(label/imageView 등 서브뷰가 붙는 곳) 배경을 칠합니다.
    
- 보통 우리가 오토레이아웃으로 올리는 UI는 전부 `contentView` 안에 있으니, “내가 만든 카드/박스 배경”은 여기 주는 게 일반적입니다.

---

## 2) 실무에서 어떤 걸 주로 쓰냐?

### ✅ “카드처럼 보이게” / 내부 패딩 주고 둥글게 만들기

→ 보통 `contentView` 또는 `contentView` 안에 별도 `containerView`를 만들어 색/코너/그림자 적용

`contentView.backgroundColor = .white contentView.layer.cornerRadius = 12 contentView.clipsToBounds = true`

(그림자는 보통 `contentView`가 아니라 바깥 view에 줘야 잘 나옵니다)

### ✅ 셀 전체가 리스트 배경과 자연스럽게 이어지게

→ `cell.backgroundColor` 를 쓰기도 함

---

## 3) 선택(하이라이트)과의 관계

- 셀에는 `selectedBackgroundView` 가 있고, 선택되면 이 뷰가 보입니다.
    
- `cell.backgroundColor` 는 이 선택 배경/백그라운드 뷰와 **경쟁**할 수 있어요.
    
- `contentView.backgroundColor` 는 선택 배경 위에 컨텐츠가 올라가는 구조라 “선택 색이 안 보인다/이상하다” 같은 일이 생길 수도 있어요(설정에 따라).

**팁**

- 선택 효과를 확실히 보이게 하려면 `selectedBackgroundView` 를 직접 지정하는 게 가장 깔끔합니다.

---

## 4) 한 줄 결론

- **셀 전체 배경(컨테이너)** 을 바꾸고 싶다 → `cell.backgroundColor`
    
- **컨텐츠 영역(내가 그린 UI 영역)** 을 바꾸고 싶다 → `contentView.backgroundColor` (가장 흔함)