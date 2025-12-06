#!/bin/bash

# Local Test Script for Xcode Cloud Build
# This script simulates the Xcode Cloud build process locally
# Run this to test if your build will work in Xcode Cloud

set -e
set -x

# Set UTF-8 encoding (required for CocoaPods)
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}ℹ️  $1${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

log_section() {
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}📋 $1${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════════${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ ERROR: $1${NC}" >&2
}

log_warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}" >&2
}

log_step() {
    echo "  → $1"
}

# Start
log_section "LOCAL XCODE CLOUD BUILD SIMULATION"
echo "This script simulates the Xcode Cloud build process"
echo "Started: $(date)"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"
FLUTTER_PROJECT_DIR="$REPO_ROOT/linkUpMobileApp"
IOS_DIR="$FLUTTER_PROJECT_DIR/ios"

log_section "ENVIRONMENT SETUP"
log_step "Repository root: $REPO_ROOT"
log_step "Flutter project: $FLUTTER_PROJECT_DIR"
log_step "iOS directory: $IOS_DIR"

# Check if we're in the right place
if [ ! -f "$FLUTTER_PROJECT_DIR/pubspec.yaml" ]; then
    log_error "pubspec.yaml not found at $FLUTTER_PROJECT_DIR/pubspec.yaml"
    exit 1
fi

# Step 1: Run post-clone script
log_section "STEP 1: RUNNING POST-CLONE SCRIPT"
if [ -f "$REPO_ROOT/ci_scripts/ci_post_clone.sh" ]; then
    log_step "Running ci_post_clone.sh..."
    bash "$REPO_ROOT/ci_scripts/ci_post_clone.sh"
    log_success "Post-clone script completed"
else
    log_warning "ci_post_clone.sh not found, skipping..."
fi

# Step 2: Run pre-xcodebuild script
log_section "STEP 2: RUNNING PRE-XCODEBUILD SCRIPT"
if [ -f "$REPO_ROOT/ci_scripts/ci_pre_xcodebuild.sh" ]; then
    log_step "Running ci_pre_xcodebuild.sh..."
    bash "$REPO_ROOT/ci_scripts/ci_pre_xcodebuild.sh"
    log_success "Pre-xcodebuild script completed"
else
    log_error "ci_pre_xcodebuild.sh not found!"
    exit 1
fi

# Step 3: Verify critical files
log_section "STEP 3: VERIFYING CRITICAL FILES"

# Check Pods.xcodeproj/project.pbxproj
PODS_PROJECT="$IOS_DIR/Pods/Pods.xcodeproj/project.pbxproj"
log_step "Checking Pods.xcodeproj/project.pbxproj..."
if [ -f "$PODS_PROJECT" ]; then
    log_success "Found: $PODS_PROJECT"
    if grep -q "PBXProject" "$PODS_PROJECT" 2>/dev/null; then
        log_success "File is valid (contains PBXProject)"
        FILE_SIZE=$(wc -c < "$PODS_PROJECT" 2>/dev/null || echo "0")
        log_step "File size: $FILE_SIZE bytes"
    else
        log_error "File exists but is invalid (missing PBXProject)"
        exit 1
    fi
else
    log_error "Missing: $PODS_PROJECT"
    log_error "This will cause 'Module not found' errors"
    exit 1
fi

# Check cloud_firestore
log_step "Checking cloud_firestore pod..."
CLOUDFIRESTORE_PATH="$IOS_DIR/Pods/Target Support Files/cloud_firestore"
if [ -d "$CLOUDFIRESTORE_PATH" ]; then
    log_success "Found cloud_firestore pod"
else
    log_error "Missing cloud_firestore pod at: $CLOUDFIRESTORE_PATH"
    exit 1
fi

# Check Generated.xcconfig
log_step "Checking Flutter/Generated.xcconfig..."
GENERATED_XCCONFIG="$IOS_DIR/Flutter/Generated.xcconfig"
if [ -f "$GENERATED_XCCONFIG" ]; then
    log_success "Found: $GENERATED_XCCONFIG"
else
    log_error "Missing: $GENERATED_XCCONFIG"
    exit 1
fi

