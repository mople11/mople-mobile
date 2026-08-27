#!/usr/bin/env bash
# 카카오 네이티브 앱 키를 ios/Flutter/Kakao.xcconfig 에서 읽어
# --dart-define 으로 넘기며 앱을 실행한다.
#
# 키를 두 곳에 따로 적어 값이 어긋나는 실수를 막기 위한 스크립트다.
# (xcconfig = iOS URL Scheme용, --dart-define = Dart SDK 초기화용)
#
#   ./tool/run.sh                 # 기본 기기
#   ./tool/run.sh -d <device-id>  # 기기 지정
set -euo pipefail

cd "$(dirname "$0")/.."

CONFIG="ios/Flutter/Kakao.xcconfig"
KEY=""
if [ -f "$CONFIG" ]; then
  KEY=$(grep '^KAKAO_NATIVE_APP_KEY' "$CONFIG" \
        | sed 's/.*=[[:space:]]*//' | tr -d '"' | tr -d '[:space:]')
fi

if [ -z "$KEY" ]; then
  echo "⚠️  $CONFIG 에 KAKAO_NATIVE_APP_KEY 가 없습니다."
  echo "    카카오 로그인은 비활성 상태로 실행합니다."
else
  echo "✅ 카카오 키 로드됨 (${#KEY}자)"
fi

exec flutter run --dart-define=KAKAO_NATIVE_APP_KEY="$KEY" "$@"
