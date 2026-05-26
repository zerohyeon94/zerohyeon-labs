#!/bin/bash
# =========================================
# SwiftSteps Codex cron 자동화 설정 스크립트
# 실행: bash setup_cron.sh
# =========================================

set -e

# 현재 스크립트 위치에서 Vault 경로 추론
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_PATH="$(which python3)"
DAILY_SCRIPT="$SCRIPT_DIR/daily_review.py"
LOG_FILE="$SCRIPT_DIR/daily_review.log"

echo ""
echo "🔧 SwiftSteps 자동화 설정 시작"
echo "================================"
echo "📁 스크립트 경로: $DAILY_SCRIPT"
echo "🐍 Python 경로:   $PYTHON_PATH"
echo "📋 로그 파일:     $LOG_FILE"
echo ""

if [ -f "$SCRIPT_DIR/.env" ]; then
  echo "⚙️  .env 설정 사용"
else
  echo "ℹ️  .env 없음: Vault 경로는 프로젝트 루트로 자동 추론합니다."
fi

# cron 작업 문자열 생성 (매일 밤 11시 실행)
CRON_JOB="0 23 * * * cd $SCRIPT_DIR && $PYTHON_PATH $DAILY_SCRIPT >> $LOG_FILE 2>&1"

# 기존 cron에 없으면 추가
(crontab -l 2>/dev/null | grep -v "daily_review.py"; echo "$CRON_JOB") | crontab -

echo "✅ cron 등록 완료!"
echo ""
echo "📅 실행 일정: 매일 밤 11:00"
echo ""
echo "현재 등록된 cron 목록:"
crontab -l | grep "daily_review"
echo ""
echo "🔍 로그 확인: tail -f $LOG_FILE"
echo "🧪 즉시 테스트: python3 $DAILY_SCRIPT"
echo ""
echo "✨ 설정 완료! 오늘 밤 11시부터 Codex 기반 자동 회고가 실행됩니다."
