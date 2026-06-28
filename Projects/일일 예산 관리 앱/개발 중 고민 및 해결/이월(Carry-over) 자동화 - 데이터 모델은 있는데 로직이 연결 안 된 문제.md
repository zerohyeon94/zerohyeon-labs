# 이월(Carry-over) 자동화 — 데이터 모델은 있는데 로직이 연결 안 된 문제

## 1. 문제 상황

가계씨의 **핵심 컨셉**은 "오늘 안 쓴 돈이 내일로 이월되는 하루 단위 예산 관리"다.
그런데 MVP 점검 중 다음을 발견했다.

- `CarryOverSource` Entity, `CarryOverSourceModel`, `CoreDataManager.createCarryOverSource()` 까지
    **데이터 계층은 전부 준비**되어 있었다.
- 홈 화면도 `이월 금액` 항목을 **표시**하고 있었다.
- **그러나** `createCarryOverSource()`가 앱 어디에서도 호출되지 않았다.

> 즉, "그릇은 다 만들어 놨는데 그 그릇에 물을 붓는 코드가 없었다."
> → 이월 금액이 **항상 0**으로 표시되고, 하루가 지나도 잔액이 다음 날로 넘어가지 않았다.

이런 류의 버그는 컴파일도 되고 화면도 멀쩡해서 **놓치기 쉽다.** 기능 명세 기준으로 "데이터·UI가 있다"와 "동작한다"는 다르다는 걸 다시 확인.

---

## 2. 이월의 수학적 정의부터 정리

하루의 **남은 돈(end-of-day leftover)** 을 식으로 고정했다.

```
남은 돈 = availableAmount(그날 기본 예산)
        + Σ carryOverSources(이월 들어온 금액)
        − Σ spendingRecords(그날 지출)
```

이 값은 기존 `DailyBudgetModel.todayAvailable` 과 정확히 동일하다.
그리고 **이 값이 그대로 다음 날의 이월금**으로 흘러간다. (음수면 음수 그대로)

```
day N 이월금 = day(N-1)의 todayAvailable
```

---

## 3. 결정한 동작 규칙

| 항목 | 결정 | 이유 |
|------|------|------|
| 초과 지출 | **마이너스도 이월** | 어제 1만원 초과 → 오늘 예산에서 −1만원. 절약 유도·정확성 |
| 며칠 만에 실행 | **전부 소급 이월** | 마지막 기록일~오늘까지 모든 날 순회해 누적 |
| 급여일 도래 | **리셋 없음(이월 유지)** | 기간이 바뀌어도 잔액은 연속적으로 흐름 |

---

## 4. 해결 — `processDailyBudgets(upTo:)`

마지막 기록일 다음 날부터 오늘까지 **누락된 날을 순회**하며,
전날 잔액을 다음 날 이월금으로 누적 연결하는 메서드를 추가했다.

```swift
func processDailyBudgets(upTo date: Date) {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: date)

    guard let config = fetchBudgetConfig() else { return }

    // 가장 최근 DailyBudget 날짜 조회
    let request: NSFetchRequest<DailyBudget> = DailyBudget.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    request.fetchLimit = 1
    guard let latest = try? context.fetch(request).first,
          let latestDate = latest.date else { return }  // 신규 사용자

    let latestDay = calendar.startOfDay(for: latestDate)
    guard latestDay < today else { return }  // 이미 오늘까지 처리됨

    var cursor = calendar.date(byAdding: .day, value: 1, to: latestDay)!
    while cursor <= today {
        if fetchDailyBudgetEntity(date: cursor) == nil {     // ← 멱등성 핵심
            let base = DailyBudgetCalculator.calculate(from: config, for: cursor)
            let prevDay = calendar.date(byAdding: .day, value: -1, to: cursor)!
            let carry = fetchDailyBudgetModel(date: prevDay)?.todayAvailable ?? 0

            var sources: [CarryOverSourceModel] = []
            if carry != 0 {
                sources.append(CarryOverSourceModel(amount: carry, date: prevDay, toDate: cursor))
            }
            _ = createDailyBudget(DailyBudgetModel(
                availableAmount: base, date: cursor,
                carryOverSources: sources, spendingRecords: []
            ))
        }
        cursor = calendar.date(byAdding: .day, value: 1, to: cursor)!
    }
}
```

### ⚡️ 핵심 포인트 — **멱등성(idempotency)**

> `if fetchDailyBudgetEntity(date: cursor) == nil` 으로 **이미 있는 날짜는 건너뛴다.**
> 덕분에 이 함수를 **하루에 몇 번을 호출해도 이월이 중복 누적되지 않는다.**

자동 처리 로직에서 멱등성은 거의 항상 필요하다. "여러 번 실행돼도 결과가 같다"를 보장하지 않으면, 앱을 껐다 켤 때마다 이월금이 불어나는 버그가 생긴다.

---

## 5. 어디서 트리거할 것인가

데이터만 만들어 놓고 호출 안 한 게 원래 버그였으니, **호출 시점**이 진짜 중요했다.

- `HomeViewModel.fetchTodayBudget()` 진입 첫머리에서 호출
    → 홈 화면 진입 때마다 보정.
- `HomeView` 에 `@Environment(\.scenePhase)` 추가 → `.active` 전환 시 재호출
    → **앱을 백그라운드에 둔 채 자정을 넘긴 경우**도 처리.

```swift
.onChange(of: scenePhase) {
    if scenePhase == .active {
        viewModel.fetchTodayBudget()
        loadWeeklyData()
    }
}
```

---

## 6. 한 줄 요약

> **"데이터 모델·CoreData·UI가 다 있어도, 그것들을 잇는 호출 한 줄이 없으면 기능은 0%다."**
> 자동 누적 로직은 반드시 **멱등하게**, 트리거는 **진입 + scenePhase 활성화** 두 군데에.

---

> [[Home]]
