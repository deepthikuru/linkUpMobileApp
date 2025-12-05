# Component Colors - Contentful Setup Guide

This document lists all component IDs that need to be added to Contentful as `componentColor` content type entries.

## Content Type Structure

Create a content type named **`componentColor`** with the following fields:
- `componentId` (Short text, unique, required) - The component identifier
- `backgroundColor` (Short text, hex format, optional)
- `textColor` (Short text, hex format, optional)
- `borderColor` (Short text, hex format, optional)
- `iconColor` (Short text, hex format, optional)
- `shadowColor` (Short text, hex format, optional)
- `gradientStartColor` (Short text, hex format, optional)
- `gradientEndColor` (Short text, hex format, optional)

---

## Component IDs to Create in Contentful

### MAIN SCREEN (`main_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `main_elevatedButton_background` | Main screen elevated button background | #014D7D | | |
| `main_elevatedButton_text` | Main screen elevated button text | | #FFFFFF | |

---

### HOME PAGE (`home_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `home_scaffold_background` | Home page background | #FFFFFF | | |
| `home_title_text` | "Welcome!" title text | | #000000 | |
| `home_subtitle_text` | User info subtitle text | | #757575 | |
| `home_sectionTitle_text` | "Our Plans" section title | | #000000 | |
| `home_description_text` | Description text | | #757575 | |
| `home_signOutButton_background` | Sign out button background | #FF0000 | | |
| `home_signOutButton_text` | Sign out button text | | #FFFFFF | |

---

### LOGIN PAGE (`login_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `login_scaffold_background` | Login page background | #FFFFFF | | |
| `login_title_text` | "Sign In" title | | #000000 | |
| `login_inputHint_text` | Input field hint text | | #757575 | |
| `login_input_background` | Input field background | #FFFFFF | | |
| `login_signInButton_disabledBackground` | Sign in button (disabled) background | #757575 | | |
| `login_signInButton_text` | Sign in button text | | #FFFFFF | |
| `login_loadingIndicator_color` | Loading indicator color | | | iconColor: #FFFFFF |
| `login_separator_text` | "OR" separator text | | #757575 | |
| `login_googleButton_background` | Google sign-in button background | #FF0000 | | |
| `login_googleButton_text` | Google sign-in button text | | #FFFFFF | |
| `login_googleButton_icon` | Google sign-in icon | | | iconColor: #FFFFFF |
| `login_appleButton_background` | Apple sign-in button background | #000000 | | |
| `login_appleButton_text` | Apple sign-in button text | | #FFFFFF | |
| `login_appleButton_icon` | Apple sign-in icon | | | iconColor: #FFFFFF |
| `login_footerText_text` | Footer "New to Telgoo5 Mobile?" text | | #000000 | |
| `login_errorSnackbar_background` | Error snackbar background | #FF0000 | | |
| `login_successSnackbar_background` | Success snackbar background | #4CAF50 | | |

---

### SPLASH SCREEN (`splash_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `splash_scaffold_background` | Splash screen background | #FFFFFF | | |
| `splash_loadingIndicator_color` | Loading indicator color | | | iconColor: #757575 |

---

### GRADIENT BUTTON (`gradientButton_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `gradientButton_gradientStart` | Gradient button gradient start | | | gradientStartColor: #014D7D |
| `gradientButton_gradientEnd` | Gradient button gradient end | | | gradientEndColor: #0C80C3 |
| `gradientButton_disabledBackground` | Disabled button background | #757575 | | |
| `gradientButton_text` | Button text | | #FFFFFF | |
| `gradientButton_loadingIndicator` | Loading indicator | | | iconColor: #FFFFFF |

---

### PLAN CARD (`planCard_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `planCard_background` | Plan card background | #FFFFFF | | |
| `planCard_border` | Plan card border (unselected) | | | borderColor: #757575 |
| `planCard_borderSelected` | Plan card border (selected) | | | borderColor: #014D7D |
| `planCard_badgeGradientStart` | Badge gradient start (selected) | | | gradientStartColor: #014D7D |
| `planCard_badgeGradientEnd` | Badge gradient end (selected) | | | gradientEndColor: #0C80C3 |
| `planCard_badgeBackground` | Badge background (unselected) | #E3F2FD | | |
| `planCard_badgeBorder` | Badge border (unselected) | | | borderColor: #66B3FF |
| `planCard_badgeTextSelected` | Badge text (selected) | | #FFFFFF | |
| `planCard_badgeText` | Badge text (unselected) | | #014D7D | |
| `planCard_price_text` | Price text | | #014D7D | |
| `planCard_planNameSmall_text` | Plan name (small variant) | | #424242 | |
| `planCard_planName_text` | Plan name text | | #757575 | |
| `planCard_divider` | Feature divider | | | borderColor: #E0E0E0 |
| `planCard_featureIcon` | Feature icon | | | iconColor: #014D7D |
| `planCard_featureLabel_text` | Feature label text | | #757575 | |

