#!/bin/bash
set -euo pipefail

# Build a release .app and zip it for distribution.
# Output: release/SimpleCaffeine-<version>.zip plus the SHA256 of that zip.

cd "$(dirname "$0")/.."

if ! command -v xcodegen >/dev/null 2>&1; then
    echo "error: xcodegen not installed. Run: brew install xcodegen" >&2
    exit 1
fi

VERSION=$(awk '/MARKETING_VERSION:/ {gsub(/"/, "", $2); print $2}' project.yml)
if [ -z "$VERSION" ]; then
    echo "error: could not read MARKETING_VERSION from project.yml" >&2
    exit 1
fi

echo "==> Regenerating Xcode project"
xcodegen generate

echo "==> Building Release"
xcodebuild \
    -project SimpleCaffeine.xcodeproj \
    -scheme SimpleCaffeine \
    -configuration Release \
    -derivedDataPath build \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    build 2>&1 | tail -3

APP_PATH="build/Build/Products/Release/SimpleCaffeine.app"
if [ ! -d "$APP_PATH" ]; then
    echo "error: $APP_PATH not found after build" >&2
    exit 1
fi

mkdir -p release
ZIP_PATH="release/SimpleCaffeine-${VERSION}.zip"
rm -f "$ZIP_PATH"

echo "==> Packaging $ZIP_PATH"
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

SHA=$(shasum -a 256 "$ZIP_PATH" | awk '{print $1}')
SIZE=$(du -h "$ZIP_PATH" | awk '{print $1}')

echo ""
echo "==> Release artifact ready"
echo "    Path:   $ZIP_PATH"
echo "    Size:   $SIZE"
echo "    SHA256: $SHA"
echo ""
echo "Paste into Casks/simple-caffeine.rb:"
echo "  version \"$VERSION\""
echo "  sha256 \"$SHA\""
