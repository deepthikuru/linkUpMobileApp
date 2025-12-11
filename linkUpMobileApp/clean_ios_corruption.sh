#!/bin/bash

echo "🧹 Cleaning corrupted iOS build files..."

cd "$(dirname "$0")"

# Kill any hanging processes
echo "🛑 Killing any hanging Flutter/Xcode processes..."
pkill -f "flutter clean" 2>/dev/null || true
pkill -f "xcodebuild -list" 2>/dev/null || true
sleep 1

# Clean Flutter build
echo "📦 Cleaning Flutter build directories..."
rm -rf build/
rm -rf ios/build/
echo "✓ Cleaned build directories"

# Clean iOS Flutter framework and generated files
echo "📱 Cleaning iOS Flutter files..."
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/Flutter.podspec
rm -rf ios/.symlinks
rm -rf ios/ServiceDefinitions.json

# Remove duplicate Generated.xcconfig files (keep only Generated.xcconfig)
echo "🗑️  Removing duplicate Generated.xcconfig files..."
cd ios/Flutter
for file in Generated*.xcconfig; do
  if [[ "$file" != "Generated.xcconfig" ]]; then
    rm -f "$file"
    echo "  Removed: $file"
  fi
done

# Remove duplicate flutter_export_environment files (keep only flutter_export_environment.sh)
for file in flutter_export_environment*.sh; do
  if [[ "$file" != "flutter_export_environment.sh" ]]; then
    rm -f "$file"
    echo "  Removed: $file"
  fi
done

# Remove duplicate Flutter podspec files (keep only Flutter.podspec if it exists)
for file in Flutter*.podspec; do
  if [[ "$file" =~ Flutter\ [0-9]+\.podspec ]]; then
    rm -f "$file"
    echo "  Removed: $file"
  fi
done

cd ../..

# Clean Xcode user data
echo "🔧 Cleaning Xcode user data..."
rm -rf ios/Runner.xcworkspace/xcuserdata
rm -rf ios/Pods.xcworkspace/xcuserdata
rm -rf ios/Runner.xcodeproj/xcuserdata
rm -rf ios/Runner.xcodeproj/project.xcworkspace/xcuserdata

# Remove duplicate Pod directories
echo "🗑️  Removing duplicate Pod directories..."
cd ios/Pods 2>/dev/null && {
  for dir in */; do
    dir_name="${dir%/}"
    # Check if directory name ends with space + number (e.g., "Firebase 2")
    if [[ "$dir_name" =~ ^.*\ [0-9]+$ ]]; then
      echo "  Removing duplicate: $dir_name"
      rm -rf "$dir_name"
    fi
  done
  cd ../..
} || echo "  No Pods directory found"

# Remove duplicate Podfile.lock files
echo "🗑️  Removing duplicate Podfile.lock files..."
rm -f ios/Podfile\ 2.lock
rm -f ios/Podfile\ 3.lock

# Remove duplicate Manifest.lock files
echo "🗑️  Removing duplicate Manifest.lock files..."
rm -f ios/Pods/Manifest\ 2.lock
rm -f ios/Pods/Manifest\ 3.lock

# Clean CocoaPods completely
echo "🧹 Cleaning CocoaPods..."
rm -rf ios/Pods
rm -f ios/Podfile.lock
rm -rf ios/.symlinks

# Clean DerivedData (Xcode build cache)
echo "🗑️  Cleaning Xcode DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*

echo ""
echo "✅ iOS corruption cleanup complete!"
echo ""
echo "Next steps:"
echo "1. Run: flutter pub get"
echo "2. Run: cd ios && pod install"
echo "3. Run: flutter clean (should work now)"

