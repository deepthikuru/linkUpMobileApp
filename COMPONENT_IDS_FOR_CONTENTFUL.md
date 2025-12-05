# Component IDs for Contentful Setup

This document lists all component IDs that need to be configured in Contentful for the LinkUp Mobile App. Each component ID should have corresponding color values defined in Contentful's Component Colors content type.

## Component ID Naming Convention

- **Screen backgrounds**: `screen-{name}` (e.g., `screen-home`, `screen-login`)
- **Text colors**: `text-{type}` (e.g., `text-title`, `text-body`)
- **Button colors**: `button-{type}` (e.g., `button-primary`, `button-danger`)
- **Icon colors**: `icon-{type}` (e.g., `icon-primary`, `icon-secondary`)
- **Snackbar colors**: `snackbar-{type}` (e.g., `snackbar-success`, `snackbar-error`)
- **Input fields**: `input-{type}` (e.g., `input-field`)
- **Links**: `link-{type}` (e.g., `link-primary`)
- **Overlays/Menus**: `{type}-background` (e.g., `menu-background`, `overlay-barrier`)
- **Tab containers**: `tab-{type}` (e.g., `tab-container`)

---

## Screen Background Colors

These component IDs are used for `Scaffold.backgroundColor` in various screens:

| Component ID | Screen/Usage | Fallback Color | Notes |
|-------------|--------------|---------------|-------|
| `screen-home` | Home page screen | `#FFFFFF` (White) | Main home screen background |
| `screen-login` | Login page | `#FFFFFF` (White) | Login screen background |
| `screen-splash` | Splash screen | `#FFFFFF` (White) | App splash/loading screen |
| `screen-main` | Main layout | `#FFFFFF` (White) | Main app layout background |
| `screen-plans` | Plans view | `#FFFFFF` (White) | Plans listing screen |
| `screen-support` | Support view | `#FFFFFF` (White) | Support/help screen |
| `screen-previous-orders` | Previous orders view | `#FFFFFF` (White) | Order history screen |

---

## Text Colors

These component IDs are used for text styling throughout the app:

| Component ID | Usage | Fallback Color | Notes |
|-------------|-------|---------------|-------|
| `text-title` | Main titles, headings | `#000000` (Black) | Primary text for titles |
| `text-body` | Body text, descriptions | `#757575` (Grey) | Secondary text content |
| `text-hint` | Input field hints | `#9E9E9E` (Grey) | Placeholder text |
| `text-secondary` | Secondary text | `#757575` (Grey) | Less prominent text |
| `text-caption` | Small captions | `#9E9E9E` (Grey) | Fine print, captions |

---

## Button Colors

These component IDs are used for button backgrounds and text:

| Component ID | Usage | Fallback Color | Notes |
|-------------|-------|---------------|-------|
| `button-primary` | Primary action buttons | `#808080` (Grey) | Main CTA buttons |
| `button-secondary` | Secondary buttons | Varies | Alternative actions |
| `button-danger` | Destructive actions | `#FF0000` (Red) | Delete, sign out, etc. |
| `button-google` | Google sign-in button | `#FF0000` (Red) | Google authentication |
| `button-apple` | Apple sign-in button | `#000000` (Black) | Apple authentication |
| `button-text` | Button text color | `#FFFFFF` (White) | Text on colored buttons |

**Note**: For buttons, you may need both `backgroundColor` and `textColor`. The app uses:
- `getComponentBackgroundColor(context, 'button-primary')` for background
- `getComponentTextColor(context, 'button-primary')` for text

---

## Icon Colors

These component IDs are used for icon coloring:

| Component ID | Usage | Fallback Color | Notes |
|-------------|-------|---------------|-------|
| `icon-primary` | Primary icons | `#000000` (Black) | Main icon color |
| `icon-secondary` | Secondary icons | `#757575` (Grey) | Less prominent icons |
| `icon-progress` | Loading indicators | `#9E9E9E` (Grey) | Progress spinners |

---

## Snackbar Colors

These component IDs are used for notification snackbars:

| Component ID | Usage | Fallback Color | Notes |
|-------------|-------|---------------|-------|
| `snackbar-success` | Success messages | `#4CAF50` (Green) | Positive feedback |
| `snackbar-error` | Error messages | `#F44336` (Red) | Error notifications |
| `snackbar-warning` | Warning messages | `#FF9800` (Orange) | Warning notifications |
| `snackbar-info` | Info messages | `#2196F3` (Blue) | Informational messages |

---

## Input Field Colors

These component IDs are used for form inputs:

| Component ID | Usage | Fallback Color | Notes |
|-------------|-------|---------------|-------|
| `input-field` | Input field background | `#FFFFFF` (White) | Text field background |

---

## Link Colors

These component IDs are used for clickable links:

