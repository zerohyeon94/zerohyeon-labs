# Vision Body Pose — 자세 분석과 포트폴리오 앱

> 태그: #iOS #Vision #OnDeviceAI #포트폴리오
> 관련: [[On-device AI 개요]] | [[Core ML 학습 파이프라인]] | [[AVCaptureSession - 세션 생명주기와 성능 최적화]]

---

## 개요

Apple Vision 프레임워크의 **Body Pose Detection**은 카메라 영상에서 사람의 관절 포인트(joint)를 실시간으로 감지한다. 별도 모델 학습 없이 온디바이스에서 동작하며, 서버 통신이 전혀 없다.

| 항목 | 내용 |
|------|------|
| API | `VNDetectHumanBodyPoseRequest` |
| 감지 포인트 수 | 19개 관절 (목, 어깨, 팔꿈치, 손목, 엉덩이, 무릎, 발목 등) |
| 입력 | `CVPixelBuffer` (카메라 프레임) 또는 `CGImage` |
| 처리 위치 | 온디바이스 (Neural Engine 활용) |
| 최소 지원 | iOS 14+ |

---

## 핵심 API 흐름

```swift
// 1. Request 생성
let request = VNDetectHumanBodyPoseRequest { request, error in
    guard let observations = request.results as? [VNHumanBodyPoseObservation],
          let body = observations.first else { return }
    
    // 2. 관절 포인트 추출
    let points = try? body.recognizedPoints(.all)
    
    // 3. 특정 관절 좌표 읽기 (0.0~1.0 정규화된 좌표)
    if let rightShoulder = points?[.rightShoulder],
       rightShoulder.confidence > 0.5 {
        let location = rightShoulder.location  // CGPoint
    }
}

// 4. AVCaptureOutput에서 프레임마다 실행
let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
try? handler.perform([request])
```

---

## 관절 포인트 상수 목록

```swift
// 상체 (포트폴리오에서 주로 사용)
VNHumanBodyPoseObservation.JointName.nose
VNHumanBodyPoseObservation.JointName.leftEye / .rightEye
VNHumanBodyPoseObservation.JointName.leftShoulder / .rightShoulder
VNHumanBodyPoseObservation.JointName.leftElbow / .rightElbow
VNHumanBodyPoseObservation.JointName.leftWrist / .rightWrist

// 하체
VNHumanBodyPoseObservation.JointName.leftHip / .rightHip
VNHumanBodyPoseObservation.JointName.leftKnee / .rightKnee
VNHumanBodyPoseObservation.JointName.leftAnkle / .rightAnkle
```

---

## ZipJoong과의 연결 포인트

ZipJoong은 이미 `AVCaptureSession` + `AVCaptureVideoDataOutput`을 구현해 두었다.  
`captureOutput(_:didOutput:from:)` 델리게이트에 `VNDetectHumanBodyPoseRequest`를 추가하면  
기존 카메라 세션 위에 자세 감지를 얹을 수 있다.

```swift
// ZipJoong의 CameraService 확장 예시
extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput buffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else { return }
        
        let request = VNDetectHumanBodyPoseRequest(completionHandler: handleBodyPose)
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        try? handler.perform([request])
    }
}
```

---

## 포트폴리오 앱 시나리오 (자세 교정 헬스 가이드)

### 기본 흐름
1. 카메라 켜기 → AVCaptureSession 시작
2. 매 프레임 → Body Pose 감지
3. 어깨 기울기 각도 계산 (leftShoulder ↔ rightShoulder)
4. 기준 각도 대비 편차 → 실시간 피드백 UI
5. 누적 데이터 → HealthKit 기록 (선택)

### 각도 계산 예시
```swift
func shoulderTiltAngle(
    from points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
) -> Double? {
    guard let left = points[.leftShoulder], left.confidence > 0.5,
          let right = points[.rightShoulder], right.confidence > 0.5 else { return nil }
    
    let dx = right.location.x - left.location.x
    let dy = right.location.y - left.location.y
    return atan2(dy, dx) * (180 / .pi)
}
```

---

## 왜 이 프로젝트가 포트폴리오에 강한가

| 요소 | 설명 |
|------|------|
| **ZipJoong 연장선** | CameraService를 이미 구현했다. "발전 과정"이 보이는 포트폴리오. |
| **온디바이스 AI** | 서버 없이 동작 → 헬스케어 프라이버시 문제 해결. 면접에서 "왜 온디바이스?"를 설명할 수 있다. |
| **헬스케어 도메인** | 자세 교정은 재활, 운동, 직업병 예방 등 헬스케어 서사와 직접 연결된다. |
| **Core ML 확장 가능** | Body Pose + 자체 분류 모델 추가 시 더 정교한 "잘못된 자세 분류" 구현 가능. |

---

## 다음 학습 연결

- [[Core ML 학습 파이프라인]] — 자체 분류 모델을 Core ML로 내보내는 방법
- [[AVCaptureSession - 세션 생명주기와 성능 최적화]] — CameraService 성능 최적화 선행 학습
