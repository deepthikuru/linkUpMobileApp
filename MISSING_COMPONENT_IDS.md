# Missing Component IDs in Contentful

This document lists the component IDs that are used in the refactored code but are **missing** from your Contentful setup.

## Component IDs Used in Code vs Contentful

The refactored code uses a **simpler naming convention** (e.g., `screen-home`, `text-title`) while your Contentful uses a **more specific naming convention** (e.g., `home_scaffold_background`, `home_title_text`).

## Missing Component IDs

You need to create these component IDs in Contentful:

### Screen Backgrounds (7 missing)
| Component ID Used in Code | Suggested Contentful ID | Fallback Color | Notes |
|--------------------------|------------------------|----------------|-------|
| `screen-home` | `home_scaffold_background` ✅ | `#FFFFFF` | Already exists! |
| `screen-login` | `login_scaffold_background` ✅ | `#FFFFFF` | Already exists! |
| `screen-splash` | `splash_scaffold_background` ✅ | `#FFFFFF` | Already exists! |
| `screen-main` | `mainLayout_scaffold_background` ✅ | `#FFFFFF` | Already exists! |
| `screen-plans` | `plansView_scaffold_background` | `#FFFFFF` | **MISSING** |
| `screen-support` | `support_scaffold_background` | `#FFFFFF` | **MISSING** |
| `screen-previous-orders` | `previousOrders_scaffold_background` ✅ | `#FFFFFF` | Already exists! |

### Text Colors (4 missing)
| Component ID Used in Code | Suggested Contentful ID | Fallback Color | Notes |
|--------------------------|------------------------|----------------|-------|
| `text-title` | `text_title` or `common_title_text` | `#000000` | **MISSING** - Used for main titles |
| `text-body` | `text_body` or `common_body_text` | `#757575` | **MISSING** - Used for body text |
| `text-hint` | `text_hint` or `common_hint_text` | `#9E9E9E` | **MISSING** - Used for input hints |
| `text-secondary` | `text_secondary` or `common_secondary_text` | `#757575` | **MISSING** - Used for secondary text |

### Button Colors (5 missing)
| Component ID Used in Code | Suggested Contentful ID | Fallback Color | Notes |
|--------------------------|------------------------|----------------|-------|
| `button-primary` | `button_primary_background` | `#808080` | **MISSING** - Primary button background |
| `button-danger` | `button_danger_background` | `#FF0000` | **MISSING** - Danger button background |
| `button-google` | `login_googleButton_background` ✅ | `#FF0000` | Already exists! |
| `button-apple` | `login_appleButton_background` ✅ | `#000000` | Already exists! |
| `button-text` | `button_text` or `common_button_text` | `#FFFFFF` | **MISSING** - Button text color |

### Icon Colors (2 missing)
| Component ID Used in Code | Suggested Contentful ID | Fallback Color | Notes |
|--------------------------|------------------------|----------------|-------|
| `icon-secondary` | `icon_secondary` or `common_icon_secondary` | `#757575` | **MISSING** - Secondary icons |
| `icon-progress` | `splash_loadingIndicator_color` ✅ | `#9E9E9E` | Already exists! |

### Snackbar Colors (2 missing)
| Component ID Used in Code | Suggested Contentful ID | Fallback Color | Notes |
|--------------------------|------------------------|----------------|-------|
| `snackbar-success` | `login_successSnackbar_background` ✅ | `#4CAF50` | Already exists! |
| `snackbar-error` | `login_errorSnackbar_background` ✅ | `#F44336` | Already exists! |

### Input Fields (1 missing)
| Component ID Used in Code | Suggested Contentful ID | Fallback Color | Notes |
|--------------------------|------------------------|----------------|-------|
| `input-field` | `login_input_background` ✅ | `#FFFFFF` | Already exists! |

### Links (1 missing)
| Component ID Used in Code | Suggested Contentful ID | Fallback Color | Notes |
|--------------------------|------------------------|----------------|-------|
| `link-primary` | `link_primary` or `common_link_primary` | `#014D7D` | **MISSING** - Primary link color |

