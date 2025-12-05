#!/bin/bash

# Xcode Cloud Pre-Build Script
# This script runs before Xcode builds the project

set -e
set -x  # Enable debug output to see what's failing

echo "🚀 Starting Xcode Cloud pre-build script..."

# Determine project root
# In Xcode Cloud, CI_WORKSPACE points to the workspace root
# The script is located at ci_scripts/ci_pre_xcodebuild.sh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FLUTTER_PROJECT_DIR="$REPO_ROOT/linkUpMobileApp"
IOS_DIR="$FLUTTER_PROJECT_DIR/ios"

echo "📂 Repository root: $REPO_ROOT"
echo "📂 Flutter project directory: $FLUTTER_PROJECT_DIR"
echo "📂 iOS directory: $IOS_DIR"
echo "📂 Current PATH: $PATH"
echo "📂 HOME: $HOME"

# Source Flutter path if set by post-clone script
if [ -f "$HOME/.flutter_path" ]; then
  source "$HOME/.flutter_path"
  echo "✅ Loaded Flutter path from post-clone script"
fi

# Navigate to Flutter project root
cd "$FLUTTER_PROJECT_DIR"

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
cd "$FLUTTER_PROJECT_DIR"

# Generate Flutter plugin symlinks by running a config-only build
# This ensures all plugin symlinks are created before pod install
# This also generates Flutter/Generated.xcconfig which is required for the build
echo "🔗 Generating Flutter plugin symlinks and configuration files..."
"$FLUTTER_CMD" build ios --config-only --no-codesign || {
  echo "⚠️  Flutter build ios --config-only failed, trying alternative method..."
  # Alternative: Force plugin symlink generation
  cd "$IOS_DIR"
  if [ -d ".symlinks" ]; then
    rm -rf .symlinks
  fi
  cd "$FLUTTER_PROJECT_DIR"
  "$FLUTTER_CMD" pub get
  # Try to trigger symlink generation by checking for plugins
  "$FLUTTER_CMD" precache --ios
}

# Navigate back to iOS directory
cd "$IOS_DIR"

# CRITICAL: Verify Flutter/Generated.xcconfig exists
# This file is required by Release.xcconfig and Debug.xcconfig
if [ ! -f "$IOS_DIR/Flutter/Generated.xcconfig" ]; then
  echo "❌ Error: Flutter/Generated.xcconfig not found after build ios --config-only"
  echo "Attempting to generate manually..."
  cd "$FLUTTER_PROJECT_DIR"
  "$FLUTTER_CMD" pub get
  "$FLUTTER_CMD" precache --ios
  cd "$IOS_DIR"
  
  if [ ! -f "$IOS_DIR/Flutter/Generated.xcconfig" ]; then
    echo "❌ Error: Flutter/Generated.xcconfig still not found"
    echo "Current directory: $(pwd)"
    echo "Listing Flutter directory:"
    ls -la "$IOS_DIR/Flutter/" || echo "Flutter directory does not exist"
    exit 1
  fi
fi

echo "✅ Flutter/Generated.xcconfig verified at $IOS_DIR/Flutter/Generated.xcconfig"

# Verify .symlinks directory exists
if [ ! -d ".symlinks" ]; then
  echo "❌ Error: .symlinks directory not found. Flutter plugin symlinks were not generated."
  echo "Attempting to create symlinks manually..."
  cd "$FLUTTER_PROJECT_DIR"
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

# CRITICAL: Verify xcfilelist files exist
# These files are required by Xcode for the build process
XC_FILELIST_DIR="$IOS_DIR/Pods/Target Support Files/Pods-Runner"
if [ ! -d "$XC_FILELIST_DIR" ]; then
  echo "❌ Error: Pods-Runner Target Support Files directory not found at $XC_FILELIST_DIR"
  echo "Listing Pods/Target Support Files directory:"
  ls -la "$IOS_DIR/Pods/Target Support Files/" || echo "Directory does not exist"
  exit 1
fi

# Check for required xcfilelist files
REQUIRED_FILES=(
  "Pods-Runner-frameworks-Release-input-files.xcfilelist"
  "Pods-Runner-frameworks-Release-output-files.xcfilelist"
  "Pods-Runner-resources-Release-input-files.xcfilelist"
  "Pods-Runner-resources-Release-output-files.xcfilelist"
)

MISSING_FILES=()
for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$XC_FILELIST_DIR/$file" ]; then
    MISSING_FILES+=("$file")
  fi
done

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
  echo "❌ Error: Missing required xcfilelist files:"
  for file in "${MISSING_FILES[@]}"; do
    echo "   - $file"
  done
  echo "Listing directory contents:"
  ls -la "$XC_FILELIST_DIR" || echo "Directory does not exist"
  exit 1
fi

echo "✅ All required xcfilelist files verified"

# Verify Generated.xcconfig is still accessible
if [ ! -f "$IOS_DIR/Flutter/Generated.xcconfig" ]; then
  echo "❌ Error: Flutter/Generated.xcconfig disappeared after pod install"
  exit 1
fi

# Verify workspace exists (both at root and in Flutter project)
if [ ! -f "$REPO_ROOT/ios/Runner.xcworkspace/contents.xcworkspacedata" ]; then
  echo "❌ Error: Root workspace not found at $REPO_ROOT/ios/Runner.xcworkspace"
  exit 1
fi

if [ ! -f "$IOS_DIR/Runner.xcworkspace/contents.xcworkspacedata" ]; then
  echo "❌ Error: Flutter project workspace not found at $IOS_DIR/Runner.xcworkspace"
  exit 1
fi

echo "✅ Workspace verified: Runner.xcworkspace"
echo "✅ Pre-build script completed successfully!"

