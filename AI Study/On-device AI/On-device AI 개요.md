# On-device AI 개요

> [[Home]] > [[AI 학습 인덱스]] > On-device AI
> 작성일: 2026-04-28 | 태그: #AI #CoreML #iOS #OnDeviceAI

---

## 1. On-device AI란?

AI 추론(Inference)을 **서버가 아닌 기기 자체에서 실행**하는 것.

| 구분     | Cloud AI     | On-device AI  |
| ------ | ------------ | ------------- |
| 처리 위치  | 원격 서버        | 기기 내 칩셋       |
| 인터넷 필요 | 필수           | 불필요           |
| 응답 속도  | 네트워크 지연 있음   | 즉각 응답         |
| 개인정보   | 서버 전송됨       | 기기 밖으로 나가지 않음 |
| 운영 비용  | API 호출 비용 발생 | 없음            |

**헬스케어에서 On-device가 중요한 이유**: 의료 데이터(얼굴, 바이탈)는 서버로 보내면 개인정보 이슈 → On-device가 규제 대응에 유리

---

## 2. Apple의 On-device AI 스택

```
┌─────────────────────────────────────┐
│         Apple Intelligence          │ ← iOS 18 (온디바이스 LLM)
├─────────────────────────────────────┤
│  Core ML    Vision    NL Framework  │ ← 개발자 직접 사용 레이어
├─────────────────────────────────────┤
│         Create ML (모델 학습)         │ ← Mac에서 모델 직접 학습
├─────────────────────────────────────┤
│    Neural Engine (ANE) / GPU / CPU  │ ← 하드웨어 (자동 선택)
└─────────────────────────────────────┘
```

### Core ML
- Apple의 기본 ML 프레임워크
- `.mlpackage` / `.mlmodel` 파일 형식
- PyTorch, TensorFlow 모델을 `coremltools`로 변환 가능
- ZipJoong이 이미 사용 중 (`FocusSense_default.mlpackage`)

```swift
// Core ML 모델 로드 및 추론 기본 패턴
let model = try FocusSense_default(configuration: MLModelConfiguration())
let input = FocusSense_defaultInput(image: pixelBuffer)
let output = try model.prediction(input: input)
```

### Vision Framework
- 얼굴 인식, 랜드마크, 자세 추정 등 컴퓨터 비전 특화
- Core ML 모델과 조합해서 사용 (ZipJoong의 70% 담당 부분)
- `VNDetectFaceLandmarksRequest`, `VNDetectHumanBodyPoseRequest` 등

### Natural Language Framework
- 텍스트 분류, 감정 분석, 언어 인식
- 헬스케어 앱에서 사용자 일기/메모 분석에 활용 가능

### Create ML
- Mac에서 직접 모델을 학습시키는 도구 (코드 or GUI)
- Image Classifier, Object Detector, Sound Classifier 등 지원
- Python의 coremltools와 함께 사용 (ZipJoong ML/ 파이프라인)

---

## 3. Apple Intelligence (iOS 18)

- iPhone에 탑재된 온디바이스 LLM (약 3B 파라미터 추정)
- Writing Tools, Image Playground, Siri 개선 등
- 개발자 API: `FoundationModels` 프레임워크로 앱 내 LLM 호출 가능
- 민감한 요청은 Private Cloud Compute로 처리 (서버이지만 Apple 서버, E2E 암호화)

```swift
// FoundationModels (iOS 18+) 예시
import FoundationModels

let session = LanguageModelSession()
let response = try await session.respond(to: "이 데이터를 요약해줘")
```

---

## 4. 모델 변환 파이프라인 (PyTorch → Core ML)

ZipJoong ML/ 폴더의 흐름과 동일:

```
학습 데이터
    ↓
PyTorch 모델 학습 (train.py)
    ↓
best_model.pth 저장
    ↓
coremltools로 변환 (convert_to_coreml.py)
    ↓
.mlpackage 생성
    ↓
Xcode 프로젝트에 추가 → iOS 앱에서 사용
```

---

## 5. 성능 최적화 포인트

| 기법 | 설명 | 효과 |
|------|------|------|
| 양자화 (Quantization) | 가중치를 float32 → int8으로 압축 | 모델 크기 ↓, 속도 ↑ |
| 프루닝 (Pruning) | 덜 중요한 가중치 제거 | 모델 크기 ↓ |
| Neural Engine 활용 | `computeUnits: .all` 설정 | Apple ANE 우선 사용 → 저전력 |
| 배치 추론 | 여러 프레임 묶어서 처리 | 처리량 ↑ |

```swift
let config = MLModelConfiguration()
config.computeUnits = .all  // CPU + GPU + Neural Engine 모두 사용
```

---

## 6. ZipJoong과의 연결점

- 현재 ZipJoong은 Vision(70%) + CoreML(30%) 하이브리드
- **개선 방향**: CoreML 모델 정확도 개선 → 비율 조정 가능
- **추가 가능한 기능**: 심박수 추정(카메라 rPPG), 눈 깜빡임 패턴 분석
- **Apple Intelligence 연동**: 집중 패턴 요약을 LLM으로 자연어 생성

---

## 7. 커리어 관점

iOS + On-device AI 개발자는 **드문 조합**:
- 일반 iOS 개발자: Swift는 알지만 ML 모델은 모름
- 일반 AI 개발자: Python은 알지만 Swift/Xcode는 모름
- **zerohyeon**: 둘 다 가능 → 차별점

관련 직군:
- iOS ML Engineer (Apple, 의료기기 회사)
- AI Feature Developer (헬스케어 스타트업)
- Core ML 전문 컨설턴트

---

## 참고 자료

- [Apple Core ML 공식 문서](https://developer.apple.com/documentation/coreml)
- [WWDC 2024 - What's new in Core ML](https://developer.apple.com/videos/play/wwdc2024/)
- [coremltools GitHub](https://github.com/apple/coremltools)
- [Apple Intelligence 개발자 가이드](https://developer.apple.com/apple-intelligence/)

---

> 연결: [[AI 학습 인덱스]] | [[iOS 학습 인덱스]] | [[Home]]
