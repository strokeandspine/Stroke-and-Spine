#!/usr/bin/env bash
# Generates the Xcode project and builds + tests the app on an iPhone simulator (macOS with Xcode 15+).
# Usage: scripts/build-ios.sh            (build and test)
#        scripts/build-ios.sh build      (build only)
set -euo pipefail
cd "$(dirname "$0")/.."
command -v xcodegen >/dev/null || { echo "Install XcodeGen first: brew install xcodegen"; exit 1; }
xcodegen generate
SIM_ID="$(xcrun simctl list devices available -j | python3 -c '
import json,sys
d=json.load(sys.stdin)["devices"]
ios=[(k,v) for k,v in d.items() if "iOS" in k]
ios.sort(key=lambda kv: [int(x) for x in kv[0].rsplit("iOS-",1)[-1].split("-")], reverse=True)
for k,v in ios:
    for dev in v:
        if dev["name"].startswith("iPhone"):
            print(dev["udid"]); sys.exit()
')"
echo "Using simulator $SIM_ID"
ACTION="${1:-test}"
xcodebuild -project SpineCare.xcodeproj -scheme SpineCare \
  -destination "id=$SIM_ID" \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
  $([ "$ACTION" = build ] && echo build || echo "build test")
