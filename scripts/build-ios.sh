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
phones=[dev for k,v in ios for dev in v if dev["name"].startswith("iPhone")]
best=[d for d in phones if "Pro Max" in d["name"]] or phones
print(best[0]["udid"])
')"
echo "Using simulator $SIM_ID"
ACTION="${1:-test}"
rm -rf build/TestResults.xcresult build/screenshots
mkdir -p build
STATUS=0
xcodebuild -project SpineCare.xcodeproj -scheme SpineCare \
  -destination "id=$SIM_ID" \
  -resultBundlePath build/TestResults.xcresult \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
  $([ "$ACTION" = build ] && echo build || echo "build test") || STATUS=$?

# Save UI-test screenshots (Xcode 16+) to build/screenshots
if [ "$ACTION" != build ] && [ -d build/TestResults.xcresult ]; then
  xcrun xcresulttool export attachments --path build/TestResults.xcresult --output-path build/screenshots >/dev/null 2>&1 \
    && echo "Screenshots saved to build/screenshots" || echo "Couldn't export screenshots (needs Xcode 16+)"
fi
exit $STATUS
