#!/usr/bin/env bash
#
# 生成本机自测凭据文件 Configs/DevSecrets.plist（已被 .gitignore 忽略）。
#
# 用法：
#   Scripts/setup-dev-secrets.sh AuthKey_XXXXXXXXXX.p8 7S6SUT5L43 2N62934Y28
#
# 生成后重新构建，App 会把这个凭据打进 bundle，「Fill this App's Info」
# 开箱即可完成自收发自测，无需在界面上手工录入。
set -euo pipefail

if [ "$#" -ne 3 ]; then
    echo "usage: $0 <AuthKey_XXXX.p8> <KEY_ID> <TEAM_ID>" >&2
    exit 64
fi

P8="$1"
KEY_ID="$2"
TEAM_ID="$3"

cd "$(dirname "$0")/.."

python3 - "$P8" "$KEY_ID" "$TEAM_ID" <<'PY'
import pathlib, plistlib, sys

p8_path, key_id, team_id = sys.argv[1:4]
private_key = pathlib.Path(p8_path).read_text().strip()
if not private_key.startswith("-----BEGIN PRIVATE KEY-----"):
    sys.exit("error: %s is not a PKCS#8 .p8 key" % p8_path)

out = pathlib.Path("Configs/DevSecrets.plist")
out.write_bytes(plistlib.dumps({
    "KeyID": key_id,
    "TeamID": team_id,
    "PrivateKey": private_key + "\n",
}))
print("wrote %s (gitignored)" % out)
PY

echo "note: rebuild the app — the credentials are copied into the bundle at build time."
