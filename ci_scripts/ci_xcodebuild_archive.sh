#!/bin/bash
# Enhanced xcodebuild archive wrapper with comprehensive debugging
# This script wraps the xcodebuild archive command with additional logging

set -e
set -x  # Enable debug output

echo "═══════════════════════════════════════════════════════════"
echo "🚀 Enhanced xcodebuild archive wrapper"
echo "═══════════════════════════════════════════════════════════"

# Parse arguments or use defaults
WORKSPACE_PATH="${1:-/Volumes/workspace/repository/ios/Runner.xcworkspace}"
SCHEME="${2:-Runner}"
ARCHIVE_PATH="${3:-/Volumes/workspace/build.xcarchive}"
DERIVED_DATA_PATH="${4:-/Volumes/workspace/DerivedData}"
RESULT_BUNDLE_PATH="${5:-/Volumes/workspace/resultbundle.xcresult}"
RESULT_STREAM_PATH="${6:-/Volumes/workspace/tmp/resultBundleStream.json}"

echo "📂 Configuration:"
echo "   Workspace: $WORKSPACE_PATH"
echo "   Scheme: $SCHEME"
echo "   Archive: $ARCHIVE_PATH"
echo "   Derived Data: $DERIVED_DATA_PATH"
echo "   Result Bundle: $RESULT_BUNDLE_PATH"

# Verify workspace exists
if [ ! -d "$WORKSPACE_PATH" ]; then
  echo "❌ ERROR: Workspace not found at $WORKSPACE_PATH"
  exit 1
fi

# Create log directory
LOG_DIR="/tmp/xcodebuild_logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/xcodebuild_archive_${TIMESTAMP}.log"
ERROR_LOG="$LOG_DIR/xcodebuild_errors_${TIMESTAMP}.log"

echo "📝 Log files:"
echo "   Full log: $LOG_FILE"
echo "   Error log: $ERROR_LOG"

# Run xcodebuild with enhanced logging
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "🔨 Running xcodebuild archive..."
echo "═══════════════════════════════════════════════════════════"

# Capture both stdout and stderr
xcodebuild archive \
  -workspace "$WORKSPACE_PATH" \
  -scheme "$SCHEME" \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  -resultBundleVersion 3 \
  -resultBundlePath "$RESULT_BUNDLE_PATH" \
  -resultStreamPath "$RESULT_STREAM_PATH" \
  -IDEPostProgressNotifications=YES \
  CODE_SIGN_IDENTITY=- \
  AD_HOC_CODE_SIGNING_ALLOWED=YES \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=S5URD3P486 \
  COMPILER_INDEX_STORE_ENABLE=NO \
  -hideShellScriptEnvironment \
  -showBuildSettings 2>&1 | tee "$LOG_FILE"

BUILD_EXIT_CODE=${PIPESTATUS[0]}

if [ $BUILD_EXIT_CODE -ne 0 ]; then
  echo ""
  echo "═══════════════════════════════════════════════════════════"
  echo "❌ Build failed with exit code: $BUILD_EXIT_CODE"
  echo "═══════════════════════════════════════════════════════════"
  
  # Extract and display errors
  echo ""
  echo "🔍 ERROR ANALYSIS:"
  echo ""
  
  # Extract errors
  echo "📋 Critical Errors:"
  grep -i "error:" "$LOG_FILE" | grep -v "warning" | head -30 > "$ERROR_LOG" || echo "No errors found"
  cat "$ERROR_LOG"
  
  echo ""
  echo "📋 Warnings:"
  grep -i "warning:" "$LOG_FILE" | head -20 || echo "No warnings found"
  
  echo ""
  echo "📋 Code Signing Issues:"
  grep -iE "code sign|signing|provisioning|certificate|identity" "$LOG_FILE" | head -20 || echo "No code signing issues found"
  
  echo ""
  echo "📋 Missing Files:"
  grep -iE "no such file|not found|missing|cannot find|file not found" "$LOG_FILE" | head -20 || echo "No missing file errors found"
  
  echo ""
  echo "📋 Build Phase Failures:"
  grep -iE "phase.*fail|script.*fail|command.*fail" "$LOG_FILE" | head -20 || echo "No build phase failures found"
  
  echo ""
  echo "📋 PODS_ROOT or Path Issues:"
  grep -iE "PODS_ROOT|path.*not|undefined|unresolved" "$LOG_FILE" | head -20 || echo "No path issues found"
  
  echo ""
  echo "📋 Full log available at: $LOG_FILE"
  echo "📋 Error log available at: $ERROR_LOG"
  
  exit $BUILD_EXIT_CODE
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅ Build completed successfully!"
echo "═══════════════════════════════════════════════════════════"

