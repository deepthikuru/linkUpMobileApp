# Xcode Cloud Build Fix - Debugging and Path Resolution

## Issues Identified

Based on the build logs, the following errors were occurring:

1. **Pre-Xcodebuild script not found**: The script wasn't being detected by Xcode Cloud
2. **Flutter/Generated.xcconfig not found**: `${SRCROOT}/Flutter/Generated.xcconfig` couldn't be found
3. **xcfilelist files not found**: Pods xcfilelist files couldn't be loaded

## Root Cause

The workspace is located at `/Volumes/workspace/repository/ios/Runner.xcworkspace`, but the Flutter project is at `/Volumes/workspace/repository/linkUpMobileApp/ios/`. When Xcode builds from the workspace, `${SRCROOT}` may resolve to the workspace directory instead of the project directory, causing path resolution issues.

## Solutions Implemented

### 1. Enhanced Pre-Build Script (`ci_scripts/ci_pre_xcodebuild.sh`)

The script now:
- ✅ Verifies Flutter and Pods are properly set up
- ✅ Creates symlinks from workspace location to project location for:
  - `Flutter/` directory (contains Generated.xcconfig)
  - `Pods/` directory (contains xcfilelist files)
- ✅ Verifies all paths are accessible from both locations
- ✅ Provides comprehensive debugging output

### 2. Debug Script (`debug_xcodebuild_archive.sh`)

A standalone debug script that:
- Verifies workspace structure
- Checks all required files exist
- Runs xcodebuild with verbose logging
- Analyzes and categorizes errors

### 3. Enhanced Archive Wrapper (`ci_scripts/ci_xcodebuild_archive.sh`)

A wrapper script that:
- Captures full build logs
- Extracts and categorizes errors
- Provides actionable error summaries

## How Xcode Cloud Finds CI Scripts

Xcode Cloud looks for CI scripts at these locations relative to the repository root:

- `ci_scripts/ci_post_clone.sh` - Runs after cloning
- `ci_scripts/ci_pre_xcodebuild.sh` - Runs before building
- `ci_scripts/ci_post_xcodebuild.sh` - Runs after building

**Important**: The scripts must be:
1. ✅ Located at the repository root in `ci_scripts/` directory
2. ✅ Executable (`chmod +x`)
3. ✅ Committed to git
4. ✅ Have proper shebang (`#!/bin/bash`)

## Workspace Structure

```
repository/
├── ci_scripts/
│   ├── ci_post_clone.sh
│   ├── ci_pre_xcodebuild.sh
│   └── ci_xcodebuild_archive.sh
├── ios/
│   └── Runner.xcworkspace  (references ../linkUpMobileApp/ios/Runner.xcodeproj)
└── linkUpMobileApp/
    └── ios/
        ├── Runner.xcodeproj
        ├── Pods/
        ├── Flutter/
        └── ...
```

## Path Resolution

When building from the workspace:
- Workspace location: `/Volumes/workspace/repository/ios/`
- Project location: `/Volumes/workspace/repository/linkUpMobileApp/ios/`
- `${SRCROOT}` should resolve to: `/Volumes/workspace/repository/linkUpMobileApp/ios/`

The pre-build script creates symlinks so that even if `${SRCROOT}` resolves to the workspace location, the files are still accessible:
- `/Volumes/workspace/repository/ios/Flutter/` → `/Volumes/workspace/repository/linkUpMobileApp/ios/Flutter/`
- `/Volumes/workspace/repository/ios/Pods/` → `/Volumes/workspace/repository/linkUpMobileApp/ios/Pods/`

## Verification

After the pre-build script runs, verify:
1. ✅ `Flutter/Generated.xcconfig` exists at project location
2. ✅ `Flutter/Generated.xcconfig` is accessible via symlink from workspace location
3. ✅ `Pods/` directory exists at project location
4. ✅ `Pods/` directory is accessible via symlink from workspace location
5. ✅ All xcfilelist files exist in `Pods/Target Support Files/Pods-Runner/`

## Next Steps

1. **Commit the updated scripts to git**:
   ```bash
   git add ci_scripts/
   git commit -m "Fix Xcode Cloud build paths and add debugging"
   git push
   ```

2. **Trigger a new build** in Xcode Cloud

3. **Check the logs** for:
   - Pre-build script execution
   - Symlink creation
   - Path verification messages

4. **If issues persist**, check:
   - Are the scripts committed to the correct branch?
   - Are the scripts executable?
   - Are there any permission issues?

## Debugging

If the build still fails:

1. **Check pre-build script logs** - Look for the emoji markers (🚀, ✅, ❌) to see where it fails
2. **Check symlink creation** - Verify symlinks are created and point to correct locations
3. **Check file existence** - Verify all required files exist at expected paths
4. **Use debug script** - Run `debug_xcodebuild_archive.sh` locally to test

## Common Issues

### Script not found
- Ensure scripts are in `ci_scripts/` at repository root
- Ensure scripts are committed to git
- Check file permissions

### Path resolution issues
- Verify symlinks are created correctly
- Check that `${SRCROOT}` resolves to project directory, not workspace directory
- Ensure Flutter and Pods directories exist at project location

### Missing files
- Run `flutter pub get` and `flutter build ios --config-only` to generate Flutter files
- Run `pod install` to generate Pods files
- Verify Generated.xcconfig exists