---

### APP HEADER (`appHeader_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `appHeader_gradientStart` | Header gradient start | | | gradientStartColor: #014D7D |
| `appHeader_gradientEnd` | Header gradient end | | | gradientEndColor: #0C80C3 |
| `appHeader_backIcon` | Back button icon (no gradient) | | | iconColor: #000000 |
| `appHeader_backIcon_gradient` | Back button icon (with gradient) | | | iconColor: #FFFFFF |
| `appHeader_titleText` | Title text (no gradient) | | #000000 | |
| `appHeader_titleText_gradient` | Title text (with gradient) | | #FFFFFF | |
| `appHeader_zipCodeText` | Zip code text (no gradient) | | #000000 | |
| `appHeader_zipCodeText_gradient` | Zip code text (with gradient) | | #FFFFFF | |
| `appHeader_zipIcon` | Zip code dropdown icon (no gradient) | | | iconColor: #757575 |
| `appHeader_zipIcon_gradient` | Zip code dropdown icon (with gradient) | | | iconColor: #FFFFFF |
| `appHeader_menuIcon` | Menu icon (no gradient) | | | iconColor: #000000 |
| `appHeader_menuIcon_gradient` | Menu icon (with gradient) | | | iconColor: #FFFFFF |

---

### APP FOOTER (`appFooter_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `appFooter_background` | Footer background | #FFFFFF | | |
| `appFooter_shadow` | Footer shadow | | | shadowColor: #1A000000 |
| `appFooter_tabIcon_selected` | Tab icon (selected) | | | iconColor: #FDC710 |
| `appFooter_tabIcon` | Tab icon (unselected) | | | iconColor: #757575 |
| `appFooter_tabLabel_selected` | Tab label (selected) | | #FDC710 | |
| `appFooter_tabLabel` | Tab label (unselected) | | #757575 | |

---

### BOTTOM ACTION BAR (`bottomActionBar_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `bottomActionBar_background` | Action bar background | #FFFFFF | | |

---

### STEP INDICATOR (`stepIndicator_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `stepIndicator_gradientStart` | Step indicator gradient start | | | gradientStartColor: #014D7D |
| `stepIndicator_gradientEnd` | Step indicator gradient end | | | gradientEndColor: #0C80C3 |
| `stepIndicator_text` | Step indicator text | | #FFFFFF | |

---

### STEP NAVIGATION CONTAINER (`stepNavigation_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `stepNavigation_scaffold_background` | Scaffold background | #FFFFFF | | |
| `stepNavigation_backIcon` | Back button icon | | | iconColor: #FDC710 |
| `stepNavigation_cancelIcon` | Cancel button icon | | | iconColor: #FDC710 |
| `stepNavigation_cancelButtonText` | Cancel dialog "Yes" button text | | #FF0000 | |
| `stepNavigation_footer_background` | Footer container background | #FFFFFF | | |

---

### ORDER CARD (`orderCard_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `orderCard_background` | Order card background | #FFFFFF | | |
| `orderCard_border` | Order card border | | | borderColor: #E0E0E0 |
| `orderCard_status_completed` | Status indicator (completed) | | | iconColor: #4CAF50 |
| `orderCard_status_cancelled` | Status indicator (cancelled) | | | iconColor: #FF0000 |
| `orderCard_status_inProgress` | Status indicator (in progress) | | | iconColor: #FF9800 |
| `orderCard_date_text` | Date text | | #757575 | |
| `orderCard_phoneNumber_text` | Phone number text | | #757575 | |
| `orderCard_chevronIcon` | Chevron icon | | | iconColor: #757575 |

---

### PLAN CAROUSEL (`planCarousel_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `planCarousel_indicatorActive_gradientStart` | Active page indicator gradient start | | | gradientStartColor: #014D7D |
| `planCarousel_indicatorActive_gradientEnd` | Active page indicator gradient end | | | gradientEndColor: #0C80C3 |
| `planCarousel_indicatorInactive` | Inactive page indicator | #E0E0E0 | | |

---

### OFFLINE BANNER (`offlineBanner_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `offlineBanner_background` | Banner background | #FFF9E6 | | |
| `offlineBanner_icon` | Banner icon | | | iconColor: #FDC710 |
| `offlineBanner_text` | Banner text | | #757575 | |

---

### MAIN LAYOUT (`mainLayout_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `mainLayout_scaffold_background` | Scaffold background | #FFFFFF | | |
| `mainLayout_dialogBarrier` | Dialog barrier | | | shadowColor: #88000000 |
| `mainLayout_hamburgerMenu_background` | Hamburger menu background | #FFFFFF | | |

