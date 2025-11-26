#!/bin/bash

# Xcode Cloud Post-Clone Script for Flutter iOS
# This script runs after cloning the repository, before any builds

set -e
set -x

echo "🚀 Starting Xcode Cloud post-clone script..."

# Determine project root
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IOS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$IOS_DIR/.." && pwd)"

echo "📂 Project root: $PROJECT_ROOT"
echo "📂 iOS directory: $IOS_DIR"
echo "📂 Current PATH: $PATH"
echo "📂 HOME: $HOME"

# Navigate to project root
cd "$PROJECT_ROOT"

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

# Make Flutter available for subsequent scripts by writing to a file
echo "export PATH=\"\$HOME/flutter/bin:\$PATH\"" > "$HOME/.flutter_path"
chmod +x "$HOME/.flutter_path" || true

# Navigate back to project root
cd "$PROJECT_ROOT"

# Accept Flutter licenses (non-blocking)
echo "📝 Checking Flutter setup..."
flutter doctor || true

echo "✅ Post-clone script completed successfully!"

