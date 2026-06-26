#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting Unsigned IPA Build..."

# 1. Install dependencies
flutter pub get

# 2. Build the iOS application bundle without codesigning
echo "🛠️ Building Runner.app (Unsigned)..."
flutter build ios --release --no-codesign --build-name=1.1.5 --build-number=1

# 3. Create Payload and IPA
echo "📦 Packaging IPA..."
rm -rf Payload DirXplore.ipa
mkdir -p Payload

# Verify Runner.app exists
APP_PATH="build/ios/iphoneos/Runner.app"
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Error: $APP_PATH not found!"
    exit 1
fi

# Use recursive copy with permissions preserved
cp -Rp "$APP_PATH" Payload/

# Zip with symbolic links preserved
zip -r -y DirXplore.ipa Payload

echo "✅ Build Complete: DirXplore.ipa"
