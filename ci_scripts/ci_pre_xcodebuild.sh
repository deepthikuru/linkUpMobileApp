#!/bin/bash

# Xcode Cloud Pre-Build Script
# This script runs before Xcode builds the project

set -e
set -x  # Enable debug output to see what's failing

# Logging functions for better visibility in Xcode Cloud
log_info() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "ℹ️  $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

log_section() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo "📋 $1"
    echo "═══════════════════════════════════════════════════════════════════════════════"
}

log_success() {
    echo "✅ $1"
}

log_error() {
    echo "❌ ERROR: $1" >&2
}

log_warning() {
    echo "⚠️  WARNING: $1" >&2
}

log_step() {
    echo "  → $1"
}

# Start script with clear header
log_section "XCODE CLOUD PRE-BUILD SCRIPT"
echo "Script: ci_pre_xcodebuild.sh"
echo "Started: $(date)"
echo ""

# Determine project root
# In Xcode Cloud, CI_WORKSPACE points to the workspace root
# The script is located at ci_scripts/ci_pre_xcodebuild.sh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ "$SCRIPT_DIR" == */ci_scripts ]]; then
    REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
else
    # Fallback: try CI_WORKSPACE if available (Xcode Cloud environment variable)
    REPO_ROOT="${CI_WORKSPACE:-$(cd "$SCRIPT_DIR/.." && pwd)}"
fi
FLUTTER_PROJECT_DIR="$REPO_ROOT/linkUpMobileApp"
IOS_DIR="$FLUTTER_PROJECT_DIR/ios"

log_section "ENVIRONMENT SETUP"
log_step "Repository root: $REPO_ROOT"
log_step "Flutter project directory: $FLUTTER_PROJECT_DIR"
log_step "iOS directory: $IOS_DIR"
log_step "Current working directory: $(pwd)"
log_step "HOME: $HOME"
log_step "PATH: $PATH"

# Source Flutter path if set by post-clone script
log_step "Checking for Flutter path from post-clone script..."
if [ -f "$HOME/.flutter_path" ]; then
  source "$HOME/.flutter_path"
  log_success "Loaded Flutter path from post-clone script"
else
  log_warning "Flutter path file not found (this is OK if post-clone script didn't run)"
fi

# Navigate to Flutter project root
cd "$FLUTTER_PROJECT_DIR"

# Check if we're in the right directory
log_step "Verifying Flutter project structure..."
if [ ! -f "pubspec.yaml" ]; then
  log_error "pubspec.yaml not found. Current directory: $(pwd)"
  log_error "Expected Flutter project at: $FLUTTER_PROJECT_DIR"
  exit 1
fi
log_success "Found pubspec.yaml at: $(pwd)/pubspec.yaml"

# Find Flutter command (should be installed by ci_post_clone.sh)
log_section "FLUTTER SETUP"
log_step "Locating Flutter command..."
FLUTTER_CMD=""
if command -v flutter >/dev/null 2>&1; then
  FLUTTER_CMD="flutter"
  log_success "Found Flutter in PATH: $(which flutter)"
elif [ -d "$HOME/flutter/bin" ]; then
  FLUTTER_CMD="$HOME/flutter/bin/flutter"
  export PATH="$HOME/flutter/bin:$PATH"
  log_success "Found Flutter at: $FLUTTER_CMD"
else
  log_error "Flutter not found. Make sure ci_post_clone.sh installed Flutter."
  log_error "Current PATH: $PATH"
  log_error "Checked locations:"
  log_error "  - PATH: $(which flutter 2>&1 || echo 'not found')"
  log_error "  - $HOME/flutter/bin/flutter: $([ -f "$HOME/flutter/bin/flutter" ] && echo 'exists' || echo 'not found')"
  exit 1
fi

# Verify Flutter is working
log_step "Verifying Flutter installation..."
if ! "$FLUTTER_CMD" --version >/dev/null 2>&1; then
  log_error "Flutter command is not working: $FLUTTER_CMD"
  "$FLUTTER_CMD" --version || true
  exit 1
