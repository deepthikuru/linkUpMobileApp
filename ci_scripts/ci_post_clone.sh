#!/bin/bash

# Xcode Cloud Post-Clone Script
# This script runs at the repository root and sets up the Flutter project structure
# that Xcode Cloud expects

set -e
set -x

echo "🚀 Starting Xcode Cloud post-clone script at repository root..."

# Get the repository root (where this script is located)
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FLUTTER_PROJECT_DIR="$REPO_ROOT/linkUpMobileApp"

echo "📂 Repository root: $REPO_ROOT"
echo "📂 Flutter project directory: $FLUTTER_PROJECT_DIR"

# Check if Flutter project exists
if [ ! -d "$FLUTTER_PROJECT_DIR" ]; then
  echo "❌ Error: Flutter project directory not found at $FLUTTER_PROJECT_DIR"
  exit 1
fi

# Navigate to Flutter project directory
cd "$FLUTTER_PROJECT_DIR"

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
  echo "❌ Error: pubspec.yaml not found. Current directory: $(pwd)"
  exit 1
fi

# Install Flutter if not available
FLUTTER_INSTALLED=false
if command -v flutter >/dev/null 2>&1; then
  echo "✅ Flutter already available: $(which flutter)"
  FLUTTER_INSTALLED=true
elif [ -d "$HOME/flutter/bin" ] && [ -f "$HOME/flutter/bin/flutter" ]; then
  echo "✅ Flutter found at $HOME/flutter/bin/flutter"
  export PATH="$HOME/flutter/bin:$PATH"
  FLUTTER_INSTALLED=true
fi

if [ "$FLUTTER_INSTALLED" = false ]; then
  echo "📥 Flutter not found. Installing Flutter..."
  
  # Check if Flutter is already cloned but not in PATH
  if [ -d "$HOME/flutter" ]; then
    echo "📂 Flutter directory exists, adding to PATH..."
    export PATH="$HOME/flutter/bin:$PATH"
  else
    # Clone Flutter
    cd "$HOME"
    echo "📥 Cloning Flutter repository..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
    export PATH="$HOME/flutter/bin:$PATH"
  fi
  
  # Verify Flutter installation
  if ! flutter --version >/dev/null 2>&1; then
    echo "❌ Failed to install/verify Flutter"
    flutter --version || true
    exit 1
  fi
  
  echo "✅ Flutter installed successfully at: $(which flutter)"
fi

# Make Flutter available for subsequent scripts
echo "export PATH=\"\$HOME/flutter/bin:\$PATH\"" > "$HOME/.flutter_path"
chmod +x "$HOME/.flutter_path" || true

# Navigate back to Flutter project root
cd "$FLUTTER_PROJECT_DIR"

# Accept Flutter licenses (non-blocking)
echo "📝 Checking Flutter setup..."
flutter doctor || true

# Verify workspace exists at expected location
if [ ! -d "$REPO_ROOT/ios/Runner.xcworkspace" ]; then
  echo "⚠️  Warning: Workspace not found at $REPO_ROOT/ios/Runner.xcworkspace"
  echo "   Make sure the workspace is committed to the repository"
else
  echo "✅ Workspace found at expected location: $REPO_ROOT/ios/Runner.xcworkspace"
fi

echo "✅ Post-clone script completed successfully!"

