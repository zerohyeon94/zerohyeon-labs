**"Poetry"**와 **"uv"**는 둘 다 Python 프로젝트에서 **패키지(라이브러리)를 관리해주는 도구**입니다.

하지만 최근 Python 생태계(특히 AI/딥러닝 분야)에서는 **"Poetry에서 uv로 넘어가는 추세"**가 매우 강합니다.

---

### 1. 간단 요약: 무엇이 다른가요?

|특징|**Poetry** (포이트리)|**uv** (유브이)|
|---|---|---|
|**정체**|기존의 **표준** 강자|떠오르는 **초신성** (Game Changer)|
|**언어**|Python으로 작성됨|**Rust**로 작성됨 (압도적인 속도)|
|**속도**|느림 (특히 PyTorch 설치 시 답답함)|**엄청나게 빠름** (10~100배 빠름)|
|**역할**|의존성 관리 + 가상환경 + 패키징|의존성 관리 + 가상환경 + **Python 버전 관리** (pyenv 대체 가능)|
|**파일**|`pyproject.toml`, `poetry.lock`|`pyproject.toml`, `uv.lock`|

### 2. 왜 지금 "uv"가 핫한가요? (딥러닝 개발자 필독)

작성자님처럼 **PyTorch, TensorFlow** 같은 무거운 라이브러리를 다루는 분들에게 **Poetry는 종종 고통**을 줍니다.

1. **속도 차이:**
    
    - **Poetry:** PyTorch 하나 깔려면 의존성 해결(Resolving dependencies...)에서 몇 분씩 멈춰 있거나, 설치 속도가 느립니다.
        
    - **uv:** 똑같은 PyTorch를 설치할 때, 캐싱 기술과 Rust 언어의 특성을 이용해 **순식간(초 단위)에 해결**합니다.
        
2. **Python 버전 관리 통합:**
    
    - 기존: `pyenv`로 파이썬 버전 깔고 -> `poetry`로 라이브러리 관리.
        
    - **uv:** `uv python install 3.12` 명령어로 파이썬 설치부터 라이브러리 관리까지 한 번에 끝냅니다.

### 3. 실전: Poetry vs uv 명령어 비교

사용법이 매우 비슷해서, Poetry를 써보셨다면 금방 적응하실 수 있습니다.

|작업|Poetry 명령어|uv 명령어|
|---|---|---|
|**프로젝트 생성**|`poetry new my-project`|`uv init my-project`|
|**라이브러리 추가**|`poetry add numpy`|`uv add numpy`|
|**실행**|`poetry run python main.py`|`uv run main.py`|
|**동기화 (설치)**|`poetry install`|`uv sync`|

### 4. 작성자님을 위한 추천 (AI/Deep Learning)

**결론부터 말씀드리면, 지금 배우시는 단계라면 `uv`를 적극 추천합니다.**

이유는 **PyTorch 설치** 때문입니다.

- **Poetry**는 PyTorch와 관련 라이브러리(Numpy, Pandas 등)들의 복잡한 버전을 맞추느라 "Resolving..." 상태에서 무한 로딩에 걸리는 경우가 잦습니다.
    
- **uv**는 이 과정을 획기적으로 단축시켜 줍니다.