fi
FLUTTER_VERSION=$("$FLUTTER_CMD" --version | head -1)
log_success "Flutter is working: $FLUTTER_VERSION"

log_section "FLUTTER DEPENDENCIES"
log_step "Getting Flutter dependencies (flutter pub get)..."
if "$FLUTTER_CMD" pub get; then
  log_success "Flutter dependencies retrieved successfully"
else
  log_error "Failed to get Flutter dependencies"
  exit 1
fi

log_step "Precaching iOS artifacts (flutter precache --ios)..."
if "$FLUTTER_CMD" precache --ios; then
  log_success "iOS artifacts precached successfully"
else
  log_warning "iOS precache had issues (continuing anyway)"
fi

# Navigate to iOS directory
cd "$IOS_DIR"

log_section "COCOAPODS SETUP"
log_step "Verifying Podfile exists..."
if [ ! -f "Podfile" ]; then
  log_error "Podfile not found in ios directory: $IOS_DIR"
  log_error "Current directory: $(pwd)"
  exit 1
fi
log_success "Podfile found at: $IOS_DIR/Podfile"

# Clean previous pod installs to ensure fresh state
log_step "Cleaning previous CocoaPods installation..."
log_step "  Removing: Pods/"
rm -rf Pods 2>/dev/null || true
log_step "  Removing: .symlinks/"
rm -rf .symlinks 2>/dev/null || true
log_step "  Removing: Podfile.lock"
rm -f Podfile.lock 2>/dev/null || true
log_success "Previous CocoaPods installation cleaned"

# Navigate back to project root to generate Flutter plugin symlinks
cd "$FLUTTER_PROJECT_DIR"

# Generate Flutter plugin symlinks by running a config-only build
# This ensures all plugin symlinks are created before pod install
# This also generates Flutter/Generated.xcconfig which is required for the build
log_section "FLUTTER CONFIGURATION GENERATION"
log_step "Generating Flutter plugin symlinks and configuration files..."
log_step "Running: flutter build ios --config-only --no-codesign"
if "$FLUTTER_CMD" build ios --config-only --no-codesign; then
  log_success "Flutter configuration generated successfully"
else
  log_warning "Flutter build ios --config-only failed, trying alternative method..."
  # Alternative: Force plugin symlink generation
  cd "$IOS_DIR"
  if [ -d ".symlinks" ]; then
    rm -rf .symlinks
  fi
  cd "$FLUTTER_PROJECT_DIR"
  "$FLUTTER_CMD" pub get
  # Try to trigger symlink generation by checking for plugins
  "$FLUTTER_CMD" precache --ios
  log_warning "Used alternative method to generate configuration"
fi

# Navigate back to iOS directory
cd "$IOS_DIR"

# CRITICAL: Verify Flutter/Generated.xcconfig exists
# This file is required by Release.xcconfig and Debug.xcconfig
log_step "Verifying Flutter/Generated.xcconfig exists..."
if [ ! -f "$IOS_DIR/Flutter/Generated.xcconfig" ]; then
  log_error "Flutter/Generated.xcconfig not found after build ios --config-only"
  log_step "Attempting to generate manually..."
  cd "$FLUTTER_PROJECT_DIR"
  "$FLUTTER_CMD" pub get
  "$FLUTTER_CMD" precache --ios
  cd "$IOS_DIR"
  
  if [ ! -f "$IOS_DIR/Flutter/Generated.xcconfig" ]; then
    log_error "Flutter/Generated.xcconfig still not found"
    log_error "Current directory: $(pwd)"
    log_error "Expected at: $IOS_DIR/Flutter/Generated.xcconfig"
    log_error "Listing Flutter directory:"
    ls -la "$IOS_DIR/Flutter/" || log_error "Flutter directory does not exist"
    exit 1
  fi
fi
log_success "Flutter/Generated.xcconfig verified at $IOS_DIR/Flutter/Generated.xcconfig"

