# CI/CD 개념 정리

> 작성일: 2026-04-28 | 태그: #Backend #CICD #GitHubActions #DevOps

---

## 1. CI/CD가 뭔가?

### 비유로 이해하기

> 식당에 비유하면:
> - **CI**: 요리가 나가기 전에 맛 검사를 자동으로 하는 시스템
> - **CD**: 검사를 통과한 요리를 자동으로 손님 테이블에 전달하는 시스템

코드로 바꾸면:
- **CI**: 코드를 push할 때마다 자동으로 테스트/검사 실행
- **CD**: 검사 통과 시 자동으로 서버에 배포

---

## 2. CI (Continuous Integration, 지속적 통합)

### 없을 때 생기는 문제
```
팀원 A가 코드 수정 → 직접 테스트 → "내 로컬에선 됩니다"
팀원 B가 코드 수정 → 직접 테스트 → "내 로컬에선 됩니다"
둘 다 합치면 → 💥 서버에서 터짐
```

### 있을 때
```
팀원 A가 PR 올림
    ↓
GitHub Actions 자동 실행
    ↓
① 코드 스타일 검사 (ruff)
② 타입 검사 (mypy)
③ 테스트 실행 (pytest)
    ↓
모두 통과 ✅ → 팀원이 코드 리뷰 후 머지
실패 ❌ → PR에 빨간불 표시 → 수정 후 다시 push
```

### GitHub Actions란?
GitHub에서 제공하는 자동화 실행 환경.  
`.github/workflows/` 폴더에 YAML 파일을 작성하면 특정 이벤트(push, PR 등)에서 자동 실행된다.

```yaml
# 기본 구조
name: CI                          # 워크플로우 이름

on:                               # 언제 실행할지
  pull_request:
    branches: [main, develop]

jobs:                             # 실행할 작업들
  test:                           # 작업 이름
    runs-on: ubuntu-latest        # 어떤 환경에서 실행
    steps:                        # 순서대로 실행할 단계들
      - uses: actions/checkout@v4 # 코드 받아오기
      - name: 테스트 실행
        run: pytest               # 실제 명령어
```

---

## 3. CD (Continuous Deployment, 지속적 배포)

### 없을 때 배포 과정
```
1. 로컬에서 코드 수정
2. 직접 EC2 서버에 SSH 접속
3. git pull
4. docker compose down
5. docker compose up --build -d
6. 잘 됐는지 확인
→ 매번 수동, 실수 가능, 시간 낭비
```

### 있을 때
```
main 브랜치에 머지됨
    ↓
GitHub Actions CD 워크플로우 자동 실행
    ↓
① EC2 서버에 SSH 접속 (비밀키는 GitHub Secrets에 저장)
② git pull
③ docker compose up --build -d
④ 헬스체크 (서버 정상 응답 확인)
    ↓
완료 → Slack/Discord 알림 (선택)
```

---

## 4. MyHealthBuddy 현재 상태 분석

### 현재 있는 것 ✅
- `.github/workflows/ci.yml` — PR 시 자동 테스트 워크플로우 존재
- `scripts/ci/code_formatting.sh` — ruff 포맷팅 스크립트
- `scripts/ci/check_mypy.sh` — mypy 타입 검사 스크립트
- `scripts/ci/run_test.sh` — pytest 실행 스크립트

### 현재 없는 것 ❌
- ruff, mypy가 GitHub Actions에 연결되지 않음 (스크립트만 있음)
- CD 워크플로우 없음 (자동 배포 안 됨)

### 현재 ci.yml의 문제점

```yaml
# ❌ 현재 (문제있음)
- name: Set up Python
  uses: actions/setup-python@v4
  with:
    python-version: '3.11'   # 프로젝트는 3.13 사용

- name: Install dependencies
  run: pip install pytest    # 프로젝트는 uv 사용
```

```yaml
# ✅ 수정해야 할 내용
- name: Set up Python
  uses: actions/setup-python@v4
  with:
    python-version: '3.13'   # pyproject.toml과 일치

- name: Install uv
  run: pip install uv        # 프로젝트 패키지 매니저

- name: Install dependencies
  run: uv sync               # uv로 의존성 설치
```

---

## 5. CI/CD 전체 흐름 (목표 상태)

```
개발자 로컬에서 feature 브랜치 작업
    ↓
develop에 PR 오픈
    ↓
[CI 자동 실행]
  - ruff 코드 스타일 검사
  - mypy 타입 검사
  - pytest 테스트 실행
    ↓
CI 통과 + 코드 리뷰 → develop 머지
    ↓
develop → main PR 오픈 (릴리즈)
    ↓
CI 통과 → main 머지
    ↓
[CD 자동 실행]
  - EC2 SSH 접속
  - docker compose pull
  - docker compose up --build -d
  - 헬스체크
```

---

## 6. GitHub Secrets (보안)

CD에서 서버 접속 정보를 코드에 직접 쓰면 안 된다.  
→ GitHub Repository Settings → Secrets and variables → Actions에 저장

```yaml
# Secrets 사용 예시
- name: Deploy to EC2
  env:
    EC2_HOST: ${{ secrets.EC2_HOST }}       # 서버 IP
    EC2_KEY: ${{ secrets.EC2_PRIVATE_KEY }} # SSH 비밀키
  run: |
    echo "$EC2_KEY" > key.pem
    chmod 600 key.pem
    ssh -i key.pem ubuntu@$EC2_HOST "cd /app && docker compose up --build -d"
```

---

## 7. 오늘 할 수 있는 것

- [x] ci.yml 열어서 Python 버전 3.13으로 수정해보기
- [x] pip → uv로 변경해보기
- [x] ruff 검사 step 추가해보기

**참고**: 수정 후 PR을 올리면 GitHub Actions 탭에서 실행 결과를 직접 확인할 수 있다.

---

## 참고 자료

- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [GitHub Actions로 FastAPI 배포하기](https://fastapi.tiangolo.com/deployment/docker/)
- [uv 공식 문서](https://docs.astral.sh/uv/)