---

### START ORDER VIEW (`startOrder_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `startOrder_loadingIndicator_color` | Loading indicator | | | iconColor: #FDC710 |
| `startOrder_loadingText_text` | Loading text | | #757575 | |
| `startOrder_heroTitle_text` | Hero title "Connect to the World..." | | #212121 | |
| `startOrder_heroSubtitle_gradientStart` | Hero subtitle gradient start | | | gradientStartColor: #014D7D |
| `startOrder_heroSubtitle_gradientEnd` | Hero subtitle gradient end | | | gradientEndColor: #0C80C3 |
| `startOrder_welcomeTitle_text` | Welcome back title | | #000000 | |
| `startOrder_welcomeSubtitle_text` | Welcome subtitle | | #757575 | |
| `startOrder_completeSetup_background` | Complete setup container background | #FFF9E6 | | |
| `startOrder_completeSetup_border` | Complete setup container border | | | borderColor: #FFE082 |
| `startOrder_completeSetup_title_text` | Complete setup title | | #212121 | |
| `startOrder_completeSetup_subtitle_text` | Complete setup subtitle | | #757575 | |
| `startOrder_completeSetup_indicator` | Complete setup indicator dots | #FFE082 | | |
| `startOrder_availablePlans_background` | Available plans container background | #F5F5F5 | | |
| `startOrder_availablePlans_title_text` | Available plans title | | #000000 | |
| `startOrder_recentOrders_background` | Recent orders container background | #F5F5F5 | | |
| `startOrder_recentOrders_title_text` | Recent orders title | | #000000 | |
| `startOrder_recentOrders_count_text` | Order count text | | #757575 | |
| `startOrder_viewAllOrders_icon` | View all orders icon | | | iconColor: #014D7D |
| `startOrder_viewAllOrders_text` | View all orders text | | #014D7D | |
| `startOrder_incompleteOrder_background` | Incomplete order card background | #FFFFFF | | |
| `startOrder_incompleteOrder_border` | Incomplete order card border | | | borderColor: #E0E0E0 |
| `startOrder_incompleteOrder_shadow` | Incomplete order card shadow | | | shadowColor: #0D000000 |
| `startOrder_incompleteOrder_title_text` | Incomplete order title | | #212121 | |
| `startOrder_incompleteOrder_date_text` | Incomplete order date | | #757575 | |
| `startOrder_incompleteOrder_badge_background` | Incomplete badge background | #FFF3E0 | | |
| `startOrder_incompleteOrder_badge_text` | Incomplete badge text | | #FF9800 | |
| `startOrder_incompleteOrder_infoIcon` | Info icon (phone, SIM, device) | | | iconColor: #FDC710 |
| `startOrder_incompleteOrder_infoText` | Info text (phone, SIM, device) | | #212121 | |
| `startOrder_incompleteOrder_taskIcon` | Task error icon | | | iconColor: #FF9800 |
| `startOrder_incompleteOrder_taskText` | Task text | | #212121 | |
| `startOrder_incompleteOrder_taskMore_text` | "X more tasks" text | | #757575 | |
| `startOrder_viewDetailsButton_background` | View details button background | #FDC710 | | |
| `startOrder_viewDetailsButton_text` | View details button text | | #FFFFFF | |
| `startOrder_viewDetailsButton_icon` | View details button icon | | | iconColor: #FFFFFF |
| `startOrder_completeSetupButton_gradientStart` | Complete setup button gradient start | | | gradientStartColor: #014D7D |
| `startOrder_completeSetupButton_gradientEnd` | Complete setup button gradient end | | | gradientEndColor: #0C80C3 |
| `startOrder_completeSetupButton_text` | Complete setup button text | | #FFFFFF | |
| `startOrder_planDetails_background` | Plan details modal background | #00000000 | | |
| `startOrder_planDetails_barrier` | Plan details modal barrier | | | shadowColor: #8A000000 |

---

### ADDRESS INFO SHEET (`addressInfo_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `addressInfo_errorButton_background` | Error button background | #FF0000 | | |

---

### PROFILE VIEW (`profile_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `profile_statusIndicator_active` | Active status indicator | | | iconColor: #4CAF50 |
| `profile_statusIndicator_inactive` | Inactive status indicator | | | iconColor: #FF0000 |
| `profile_notificationBadge_background` | Notification badge background | #FF9800 | | |
| `profile_errorButton_background` | Error button background | #FF0000 | |

---

### PROFILE - HAMBURGER MENU (`hamburgerMenu_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `hamburgerMenu_logoutIcon` | Logout icon | | | iconColor: #FF0000 |
| `hamburgerMenu_logoutText` | Logout text | | #FF0000 | |