# Verify .symlinks directory exists
log_step "Verifying .symlinks directory exists..."
if [ ! -d ".symlinks" ]; then
  log_error ".symlinks directory not found. Flutter plugin symlinks were not generated."
  log_step "Attempting to create symlinks manually..."
  cd "$FLUTTER_PROJECT_DIR"
  "$FLUTTER_CMD" pub get
  cd "$IOS_DIR"
  
  # Check again
  if [ ! -d ".symlinks" ]; then
    log_error ".symlinks directory still not found after retry."
    log_error "Current directory: $(pwd)"
    log_error "Expected at: $IOS_DIR/.symlinks"
    exit 1
  fi
fi
log_success "Flutter plugin symlinks verified in .symlinks directory"

# Find pod command
log_step "Locating CocoaPods (pod) command..."
POD_CMD=""
if command -v pod >/dev/null 2>&1; then
  POD_CMD="pod"
  log_success "Found CocoaPods in PATH: $(which pod)"
elif [ -f "$HOME/.gem/bin/pod" ]; then
  POD_CMD="$HOME/.gem/bin/pod"
  export PATH="$HOME/.gem/bin:$PATH"
  log_success "Found CocoaPods at: $POD_CMD"
else
  log_error "CocoaPods (pod) not found in PATH"
  log_error "Current PATH: $PATH"
  log_error "Attempting to find pod in common locations..."
  which -a pod || true
  exit 1
fi

log_section "COCOAPODS INSTALLATION"
log_step "Verifying working directory..."
log_step "  Current directory: $(pwd)"
log_step "  Expected iOS directory: $IOS_DIR"
if [ "$(pwd)" != "$IOS_DIR" ]; then
  log_warning "Not in iOS directory, changing to $IOS_DIR"
  cd "$IOS_DIR"
  log_step "Changed to: $(pwd)"
fi

# Use --repo-update to ensure we have the latest pod specs
log_step "Installing CocoaPods dependencies..."
log_step "Running: $POD_CMD install --repo-update"
if "$POD_CMD" install --repo-update; then
  POD_INSTALL_EXIT_CODE=0
  log_success "CocoaPods dependencies installed successfully"
else
  POD_INSTALL_EXIT_CODE=$?
  log_error "CocoaPods installation failed with exit code: $POD_INSTALL_EXIT_CODE"
  exit 1
fi

# Verify Pods were installed correctly
log_section "VERIFYING PODS INSTALLATION"
log_step "Current directory: $(pwd)"
log_step "Checking for Pods directory..."
if [ ! -d "Pods" ]; then
  log_error "Pods directory not found after pod install"
  log_step "Listing current directory contents:"
  ls -la || log_error "Failed to list directory"
  log_step "Checking if Pods exists at absolute path: $IOS_DIR/Pods"
  if [ -d "$IOS_DIR/Pods" ]; then
    log_warning "Pods directory exists at $IOS_DIR/Pods but not in current directory"
    log_step "Changing to $IOS_DIR"
    cd "$IOS_DIR"
  else
    log_error "Pods directory does not exist at $IOS_DIR/Pods either"
    exit 1
  fi
else
  log_success "Pods directory found at: $(pwd)/Pods"
fi

# CRITICAL: Verify xcfilelist files exist
# These files are required by Xcode for the build process
log_section "VERIFYING XCFILELIST FILES"
log_step "Current directory: $(pwd)"
log_step "IOS_DIR: $IOS_DIR"

# Determine the correct path to Pods directory
if [ -d "Pods" ]; then
  PODS_DIR="$(pwd)/Pods"
  log_success "Found Pods directory at: $PODS_DIR"
elif [ -d "$IOS_DIR/Pods" ]; then
  PODS_DIR="$IOS_DIR/Pods"
  log_success "Found Pods directory at: $PODS_DIR"
else
  log_error "Cannot find Pods directory"
  log_error "Searched in: $(pwd)/Pods"
  log_error "Searched in: $IOS_DIR/Pods"
  exit 1
fi

XC_FILELIST_DIR="$PODS_DIR/Target Support Files/Pods-Runner"
log_step "Checking xcfilelist directory: $XC_FILELIST_DIR"

