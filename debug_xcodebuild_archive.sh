#!/bin/bash
# debug_xcodebuild_archive.sh
# Enhanced xcodebuild archive command with comprehensive debugging

set -e
set -x  # Enable debug output

echo "═══════════════════════════════════════════════════════════"
echo "🔍 DEBUG: Starting xcodebuild archive with enhanced logging"
echo "═══════════════════════════════════════════════════════════"

# Set paths (adjust these based on your CI environment)
WORKSPACE_PATH="${1:-/Volumes/workspace/repository/ios/Runner.xcworkspace}"
SCHEME="${2:-Runner}"
ARCHIVE_PATH="${3:-/Volumes/workspace/build.xcarchive}"
DERIVED_DATA_PATH="${4:-/Volumes/workspace/DerivedData}"
RESULT_BUNDLE_PATH="${5:-/Volumes/workspace/resultbundle.xcresult}"

echo "📂 Workspace path: $WORKSPACE_PATH"
echo "📂 Archive path: $ARCHIVE_PATH"
echo "📂 Derived data path: $DERIVED_DATA_PATH"
echo "📂 Result bundle path: $RESULT_BUNDLE_PATH"

# Verify workspace exists
echo ""
echo "🔍 DEBUG: Verifying workspace structure..."
if [ ! -d "$WORKSPACE_PATH" ]; then
    echo "❌ ERROR: Workspace not found at $WORKSPACE_PATH"
    echo "📂 Listing parent directory:"
    ls -la "$(dirname "$WORKSPACE_PATH")" || echo "Parent directory does not exist"
    exit 1
fi

echo "✅ Workspace directory exists"

# Check workspace contents
if [ -f "$WORKSPACE_PATH/contents.xcworkspacedata" ]; then
    echo "✅ Workspace contents file found"
    echo "📄 Workspace contents:"
    cat "$WORKSPACE_PATH/contents.xcworkspacedata"
else
    echo "❌ ERROR: Workspace contents file not found"
    exit 1
fi

# Determine repository root
REPO_ROOT="$(cd "$(dirname "$WORKSPACE_PATH")/.." && pwd)"
FLUTTER_PROJECT_DIR="$REPO_ROOT/linkUpMobileApp"
FLUTTER_IOS_DIR="$FLUTTER_PROJECT_DIR/ios"

echo ""
echo "🔍 DEBUG: Verifying Flutter project structure..."
echo "📂 Repository root: $REPO_ROOT"
echo "📂 Flutter project: $FLUTTER_PROJECT_DIR"
echo "📂 Flutter iOS: $FLUTTER_IOS_DIR"

# Verify referenced projects exist
echo ""
echo "🔍 DEBUG: Verifying referenced projects..."

RUNNER_PROJECT="$FLUTTER_IOS_DIR/Runner.xcodeproj"
PODS_PROJECT="$FLUTTER_IOS_DIR/Pods/Pods.xcodeproj"

if [ ! -d "$RUNNER_PROJECT" ]; then
    echo "❌ ERROR: Runner.xcodeproj not found at $RUNNER_PROJECT"
    echo "📂 Listing Flutter iOS directory:"
    ls -la "$FLUTTER_IOS_DIR" || echo "Directory does not exist"
    exit 1
fi
echo "✅ Runner.xcodeproj found at $RUNNER_PROJECT"

if [ ! -d "$PODS_PROJECT" ]; then
    echo "❌ ERROR: Pods.xcodeproj not found at $PODS_PROJECT"
    echo "📂 Listing Pods directory:"
    ls -la "$FLUTTER_IOS_DIR/Pods" || echo "Pods directory does not exist"
    echo ""
    echo "⚠️  WARNING: Pods not installed. You may need to run 'pod install' first."
    exit 1
fi
echo "✅ Pods.xcodeproj found at $PODS_PROJECT"

# Verify Flutter configuration
echo ""
echo "🔍 DEBUG: Verifying Flutter configuration..."

GENERATED_XCCONFIG="$FLUTTER_IOS_DIR/Flutter/Generated.xcconfig"
if [ ! -f "$GENERATED_XCCONFIG" ]; then
    echo "❌ ERROR: Flutter/Generated.xcconfig not found at $GENERATED_XCCONFIG"
    echo "📂 Listing Flutter directory:"
    ls -la "$FLUTTER_IOS_DIR/Flutter" || echo "Flutter directory does not exist"
    exit 1
fi
echo "✅ Generated.xcconfig found"
echo "📄 Generated.xcconfig contents:"
cat "$GENERATED_XCCONFIG"

# Verify Pods configuration
echo ""
echo "🔍 DEBUG: Verifying Pods configuration..."

PODS_XCCONFIG="$FLUTTER_IOS_DIR/Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig"
if [ ! -f "$PODS_XCCONFIG" ]; then
    echo "❌ ERROR: Pods-Runner.release.xcconfig not found at $PODS_XCCONFIG"
    echo "📂 Searching for xcconfig files:"
    find "$FLUTTER_IOS_DIR/Pods" -name "*.xcconfig" -type f 2>/dev/null | head -5 || echo "No xcconfig files found"
    exit 1
fi
echo "✅ Pods-Runner.release.xcconfig found"
echo "📄 Checking PODS_ROOT in xcconfig:"
grep "PODS_ROOT" "$PODS_XCCONFIG" || echo "⚠️  WARNING: PODS_ROOT not found in xcconfig"

# Verify xcfilelist files
echo ""
echo "🔍 DEBUG: Verifying xcfilelist files..."