### Menu/Overlay (2 missing)
| Component ID Used in Code | Suggested Contentful ID | Fallback Color | Notes |
|--------------------------|------------------------|----------------|-------|
| `menu-background` | `mainLayout_hamburgerMenu_background` ✅ | `#FFFFFF` | Already exists! |
| `overlay-barrier` | `mainLayout_dialogBarrier` ✅ | `#000000` (54% opacity) | Already exists! |

### Tab Container (1 missing)
| Component ID Used in Code | Suggested Contentful ID | Fallback Color | Notes |
|--------------------------|------------------------|----------------|-------|
| `tab-container` | `tab_container_background` | `#E0E0E0` | **MISSING** - Tab selector background |

---

## Summary

### Already Exist in Contentful (11):
- ✅ `home_scaffold_background` (maps to `screen-home`)
- ✅ `login_scaffold_background` (maps to `screen-login`)
- ✅ `splash_scaffold_background` (maps to `screen-splash`)
- ✅ `mainLayout_scaffold_background` (maps to `screen-main`)
- ✅ `previousOrders_scaffold_background` (maps to `screen-previous-orders`)
- ✅ `login_googleButton_background` (maps to `button-google`)
- ✅ `login_appleButton_background` (maps to `button-apple`)
- ✅ `splash_loadingIndicator_color` (maps to `icon-progress`)
- ✅ `login_successSnackbar_background` (maps to `snackbar-success`)
- ✅ `login_errorSnackbar_background` (maps to `snackbar-error`)
- ✅ `login_input_background` (maps to `input-field`)
- ✅ `mainLayout_hamburgerMenu_background` (maps to `menu-background`)
- ✅ `mainLayout_dialogBarrier` (maps to `overlay-barrier`)

### Missing from Contentful (15):
1. ❌ `plansView_scaffold_background` (for `screen-plans`)
2. ❌ `support_scaffold_background` (for `screen-support`)
3. ❌ `text_title` or `common_title_text` (for `text-title`)
4. ❌ `text_body` or `common_body_text` (for `text-body`)
5. ❌ `text_hint` or `common_hint_text` (for `text-hint`)
6. ❌ `text_secondary` or `common_secondary_text` (for `text-secondary`)
7. ❌ `button_primary_background` (for `button-primary`)
8. ❌ `button_danger_background` (for `button-danger`)
9. ❌ `button_text` or `common_button_text` (for `button-text`)
10. ❌ `icon_secondary` or `common_icon_secondary` (for `icon-secondary`)
11. ❌ `link_primary` or `common_link_primary` (for `link-primary`)
12. ❌ `tab_container_background` (for `tab-container`)

---

## Recommended Solution

You have two options:

### Option 1: Create Missing Component IDs in Contentful (Recommended)
Create the 12 missing component IDs listed above in Contentful. This maintains the current code structure.

### Option 2: Update Code to Use Existing Contentful IDs
Update the refactored code to use the existing Contentful component IDs. This would require changing the code to match your Contentful naming convention.

**I recommend Option 1** as it's simpler and maintains consistency with the refactored code.

---

## Quick Import Template

Here's a JSON snippet you can add to your `component-colors.json` file for the missing entries:

```json
{
  "componentId": "plansView_scaffold_background",
  "backgroundColor": "#FFFFFF"
},
{
  "componentId": "support_scaffold_background",
  "backgroundColor": "#FFFFFF"
},
{
  "componentId": "text_title",
  "textColor": "#000000"
},
{
  "componentId": "text_body",
  "textColor": "#757575"
},
{
  "componentId": "text_hint",
  "textColor": "#9E9E9E"
},
{
  "componentId": "text_secondary",
  "textColor": "#757575"
},
{
  "componentId": "button_primary_background",
  "backgroundColor": "#808080"
},
{
  "componentId": "button_danger_background",
  "backgroundColor": "#FF0000"
},
{
  "componentId": "button_text",
  "textColor": "#FFFFFF"
},
{
  "componentId": "icon_secondary",
  "iconColor": "#757575"
},
{
  "componentId": "link_primary",
  "textColor": "#014D7D"
},
{
  "componentId": "tab_container_background",
  "backgroundColor": "#E0E0E0"
}
```

---

## Next Steps

1. **Create the 12 missing component IDs** in Contentful using the naming convention above
2. **OR** let me know if you'd prefer to update the code to match your existing Contentful IDs
3. Test the app to ensure all colors load correctly from Contentful

