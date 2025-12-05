# FLUTTER_ROOT Build Script Fix

## Issue

The Xcode build was failing with the error:
```
/bin/sh: /packages/flutter_tools/bin/xcode_backend.sh: No such file or directory
Command PhaseScriptExecution failed with a nonzero exit code
```

This occurred because `FLUTTER_ROOT` environment variable was not set when Xcode tried to execute the Flutter build scripts.

## Root Cause

The build script phases were directly referencing `$FLUTTER_ROOT` without first ensuring it was set:
```bash
"/bin/sh \"$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh\" build"
```

When `FLUTTER_ROOT` was empty, the path resolved to `/packages/flutter_tools/bin/xcode_backend.sh` (invalid path), causing the build to fail.

## Solution

Updated both Flutter build script phases to:
1. **Detect FLUTTER_ROOT** if not already set
2. **Read from Generated.xcconfig** if available (primary source)
3. **Fallback to common paths**:
   - `/Users/local/flutter` (Xcode Cloud default)
   - `$HOME/flutter` (common local installation)
   - Detect from `flutter` command in PATH
4. **Validate** that FLUTTER_ROOT is set and points to a valid directory
5. **Provide clear error** if FLUTTER_ROOT cannot be determined

## Files Modified

### `linkUpMobileApp/ios/Runner.xcodeproj/project.pbxproj`

**Build Phases Updated:**
1. **Run Script** (9740EEB61CF901F6004384FC) - Runs Flutter build
2. **Thin Binary** (3B06AD1E1E4923F5004D2608) - Thins the binary after build

Both phases now use the same robust FLUTTER_ROOT detection logic.

## How It Works

The updated script:
1. Checks if `FLUTTER_ROOT` is already set (from xcconfig files)
2. If not, tries to read it from `Flutter/Generated.xcconfig`
3. Falls back to checking common installation directories
4. Validates the path exists before using it
5. Provides a clear error message if detection fails

## Detection Priority

1. **Xcode build settings** (from xcconfig files) - if already set
2. **Generated.xcconfig** - reads `FLUTTER_ROOT` from the generated config file
3. **Xcode Cloud path** - `/Users/local/flutter` (where CI installs Flutter)
4. **Home directory** - `$HOME/flutter` (common local installation)
5. **PATH detection** - finds Flutter from `which flutter` command

## Testing

After this fix:
- ✅ Build should detect Flutter installation automatically
- ✅ Works in Xcode Cloud (CI environment)
- ✅ Works locally with different Flutter installation paths
- ✅ Provides clear error if Flutter is not found

## Next Steps

1. Commit this change
2. Push to trigger a new Xcode Cloud build
3. Verify build succeeds with FLUTTER_ROOT detection

## Expected Build Log Output

When the script runs successfully, you should see:
- No "FLUTTER_ROOT not set" errors
- Flutter build script executing correctly
- Build proceeding normally

If FLUTTER_ROOT cannot be detected, you'll see:
```
error: FLUTTER_ROOT not set or invalid. Expected Flutter installation directory.
```

This provides clear feedback for troubleshooting.

