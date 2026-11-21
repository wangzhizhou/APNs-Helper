#!/usr/bin/env bash
#
# Build phase: 把本机自测凭据（如果有）复制进 App bundle。
# 只在构建本机存在 Configs/DevSecrets.plist 时生效；CI / 其他人克隆仓库时没有该文件，
# 构建产物里也就不会包含任何私钥，App 会回退到界面里录入的 Keychain 凭据。
set -euo pipefail

SRC="${SRCROOT}/Configs/DevSecrets.plist"
DEST_DIR="${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
DEST="${DEST_DIR}/DevSecrets.plist"

mkdir -p "${DEST_DIR}"

if [ -f "${SRC}" ]; then
    cp "${SRC}" "${DEST}"
    echo "note: injected self-test credentials into ${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
else
    rm -f "${DEST}"
fi
