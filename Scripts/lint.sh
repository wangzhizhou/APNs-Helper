#!/bin/sh
# 代码规范检查（本地与 CI 共用同一份配置与参数）
#
# 安装 SwiftLint：brew install swiftlint
# 用法：./Scripts/lint.sh [swiftlint 额外参数...]
set -eu

cd "$(dirname "$0")/.."

if ! command -v swiftlint >/dev/null 2>&1; then
    echo "未找到 swiftlint，请先安装：brew install swiftlint" >&2
    exit 1
fi

exec swiftlint lint --config .swiftlint.yml --quiet --force-exclude "$@"
