# Component ID Mapping: Code to Contentful

This document shows the mapping between component IDs used in the refactored code and the actual Contentful component IDs.

## Mapping Table

| Code Component ID | Contentful Component ID | Status |
|------------------|------------------------|--------|
| `screen-home` | `home_scaffold_background` | ✅ Exists |
| `screen-login` | `login_scaffold_background` | ✅ Exists |
| `screen-splash` | `splash_scaffold_background` | ✅ Exists |
| `screen-main` | `mainLayout_scaffold_background` | ✅ Exists |
| `screen-plans` | `plansView_scaffold_background` | ❌ Missing |
| `screen-support` | `support_scaffold_background` | ❌ Missing |
| `screen-previous-orders` | `previousOrders_scaffold_background` | ✅ Exists |
| `text-title` | `home_title_text` or `login_title_text` | ⚠️ Screen-specific |
| `text-body` | `home_description_text` or `home_subtitle_text` | ⚠️ Screen-specific |
| `text-hint` | `login_inputHint_text` | ✅ Exists |
| `text-secondary` | Various screen-specific | ⚠️ Screen-specific |
| `button-primary` | `login_signInButton_text` (for text) | ⚠️ Partial |
| `button-danger` | `home_signOutButton_background` | ✅ Exists |
| `button-google` | `login_googleButton_background` | ✅ Exists |
| `button-apple` | `login_appleButton_background` | ✅ Exists |
| `button-text` | `login_signInButton_text` | ✅ Exists |
| `icon-secondary` | Various | ❌ Missing |
| `icon-progress` | `splash_loadingIndicator_color` | ✅ Exists |
| `snackbar-success` | `login_successSnackbar_background` | ✅ Exists |
| `snackbar-error` | `login_errorSnackbar_background` | ✅ Exists |
| `input-field` | `login_input_background` | ✅ Exists |
| `link-primary` | N/A | ❌ Missing |
| `menu-background` | `mainLayout_hamburgerMenu_background` | ✅ Exists |
| `overlay-barrier` | `mainLayout_dialogBarrier` | ✅ Exists |
| `tab-container` | N/A | ❌ Missing |

## Solution Options

### Option 1: Create Generic/Common Component IDs (Recommended)
Create generic component IDs that can be reused across screens:
- `common_title_text` (for `text-title`)
- `common_body_text` (for `text-body`)
- `common_hint_text` (for `text-hint`)
- `common_secondary_text` (for `text-secondary`)
- `common_button_primary_background` (for `button-primary`)
- `common_icon_secondary` (for `icon-secondary`)
- `common_link_primary` (for `link-primary`)
- `common_tab_container_background` (for `tab-container`)

### Option 2: Update Code to Use Screen-Specific IDs
Update the code to use the existing screen-specific IDs (e.g., `home_title_text` instead of `text-title`).

**I recommend Option 1** as it's cleaner and allows for consistent theming across the app.

