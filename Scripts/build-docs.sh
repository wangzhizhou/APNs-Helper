#!/bin/sh
# 构建 DocC 静态文档站（本地预览与 CI 共用）
#
# 用法：./Scripts/build-docs.sh [base_path] [output_dir]
#   base_path   部署路径前缀，默认 /APNs-Helper（GitHub Pages 项目站点）
#   output_dir  产物目录，默认 dist/docs
#
# 说明：DocC 的 transform-for-static-hosting 在较新工具链上不再改写 index.html
# 里的 baseUrl 与资源路径（带不带 --hosting-base-path 输出一致），
# 因此这里额外做一次替换，保证部署在子路径下时 CSS/JS 不会 404。
set -eu

cd "$(dirname "$0")/.."

BASE_PATH="${1:-/APNs-Helper}"
OUTPUT_DIR="${2:-dist/docs}"
DERIVED_DIR="dist/doccarchive"

rm -rf "$DERIVED_DIR" "$OUTPUT_DIR"
mkdir -p dist

xcodebuild docbuild \
    -project "APNs Helper.xcodeproj" \
    -scheme "APNs Helper Doc" \
    -sdk macosx \
    -destination 'generic/platform=macOS' \
    -derivedDataPath "$DERIVED_DIR" \
    CODE_SIGNING_ALLOWED=NO \
    -quiet

ARCHIVE=$(find "$DERIVED_DIR" -maxdepth 6 -type d -name "*.doccarchive" | head -1)
if [ -z "$ARCHIVE" ]; then
    echo "未找到 .doccarchive，docbuild 可能失败" >&2
    exit 1
fi

xcrun docc process-archive transform-for-static-hosting "$ARCHIVE" \
    --hosting-base-path "$BASE_PATH" \
    --output-path "$OUTPUT_DIR"

INDEX="$OUTPUT_DIR/index.html"
if [ ! -f "$INDEX" ]; then
    echo "未生成 $INDEX" >&2
    exit 1
fi

/usr/bin/sed -i '' \
    -e "s|var baseUrl = \"[^\"]*\"|var baseUrl = \"$BASE_PATH\"|" \
    -e "s|href=\"/|href=\"$BASE_PATH/|g" \
    -e "s|src=\"/|src=\"$BASE_PATH/|g" \
    "$INDEX"

echo "文档站已生成：${OUTPUT_DIR}（base path: ${BASE_PATH}）"
echo "本地预览："
echo "  rm -rf /tmp/apns-doc-preview && mkdir -p /tmp/apns-doc-preview"
echo "  cp -R $OUTPUT_DIR /tmp/apns-doc-preview${BASE_PATH}"
echo "  python3 -m http.server 8000 --directory /tmp/apns-doc-preview"
echo "  打开 http://localhost:8000${BASE_PATH}/"
