#!/usr/bin/env python3
"""
SwiftSteps Daily Auto Review System
====================================
매일 밤 자동 실행:
1. 오늘 Daily Note 읽기
2. Claude API로 분석
3. 저녁 회고 섹션 자동 작성
4. 내일 Daily Note 자동 생성

Setup:
  pip install anthropic python-dotenv
  cp .env.example .env  # API 키와 Vault 경로 설정
"""

import os
import sys
from datetime import datetime, timedelta
from pathlib import Path
from dotenv import load_dotenv
import anthropic

# ─── 설정 ───────────────────────────────────────────────
load_dotenv(Path(__file__).parent / ".env")

VAULT_PATH = Path(os.getenv("OBSIDIAN_VAULT_PATH", ""))
API_KEY    = os.getenv("ANTHROPIC_API_KEY", "")
MODEL      = "claude-sonnet-4-20250514"

if not VAULT_PATH or not API_KEY:
    print("❌ .env 파일에 OBSIDIAN_VAULT_PATH와 ANTHROPIC_API_KEY를 설정하세요.")
    sys.exit(1)

client = anthropic.Anthropic(api_key=API_KEY)

# ─── 날짜 유틸 ──────────────────────────────────────────
today     = datetime.now().strftime("%Y-%m-%d")
tomorrow  = (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d")

today_note_path    = VAULT_PATH / "Daily" / f"{today}.md"
tomorrow_note_path = VAULT_PATH / "Daily" / f"{tomorrow}.md"
template_path      = VAULT_PATH / "Templates" / "Daily Note Template.md"

# ─── 오늘 노트 읽기 ─────────────────────────────────────
def read_today_note() -> str:
    if not today_note_path.exists():
        print(f"⚠️  오늘 노트가 없습니다: {today_note_path}")
        sys.exit(1)
    return today_note_path.read_text(encoding="utf-8")

# ─── Claude API 호출 ────────────────────────────────────
def get_review(note_content: str) -> dict:
    prompt = f"""
당신은 개발자의 학습 코치입니다.
아래는 오늘 하루의 학습 노트입니다. 다음 항목을 JSON 형식으로 작성해주세요.

노트 내용:
{note_content}

응답은 반드시 아래 JSON 형식만 출력하세요 (마크다운 코드블록 없이):
{{
  "completed": ["완료된 항목1", "완료된 항목2"],
  "feedback": ["피드백1", "피드백2"],
  "tomorrow_tasks": ["내일 할 일1", "내일 할 일2", "내일 할 일3"],
  "concept_connections": ["개념 연결 추천1", "개념 연결 추천2"],
  "english_tip": "오늘 학습과 관련된 영어 표현 1가지"
}}

기준:
- 완료 항목: 체크박스 [x] 또는 내용이 작성된 섹션 기준
- 피드백: 잘한 점 1개 + 개선 제안 1개
- 내일 할 일: 오늘 미완료 + 자연스러운 다음 단계
- 개념 연결: 오늘 학습한 개념과 연결되는 추천 개념
"""
    message = client.messages.create(
        model=MODEL,
        max_tokens=1000,
        messages=[{"role": "user", "content": prompt}]
    )

    import json
    text = message.content[0].text.strip()
    # 혹시 코드블록으로 감싸진 경우 제거
    text = text.replace("```json", "").replace("```", "").strip()
    return json.loads(text)

# ─── 저녁 회고 섹션 업데이트 ────────────────────────────
def update_evening_review(review: dict):
    content = today_note_path.read_text(encoding="utf-8")

    completed_str    = "\n".join(f"- ✅ {item}" for item in review["completed"]) or "- 기록된 완료 항목 없음"
    feedback_str     = "\n".join(f"- {fb}" for fb in review["feedback"])
    tomorrow_str     = "\n".join(f"- [ ] {task}" for task in review["tomorrow_tasks"])
    connections_str  = "\n".join(f"- {c}" for c in review["concept_connections"])
    english_str      = review.get("english_tip", "")

    new_section = f"""## 🌙 저녁 회고 (Claude 자동 작성 영역)
> 자동 생성: {datetime.now().strftime("%Y-%m-%d %H:%M")}

### 오늘 완료된 항목
{completed_str}

### 피드백
{feedback_str}

### 내일 추천 일정
{tomorrow_str}

### 연결 개념 추천
{connections_str}

### 💬 오늘의 영어 표현
{english_str}
"""

    # 기존 저녁 회고 섹션 교체
    if "## 🌙 저녁 회고" in content:
        before = content.split("## 🌙 저녁 회고")[0]
        updated = before.rstrip() + "\n\n---\n\n" + new_section
    else:
        updated = content.rstrip() + "\n\n---\n\n" + new_section

    today_note_path.write_text(updated, encoding="utf-8")
    print(f"✅ 오늘 노트 회고 섹션 업데이트 완료: {today_note_path.name}")

# ─── 내일 노트 생성 ─────────────────────────────────────
def create_tomorrow_note(review: dict):
    if tomorrow_note_path.exists():
        print(f"ℹ️  내일 노트 이미 존재: {tomorrow_note_path.name}")
        return

    tomorrow_tasks = "\n".join(
        f"- [ ] {task}" for task in review["tomorrow_tasks"]
    )

    content = f"""# 📅 Daily Note - {tomorrow}

## ✅ 오늘의 수행 목록
> Claude 추천 (수정 가능)

{tomorrow_tasks}

---

## 📚 학습 내용
> 오늘 공부한 개념/기술 (직접 작성)

### 개념명:
- **언제 쓰는가?** (상황/문제):
- **무엇인가?** (정의):
- **어떻게 쓰는가?** (예시 코드):
```python

```
- **연관 개념**: 
- **태그**: #

---

## 🛠️ 프로젝트 진행 상황
> 오늘 작업한 프로젝트 내용

- **프로젝트명**:
- **오늘 한 것**:
- **막힌 부분**:
- **다음에 할 것**:

---

## 🔗 오늘 배운 개념 연결
> 오늘 학습한 것들이 서로 어떻게 연결되는가?

- 

---

## 🌙 저녁 회고 (Claude 자동 작성 영역)
> 매일 밤 자동으로 채워집니다

### 오늘 완료된 항목
- 

### 피드백
- 

### 내일 추천 일정
- 

### 연결 개념 추천
- 

### 💬 오늘의 영어 표현
- 
"""
    tomorrow_note_path.parent.mkdir(parents=True, exist_ok=True)
    tomorrow_note_path.write_text(content, encoding="utf-8")
    print(f"✅ 내일 노트 생성 완료: {tomorrow_note_path.name}")

# ─── 메인 ───────────────────────────────────────────────
def main():
    print(f"\n🔄 SwiftSteps 일일 자동 리뷰 시작 - {today}")
    print("=" * 50)

    print("📖 오늘 노트 읽는 중...")
    note_content = read_today_note()

    print("🤖 Claude 분석 중...")
    review = get_review(note_content)

    print("✍️  저녁 회고 작성 중...")
    update_evening_review(review)

    print("📅 내일 노트 생성 중...")
    create_tomorrow_note(review)

    print("=" * 50)
    print("✨ 완료! Obsidian에서 확인하세요.\n")

if __name__ == "__main__":
    main()
