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
echo "📍 Current directory before pod install: $(pwd)"
echo "📍 IOS_DIR variable: $IOS_DIR"
echo "📍 Checking if we're in the right directory..."
if [ "$(pwd)" != "$IOS_DIR" ]; then
  echo "⚠️  Warning: Not in iOS directory, changing to $IOS_DIR"
  cd "$IOS_DIR"
  echo "📍 Changed to: $(pwd)"
fi

# Use --repo-update to ensure we have the latest pod specs
echo "🔧 Running: $POD_CMD install --repo-update"
"$POD_CMD" install --repo-update
POD_INSTALL_EXIT_CODE=$?
echo "📍 Pod install exit code: $POD_INSTALL_EXIT_CODE"

# Verify Pods were installed correctly
echo "🔍 Verifying Pods installation..."
echo "📍 Current directory: $(pwd)"
echo "📍 Checking for Pods directory..."
if [ ! -d "Pods" ]; then
  echo "❌ Error: Pods directory not found after pod install"
  echo "📍 Listing current directory contents:"
  ls -la || echo "Failed to list directory"
  echo "📍 Checking if Pods exists at absolute path: $IOS_DIR/Pods"
  if [ -d "$IOS_DIR/Pods" ]; then
    echo "⚠️  Pods directory exists at $IOS_DIR/Pods but not in current directory"
    echo "📍 Changing to $IOS_DIR"
    cd "$IOS_DIR"
  else
    echo "❌ Pods directory does not exist at $IOS_DIR/Pods either"
    exit 1
  fi
else
  echo "✅ Pods directory found at: $(pwd)/Pods"
fi

# CRITICAL: Verify xcfilelist files exist
# These files are required by Xcode for the build process
echo "🔍 Verifying xcfilelist files..."
echo "📍 Current directory: $(pwd)"
echo "📍 IOS_DIR: $IOS_DIR"

# Determine the correct path to Pods directory
if [ -d "Pods" ]; then
  PODS_DIR="$(pwd)/Pods"
  echo "✅ Found Pods directory at: $PODS_DIR"
elif [ -d "$IOS_DIR/Pods" ]; then
  PODS_DIR="$IOS_DIR/Pods"
  echo "✅ Found Pods directory at: $PODS_DIR"
else
  echo "❌ Error: Cannot find Pods directory"
  echo "📍 Searched in: $(pwd)/Pods"
  echo "📍 Searched in: $IOS_DIR/Pods"
  exit 1
fi

XC_FILELIST_DIR="$PODS_DIR/Target Support Files/Pods-Runner"
echo "📍 Checking xcfilelist directory: $XC_FILELIST_DIR"

if [ ! -d "$XC_FILELIST_DIR" ]; then
  echo "❌ Error: Pods-Runner Target Support Files directory not found at $XC_FILELIST_DIR"
  echo "📍 Listing Pods directory structure:"
  ls -la "$PODS_DIR" || echo "Cannot list Pods directory"
  if [ -d "$PODS_DIR/Target Support Files" ]; then
    echo "📍 Listing Target Support Files directory:"
    ls -la "$PODS_DIR/Target Support Files/" || echo "Cannot list Target Support Files"
  else
    echo "❌ Target Support Files directory does not exist"
  fi
  exit 1
fi

echo "✅ xcfilelist directory found at: $XC_FILELIST_DIR"

# Check for required xcfilelist files
echo "🔍 Checking for required xcfilelist files..."
REQUIRED_FILES=(
  "Pods-Runner-frameworks-Release-input-files.xcfilelist"
  "Pods-Runner-frameworks-Release-output-files.xcfilelist"
  "Pods-Runner-resources-Release-input-files.xcfilelist"
  "Pods-Runner-resources-Release-output-files.xcfilelist"
)

echo "📍 Listing all files in xcfilelist directory:"
ls -la "$XC_FILELIST_DIR" || echo "Cannot list xcfilelist directory"

MISSING_FILES=()
for file in "${REQUIRED_FILES[@]}"; do
  FILE_PATH="$XC_FILELIST_DIR/$file"
  echo "📍 Checking for: $file"
  if [ ! -f "$FILE_PATH" ]; then
    echo "❌ Missing: $file"
    MISSING_FILES+=("$file")
  else
    echo "✅ Found: $file"
  fi
