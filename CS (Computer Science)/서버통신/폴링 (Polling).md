## 1. 먼저, “폴링”이 뭔지부터

**폴링(polling)** : “**클라이언트(앱)**가 일정 간격으로 계속 서버에 '지금 상태 어때요?' 하고 물어보는 방식”

- 항상 **요청은 앱 → 서버 방향**으로 먼저 간다.

- 서버는 그 시점의 **현재 상태**만 응답해 준다.

- 서버가 먼저 “알아서 푸시해주는 것”이 아니다. (그건 푸시 / 웹소켓 계열)

폴링 예시)

1. 앱이 분석 요청 보내기 → 서버가 “jobId” 같은 걸 발급 (`"analysisId": "abc123"`)
    
2. 앱이 이 `analysisId`를 들고 **2~3초마다** `/analysis/status?jobId=abc123` 처럼 호출
    
3. 서버는 그때그때
    
    - 아직: `step = 0`
        
    - 1단계 끝: `step = 1`
        
    - 2단계 끝: `step = 2`
        
    - …
        
    - 완료: `step = 4, status = completed`
        
4. 앱은 응답을 보고 **UI에 1단계/2단계/3단계/4단계를 채워나감**

---

## 2. 프로젝트에서 폴링 구현

> “앱이 주기적으로 서버에 물어보면, 서버가 ‘이제 1단계까지 끝났어’라고 대답해준다.”

### 서버 응답 예시(JSON)

```json
// GET /analysis/status?jobId=abc123

{
  "jobId": "abc123",
  "status": "running",        // running / completed / failed
  "currentStep": 2,           // 0~4
  "totalSteps": 4
}
```

iOS 쪽 로직:

- `currentStep` 이 1이면 → 1단계 UI 완료 처리
    
- 2이면 → 2단계까지 완료 표시
    
- 4 && status == "completed" → 모든 단계 완료, 타이머 종료

### 폴링 패턴

1. **앱이 작업 시작 요청**
    
    ```http
    POST /analysis/start
    ```
    
    서버 응답:
    
    ```json
    {
		  "jobId": "abc123",
		  "status": "queued"
	}
    ```
    
2. **앱은 `jobId` 를 들고 일정 간격으로 상태 조회**
    
    ```http
    GET /analysis/status?jobId=abc123
    ```
    
    서버 응답 예시들:
    
    ```json
    // 아직 처리 중
	{ "jobId": "abc123", "status": "running", "currentStep": 1, "totalSteps": 4 }
	
	// 조금 더 지나고
	{ "jobId": "abc123", "status": "running", "currentStep": 2, "totalSteps": 4 }
	
	// 다 끝난 후
	{ "jobId": "abc123", "status": "completed", "currentStep": 4, "totalSteps": 4 }
    ```
    
3. **앱은 응답을 보고 UI 업데이트**
    
    - `currentStep == 1` → 1단계 완료 UI
        
    - `currentStep == 2` → 2단계 완료 UI
        
    - …
        
    - `status == "completed"` → 모든 단계 완료, 더 이상 폴링 X (타이머 종료)

---

## 3. 폴링할 때 고려해야되는 점

1. **간격(interval)**
    
    - 너무 짧으면 → 서버 부하 증가, 배터리/데이터 낭비
        
    - 너무 길면 → “실시간 느낌”이 떨어짐
        
    - 보통 2~5초 정도로 시작해서 조절
        
2. **타임아웃/에러 처리**
    
    - 일정 시간 동안 status가 안 바뀌면 “실패”로 보고 메시지 표시
        
    - 네트워크 에러 시 재시도 정책 (몇 번까지 할지 등)
        
3. **앱이 백그라운드로 갈 때**
    
    - 폴링을 계속 할지 / 일단 멈출지 기획 필요
        
    - iOS는 백그라운드 네트워크에 제한이 있어요 (장기 작업은 푸시/백그라운드 작업 고려)
        
4. **대안 기술** (참고만)
    
    - WebSocket, Server-Sent Events(SSE), 푸시 알림 등
        
    - 이건 “서버가 먼저 알려준다”에 더 가까운 방식
        
    - 이번처럼 “백엔드에서 폴링 쓰자”고 했다면, 지금은 **클라이언트 폴링**이 전제라고 보면 됩니다.

---

## 4. Short Polling vs Long Polling

### 1) Short Polling (우리가 보통 말하는 폴링)

- 규칙: **“주기적으로 짧게 요청”**
    
- 예: 2초마다 `/status` 호출
    
- 장점: 구현 단순, 대부분의 서버 구조에서 바로 사용 가능
        
- 단점: 상태 변화가 없는데도 계속 요청 → **서버 부하 + 네트워크 낭비**

### 2) Long Polling

- 요청을 보냈을 때, 서버가 **바로 응답하지 않고**
    
    - 상태가 바뀌거나
        
    - 타임아웃될 때까지 답을 “들고 있다가” 보내는 방식
        
- 특징:
    
    - 상태 변화가 없을 땐 응답이 늦게 옴
        
    - 상태가 바뀌는 순간 응답이 와서 “푸시 비슷한 느낌” 가능
        
- 구현은 좀 더 복잡 (서버가 커넥션 오래 잡고 있어야 함)

> 대부분의 **모바일 앱 + 일반 REST 서버** 조합에서는 우선 **Short Polling**부터 쓰는 게 일반적

---

> [[CS 학습 인덱스]]