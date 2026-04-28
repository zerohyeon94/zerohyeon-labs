#!/bin/bash
# ──────────────────────────────────────────
# SwiftSteps Daily Auto Review
# Claude Code CLI 기반 자동화 스크립트
# (API Key 불필요 — Pro 플랜 구독으로 동작)
#
# cron 설정:
#   crontab -e
#   0 23 * * * /bin/bash /path/to/auto_review.sh >> /path/to/auto_review.log 2>&1
# ──────────────────────────────────────────

# ✏️ Vault 경로 설정 (본인 경로로 변경)
VAULT_PATH="$HOME/Documents/SwiftSteps"
DAILY_DIR="$VAULT_PATH/Daily"

# 날짜 설정
TODAY=$(date +"%Y-%m-%d")
TOMORROW=$(date -v+1d +"%Y-%m-%d")  # macOS 기준
# Linux라면: TOMORROW=$(date -d "+1 day" +"%Y-%m-%d")

TODAY_NOTE="$DAILY_DIR/$TODAY.md"
TOMORROW_NOTE="$DAILY_DIR/$TOMORROW.md"

echo ""
echo "🚀 SwiftSteps Daily Review 시작 - $TODAY"
echo "=================================================="

# ──────────────────────────────────────────
# 1. 오늘 노트 존재 확인
# ──────────────────────────────────────────
if [ ! -f "$TODAY_NOTE" ]; then
  echo "❌ 오늘 노트가 없습니다: $TODAY_NOTE"
  echo "   Obsidian에서 오늘 날짜 노트를 먼저 작성해주세요."
  exit 1
fi

echo "📖 오늘 노트 읽기: $TODAY_NOTE"
TODAY_CONTENT=$(cat "$TODAY_NOTE")

# ──────────────────────────────────────────
# 2. Claude Code로 분석 요청
# ──────────────────────────────────────────
echo "🤖 Claude 분석 중..."

PROMPT="당신은 개발자 학습 코치입니다.
아래는 오늘($TODAY)의 학습 Daily Note입니다.

---
$TODAY_CONTENT
---

다음 작업을 수행해주세요:

1. 오늘 완료된 항목 파악
2. 학습 내용에 대한 전문가 피드백 (2-3문장, 구체적으로)
3. 오늘 배운 개념들의 연결 관계 설명
4. 내일($TOMORROW) 추천 일정 3가지 (오늘 미완료 + 다음 단계 반영)
5. 함께 공부하면 좋은 연관 개념 2가지
6. 오늘 배운 핵심 영어 용어

아래 마크다운 형식으로 정확히 출력해주세요:

## 🌙 저녁 회고 (Claude 자동 작성)
> 자동 생성: $TODAY

### ✅ 오늘 완료된 항목
- [완료 항목들]

### 💬 피드백
[피드백 내용]

### 🔗 개념 연결
- [연결 관계]

### 📋 내일 추천 일정
- [ ] [할 것 1]
- [ ] [할 것 2]
- [ ] [할 것 3]

### 📚 함께 공부하면 좋은 연관 개념
- [[개념1]]
- [[개념2]]

### 🇺🇸 오늘의 영어 핵심 용어
- \`용어1\`
- \`용어2\`"

# Claude Code CLI 실행 (--print: 비대화형 모드)
REVIEW=$(claude --print "$PROMPT" 2>/dev/null)

if [ -z "$REVIEW" ]; then
  echo "❌ Claude 응답을 받지 못했습니다. claude login 상태를 확인해주세요."
  exit 1
fi

# ──────────────────────────────────────────
# 3. 오늘 노트에 저녁 회고 섹션 업데이트
# ──────────────────────────────────────────
echo "✍️  오늘 노트 업데이트 중..."

# 기존 저녁 회고 섹션 제거 후 새 내용 추가
if grep -q "## 🌙 저녁 회고" "$TODAY_NOTE"; then
  # 저녁 회고 섹션 이전 내용만 유지
  BEFORE_REVIEW=$(awk '/## 🌙 저녁 회고/{exit}1' "$TODAY_NOTE")
  echo "$BEFORE_REVIEW" > "$TODAY_NOTE"
fi

# 새 회고 내용 추가
echo "" >> "$TODAY_NOTE"
echo "" >> "$TODAY_NOTE"
echo "$REVIEW" >> "$TODAY_NOTE"

echo "✅ 오늘 노트 업데이트 완료: $TODAY.md"

# ──────────────────────────────────────────
# 4. 내일 Daily Note 생성
# ──────────────────────────────────────────
if [ -f "$TOMORROW_NOTE" ]; then
  echo "ℹ️  내일 노트가 이미 존재합니다: $TOMORROW.md"
else
  echo "📄 내일 노트 생성 중..."

  # 내일 추천 일정만 추출 (Claude 응답에서)
  TOMORROW_TASKS=$(echo "$REVIEW" | awk '/### 📋 내일 추천 일정/{found=1; next} found && /^###/{exit} found{print}')

  cat > "$TOMORROW_NOTE" << EOF
# 📅 Daily Note - $TOMORROW

## ✅ 오늘의 수행 목록
> Claude 추천 일정 (자유롭게 수정하세요)

$TOMORROW_TASKS

---

## 📚 학습 내용
> 오늘 공부한 개념/기술 (직접 작성)

### 개념명:
- **언제 쓰는가?** (상황/문제):
- **무엇인가?** (정의):
- **어떻게 쓰는가?** (예시 코드):
\`\`\`python

\`\`\`
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

## 🌙 저녁 회고 (Claude 자동 작성)
> 매일 밤 auto_review.sh가 자동으로 채워줍니다

EOF

  echo "✅ 내일 노트 생성 완료: $TOMORROW.md"
fi

echo "=================================================="
echo "✨ 완료! Obsidian에서 확인해보세요."
echo ""