if [ ! -d "$XC_FILELIST_DIR" ]; then
  log_error "Pods-Runner Target Support Files directory not found at $XC_FILELIST_DIR"
  log_step "Listing Pods directory structure:"
  ls -la "$PODS_DIR" || log_error "Cannot list Pods directory"
  if [ -d "$PODS_DIR/Target Support Files" ]; then
    log_step "Listing Target Support Files directory:"
    ls -la "$PODS_DIR/Target Support Files/" || log_error "Cannot list Target Support Files"
  else
    log_error "Target Support Files directory does not exist"
  fi
  exit 1
fi

log_success "xcfilelist directory found at: $XC_FILELIST_DIR"

# Check for required xcfilelist files
log_step "Checking for required xcfilelist files..."
REQUIRED_FILES=(
  "Pods-Runner-frameworks-Release-input-files.xcfilelist"
  "Pods-Runner-frameworks-Release-output-files.xcfilelist"
  "Pods-Runner-resources-Release-input-files.xcfilelist"
  "Pods-Runner-resources-Release-output-files.xcfilelist"
)

log_step "Listing all files in xcfilelist directory:"
ls -la "$XC_FILELIST_DIR" || log_error "Cannot list xcfilelist directory"

MISSING_FILES=()
for file in "${REQUIRED_FILES[@]}"; do
  FILE_PATH="$XC_FILELIST_DIR/$file"
  log_step "Checking for: $file"
  if [ ! -f "$FILE_PATH" ]; then
    log_error "Missing: $file"
    MISSING_FILES+=("$file")
  else
    # Verify file has content
    if [ -s "$FILE_PATH" ]; then
      LINE_COUNT=$(wc -l < "$FILE_PATH")
      log_success "Found: $file ($LINE_COUNT lines)"
    else
      log_warning "Found but empty: $file"
    fi
  fi
done

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
  log_error "Missing required xcfilelist files:"
  for file in "${MISSING_FILES[@]}"; do
    log_error "   - $file"
  done
  log_step "Full directory listing:"
  ls -la "$XC_FILELIST_DIR" || log_error "Directory does not exist"
  exit 1
fi

log_success "All required xcfilelist files verified and have content"

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

