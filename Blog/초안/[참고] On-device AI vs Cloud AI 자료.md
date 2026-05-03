# [참고] On-device AI vs Cloud AI 자료

> 블로그 초안 작성을 위한 참고 자료 모음
> 연결: [[On-device AI vs Cloud AI - 헬스케어 앱 개발자가 알아야 할 차이]] | [[On-device AI 개요]] | [[AI 학습 인덱스]]

---

## 핵심 비교 데이터

### 아키텍처 비교

| 항목 | Cloud AI | On-device AI |
|------|----------|--------------|
| 추론 위치 | 원격 서버 (AWS, GCP 등) | 기기 내 칩셋 (CPU/GPU/NPU) |
| 인터넷 필수 여부 | 필수 | 불필요 |
| 응답 지연 | 50ms ~ 수초 (네트워크 포함) | 1~30ms (기기 성능 따라) |
| 개인정보 흐름 | 데이터가 서버로 전송됨 | 기기 밖으로 나가지 않음 |
| 모델 업데이트 | 서버에서 즉시 가능 | 앱 업데이트 필요 |
| 운영 비용 | API 호출당 비용 발생 | 없음 (기기 자원 사용) |
| 모델 크기 제한 | 사실상 무제한 | 기기 저장 공간/RAM 한계 |
| 배터리 소모 | 낮음 (네트워크만 사용) | 높음 (연산이 기기에서 발생) |

### Apple On-device AI 스택 성능 참고
- iPhone 15 Pro (A17 Pro) Neural Engine: 35 TOPS
- MobileNetV3-Small: 추론 시간 약 5~15ms / 모델 크기 약 5MB
- CoreML 양자화 모델: 원본 대비 4배 경량화 가능

---

## 헬스케어 규제 관점

### 한국 개인정보보호법 (의료 데이터)
- 민감정보 (건강정보, 바이오정보) 처리 시 별도 동의 필요
- 서버 전송 시 암호화 의무
- **On-device 처리 시**: 서버 전송 없으므로 규제 부담 대폭 감소

### 미국 HIPAA (Protected Health Information)
- PHI(보호 건강 정보)를 서버로 전송 시 Business Associate Agreement 필요
- 얼굴 이미지, 심박수 등 바이탈은 PHI에 해당 가능
- **On-device 처리 시**: PHI가 기기 외부로 나가지 않아 HIPAA 부담 감소

### FDA AI/ML SaMD 가이드라인 (2026 최신)
- AI 기반 의료기기 소프트웨어(SaMD) 별도 심사 기준 적용
- 연속 학습(Continuous Learning) 모델은 추가 검증 필요
- On-device 고정 모델(Locked Algorithm): 상대적으로 단순한 인허가 경로

---

## 실시간성 요구 — 헬스케어 AI의 특수 조건

헬스케어 AI에서 실시간이 필요한 사례:
- **졸음/집중 감지** (ZipJoong): 지속적으로 카메라 프레임 분석, 0.1초 이내 판단
- **낙상 감지**: 센서 데이터 실시간 분석, 즉각 알림
- **심방세동 감지**: ECG 파형 즉시 분류
- **혈압/혈당 이상 경보**: 연속 모니터링 중 임계값 초과 시 즉각 반응

이런 시나리오에서 Cloud AI는 네트워크 지연 + 서버 처리 시간으로 **수백ms~수초** 지연 발생.
On-device AI는 로컬에서 즉시 처리 → **수ms~수십ms**.

---

## ZipJoong 실제 선택 근거 (zerohyeon 직접 경험)

### 왜 Vision(70%) + CoreML(30%) 하이브리드?

**Vision Framework 역할 (70%)**:
- 얼굴 랜드마크 좌표 계산 (눈 종횡비 EAR)
- Apple이 직접 최적화한 프레임워크 → 매우 빠르고 정확
- CoreML 없이도 동작 가능 → 안정적인 fallback

**CoreML 역할 (30%)**:
- 커스텀 MobileNetV3-Small 모델
- Vision이 판단하기 어려운 중간 상태 (졸음과 집중의 경계) 보완
- 직접 학습한 데이터셋 기반 → 도메인 특화

**왜 30%만?**
- 현재 모델 정확도 한계 → 100% 적용 시 오탐(False Positive) 증가
- Vision의 높은 정확도를 기반으로 가중치 조합

### MobileNetV3-Small을 선택한 이유
- **크기**: ~5MB → 앱 용량 부담 최소화
- **속도**: iPhone 12 이상에서 실시간 추론 가능
- **정확도**: MobileNetV2 대비 약 10% 성능 개선, EfficientNet 대비 약 3배 빠름
- **배터리**: Small 버전으로 연산량 최소화 → 지속 감지에 적합

---

## Cloud AI가 맞는 헬스케어 시나리오

반대로 Cloud AI가 더 나은 경우도 있다:

| 시나리오                       | 이유                        |
| -------------------------- | ------------------------- |
| 대규모 의료 영상 판독 (CT, MRI)     | 모델 크기가 수GB → 기기에 올릴 수 없음  |
| 전체 환자 데이터 기반 예측            | 개인 데이터만으로는 부족, 서버에서 집계 필요 |
| 모델 지속 개선 (Active Learning) | 새 데이터로 실시간 재학습 → 서버에서만 가능 |
| 진단 보조 (의사 결정 지원)           | 정확도가 최우선, 지연 허용 가능        |
|                            |                           |

---

## 향후 방향 — Apple Intelligence 시대

- `FoundationModels` 프레임워크 (iOS 18): 앱 내에서 온디바이스 LLM 직접 호출
- 헬스케어 활용 가능성: 집중 패턴 요약, 건강 리포트 자연어 생성
- Private Cloud Compute: On-device 처리 불가 시 Apple 서버로 전송 (E2E 암호화)

---

## 참고 링크

- [Apple Core ML 공식 문서](https://developer.apple.com/documentation/coreml)
- [Apple FoundationModels (iOS 18)](https://developer.apple.com/apple-intelligence/)
- [FDA AI/ML SaMD Action Plan](https://www.fda.gov/medical-devices/software-medical-device-samd/artificial-intelligence-and-machine-learning-software-medical-device)
- [MobileNetV3 논문](https://arxiv.org/abs/1905.02244)