XC_FILELIST_DIR="$FLUTTER_IOS_DIR/Pods/Target Support Files/Pods-Runner"
REQUIRED_FILES=(
    "Pods-Runner-frameworks-Release-input-files.xcfilelist"
    "Pods-Runner-frameworks-Release-output-files.xcfilelist"
    "Pods-Runner-resources-Release-input-files.xcfilelist"
    "Pods-Runner-resources-Release-output-files.xcfilelist"
)

for file in "${REQUIRED_FILES[@]}"; do
    FILE_PATH="$XC_FILELIST_DIR/$file"
    if [ ! -f "$FILE_PATH" ]; then
        echo "❌ ERROR: Missing required file: $file"
        echo "📂 Listing xcfilelist directory:"
        ls -la "$XC_FILELIST_DIR" || echo "Directory does not exist"
        exit 1
    fi
    echo "✅ Found: $file"
done

# Check for Flutter symlinks
echo ""
echo "🔍 DEBUG: Verifying Flutter plugin symlinks..."

if [ ! -d "$FLUTTER_IOS_DIR/.symlinks" ]; then
    echo "⚠️  WARNING: .symlinks directory not found. Flutter plugins may not be properly linked."
    echo "   This might cause build failures if plugins are used."
else
    echo "✅ .symlinks directory found"
    echo "📂 Listing symlinks:"
    ls -la "$FLUTTER_IOS_DIR/.symlinks" | head -10 || echo "Cannot list symlinks"
fi

# Verify scheme exists
echo ""
echo "🔍 DEBUG: Verifying scheme exists..."

SCHEME_PATH="$FLUTTER_IOS_DIR/Runner.xcodeproj/xcshareddata/xcschemes/${SCHEME}.xcscheme"
if [ ! -f "$SCHEME_PATH" ]; then
    echo "⚠️  WARNING: Scheme file not found at $SCHEME_PATH"
    echo "📂 Listing available schemes:"
    find "$FLUTTER_IOS_DIR" -name "*.xcscheme" -type f 2>/dev/null || echo "No schemes found"
else
    echo "✅ Scheme file found: $SCHEME_PATH"
fi

# Check code signing
echo ""
echo "🔍 DEBUG: Verifying code signing configuration..."

# List available identities
echo "📋 Available code signing identities:"
security find-identity -v -p codesigning 2>/dev/null | head -5 || echo "⚠️  Cannot list code signing identities"

# Clean derived data
echo ""
echo "🧹 Cleaning derived data..."
rm -rf "$DERIVED_DATA_PATH" || echo "⚠️  Could not clean derived data (may not exist)"
mkdir -p "$DERIVED_DATA_PATH" || echo "⚠️  Could not create derived data directory"

# Clean archive path
echo ""
echo "🧹 Cleaning archive path..."
rm -rf "$ARCHIVE_PATH" || echo "⚠️  Could not clean archive path (may not exist)"
mkdir -p "$(dirname "$ARCHIVE_PATH")" || echo "⚠️  Could not create archive directory"

# Now run xcodebuild with maximum verbosity
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "🚀 Starting xcodebuild archive..."
echo "═══════════════════════════════════════════════════════════"

# Create a log file
LOG_FILE="/tmp/xcodebuild_archive_$(date +%s).log"
echo "📝 Log file: $LOG_FILE"

# Run xcodebuild with all debug options
xcodebuild archive \
    -workspace "$WORKSPACE_PATH" \
    -scheme "$SCHEME" \
    -destination "generic/platform=iOS" \
    -archivePath "$ARCHIVE_PATH" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    -resultBundleVersion 3 \
    -resultBundlePath "$RESULT_BUNDLE_PATH" \
    -IDEPostProgressNotifications=YES \
    CODE_SIGN_IDENTITY=- \
    AD_HOC_CODE_SIGNING_ALLOWED=YES \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM=S5URD3P486 \
    COMPILER_INDEX_STORE_ENABLE=NO \
    -hideShellScriptEnvironment \
    -showBuildSettings \
    2>&1 | tee "$LOG_FILE"

BUILD_EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📊 Build completed with exit code: $BUILD_EXIT_CODE"
echo "═══════════════════════════════════════════════════════════"

if [ $BUILD_EXIT_CODE -ne 0 ]; then
    echo "❌ Build failed with exit code $BUILD_EXIT_CODE"
    echo ""
    echo "🔍 DEBUG: Analyzing error output..."
    
    # Extract common error patterns
    echo ""
    echo "📋 Error summary from log:"
    grep -i "error:" "$LOG_FILE" | head -20 || echo "No 'error:' patterns found"
    
    echo ""
    echo "📋 Warning summary from log:"
    grep -i "warning:" "$LOG_FILE" | head -20 || echo "No 'warning:' patterns found"
    
    echo ""
    echo "📋 Failed commands from log:"
    grep -i "failed\|failure" "$LOG_FILE" | head -20 || echo "No failure patterns found"
    
    echo ""
    echo "📋 Code signing errors:"
    grep -i "code sign\|signing\|provisioning\|certificate" "$LOG_FILE" | head -20 || echo "No code signing errors found"
    
    echo ""
    echo "📋 Missing file errors:"
    grep -i "no such file\|not found\|missing\|cannot find" "$LOG_FILE" | head -20 || echo "No missing file errors found"
    
    echo ""
    echo "📋 Full log file available at: $LOG_FILE"
    echo "   You can review the complete output there."
fi

exit $BUILD_EXIT_CODE

