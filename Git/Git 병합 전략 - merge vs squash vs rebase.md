
> [[Home]] > Git
> 작성일: 2026-04-29 | 태그: #Git #버전관리 #협업

---

## 세 방식의 핵심 차이

```
feature 브랜치:  A - B - C
main 브랜치:     1 - 2
```

세 방식 모두 feature 브랜치의 변경사항을 main에 반영하지만, **커밋 히스토리 모양이 달라진다.**
![[Pasted image 20260501004703.png]]

---

## 1. Merge (기본 병합)

```bash
git checkout main
git merge feature
```

**결과:**
```
1 - 2 - A - B - C - M(merge commit)
         \_________/
```

- feature의 커밋(A, B, C)을 **그대로** main에 가져옴
- 두 브랜치가 합쳐졌다는 **Merge commit(M)이 추가**됨
- 히스토리가 브랜치 분기/합류 형태로 보임

**언제 쓰나:**
- 팀 프로젝트에서 누가 어떤 브랜치에서 작업했는지 이력을 남길 때
- PR을 통한 코드 리뷰 후 병합하는 일반적인 협업 흐름
- GitHub의 "Merge pull request" 기본 동작

**장점:** 히스토리가 정직하게 남음, 충돌 해결이 비교적 쉬움
**단점:** 히스토리가 복잡해짐 (브랜치 많을수록 graph가 지저분)

---

## 2. Squash Merge (커밋 압축 병합)

```bash
git checkout main
git merge --squash feature
git commit -m "feat: 기능 A 추가"
```

**결과:**
```
1 - 2 - S
```
(A + B + C가 하나의 커밋 S로 압축됨)

- feature 브랜치의 A, B, C를 **하나의 커밋으로 압축**해서 main에 추가
- 개발 과정의 "작업 중" 커밋들이 깔끔하게 정리됨
- 원본 브랜치와의 연결 관계는 히스토리에 남지 않음

**언제 쓰나:**
- 작업 중에 "wip", "fix typo" 같은 지저분한 커밋이 많을 때
- 하나의 기능 단위를 하나의 커밋으로 정리하고 싶을 때
- GitHub의 "Squash and merge" 옵션

**장점:** main 브랜치 히스토리가 깔끔하고 읽기 쉬움
**단점:** 개발 중간 과정이 사라짐, 나중에 특정 시점으로 롤백 어려움

---

## 3. Rebase (재배치)

```bash
git checkout feature
git rebase main
# 이후
git checkout main
git merge feature  # Fast-forward
```

**결과:**
```
1 - 2 - A' - B' - C'
```

- feature의 커밋들을 main의 **최신 커밋 뒤로 재배치**
- 커밋 내용은 같지만 커밋 해시가 바뀜 (A → A')
- Merge commit 없이 히스토리가 **일직선**으로 유지됨

**언제 쓰나:**
- 개인 브랜치를 최신 main과 동기화할 때 (`git pull --rebase`)
- PR 올리기 전 main 변경사항을 내 브랜치에 반영할 때
- 히스토리를 깔끔한 선형으로 유지하고 싶을 때

**장점:** 히스토리가 선형으로 깔끔, 로그 보기 쉬움
**단점:** 이미 push된 브랜치에 rebase하면 팀원과 충돌 위험 → **혼자 쓰는 브랜치에서만**

> **주의**: 공유 브랜치(main, develop)에 rebase 금지. 커밋 해시가 바뀌어 팀원의 로컬과 충돌함.

---

## 한눈에 비교

|           | Merge             | Squash Merge | Rebase        |
| --------- | ----------------- | ------------ | ------------- |
| 커밋 수      | 원본 + Merge commit | 1개로 압축       | 원본 유지 (해시 변경) |
| 히스토리 형태   | 분기/합류 그래프         | 선형 (단순)      | 선형 (상세)       |
| 개발 과정 보존  | ✅ 완전 보존           | ❌ 압축됨        | ✅ 보존 (해시 변경)  |
| 공유 브랜치 사용 | ✅ 안전              | ✅ 안전         | ❌ 위험          |
| 적합한 상황    | 팀 협업, PR 병합       | 지저분한 커밋 정리   | 개인 브랜치 동기화    |

---

## 실제 팀 프로젝트 워크플로우 예시

```bash
# 1. feature 브랜치 작업 중 main이 업데이트됐을 때
git checkout feature/my-work
git rebase main              # main 변경사항을 내 브랜치 아래로 재배치

# 2. PR 올리고 리뷰 통과 후 병합
# GitHub에서 "Squash and merge" 선택 → 깔끔한 히스토리

# 3. 긴급 핫픽스는 그냥 Merge
git checkout main
git merge hotfix/critical-bug
```

---

## Zero-Alpha-Beta 프로젝트에서의 적용

개인 프로젝트이므로:
- 작업 중 커밋은 자유롭게
- main에 반영할 때는 **Squash Merge** → 기능 단위로 깔끔한 히스토리 유지
- 참고: `docs/아키텍처 결정/` 에 브랜치 전략 ADR 추가 가능

---

> 연결: [[CS 학습 인덱스]] | [[CI-CD 개념 정리]] | [[Zero-Alpha-Beta 개요]] | [[Home]]
