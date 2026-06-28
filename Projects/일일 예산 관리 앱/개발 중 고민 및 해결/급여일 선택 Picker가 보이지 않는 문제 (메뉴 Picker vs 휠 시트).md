# 급여일 선택 Picker가 보이지 않는 문제 (메뉴 Picker vs 휠 시트)

## 1. 문제 상황

설정 → "월급 & 급여일"(`EditBudgetView`) 화면에서
**급여일을 선택해도 선택 UI(드롭다운)가 제대로 보이지 않는** 문제가 있었다.

당시 급여일은 인라인 메뉴 Picker로 구현되어 있었다.

```swift
Picker("급여일", selection: $payday) {
    ForEach(1...31, id: \.self) { day in
        Text("\(day)일").tag(day)
    }
}
.pickerStyle(.menu)
.tint(.gagaePinkDark)
```

---

## 2. 원인 분석 — 두 가지가 겹쳤다

### ① 부모 `.onTapGesture` 와 탭 충돌

화면 전체(ScrollView)에 키보드 내리기용 제스처가 걸려 있었다.

```swift
.onTapGesture { isSalaryFocused = false }
```

이 제스처가 **Picker(.menu)의 탭을 가로채** 메뉴가 열리지 않는 충돌을 일으킬 수 있다.
(SwiftUI에서 부모 컨테이너의 `onTapGesture` 가 `Menu`/`Picker(.menu)` 탭과 경쟁하는 알려진 패턴)

### ② 숫자 키보드가 메뉴를 가림

이 화면은 진입하면 월급 입력 필드에 **자동 포커스 → 숫자 키보드가 항상 떠 있는** 상태다.

```swift
.onAppear {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        isSalaryFocused = true   // 진입 시 숫자 키보드 자동 표시
    }
}
```

이 상태에서 급여일 메뉴를 열면 **드롭다운이 키보드 영역에 가려져** 보이지 않는다.

---

## 3. 해결 — 인라인 메뉴 → 하단 시트 휠(wheel) 피커

핵심은 **"선택 액션을 누르면 먼저 키보드를 내리고, 별도 시트에서 선택"** 하도록 흐름을 바꾼 것.

```swift
@State private var showPaydayPicker = false

// 급여일 영역: Picker → Button 으로 교체
Button {
    isSalaryFocused = false     // ← 먼저 키보드를 내린다
    showPaydayPicker = true     // ← 그다음 시트를 연다
} label: {
    GagaeCard {
        HStack {
            Text("매월")
            Spacer()
            Text("\(payday)일")
            Image(systemName: "chevron.up.chevron.down")
            Text("에 월급을 받아요")
        }
    }
}
.buttonStyle(.plain)
```

```swift
.sheet(isPresented: $showPaydayPicker) {
    VStack(spacing: 0) {
        // 취소 / 급여일 선택 / 완료 헤더
        Picker("급여일", selection: $payday) {
            ForEach(1...31, id: \.self) { Text("\($0)일").tag($0) }
        }
        .pickerStyle(.wheel)
        .labelsHidden()
    }
    .presentationDetents([.height(320)])
    .presentationDragIndicator(.visible)
}
```

### 왜 이게 더 나은가

- **버튼이 명시적으로 키보드를 먼저 내리므로** 가림·탭 충돌이 원천 해소된다.
- 31개 숫자 선택에는 드롭다운 메뉴보다 **휠 피커가 훨씬 빠르고 직관적**이다.
- 인라인에는 `25일 ⌃⌄` 으로 **선택된 값이 항상 보인다.**

---

## 4. 참고 — 온보딩 화면은 왜 멀쩡했나

같은 "급여일 선택"이지만 온보딩(`SetupSalaryView`)은 **가로 스크롤 칩(`paydayChip`)** 방식이라
드롭다운/키보드 가림 문제가 애초에 없었다. → 메뉴 Picker를 쓴 설정 화면만 고치면 됐다.

> 같은 기능이라도 **입력 컴포넌트 선택**에 따라 버그 유무가 갈린다.
> 키보드가 떠 있는 화면에서의 선택 UI는 **메뉴 드롭다운보다 시트/칩**이 안전하다.

---

## 5. 한 줄 요약

> **"키보드가 떠 있는 화면에서 인라인 메뉴 Picker는 가려지거나 탭이 충돌한다.
> 선택은 키보드를 먼저 내리고 별도 시트(휠)로 분리하자."**

---

> [[Home]]