# CRITICAL: Ensure Xcode Cloud can find Pods and Flutter files
# Xcode Cloud builds from /Volumes/workspace/repository/ios/Runner.xcworkspace
# but the project is at /Volumes/workspace/repository/linkUpMobileApp/ios/
# We need to ensure symlinks or structure exists for Xcode to find everything
echo "🔗 Ensuring Xcode Cloud can access required files..."
ROOT_IOS_DIR="$REPO_ROOT/ios"
if [ "$ROOT_IOS_DIR" != "$IOS_DIR" ] && [ -d "$ROOT_IOS_DIR" ]; then
  echo "📍 Root ios directory exists: $ROOT_IOS_DIR"
  echo "📍 Flutter project ios directory: $IOS_DIR"
  
  # Remove existing symlinks/directories if they exist (to ensure fresh state)
  if [ -L "$ROOT_IOS_DIR/Pods" ] || [ -d "$ROOT_IOS_DIR/Pods" ]; then
    echo "🧹 Removing existing Pods at root ios..."
    rm -rf "$ROOT_IOS_DIR/Pods"
  fi
  
  if [ -L "$ROOT_IOS_DIR/Flutter" ] || [ -d "$ROOT_IOS_DIR/Flutter" ]; then
    echo "🧹 Removing existing Flutter at root ios..."
    rm -rf "$ROOT_IOS_DIR/Flutter"
  fi
  
  # Create symlink for Pods if it doesn't exist at root ios
  if [ -d "$IOS_DIR/Pods" ]; then
    echo "🔗 Creating symlink: $ROOT_IOS_DIR/Pods -> $IOS_DIR/Pods"
    # Use absolute path for symlink to ensure it works from any location
    ABSOLUTE_IOS_DIR="$(cd "$IOS_DIR" && pwd)"
    ln -sf "$ABSOLUTE_IOS_DIR/Pods" "$ROOT_IOS_DIR/Pods" || {
      echo "❌ ERROR: Could not create Pods symlink"
      exit 1
    }
    echo "✅ Pods symlink created"
  else
    echo "❌ ERROR: Pods directory not found at $IOS_DIR/Pods"
    exit 1
  fi
  
  # Create symlink for Flutter directory if it doesn't exist at root ios
  if [ -d "$IOS_DIR/Flutter" ]; then
    echo "🔗 Creating symlink: $ROOT_IOS_DIR/Flutter -> $IOS_DIR/Flutter"
    # Use absolute path for symlink to ensure it works from any location
    ABSOLUTE_IOS_DIR="$(cd "$IOS_DIR" && pwd)"
    ln -sf "$ABSOLUTE_IOS_DIR/Flutter" "$ROOT_IOS_DIR/Flutter" || {
      echo "❌ ERROR: Could not create Flutter symlink"
      exit 1
    }
    echo "✅ Flutter symlink created"
  else
    echo "❌ ERROR: Flutter directory not found at $IOS_DIR/Flutter"
    exit 1
  fi
  
  # Verify symlinks were created and are valid
  if [ -L "$ROOT_IOS_DIR/Pods" ] && [ -d "$ROOT_IOS_DIR/Pods" ]; then
    echo "✅ Pods symlink verified and accessible at $ROOT_IOS_DIR/Pods"
    echo "   Points to: $(readlink -f "$ROOT_IOS_DIR/Pods")"
    
    # CRITICAL: Verify xcfilelist files are accessible through symlink
    XCFILELIST_TEST="$ROOT_IOS_DIR/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-input-files.xcfilelist"
    if [ -f "$XCFILELIST_TEST" ]; then
      echo "✅ xcfilelist files accessible through Pods symlink"
    else
      echo "⚠️  WARNING: xcfilelist file not accessible through symlink at: $XCFILELIST_TEST"
      echo "   Checking actual path: $IOS_DIR/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-input-files.xcfilelist"
      if [ -f "$IOS_DIR/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-input-files.xcfilelist" ]; then
        echo "   File exists at actual path, symlink may need to be recreated"
        # Try recreating the symlink
        rm -f "$ROOT_IOS_DIR/Pods"
        ln -sf "$ABSOLUTE_IOS_DIR/Pods" "$ROOT_IOS_DIR/Pods"
        if [ -f "$XCFILELIST_TEST" ]; then
          echo "   ✅ Symlink recreated successfully"
        else
          echo "   ❌ Symlink still not working"
        fi
      fi
    fi
  else
    echo "❌ ERROR: Pods symlink verification failed"
    exit 1
  fi
  
  if [ -L "$ROOT_IOS_DIR/Flutter" ] && [ -d "$ROOT_IOS_DIR/Flutter" ]; then
    echo "✅ Flutter symlink verified and accessible at $ROOT_IOS_DIR/Flutter"
    echo "   Points to: $(readlink -f "$ROOT_IOS_DIR/Flutter")"
    
    # Verify Generated.xcconfig is accessible through symlink
    if [ -f "$ROOT_IOS_DIR/Flutter/Generated.xcconfig" ]; then
      echo "✅ Generated.xcconfig accessible through symlink"
    else
      echo "❌ ERROR: Generated.xcconfig not accessible through symlink"
      echo "   Checking actual path: $IOS_DIR/Flutter/Generated.xcconfig"
      if [ -f "$IOS_DIR/Flutter/Generated.xcconfig" ]; then
        echo "   File exists at actual path, symlink may be broken"
      else
        echo "   File does not exist at actual path either"
      fi
      exit 1
    fi
  else
    echo "❌ ERROR: Flutter symlink verification failed"
    exit 1
  fi
else
  echo "📍 Root ios directory is the same as Flutter project ios directory, no symlinks needed"
fi

