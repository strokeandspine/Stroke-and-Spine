#!/usr/bin/env bash
# Builds and tests the platform-independent code (SpineCare/Core) on Linux or macOS without Xcode.
# The SwiftUI, SwiftData, StoreKit and HealthKit code is not included — use the iOS build for that.
# Needs a Swift 5.9+ toolchain, e.g.:  docker run --rm -v "$PWD":/src -w /src swift:5.10 scripts/test-core-linux.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PKG="$(mktemp -d)"
trap 'rm -rf "$PKG"' EXIT
mkdir -p "$PKG/Sources/SpineCare" "$PKG/Tests/SpineCareTests"
ln -s "$ROOT"/SpineCare/Core/*.swift "$PKG/Sources/SpineCare/"
ln -s "$ROOT"/SpineCareTests/*.swift "$PKG/Tests/SpineCareTests/"
cat > "$PKG/Package.swift" <<'SWIFT'
// swift-tools-version:5.9
import PackageDescription
let package = Package(name: "SpineCare", targets: [
    .target(name: "SpineCare", path: "Sources/SpineCare"),
    .testTarget(name: "SpineCareTests", dependencies: ["SpineCare"], path: "Tests/SpineCareTests"),
])
SWIFT
cd "$PKG"
swift test