| Component ID | Usage | Fallback Color | Notes |
|-------------|-------|---------------|-------|
| `link-primary` | Primary links | `#014D7D` (Main Blue) | Clickable text links |

---

## Menu and Overlay Colors

These component IDs are used for menus and overlays:

| Component ID | Usage | Fallback Color | Notes |
|-------------|-------|---------------|-------|
| `menu-background` | Hamburger menu | `#FFFFFF` (White) | Side menu background |
| `overlay-barrier` | Modal overlays | `#000000` with 54% opacity | Dialog/modal backdrop |

---

## Tab Container Colors

These component IDs are used for tab containers:

| Component ID | Usage | Fallback Color | Notes |
|-------------|-------|---------------|-------|
| `tab-container` | Tab selector background | `#E0E0E0` (Light Grey) | Tab button container |

---

## Color Field Types in Component Colors

Each component color entry in Contentful should have the following fields:

1. **componentId** (Text) - The unique identifier (e.g., `screen-home`, `text-title`)
2. **backgroundColor** (Text) - Hex color code (e.g., `#FFFFFF` or `FFFFFF`)
3. **textColor** (Text) - Hex color code for text
4. **borderColor** (Text) - Hex color code for borders (optional)
5. **iconColor** (Text) - Hex color code for icons (optional)
6. **shadowColor** (Text) - Hex color code for shadows (optional)
7. **gradientStartColor** (Text) - Hex color code for gradient start (optional)
8. **gradientEndColor** (Text) - Hex color code for gradient end (optional)

---

## Implementation Notes

### How Colors are Retrieved

The app uses the following helper methods from `AppTheme`:

```dart
// Get background color
AppTheme.getComponentBackgroundColor(context, 'component-id', fallback: Colors.white)

// Get text color
AppTheme.getComponentTextColor(context, 'component-id', fallback: Colors.black)

// Get border color
AppTheme.getComponentBorderColor(context, 'component-id', fallback: Colors.grey)

// Get icon color
AppTheme.getComponentIconColor(context, 'component-id', fallback: Colors.black)

// Get generic color
AppTheme.getComponentColor(context, 'component-id', 'background', fallback: Colors.white)
```

### Fallback Colors

All component color lookups include fallback colors. If Contentful is unavailable or a component ID is not found, the app will use the fallback color to ensure the UI remains functional.

### Caching

Component colors are cached locally for 24 hours. The app will:
1. Load from cache immediately on startup
2. Fetch fresh colors from Contentful in the background
3. Update the UI when new colors are available

---

## Required Contentful Setup

1. **Content Type**: Ensure you have a `componentColor` content type in Contentful with the fields listed above.

2. **Entries**: Create entries for each component ID listed in this document.

3. **Color Format**: Use hex color codes without the `#` prefix, or with it - both formats are supported.

4. **Testing**: After setting up in Contentful:
   - Verify colors load correctly
   - Test with Contentful offline to ensure fallbacks work
   - Check that color updates reflect in the app after cache refresh

---

## Quick Reference: All Component IDs

### Screens (8)
- `screen-home`
- `screen-login`
- `screen-splash`
- `screen-main`
- `screen-plans`
- `screen-support`
- `screen-previous-orders`

### Text (5)
- `text-title`
- `text-body`
- `text-hint`
- `text-secondary`
- `text-caption`

### Buttons (6)
- `button-primary`
- `button-secondary`
- `button-danger`
- `button-google`
- `button-apple`
- `button-text`

### Icons (3)
- `icon-primary`
- `icon-secondary`
- `icon-progress`

### Snackbars (4)
- `snackbar-success`
- `snackbar-error`
- `snackbar-warning`
- `snackbar-info`

### Inputs (1)
- `input-field`

### Links (1)
- `link-primary`

### Menus/Overlays (2)
- `menu-background`
- `overlay-barrier`

### Tabs (1)
- `tab-container`

**Total: 32 Component IDs**

---

## Example Contentful Entry

Here's an example of how to set up a component color entry in Contentful:

**Entry Title**: `screen-home`
**Content Type**: `componentColor`

**Fields**:
- `componentId`: `screen-home`
- `backgroundColor`: `FFFFFF` (or `#FFFFFF`)
- `textColor`: `000000` (or `#000000`)
- `borderColor`: (leave empty or set to default)
- `iconColor`: (leave empty or set to default)
- `shadowColor`: (leave empty or set to default)
- `gradientStartColor`: (leave empty)
- `gradientEndColor`: (leave empty)

---

## Maintenance

When adding new screens or components:
1. Use the naming convention defined above
2. Add the component ID to this document
3. Create the corresponding entry in Contentful
4. Test with fallback colors first, then verify Contentful integration

---

**Last Updated**: Generated automatically during refactoring
**App Version**: Current
**Contentful Content Type**: `componentColor`

