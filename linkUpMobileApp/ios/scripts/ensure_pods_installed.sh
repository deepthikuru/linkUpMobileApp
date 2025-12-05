#!/bin/bash
# Ensure Pods are installed before build
# This script should be added as a "Run Script" build phase BEFORE the Pods check phase

set -e

echo "🔍 Checking if Pods are installed..."

# Get the script directory (should be in ios/scripts/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IOS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$IOS_DIR/.." && pwd)"

echo "📂 iOS directory: $IOS_DIR"
echo "📂 Project root: $PROJECT_ROOT"

# Check if Pods directory exists
if [ ! -d "$IOS_DIR/Pods" ]; then
    echo "⚠️  Pods directory not found. Installing Pods..."
    
    # Navigate to iOS directory
    cd "$IOS_DIR"
    
    # Check if Podfile exists
    if [ ! -f "Podfile" ]; then
        echo "❌ Error: Podfile not found at $IOS_DIR/Podfile"
        exit 1
    fi
    
    # Find pod command
    POD_CMD=""
    if command -v pod >/dev/null 2>&1; then
        POD_CMD="pod"
    elif [ -f "$HOME/.gem/bin/pod" ]; then
        POD_CMD="$HOME/.gem/bin/pod"
        export PATH="$HOME/.gem/bin:$PATH"
    else
        echo "❌ Error: CocoaPods (pod) not found in PATH"
        echo "   Please install CocoaPods or ensure it's in PATH"
        exit 1
    fi
    
    echo "📱 Running: $POD_CMD install"
    "$POD_CMD" install
    
    # Verify Pods were installed
    if [ ! -d "$IOS_DIR/Pods" ]; then
        echo "❌ Error: Pods directory still not found after pod install"
        exit 1
    fi
    
    echo "✅ Pods installed successfully"
else
    echo "✅ Pods directory exists"
fi

# Verify xcfilelist files exist
XC_FILELIST_DIR="$IOS_DIR/Pods/Target Support Files/Pods-Runner"
if [ ! -d "$XC_FILELIST_DIR" ]; then
    echo "⚠️  Warning: Pods-Runner Target Support Files directory not found"
    echo "   This might cause build errors"
else
    echo "✅ Pods-Runner Target Support Files directory found"
    
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
        echo "⚠️  Warning: Missing xcfilelist files:"
        for file in "${MISSING_FILES[@]}"; do
            echo "   - $file"
        done
        echo "   Re-running pod install to regenerate..."
        cd "$IOS_DIR"
        if command -v pod >/dev/null 2>&1; then
            pod install
        fi
    else
        echo "✅ All required xcfilelist files exist"
    fi
fi

echo "✅ Pods check completed"