---

### PROFILE - INTERNATIONAL LONG DISTANCE (`international_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `international_container_background` | Container background | #F5F5F5 | | |
| `international_container_border` | Container border | | | borderColor: #E0E0E0 |
| `international_button_background` | Button background | #FFFFFF | | |
| `international_button_text` | Button text | | #757575 | |
| `international_searchIcon` | Search icon | | | iconColor: #757575 |
| `international_phoneIcon` | Phone icon | | | iconColor: #FFFFFF |
| `international_phoneButton_gradientStart` | Phone button gradient start | | | gradientStartColor: #014D7D |
| `international_phoneButton_gradientEnd` | Phone button gradient end | | | gradientEndColor: #0C80C3 |

---

### PROFILE - PRIVACY POLICY (`privacy_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `privacy_icon` | Privacy icon | | | iconColor: #757575 | |

---

### PROFILE - TERMS AND CONDITIONS (`terms_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `terms_icon` | Terms icon | | | iconColor: #757575 | |

---

### PROFILE - PREVIOUS ORDERS (`previousOrders_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `previousOrders_scaffold_background` | Scaffold background | #FFFFFF | | |
| `previousOrders_orderCard_border` | Order card border | | | borderColor: #E0E0E0 |

---

### PLANS VIEW (`plansView_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `plansView_modal_background` | Modal background | #00000000 | | |
| `plansView_modal_barrier` | Modal barrier | | | shadowColor: #8A000000 |
| `plansView_modal_content_background` | Modal content background | #FFFFFF | | |
| `plansView_filterIcon` | Filter icon | | | iconColor: #757575 |
| `plansView_filterTitle_text` | Filter title text | | #424242 | |
| `plansView_filterSubtitle_text` | Filter subtitle text | | #757575 | |

---

### ORDER FLOW - NUMBER PORTING (`numberPorting_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `numberPorting_warning_background` | Warning banner background | #FF0000 | | |

---

### ORDER FLOW - PORTING VIEW (`porting_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `porting_warning_background` | Warning banner background | #FF0000 | | |

---

### ORDER FLOW - DEVICE COMPATIBILITY (`deviceCompatibility_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `deviceCompatibility_button_background` | Button background | #00000000 | | |
| `deviceCompatibility_loadingIndicator` | Loading indicator | | | iconColor: #FFFFFF |
| `deviceCompatibility_icon` | Device icon | | | iconColor: #FFFFFF |
| `deviceCompatibility_text` | Device text | | #FFFFFF | |

---

### ORDER FLOW - CONTACT INFO (`contactInfo_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `contactInfo_button_text` | Button text | | #FFFFFF | |

---

### ORDER FLOW - NUMBER SELECTION (`numberSelection_*`)

| Component ID | Description | Background Color | Text Color | Other Colors |
|-------------|-------------|------------------|------------|--------------|
| `numberSelection_radio_unselected` | Radio button (unselected) | | | borderColor: #E0E0E0 |
| `numberSelection_radio_selected` | Radio button (selected) | | | borderColor: #E0E0E0 |
| `numberSelection_availabilityIcon_available` | Availability icon (available) | | | iconColor: #4CAF50 |
| `numberSelection_availabilityIcon_unavailable` | Availability icon (unavailable) | | | iconColor: #FF0000 |
| `numberSelection_statusIcon_available` | Status icon (available) | | | iconColor: #4CAF50 |
| `numberSelection_statusIcon_unavailable` | Status icon (unavailable) | | | iconColor: #FF0000 |
| `numberSelection_warningIcon` | Warning icon | | | iconColor: #FF9800 |
| `numberSelection_warningText` | Warning text | | #FF9800 |
| `numberSelection_selectedText` | Selected number text | | #757575 |
| `numberSelection_button_text` | Button text | | #FFFFFF or #000000 |

---

## Implementation Notes

1. **Color Format**: All colors should be in hex format (e.g., `#FFFFFF` or `FFFFFF`)
2. **Optional Fields**: Not all fields need to be filled for every component. Only fill the fields that are relevant.
3. **Gradients**: For gradient components, fill both `gradientStartColor` and `gradientEndColor`
4. **Fallback**: If a component color is not found in Contentful, the app will fall back to default colors from `AppColorsModel`

## Quick Reference Color Values

Based on your existing App Colors:
- Yellow Accent: `#FDC710`
- Red Accent: `#FF0000`
- Main Blue: `#014D7D`
- Second Blue: `#0C80C3`
- White: `#FFFFFF`
- Black: `#000000`
- Grey: `#757575`
- Light Grey: `#E0E0E0`
- Success: `#4CAF50`
- Error: `#FF0000`
- Warning/Orange: `#FF9800`

