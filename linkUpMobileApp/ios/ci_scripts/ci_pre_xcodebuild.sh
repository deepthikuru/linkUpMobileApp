#!/bin/bash

# Xcode Cloud Pre-Build Script for Flutter iOS
# This script runs before Xcode builds the project

set -e
set -x  # Enable debug output to see what's failing

echo "🚀 Starting Xcode Cloud pre-build script..."

# Determine project root
# In Xcode Cloud, CI_WORKSPACE points to the workspace root
# The script is located at ios/ci_scripts/ci_pre_xcodebuild.sh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IOS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$IOS_DIR/.." && pwd)"

echo "📂 Project root: $PROJECT_ROOT"
echo "📂 iOS directory: $IOS_DIR"
echo "📂 Current PATH: $PATH"
echo "📂 HOME: $HOME"

# Source Flutter path if set by post-clone script
if [ -f "$HOME/.flutter_path" ]; then
  source "$HOME/.flutter_path"
  echo "✅ Loaded Flutter path from post-clone script"
fi

# Navigate to project root
cd "$PROJECT_ROOT"

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
  echo "❌ Error: pubspec.yaml not found. Current directory: $(pwd)"
  exit 1
fi

# Find Flutter command (should be installed by ci_post_clone.sh)
FLUTTER_CMD=""
if command -v flutter >/dev/null 2>&1; then
  FLUTTER_CMD="flutter"
  echo "✅ Found Flutter: $(which flutter)"
elif [ -d "$HOME/flutter/bin" ]; then
  FLUTTER_CMD="$HOME/flutter/bin/flutter"
  export PATH="$HOME/flutter/bin:$PATH"
  echo "✅ Found Flutter at: $FLUTTER_CMD"
else
  echo "❌ Flutter not found. Make sure ci_post_clone.sh installed Flutter."
  echo "Current PATH: $PATH"
  exit 1
fi

# Verify Flutter is working
if ! "$FLUTTER_CMD" --version >/dev/null 2>&1; then
  echo "❌ Flutter command is not working: $FLUTTER_CMD"
  "$FLUTTER_CMD" --version || true
  exit 1
fi

echo "📦 Getting Flutter dependencies..."
"$FLUTTER_CMD" pub get

echo "🔧 Precaching iOS artifacts..."
"$FLUTTER_CMD" precache --ios

# Navigate to iOS directory
cd "$IOS_DIR"

# Check if Podfile exists
if [ ! -f "Podfile" ]; then
  echo "❌ Error: Podfile not found in ios directory"
  exit 1
fi

# Clean previous pod installs to ensure fresh state
echo "🧹 Cleaning previous CocoaPods installation..."
rm -rf Pods
rm -rf .symlinks
rm -f Podfile.lock

# Navigate back to project root to generate Flutter plugin symlinks
cd "$PROJECT_ROOT"

# Generate Flutter plugin symlinks by running a config-only build
# This ensures all plugin symlinks are created before pod install
echo "🔗 Generating Flutter plugin symlinks..."
"$FLUTTER_CMD" build ios --config-only --no-codesign || {
  echo "⚠️  Flutter build ios --config-only failed, trying alternative method..."
  # Alternative: Force plugin symlink generation
  cd "$IOS_DIR"
  if [ -d ".symlinks" ]; then
    rm -rf .symlinks
  fi
  cd "$PROJECT_ROOT"
  "$FLUTTER_CMD" pub get
  # Try to trigger symlink generation by checking for plugins
  "$FLUTTER_CMD" precache --ios
}

# Navigate back to iOS directory
cd "$IOS_DIR"

# Verify .symlinks directory exists
if [ ! -d ".symlinks" ]; then
  echo "❌ Error: .symlinks directory not found. Flutter plugin symlinks were not generated."
  echo "Attempting to create symlinks manually..."
  cd "$PROJECT_ROOT"
  "$FLUTTER_CMD" pub get
  cd "$IOS_DIR"
  
  # Check again
  if [ ! -d ".symlinks" ]; then
    echo "❌ Error: .symlinks directory still not found after retry."
    exit 1
  fi
fi

echo "✅ Flutter plugin symlinks verified in .symlinks directory"

# Find pod command
POD_CMD=""
if command -v pod >/dev/null 2>&1; then
  POD_CMD="pod"
  echo "✅ Found CocoaPods: $(which pod)"
elif [ -f "$HOME/.gem/bin/pod" ]; then
  POD_CMD="$HOME/.gem/bin/pod"
  export PATH="$HOME/.gem/bin:$PATH"
  echo "✅ Found CocoaPods at: $POD_CMD"
else
  echo "❌ CocoaPods (pod) not found in PATH"
  echo "Current PATH: $PATH"
  echo "Attempting to find pod in common locations..."
  which -a pod || true
  exit 1
fi

echo "📱 Installing CocoaPods dependencies..."
# Use --repo-update to ensure we have the latest pod specs
"$POD_CMD" install --repo-update

# Verify Pods were installed correctly
if [ ! -d "Pods" ]; then
  echo "❌ Error: Pods directory not found after pod install"
  exit 1
fi

# Verify workspace exists
if [ ! -f "Runner.xcworkspace/contents.xcworkspacedata" ]; then
  echo "❌ Error: Runner.xcworkspace not found or invalid"
  exit 1
fi

echo "✅ Workspace verified: Runner.xcworkspace"
echo "✅ Pre-build script completed successfully!"
