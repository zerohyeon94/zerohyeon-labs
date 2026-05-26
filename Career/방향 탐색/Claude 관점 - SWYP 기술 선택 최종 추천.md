# Claude 관점 — SWYP 기술 선택 최종 추천

> 연결: [[SWYP iOS 네이티브 vs 크로스플랫폼 선택 기준]]
> 작성일: 2026-05-24
> 목적: 기존 비교 분석을 바탕으로, Claude가 영현님 커리어 성장 관점에서 내린 객관적 결론

---

## 한 줄 결론

**iOS 네이티브로 가라. 지금 이 시점에서 선택지가 아니라 전략이다.**

---

## 왜 이 결론인가

### 1. 2026년 Apple 생태계는 지금이 가장 중요한 변곡점이다

2025 WWDC에서 Apple은 **Foundation Models framework**를 공개했다.  
이제 SwiftUI 앱에서 on-device LLM을 직접 호출할 수 있다.

```text
import FoundationModels

let session = LanguageModelSession()
let response = try await session.respond(to: "...")
```

이것이 Flutter나 React Native에서 동작하려면 Platform Channel, 네이티브 브릿지를 거쳐야 한다.  
**Swift + SwiftUI로 직접 작성한 개발자만 이 기능을 자연스럽게 다룰 수 있다.**

지금 iOS 네이티브를 선택하는 것은 단순히 포트폴리오를 위한 선택이 아니다.  
2026-2027년 Apple Intelligence, Foundation Models, HealthKit AI 통합이 본격화되는 시기에  
**가장 빠르게 올라탈 수 있는 위치를 선점하는 것이다.**

---

### 2. 영현님의 조합은 드물다. 그 희소성을 버리면 안 된다

```text
의료기기 펌웨어 3년 (하드웨어 레벨 이해)
+ iOS/Android 헬스케어 앱 개발 경험
+ AI 헬스케어 부트캠프 수료
+ 현재 AI 조교로 교육 역량도 쌓는 중
```

이 조합을 가진 개발자는 국내에서 극히 드물다.  
채용 시장에서 이 포지션을 명확하게 전달하려면 기술 신호가 흐려져선 안 된다.

Flutter를 선택하면 이력서에 이렇게 쓰게 된다.
```text
Flutter로 크로스플랫폼 앱을 만들었습니다.
```

iOS 네이티브를 선택하면 이렇게 쓸 수 있다.
```text
SwiftUI 기반 iOS 앱을 설계·구현하며 Apple 헬스케어 생태계(HealthKit, Core ML)와
연결 가능한 구조를 고려했습니다. 의료기기 도메인과 AI 헬스케어 경험을 모바일로 연결합니다.
```

어느 문장이 면접관의 눈을 멈추게 하는가.

---

### 3. 크로스플랫폼은 "나중에도 배울 수 있다"

Flutter나 React Native를 배우는 것은 취업 후에도, 다음 프로젝트에서도 가능하다.  
하지만 iOS 네이티브 깊이 — Apple HIG, Swift Concurrency, SwiftData, App Store 심사,  
그리고 지금 막 나오는 Foundation Models, App Intents — 는  
**몇 달간 집중하지 않으면 얻기 어려운 경험이다.**

지금 SWYP에서 iOS 네이티브로 한 번 제대로 완성하면,  
"Foundation Models를 직접 써본 iOS 개발자"가 된다.  
이 타이밍은 다시 오지 않는다.

---

### 4. 학습 부담 현실 계산

현재 상황:
```text
평일 10:00-17:00 근무 (넥스트러너스 조교)
수강생 과제 피드백 + 풀이 준비 병행
Python 학습 지속
SWYP 진행 예정
```

이 상황에서 **새 언어/프레임워크를 깊게 배우는 것은 비효율**이다.  
Swift는 이미 손에 익어 있다. Dart는 아직 낯설다.  
SWYP에서 Flutter를 선택하면, 앱 기능을 구현하는 시간보다  
프레임워크를 배우는 시간이 더 많아질 수 있다.

**iOS 네이티브는 지금 당장 시작할 수 있다. Flutter는 학습 진입비용부터 지불해야 한다.**

---

## 단 하나의 예외 조건

> **팀이 Android 동시 출시를 필수 조건으로 요구하는가?**

이 경우에만 재검토가 필요하다.  
그럴 때 나의 추천 순서는 아래와 같다.

```text
1순위: iOS 네이티브 + Android Native 분업 (팀원이 Kotlin 담당)
2순위: Flutter (Swift보다 Dart가 낯설지만, Kotlin 경험이 있어 적응 가능)
3순위: React Native (TypeScript/React까지 추가 학습 필요 — 현재 스택과 가장 거리 멀다)
```

React Native는 영현님 현재 기술 축과 가장 거리가 멀기 때문에 마지막 선택지다.  
팀에 React/TS 경험자가 없다면 사실상 선택지에서 제외해도 된다.

---

## 2027년 영현님이 되어야 하는 모습

```text
"의료기기와 헬스케어 앱 배경을 가진 iOS 개발자로,
 Apple 생태계 AI (Foundation Models, Core ML, HealthKit AI)를
 실제로 구현해본 경험이 있습니다."
```

이 문장에 도달하는 가장 빠른 경로가 **지금 SWYP에서 iOS 네이티브를 선택하는 것**이다.

---

## 실행 제안

```text
SWYP 전략:

1단계 (MVP)
  SwiftUI + Swift Concurrency + URLSession
  → 핵심 기능 2-3개만 완성
  → App Store 심사까지 진행

2단계 (AI 연결)
  Foundation Models 또는 Core ML로 기능 1개 추가
  → "AI를 직접 앱에 넣어봤다"는 경험

3단계 (포트폴리오화)
  GitHub README + 이력서 문장 + 블로그 포스팅
  → "iOS AI 헬스케어 개발자" 포지션 명확화
```

---

## 요약

| 관점 | 판단 |
|------|------|
| 커리어 신호 | iOS 네이티브가 압도적으로 유리 |
| 2026 기술 트렌드 | Apple Foundation Models 시점에 iOS가 유리 |
| 학습 부담 | iOS 네이티브가 가장 낮음 (기존 경험 활용) |
| 희소성 보존 | iOS 네이티브 선택 시 차별점 유지 |
| 예외 조건 | Android 필수 출시 시 Flutter 차선책 |

**결론: iOS 네이티브. 조건이 바뀌지 않는 한 고민을 끝내도 된다.**
