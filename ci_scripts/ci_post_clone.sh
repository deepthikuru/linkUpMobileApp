#!/bin/bash

# Xcode Cloud Post-Clone Script
# This script runs at the repository root and sets up the Flutter project structure
# that Xcode Cloud expects

set -e
set -x

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
log_section "XCODE CLOUD POST-CLONE SCRIPT"
echo "Script: ci_post_clone.sh"
echo "Started: $(date)"
echo ""

# Get the repository root (where this script is located)
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FLUTTER_PROJECT_DIR="$REPO_ROOT/linkUpMobileApp"

log_section "ENVIRONMENT SETUP"
log_step "Repository root: $REPO_ROOT"
log_step "Flutter project directory: $FLUTTER_PROJECT_DIR"

# Check if Flutter project exists
log_step "Verifying Flutter project directory exists..."
if [ ! -d "$FLUTTER_PROJECT_DIR" ]; then
  log_error "Flutter project directory not found at $FLUTTER_PROJECT_DIR"
  exit 1
fi
log_success "Flutter project directory found"

# Navigate to Flutter project directory
cd "$FLUTTER_PROJECT_DIR"

# Check if we're in the right directory
log_step "Verifying pubspec.yaml exists..."
if [ ! -f "pubspec.yaml" ]; then
  log_error "pubspec.yaml not found. Current directory: $(pwd)"
  exit 1
fi
log_success "pubspec.yaml found"

# Install Flutter if not available
log_section "FLUTTER INSTALLATION"
FLUTTER_INSTALLED=false
if command -v flutter >/dev/null 2>&1; then
  log_success "Flutter already available: $(which flutter)"
  FLUTTER_INSTALLED=true
elif [ -d "$HOME/flutter/bin" ] && [ -f "$HOME/flutter/bin/flutter" ]; then
  log_success "Flutter found at $HOME/flutter/bin/flutter"
  export PATH="$HOME/flutter/bin:$PATH"
  FLUTTER_INSTALLED=true
fi

if [ "$FLUTTER_INSTALLED" = false ]; then
  log_step "Flutter not found. Installing Flutter..."
  
  # Check if Flutter is already cloned but not in PATH
  if [ -d "$HOME/flutter" ]; then
    log_step "Flutter directory exists, adding to PATH..."
    export PATH="$HOME/flutter/bin:$PATH"
  else
    # Clone Flutter
    cd "$HOME"
    log_step "Cloning Flutter repository (stable branch)..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
    export PATH="$HOME/flutter/bin:$PATH"
  fi
  
  # Verify Flutter installation
  log_step "Verifying Flutter installation..."
  if ! flutter --version >/dev/null 2>&1; then
    log_error "Failed to install/verify Flutter"
    flutter --version || true
    exit 1
  fi
  
  FLUTTER_VERSION=$(flutter --version | head -1)
  log_success "Flutter installed successfully: $FLUTTER_VERSION"
fi

# Make Flutter available for subsequent scripts
log_step "Saving Flutter path for subsequent scripts..."
echo "export PATH=\"\$HOME/flutter/bin:\$PATH\"" > "$HOME/.flutter_path"
chmod +x "$HOME/.flutter_path" || true
log_success "Flutter path saved to $HOME/.flutter_path"

# Navigate back to Flutter project root
cd "$FLUTTER_PROJECT_DIR"

# Accept Flutter licenses (non-blocking)
log_section "FLUTTER SETUP VERIFICATION"
log_step "Running flutter doctor (non-blocking)..."
flutter doctor || log_warning "flutter doctor had issues (continuing anyway)"

# Verify workspace exists at expected location
log_step "Verifying workspace exists at expected location..."
if [ ! -d "$REPO_ROOT/ios/Runner.xcworkspace" ]; then
  log_warning "Workspace not found at $REPO_ROOT/ios/Runner.xcworkspace"
  log_warning "Make sure the workspace is committed to the repository"
else
  log_success "Workspace found at expected location: $REPO_ROOT/ios/Runner.xcworkspace"
fi

log_section "POST-CLONE SCRIPT SUMMARY"
log_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_success "POST-CLONE SCRIPT COMPLETED SUCCESSFULLY"
log_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_step "Script completed at: $(date)"
echo ""

