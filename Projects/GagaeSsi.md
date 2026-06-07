---
project: GagaeSsi
platform: iOS
tech: SwiftUI, CoreData
status: In Progress
priority: P1
created: 2026-05-07
updated: 2026-06-08
---

# 🐷 가계씨 (GagaeSsi)

> **한 줄 요약:** 월급 기반 일일 예산 관리 + 카테고리별 소비 분석 iOS 앱

월급을 입력하면 하루에 쓸 수 있는 금액을 자동 계산해주고, 소비를 간편하게 기록·분석하는 가계부 앱. 쓰고 남은 금액은 다음 날로 이월되며, 돼지 캐릭터 테마로 예산 상태를 시각적으로 표현함.

---

## 📱 현재 구현 상황

### ✅ 완료된 화면

| 화면 | 파일 | 주요 기능 | 상태 |
|------|------|-----------|------|
| 홈 (Home) | `HomeView.swift` | 오늘 가용 예산, 이월 금액, 기본 예산, 오늘 소비, 7일 흐름(mock) | ✅ 완성 |
| 소비 기록 (Spend) | `SpendView.swift` | 제목·금액·날짜 입력, 오늘 지출 목록, 삭제 기능 | ✅ 완성 |
| 설정 (Settings) | `SettingsView.swift` | 월급·급여일 수정, 고정비 관리(추가/수정/삭제), 데이터 초기화 | ✅ 완성 |
| 초기 설정 (Setup) | `SetupSalaryView` / `SetupFixedCostView` | 최초 실행 시 월급·급여일·고정비 입력 플로우 | ✅ 완성 |

### ❌ 미구현 화면

| 화면 | 파일 | 상태 |
|------|------|------|
| 통계 (Stats) | `StatsView.swift` | 플레이스홀더만 존재 ("곧 공개" 카드) |

---

## 🗂️ 프로젝트 구조

```
GagaeSsi/
├── App/
│   ├── GagaeSsiApp.swift       # 앱 진입점, AppState/AppEventBus 주입
│   └── ContentView.swift       # 탭 네비게이션 (홈/기록/통계/설정)
├── Models/
│   ├── BudgetModels.swift      # BudgetConfigModel, SpendingRecordModel, DailyBudgetModel 등
│   └── SettingsModels.swift
├── Core/
│   ├── CoreDataManager.swift   # CoreData CRUD 인터페이스
│   └── Utils/
│       ├── FormatterUtils.swift
│       └── BudgetCalculationUtils.swift
├── Common/
│   ├── AppEventBus.swift       # 화면 간 이벤트 전달 (소비추가/예산변경 트리거)
│   ├── DesignSystem.swift      # 색상, 타이포그래피, 공통 컴포넌트
│   └── DebugLogger.swift
└── Features/
    ├── Home/       HomeView + HomeViewModel
    ├── Spend/      SpendView + SpendViewModel
    ├── Stats/      StatsView (미구현)
    ├── Settings/   SettingsView + 하위 화면들
    └── Setup/      초기 설정 플로우
```

---

## 🎨 디자인 시스템

- **테마:** 돼지 캐릭터 (`🐷`) 기반 분홍 계열
- **주색:** `gagaePinkDark` (#F5706B), `gagaePink` (#FFAFAF)
- **상태 색:**
  - 여유 → `gagaeGood` (초록)
  - 주의 → `gagaeWarning` (주황)
  - 위험 → `gagaeDanger` (빨강)
  - 소진 → 회색
- **공통 컴포넌트:** `GagaeCard`, `GagaePrimaryButton`, `GagaeBackground`, `GagaeSectionHeader`, `GagaeEmptyStateView`

---

## 📊 핵심 예산 로직

```
하루 기본 예산 = (월급 - 고정비 합산) ÷ 해당 월 일수
오늘 가용 예산 = 하루 기본 예산 + 이월 금액 - 오늘 지출 합산
이월 금액 = 전날 남은 예산 (매일 자동 이월)
```

- **급여일 기준:** 설정한 날짜부터 다음 급여일까지를 한 주기로 계산
- **이벤트 버스:** `AppEventBus`로 소비 추가/예산 변경 시 홈 화면 즉시 갱신

---

## ✨ 다음 구현 목표 (Notion 기획 기준)

### Phase 1 — 카테고리 시스템 추가

- [ ] `SpendingCategory` enum 정의 (식비, 교통, 카페, 쇼핑, 의료, 여가, 기타)
- [ ] 카테고리별 이모지 + 색상 매핑을 `DesignSystem.swift`에 추가
- [ ] CoreData 스키마 마이그레이션 (`SpendingRecord`에 `category` String 속성 추가)
- [ ] `SpendView` — 카테고리 선택 버튼 그리드 UI 추가

### Phase 2 — 통계 화면 구현

- [ ] 카테고리별 지출 비율 — 도넛 차트 (Swift Charts, iOS 16+)
- [ ] 일별 소비 비교 — 최근 7~30일 바 차트
- [ ] 월별 요약 카드 — 이번 달 총 지출 vs 예산, 전월 대비

### Phase 3 — HomeView 개선

- [ ] 7일 소비 흐름 — mock 데이터 → 실제 CoreData 연결
- [ ] 일일 평균 지출 vs 기본 예산 비교 표시

---

## ❓ 미결 결정 사항

| 항목 | 옵션 A | 옵션 B | 메모 |
|------|--------|--------|------|
| 카테고리 수 | 기본 7개 고정 | 사용자 커스텀 가능 | 1.0은 고정, 이후 확장 고려 |
| 차트 라이브러리 | Swift Charts (네이티브, iOS 16+) | 직접 구현 | Swift Charts 권장 |
| 입력 UX | 현재 방식 + 카테고리만 추가 | 숫자패드 스타일로 전면 개편 | |
| 통계 기간 | 이번 달 고정 | 월 선택 가능 | 1.0은 이번 달 고정 |
| CoreData 마이그레이션 | Lightweight migration | 수동 마이그레이션 | category 추가는 lightweight 가능 |

---

## 🔗 참고

- Notion 기획서: https://app.notion.com/p/359e5d4a0bac80e6b9bec68a15a22d72
- 레포지토리: `/Users/joyeonghyeon/Documents/Develop/GagaeSsi Project/GagaeSsi`
- 브랜치: `develop`
