#!/bin/bash
echo "Cleaning Flutter build directories..."

# Clean Flutter build
rm -rf build/
echo "✓ Cleaned build/"

# Clean iOS build
rm -rf ios/build/
echo "✓ Cleaned ios/build/"

# Clean iOS Flutter framework
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/Flutter.podspec
rm -rf ios/.symlinks
rm -rf ios/ServiceDefinitions.json
echo "✓ Cleaned iOS Flutter files"

# Clean Xcode user data
rm -rf ios/Runner.xcworkspace/xcuserdata
rm -rf ios/Pods.xcworkspace/xcuserdata
echo "✓ Cleaned Xcode user data"

# Clean Pods build (optional - comment out if you want to keep Pods)
# rm -rf ios/Pods/build/

echo ""
echo "✅ Build cleanup complete!"
echo "Run 'flutter pub get' to restore dependencies."