# Step 4: Test xcodebuild workspace listing
log_section "STEP 4: TESTING XCODEBUILD WORKSPACE"
WORKSPACE_PATH="$REPO_ROOT/ios/Runner.xcworkspace"
if [ ! -f "$WORKSPACE_PATH/contents.xcworkspacedata" ]; then
    # Try Flutter project workspace
    WORKSPACE_PATH="$IOS_DIR/Runner.xcworkspace"
fi

if [ -f "$WORKSPACE_PATH/contents.xcworkspacedata" ]; then
    log_success "Found workspace at: $WORKSPACE_PATH"
    log_step "Workspace contents:"
    cat "$WORKSPACE_PATH/contents.xcworkspacedata"
    
    # Test xcodebuild -list
    if command -v xcodebuild >/dev/null 2>&1; then
        log_step "Testing xcodebuild -list..."
        cd "$(dirname "$WORKSPACE_PATH")"
        if xcodebuild -list -workspace "$(basename "$WORKSPACE_PATH")" >/dev/null 2>&1; then
            log_success "xcodebuild can read the workspace"
            log_step "Available schemes:"
            xcodebuild -list -workspace "$(basename "$WORKSPACE_PATH")" 2>&1 | grep -A 10 "Schemes:" || true
        else
            log_warning "xcodebuild -list had issues (may still be OK)"
            xcodebuild -list -workspace "$(basename "$WORKSPACE_PATH")" 2>&1 || true
        fi
    else
        log_warning "xcodebuild not found in PATH (skipping workspace test)"
    fi
else
    log_error "Workspace not found at: $WORKSPACE_PATH"
    exit 1
fi

# Step 5: Test archive (optional, can be skipped)
log_section "STEP 5: OPTIONAL - TEST ARCHIVE"
read -p "Do you want to test the archive build? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_step "Testing archive build..."
    cd "$(dirname "$WORKSPACE_PATH")"
    
    # Create a temporary archive path
    ARCHIVE_PATH="/tmp/Runner_$(date +%s).xcarchive"
    
    log_step "Running: xcodebuild archive..."
    if xcodebuild archive \
        -workspace "$(basename "$WORKSPACE_PATH")" \
        -scheme Runner \
        -destination "generic/platform=iOS" \
        -archivePath "$ARCHIVE_PATH" \
        CODE_SIGN_IDENTITY="-" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        AD_HOC_CODE_SIGNING_ALLOWED=YES \
        COMPILER_INDEX_STORE_ENABLE=NO \
        2>&1 | tee /tmp/xcodebuild_archive.log; then
        log_success "Archive build completed successfully"
        log_step "Archive location: $ARCHIVE_PATH"
        
        # Check for the error we're trying to fix
        if grep -q "Module 'cloud_firestore' not found" /tmp/xcodebuild_archive.log; then
            log_error "The cloud_firestore module error still occurs!"
            log_step "Check the log at: /tmp/xcodebuild_archive.log"
            exit 1
        else
            log_success "No 'Module cloud_firestore not found' error detected"
        fi
    else
        log_error "Archive build failed"
        log_step "Check the log at: /tmp/xcodebuild_archive.log"
        
        # Check for specific errors
        if grep -q "Module 'cloud_firestore' not found" /tmp/xcodebuild_archive.log; then
            log_error "The cloud_firestore module error occurred!"
        fi
        
        if grep -q "missing its project.pbxproj file" /tmp/xcodebuild_archive.log; then
            log_error "Pods.xcodeproj/project.pbxproj is missing!"
        fi
        
        exit 1
    fi
else
    log_step "Skipping archive test"
fi

# Final summary
log_section "TEST SUMMARY"
log_success "All verification steps passed!"
log_step "Repository root: $REPO_ROOT"
log_step "Flutter project: $FLUTTER_PROJECT_DIR"
log_step "iOS directory: $IOS_DIR"
log_step "Pods project: $PODS_PROJECT"
log_step "Workspace: $WORKSPACE_PATH"
echo ""
log_info "If all checks passed, your build should work in Xcode Cloud"
log_info "If any checks failed, fix the issues before pushing to Xcode Cloud"
echo ""