# CRITICAL: Pre-build verification for xcodebuild
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "🔍 PRE-BUILD VERIFICATION FOR XCODEBUILD"
echo "═══════════════════════════════════════════════════════════"

# Verify workspace that xcodebuild will use
XCODEBUILD_WORKSPACE="$REPO_ROOT/ios/Runner.xcworkspace"
echo "📍 Xcodebuild workspace path: $XCODEBUILD_WORKSPACE"

if [ ! -f "$XCODEBUILD_WORKSPACE/contents.xcworkspacedata" ]; then
  echo "❌ ERROR: Workspace not found at $XCODEBUILD_WORKSPACE"
  echo "📍 Creating workspace if it doesn't exist..."
  
  # Create workspace directory
  mkdir -p "$XCODEBUILD_WORKSPACE"
  
  # Create workspace contents
  cat > "$XCODEBUILD_WORKSPACE/contents.xcworkspacedata" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "container:../linkUpMobileApp/ios/Runner.xcodeproj">
   </FileRef>
   <FileRef
      location = "container:../linkUpMobileApp/ios/Pods/Pods.xcodeproj">
   </FileRef>
</Workspace>
EOF
  
  echo "✅ Created workspace at $XCODEBUILD_WORKSPACE"
else
  echo "✅ Workspace exists at $XCODEBUILD_WORKSPACE"
  echo "📄 Workspace contents:"
  cat "$XCODEBUILD_WORKSPACE/contents.xcworkspacedata"
  
  # Verify workspace references are correct
  WORKSPACE_CONTENTS=$(cat "$XCODEBUILD_WORKSPACE/contents.xcworkspacedata")
  if ! echo "$WORKSPACE_CONTENTS" | grep -q "linkUpMobileApp/ios/Runner.xcodeproj"; then
    echo "⚠️  WARNING: Workspace may not reference project correctly"
    echo "   Updating workspace references..."
    cat > "$XCODEBUILD_WORKSPACE/contents.xcworkspacedata" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "container:../linkUpMobileApp/ios/Runner.xcodeproj">
   </FileRef>
   <FileRef
      location = "container:../linkUpMobileApp/ios/Pods/Pods.xcodeproj">
   </FileRef>
</Workspace>
EOF
    echo "✅ Updated workspace references"
  fi
fi

# Verify all paths are relative and correct
echo "📍 Verifying workspace references..."
WORKSPACE_CONTENTS=$(cat "$XCODEBUILD_WORKSPACE/contents.xcworkspacedata")
echo "$WORKSPACE_CONTENTS"

# Verify referenced projects exist from workspace perspective
cd "$REPO_ROOT"
echo "📍 Current directory for path resolution: $(pwd)"

# Check Runner.xcodeproj
if [ -f "linkUpMobileApp/ios/Runner.xcodeproj/project.pbxproj" ]; then
  echo "✅ Runner.xcodeproj accessible from workspace"
else
  echo "❌ ERROR: Runner.xcodeproj not accessible from workspace"
  echo "   Expected at: linkUpMobileApp/ios/Runner.xcodeproj"
  echo "   Current directory: $(pwd)"
  echo "   Listing repository root:"
  ls -la | head -20
  if [ -d "linkUpMobileApp" ]; then
    echo "   Listing linkUpMobileApp directory:"
    ls -la linkUpMobileApp/ | head -20
    if [ -d "linkUpMobileApp/ios" ]; then
      echo "   Listing linkUpMobileApp/ios:"
      ls -la linkUpMobileApp/ios/ | grep -E "Runner|Pods" || echo "Cannot list directory"
    fi
  fi
  exit 1
fi

# Check Pods.xcodeproj
if [ -f "linkUpMobileApp/ios/Pods/Pods.xcodeproj/project.pbxproj" ]; then
  echo "✅ Pods.xcodeproj accessible from workspace"
else
  echo "❌ ERROR: Pods.xcodeproj not accessible from workspace"
  echo "   Expected at: linkUpMobileApp/ios/Pods/Pods.xcodeproj"
  echo "   Current directory: $(pwd)"
  if [ -d "linkUpMobileApp/ios/Pods" ]; then
    echo "   Listing Pods directory:"
    ls -la linkUpMobileApp/ios/Pods/ | head -20
  else
    echo "   Pods directory does not exist"
  fi
  exit 1
