#!/bin/bash
# This script fixes PODS_ROOT if it resolves incorrectly when building from workspace
# It checks if PODS_ROOT points to a valid directory, and if not, tries alternative paths

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Try to find Pods directory
if [ -d "$SCRIPT_DIR/Pods" ]; then
    # If Pods exists in the same directory as this script (workspace location)
    export PODS_ROOT="$SCRIPT_DIR/Pods"
elif [ -d "$SCRIPT_DIR/../linkUpMobileApp/ios/Pods" ]; then
    # If Pods exists in the Flutter project location
    export PODS_ROOT="$(cd "$SCRIPT_DIR/../linkUpMobileApp/ios" && pwd)/Pods"
elif [ -d "$SCRIPT_DIR/../../linkUpMobileApp/ios/Pods" ]; then
    # Alternative path resolution
    export PODS_ROOT="$(cd "$SCRIPT_DIR/../../linkUpMobileApp/ios" && pwd)/Pods"
fi

# Verify PODS_ROOT is set and valid
if [ -z "$PODS_ROOT" ] || [ ! -d "$PODS_ROOT" ]; then
    echo "⚠️  WARNING: Could not determine PODS_ROOT"
    echo "   SCRIPT_DIR: $SCRIPT_DIR"
    echo "   Attempted paths:"
    echo "     - $SCRIPT_DIR/Pods"
    echo "     - $SCRIPT_DIR/../linkUpMobileApp/ios/Pods"
    echo "     - $SCRIPT_DIR/../../linkUpMobileApp/ios/Pods"
else
    echo "✅ PODS_ROOT resolved to: $PODS_ROOT"
    # Verify xcfilelist files exist
    XCFILELIST_TEST="$PODS_ROOT/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-input-files.xcfilelist"
    if [ -f "$XCFILELIST_TEST" ]; then
        echo "✅ xcfilelist files accessible at PODS_ROOT"
    else
        echo "⚠️  WARNING: xcfilelist files not found at PODS_ROOT"
    fi
fi
