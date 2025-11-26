#!/bin/sh

# Xcode Cloud Pre-Build Script for Flutter iOS
# This script runs before Xcode builds the project

set -e

echo "🚀 Starting Xcode Cloud pre-build script..."

# Determine project root
# In Xcode Cloud, CI_WORKSPACE points to the workspace root
# The script is located at ios/ci_scripts/ci_pre_xcodebuild.sh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IOS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$IOS_DIR/.." && pwd)"

echo "📂 Project root: $PROJECT_ROOT"
echo "📂 iOS directory: $IOS_DIR"

# Navigate to project root
cd "$PROJECT_ROOT"

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
  echo "❌ Error: pubspec.yaml not found. Current directory: $(pwd)"
  exit 1
fi

echo "📦 Getting Flutter dependencies..."
flutter pub get

echo "🔧 Generating Flutter files..."
flutter precache --ios

# Navigate to iOS directory
cd "$IOS_DIR"

# Check if Podfile exists
if [ ! -f "Podfile" ]; then
  echo "❌ Error: Podfile not found in ios directory"
  exit 1
fi

echo "📱 Installing CocoaPods dependencies..."
# Use --repo-update to ensure we have the latest pod specs
pod install --repo-update

echo "✅ Pre-build script completed successfully!"

