### 1단계: 전체 파이프라인 이해 및 환경 세팅

Core ML 생태계는 크게 '모델 변환'과 '앱 내 구동' 두 가지로 나뉩니다.

- **모델 학습:** Python 환경에서 PyTorch나 TensorFlow를 사용해 모델을 학습합니다. (이미 만들어진 Pre-trained 모델을 가져와도 됩니다.)
    
- **모델 변환:** 학습된 모델을 iOS 기기가 이해할 수 있는 형태(`.mlpackage` 파일)로 바꿔야 합니다. 이때 사용하는 것이 `coremltools`입니다.
    
- **모델 구동:** 변환된 모델을 Xcode 프로젝트에 넣고 Swift 코드를 통해 실행합니다. (Core ML 프레임워크)

### 2단계: `coremltools`로 모델 변환하기 (Python 영역)

GitHub 리포지토리의 소스 코드를 분석하기보다는, `coremltools`의 공식 사용자 가이드(coremltools.readme.io)에 있는 튜토리얼을 먼저 보시는 것이 좋습니다.

- **학습 포인트:**
    
    - `ct.convert()` 함수의 기본적인 사용법.
        
    - 모델의 Input과 Output 형태 지정 방법 (예: Tensor를 Image 타입으로 변환하여 iOS에서 다루기 쉽게 만들기).
        
    - PyTorch의 TorchScript 모델을 변환하는 기초 예제 실습.

### 3단계: iOS 앱 내 통합 (Swift 영역)

이때 Apple의 공식 문서를 레퍼런스로 활용하시면 됩니다. 모델 파일을 Xcode에 드래그 앤 드롭하면, Xcode가 자동으로 모델을 사용하기 위한 Swift 클래스를 생성해 줍니다.

- **학습 포인트:**
    
    - 자동 생성된 Swift 클래스의 `prediction()` 메서드 사용법.
        
    - Vision 프레임워크와의 연동: 이미지 기반 AI 모델(분류, 객체 인식 등)을 다룰 때는 Core ML 단독보다는 Vision 프레임워크(`VNCoreMLModel`, `VNCoreMLRequest`)와 결합해서 사용하는 것이 표준입니다. 이 부분을 중점적으로 살펴보세요.

### 4단계: 모델 최적화 (Advanced)

기본적인 구동에 성공했다면, On-device의 핵심인 제한된 리소스(메모리, 배터리) 관리를 위해 최적화 기법을 학습합니다.

- **학습 포인트:**
    
    - `coremltools`를 활용한 Quantization (양자화: Float32 모델을 Float16이나 Int8로 줄여 용량과 연산 속도를 개선하는 방법).
        
    - Apple Neural Engine (ANE)을 타겟팅하여 성능을 극대화하는 방법.

---

> [[AI 학습 인덱스]]