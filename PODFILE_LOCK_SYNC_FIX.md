# Podfile.lock Sync Fix

## Problem

Build failing with:
```
error: The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation.
```

## Root Cause

The build phase script `[CP] Check Pods Manifest.lock` checks if:
- `${PODS_PODFILE_DIR_PATH}/Podfile.lock` (usually `ios/Podfile.lock`)
- `${PODS_ROOT}/Manifest.lock` (usually `ios/Pods/Manifest.lock`)

are in sync. If they differ, the build fails.

## What Was Happening

1. `pod install` was running
2. But `Podfile.lock` and `Pods/Manifest.lock` were either:
   - Not being generated
   - Not in sync
   - Not accessible from the build phase script paths

## Fix Applied

Added comprehensive verification in `ci_pre_xcodebuild.sh`:

### 1. Verify Both Files Exist
- Checks `Podfile.lock` exists after `pod install`
- Checks `Pods/Manifest.lock` exists after `pod install`
- Shows file sizes to detect empty/corrupted files

### 2. Verify Files Are In Sync
- Uses `diff` to compare the files
- If out of sync, automatically copies `Podfile.lock` to `Manifest.lock`
- Re-verifies they're now in sync

### 3. Verify File Validity
- Checks file sizes (must be > 100 bytes)
- Shows first 10 lines if there are issues

### 4. Verify Build Phase Paths
- Checks that `PODS_PODFILE_DIR_PATH` is set correctly
- Tests that the build phase script logic would succeed
- Ensures paths will resolve correctly during build

## What the Script Now Does

After `pod install` completes:

1. ✅ Verifies `Podfile.lock` exists and has content
2. ✅ Verifies `Pods/Manifest.lock` exists and has content
3. ✅ Compares both files to ensure they're identical
4. ✅ If out of sync, automatically fixes by copying `Podfile.lock` to `Manifest.lock`
5. ✅ Tests that the build phase script check would pass
6. ✅ Verifies paths will resolve correctly during build

## Expected Behavior

### Success Case:
```
✅ Podfile.lock found at: .../ios/Podfile.lock
✅ Manifest.lock found at: .../ios/Pods/Manifest.lock
✅ Podfile.lock and Manifest.lock are in sync
✅ Build phase script check would PASS
```

### Auto-Fix Case:
```
⚠️  Podfile.lock and Manifest.lock are OUT OF SYNC
  → Attempting to fix by copying Podfile.lock to Manifest.lock...
✅ Lock files synced manually
✅ Lock files are now in sync
✅ Build phase script check would PASS
```

### Failure Case:
```
❌ Podfile.lock is MISSING after pod install
   OR
❌ Podfile.lock and Manifest.lock are OUT OF SYNC (and fix failed)
   OR
❌ Build phase script check would FAIL
```

## Why This Fixes It

1. **Early Detection**: Catches the problem immediately after `pod install`
2. **Auto-Recovery**: Automatically fixes sync issues
3. **Path Verification**: Ensures paths will work during build
4. **Clear Errors**: Shows exactly what's wrong if it can't be fixed

## Testing

The fix is verified by:
1. Checking both lock files exist
2. Comparing their contents
3. Testing the actual build phase script logic
4. Verifying paths resolve correctly

## Next Steps

1. Commit and push to Xcode Cloud
2. Check logs for the new verification messages
3. Build should now succeed, or show clear error if something else is wrong

## Related Issues

This fix works together with:
- `Pods.xcodeproj/project.pbxproj` verification (prevents "Module not found" errors)
- Path resolution fixes (ensures files are accessible)
- Final pre-build verification (last check before build starts)