fi

# CRITICAL: Verify that when building from the workspace, SRCROOT will resolve correctly
# The workspace is at REPO_ROOT/ios/, but the project is at REPO_ROOT/linkUpMobileApp/ios/
# When Xcode builds, SRCROOT for the Runner project should be REPO_ROOT/linkUpMobileApp/ios/
# But we need to ensure Flutter and Pods are accessible from both locations
echo "📍 Verifying SRCROOT resolution..."
echo "   Workspace location: $REPO_ROOT/ios/"
echo "   Project location: $REPO_ROOT/linkUpMobileApp/ios/"
echo "   When building, SRCROOT should be: $REPO_ROOT/linkUpMobileApp/ios/"

# Verify Flutter directory exists at project location
if [ -d "$REPO_ROOT/linkUpMobileApp/ios/Flutter" ]; then
  echo "✅ Flutter directory exists at project location"
  if [ -f "$REPO_ROOT/linkUpMobileApp/ios/Flutter/Generated.xcconfig" ]; then
    echo "✅ Generated.xcconfig exists at project location"
  else
    echo "❌ ERROR: Generated.xcconfig missing at project location"
    exit 1
  fi
else
  echo "❌ ERROR: Flutter directory missing at project location"
  exit 1
fi

# Verify Pods directory exists at project location
if [ -d "$REPO_ROOT/linkUpMobileApp/ios/Pods" ]; then
  echo "✅ Pods directory exists at project location"
else
  echo "❌ ERROR: Pods directory missing at project location"
  exit 1
fi

# Verify PODS_ROOT will resolve correctly
echo "📍 Verifying PODS_ROOT resolution..."
cd "$IOS_DIR"
PODS_ABSOLUTE_PATH="$(pwd)/Pods"
echo "📍 Absolute Pods path: $PODS_ABSOLUTE_PATH"
echo "📍 PODS_ROOT from xcconfig: $(grep PODS_ROOT "$PODS_DIR/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig" | head -1)"

# Test that xcodebuild can see the workspace
echo "📍 Testing xcodebuild workspace listing..."
if command -v xcodebuild >/dev/null 2>&1; then
  cd "$REPO_ROOT/ios"
  echo "📍 Listing schemes in workspace..."
  xcodebuild -list -workspace Runner.xcworkspace 2>&1 | head -20 || echo "⚠️  Could not list schemes"
else
  echo "⚠️  xcodebuild not found in PATH (this is OK in pre-build script)"
fi

# CRITICAL: Final verification - ensure all paths are accessible from workspace location
echo ""
echo "🔍 FINAL PATH VERIFICATION FROM WORKSPACE LOCATION..."
cd "$REPO_ROOT/ios"
echo "📍 Current directory: $(pwd)"

# Check if Flutter directory is accessible (either directly or via symlink)
if [ -f "Flutter/Generated.xcconfig" ]; then
  echo "✅ Flutter/Generated.xcconfig accessible from workspace location"
  echo "   Path: $(pwd)/Flutter/Generated.xcconfig"
  if [ -L "Flutter" ]; then
    echo "   (via symlink: $(readlink Flutter))"
  fi
else
  echo "❌ ERROR: Flutter/Generated.xcconfig NOT accessible from workspace location"
  echo "   Current directory: $(pwd)"
  echo "   Listing current directory:"
  ls -la | head -20
  if [ -d "Flutter" ]; then
    echo "   Flutter directory exists but Generated.xcconfig missing"
    ls -la Flutter/ | head -10
  else
    echo "   Flutter directory does not exist"
  fi
  exit 1
fi