done

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
  echo "❌ Error: Missing required xcfilelist files:"
  for file in "${MISSING_FILES[@]}"; do
    echo "   - $file"
  done
  echo "📍 Full directory listing:"
  ls -la "$XC_FILELIST_DIR" || echo "Directory does not exist"
  exit 1
fi

echo "✅ All required xcfilelist files verified"

# CRITICAL: Verify PODS_ROOT will be set correctly
# Check that the xcconfig files define PODS_ROOT
echo "🔍 Verifying PODS_ROOT in xcconfig files..."
XCCONFIG_FILE="$PODS_DIR/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig"
echo "📍 Checking xcconfig file: $XCCONFIG_FILE"

if [ -f "$XCCONFIG_FILE" ]; then
  echo "✅ Found xcconfig file"
  echo "📍 Checking for PODS_ROOT definition..."
  if ! grep -q "PODS_ROOT" "$XCCONFIG_FILE"; then
    echo "❌ Error: PODS_ROOT not found in Pods-Runner.release.xcconfig"
    echo "📍 File contents:"
    cat "$XCCONFIG_FILE" || echo "Cannot read file"
    exit 1
  fi
  echo "✅ PODS_ROOT is defined in Pods-Runner.release.xcconfig"
  echo "📍 PODS_ROOT value from xcconfig:"
  grep "PODS_ROOT" "$XCCONFIG_FILE" || echo "Cannot extract PODS_ROOT"
else
  echo "❌ Error: Pods-Runner.release.xcconfig not found at $XCCONFIG_FILE"
  echo "📍 Searching for xcconfig files:"
  find "$PODS_DIR" -name "*.xcconfig" -type f 2>/dev/null | head -10 || echo "Cannot search for xcconfig files"
  exit 1
fi

# Verify Generated.xcconfig is still accessible
echo "🔍 Verifying Flutter/Generated.xcconfig still exists..."
GENERATED_XCCONFIG="$IOS_DIR/Flutter/Generated.xcconfig"
echo "📍 Checking: $GENERATED_XCCONFIG"
if [ ! -f "$GENERATED_XCCONFIG" ]; then
  echo "❌ Error: Flutter/Generated.xcconfig disappeared after pod install"
  echo "📍 Listing Flutter directory:"
  ls -la "$IOS_DIR/Flutter/" || echo "Flutter directory does not exist"
  exit 1
fi
echo "✅ Flutter/Generated.xcconfig verified at: $GENERATED_XCCONFIG"

# Verify workspace exists (both at root and in Flutter project)
echo "🔍 Verifying workspace configuration..."
echo "📍 Checking root workspace: $REPO_ROOT/ios/Runner.xcworkspace"
if [ ! -f "$REPO_ROOT/ios/Runner.xcworkspace/contents.xcworkspacedata" ]; then
  echo "⚠️  Warning: Root workspace not found at $REPO_ROOT/ios/Runner.xcworkspace"
  echo "📍 This might be expected if workspace is only in Flutter project directory"
else
  echo "✅ Root workspace found"
fi

echo "📍 Checking Flutter project workspace: $IOS_DIR/Runner.xcworkspace"
if [ ! -f "$IOS_DIR/Runner.xcworkspace/contents.xcworkspacedata" ]; then
  echo "❌ Error: Flutter project workspace not found at $IOS_DIR/Runner.xcworkspace"
  echo "📍 Listing iOS directory:"
  ls -la "$IOS_DIR" | grep -E "workspace|xcworkspace" || echo "No workspace files found"
  exit 1
fi
echo "✅ Flutter project workspace found"

# Final summary
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅ PRE-BUILD SCRIPT SUMMARY"
echo "═══════════════════════════════════════════════════════════"
echo "📍 Repository root: $REPO_ROOT"
echo "📍 Flutter project: $FLUTTER_PROJECT_DIR"
echo "📍 iOS directory: $IOS_DIR"
echo "📍 Pods directory: $PODS_DIR"
echo "📍 Generated.xcconfig: $GENERATED_XCCONFIG"
echo "📍 Workspace: $IOS_DIR/Runner.xcworkspace"
echo "═══════════════════════════════════════════════════════════"
echo "✅ Pre-build script completed successfully!"
echo "═══════════════════════════════════════════════════════════"