# Check if Pods directory is accessible
log_section "FINAL VERIFICATION FROM WORKSPACE LOCATION"
log_step "Verifying Pods directory is accessible from workspace location..."
if [ -d "Pods" ]; then
  log_success "Pods directory accessible from workspace location"
  if [ -L "Pods" ]; then
    log_step "  (via symlink: $(readlink -f Pods))"
  fi
  
  # Verify xcfilelist files are accessible
  XCFILELIST_DIR="Pods/Target Support Files/Pods-Runner"
  if [ -d "$XCFILELIST_DIR" ]; then
    log_success "Pods-Runner Target Support Files accessible"
    REQUIRED_FILES=(
      "Pods-Runner-frameworks-Release-input-files.xcfilelist"
      "Pods-Runner-frameworks-Release-output-files.xcfilelist"
      "Pods-Runner-resources-Release-input-files.xcfilelist"
      "Pods-Runner-resources-Release-output-files.xcfilelist"
    )
    ALL_FILES_FOUND=true
    for file in "${REQUIRED_FILES[@]}"; do
      FILE_PATH="$XCFILELIST_DIR/$file"
      if [ -f "$FILE_PATH" ]; then
        # Verify file is readable and has content
        if [ -s "$FILE_PATH" ]; then
          LINE_COUNT=$(wc -l < "$FILE_PATH")
          log_success "Found: $file ($LINE_COUNT lines)"
        else
          log_warning "Found but empty: $file"
        fi
      else
        log_error "Missing: $file"
        log_error "  Full path: $(pwd)/$FILE_PATH"
        ALL_FILES_FOUND=false
      fi
    done
    
    if [ "$ALL_FILES_FOUND" = false ]; then
      log_error "Some required xcfilelist files are missing"
      log_step "Listing directory contents:"
      ls -la "$XCFILELIST_DIR" || log_error "Cannot list directory"
      exit 1
    fi
  else
    log_error "Pods-Runner Target Support Files not accessible"
    log_error "  Expected at: $(pwd)/$XCFILELIST_DIR"
    log_step "Checking if Pods directory structure is correct..."
    if [ -d "Pods/Target Support Files" ]; then
      log_step "Target Support Files directory exists, listing:"
      ls -la "Pods/Target Support Files" || log_error "Cannot list"
    else
      log_error "Target Support Files directory does not exist"
    fi
    exit 1
  fi
else
  log_error "Pods directory NOT accessible from workspace location"
  log_error "  Current directory: $(pwd)"
  log_error "  Expected Pods at: $(pwd)/Pods"
  log_step "Checking if symlink should have been created..."
  if [ -d "$IOS_DIR/Pods" ]; then
    log_error "  Pods exists at: $IOS_DIR/Pods"
    log_error "  Symlink should have been created at: $(pwd)/Pods"
  fi
  exit 1
fi

log_success "Pre-build verification completed"

# CRITICAL: Create a script that fixes PODS_ROOT if it resolves incorrectly
# This script will be sourced by Xcode build phases if needed
log_step "Creating PODS_ROOT fix script (for future use if needed)..."
PODS_ROOT_FIX_SCRIPT="$REPO_ROOT/ios/fix_pods_root.sh"
cat > "$PODS_ROOT_FIX_SCRIPT" <<'EOF'
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
EOF
chmod +x "$PODS_ROOT_FIX_SCRIPT"
log_success "Created PODS_ROOT fix script at: $PODS_ROOT_FIX_SCRIPT"

# Final summary
log_section "PRE-BUILD SCRIPT SUMMARY"
log_info "All pre-build tasks completed successfully"
log_step "Repository root: $REPO_ROOT"
log_step "Flutter project: $FLUTTER_PROJECT_DIR"
log_step "iOS directory: $IOS_DIR"
log_step "Pods directory: $PODS_DIR"
log_step "Generated.xcconfig: $GENERATED_XCCONFIG"
log_step "Workspace: $IOS_DIR/Runner.xcworkspace"
log_step "PODS_ROOT fix script: $PODS_ROOT_FIX_SCRIPT"
log_step "Script completed at: $(date)"
echo ""
log_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_success "PRE-BUILD SCRIPT COMPLETED SUCCESSFULLY"
log_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

