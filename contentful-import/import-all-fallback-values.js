/**
 * Contentful Complete Import Script
 * 
 * This script imports ALL fallback values (colors and text) into Contentful.
 * It creates/updates both componentColor and componentText entries.
 * 
 * Usage:
 *   1. Install dependencies: npm install contentful-management
 *   2. Set environment variables:
 *      - CONTENTFUL_SPACE_ID: Your Contentful space ID
 *      - CONTENTFUL_MANAGEMENT_TOKEN: Your Contentful Management API token
 *   3. Run: node import-all-fallback-values.js
 * 
 * Or pass as arguments:
 *   node import-all-fallback-values.js --space-id=YOUR_SPACE_ID --token=YOUR_TOKEN
 */

const contentful = require('contentful-management');
const fs = require('fs');
const path = require('path');

// ========== COLOR VALUES FROM FallbackValues ==========
const componentColors = [
  // Primary Colors
  { componentId: 'color_yellowAccent', backgroundColor: '#FDC710' },
  { componentId: 'color_redAccent', backgroundColor: '#FF0000' },
  { componentId: 'color_mainBlue', backgroundColor: '#014D7D' },
  { componentId: 'color_secondBlue', backgroundColor: '#0C80C3' },
  { componentId: 'color_appBackground', backgroundColor: '#FFFFFF' },
  { componentId: 'color_appText', textColor: '#000000' },
  
  // Status Colors
  { componentId: 'color_successColor', backgroundColor: '#4CAF50' },
  { componentId: 'color_successBackground', backgroundColor: '#E8F5E9' },
  { componentId: 'color_errorColor', backgroundColor: '#F44336' },
  { componentId: 'color_errorBackground', backgroundColor: '#FFEBEE' },
  { componentId: 'color_warningColor', backgroundColor: '#FDC710' },
  
  // UI Colors
  { componentId: 'color_borderColor', borderColor: '#E0E0E0' },
  { componentId: 'color_borderColorSelected', borderColor: '#0C80C3' },
  { componentId: 'color_textSecondary', textColor: '#757575' },
  { componentId: 'color_textTertiary', textColor: '#9E9E9E' },
  { componentId: 'color_disabledBackground', backgroundColor: '#F5F5F5' },
  { componentId: 'color_dividerColor', borderColor: '#E0E0E0' },
  { componentId: 'color_headerBackground', backgroundColor: '#014D7D' },
  { componentId: 'color_headerText', textColor: '#FFFFFF' },
  { componentId: 'color_headerIcon', iconColor: '#FFFFFF' },
  
  // Existing component colors (from previous import)
  { componentId: 'main_elevatedButton_background', backgroundColor: '#014D7D' },
  { componentId: 'main_elevatedButton_text', textColor: '#FFFFFF' },
  { componentId: 'home_scaffold_background', backgroundColor: '#FFFFFF' },
  { componentId: 'home_title_text', textColor: '#000000' },
  { componentId: 'home_subtitle_text', textColor: '#757575' },
  { componentId: 'home_sectionTitle_text', textColor: '#000000' },
  { componentId: 'home_description_text', textColor: '#757575' },
  { componentId: 'home_signOutButton_background', backgroundColor: '#FF0000' },
  { componentId: 'home_signOutButton_text', textColor: '#FFFFFF' },
  { componentId: 'home_seePlansButton_background', backgroundColor: '#014D7D' },
  { componentId: 'home_seePlansButton_text', textColor: '#FFFFFF' },
  { componentId: 'login_scaffold_background', backgroundColor: '#FFFFFF' },
  { componentId: 'login_title_text', textColor: '#000000' },
  { componentId: 'login_inputHint_text', textColor: '#757575' },
  { componentId: 'login_input_background', backgroundColor: '#FFFFFF' },
  { componentId: 'login_signInButton_disabledBackground', backgroundColor: '#757575' },
  { componentId: 'login_signInButton_text', textColor: '#FFFFFF' },
  { componentId: 'login_loadingIndicator_color', iconColor: '#FFFFFF' },
  { componentId: 'login_separator_text', textColor: '#757575' },
  { componentId: 'login_googleButton_background', backgroundColor: '#FF0000' },
  { componentId: 'login_googleButton_text', textColor: '#FFFFFF' },
  { componentId: 'login_googleButton_icon', iconColor: '#FFFFFF' },
  { componentId: 'login_appleButton_background', backgroundColor: '#000000' },
  { componentId: 'login_appleButton_text', textColor: '#FFFFFF' },
  { componentId: 'login_appleButton_icon', iconColor: '#FFFFFF' },
  { componentId: 'login_footerText_text', textColor: '#000000' },
  { componentId: 'login_errorSnackbar_background', backgroundColor: '#FF0000' },
  { componentId: 'login_successSnackbar_background', backgroundColor: '#4CAF50' },
  { componentId: 'splash_scaffold_background', backgroundColor: '#FFFFFF' },
  { componentId: 'splash_loadingIndicator_color', iconColor: '#757575' },
  { componentId: 'gradientButton_gradientStart', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'gradientButton_gradientEnd', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'gradientButton_disabledBackground', backgroundColor: '#757575' },
  { componentId: 'gradientButton_text', textColor: '#FFFFFF' },
  { componentId: 'gradientButton_loadingIndicator', iconColor: '#FFFFFF' },
  { componentId: 'planCard_background', backgroundColor: '#FFFFFF' },
  { componentId: 'planCard_border', borderColor: '#757575' },
  { componentId: 'planCard_borderSelected', borderColor: '#014D7D' },
  { componentId: 'planCard_badgeGradientStart', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'planCard_badgeGradientEnd', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'planCard_badgeBackground', backgroundColor: '#E3F2FD' },
  { componentId: 'planCard_badgeBorder', borderColor: '#66B3FF' },
  { componentId: 'planCard_badgeTextSelected', textColor: '#FFFFFF' },
  { componentId: 'planCard_badgeText', textColor: '#014D7D' },
  { componentId: 'planCard_price_text', textColor: '#014D7D' },
  { componentId: 'planCard_planNameSmall_text', textColor: '#424242' },
  { componentId: 'planCard_planName_text', textColor: '#757575' },
  { componentId: 'planCard_divider', borderColor: '#E0E0E0' },
  { componentId: 'planCard_featureIcon', iconColor: '#014D7D' },
  { componentId: 'planCard_featureLabel_text', textColor: '#757575' },
  { componentId: 'appHeader_gradientStart', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'appHeader_gradientEnd', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'appHeader_backIcon', iconColor: '#000000' },
  { componentId: 'appHeader_backIcon_gradient', iconColor: '#FFFFFF' },
  { componentId: 'appHeader_titleText', textColor: '#000000' },
  { componentId: 'appHeader_titleText_gradient', textColor: '#FFFFFF' },
  { componentId: 'appHeader_zipCodeText', textColor: '#000000' },
  { componentId: 'appHeader_zipCodeText_gradient', textColor: '#FFFFFF' },
  { componentId: 'appHeader_zipIcon', iconColor: '#757575' },
  { componentId: 'appHeader_zipIcon_gradient', iconColor: '#FFFFFF' },
  { componentId: 'appHeader_menuIcon', iconColor: '#000000' },
  { componentId: 'appHeader_menuIcon_gradient', iconColor: '#FFFFFF' },
  { componentId: 'appFooter_background', backgroundColor: '#FFFFFF' },
  { componentId: 'appFooter_shadow', shadowColor: '#1A000000' },
  { componentId: 'appFooter_tabIcon_selected', iconColor: '#FDC710' },
  { componentId: 'appFooter_tabIcon', iconColor: '#757575' },
  { componentId: 'appFooter_tabLabel_selected', textColor: '#FDC710' },
  { componentId: 'appFooter_tabLabel', textColor: '#757575' },
  { componentId: 'bottomActionBar_background', backgroundColor: '#FFFFFF' },
  { componentId: 'stepIndicator_gradientStart', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'stepIndicator_gradientEnd', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'stepIndicator_text', textColor: '#FFFFFF' },
  { componentId: 'stepNavigation_scaffold_background', backgroundColor: '#FFFFFF' },
  { componentId: 'stepNavigation_backIcon', iconColor: '#FDC710' },
  { componentId: 'stepNavigation_cancelIcon', iconColor: '#FDC710' },
  { componentId: 'stepNavigation_cancelButtonText', textColor: '#FF0000' },
  { componentId: 'stepNavigation_footer_background', backgroundColor: '#FFFFFF' },
  { componentId: 'orderCard_background', backgroundColor: '#FFFFFF' },
  { componentId: 'orderCard_border', borderColor: '#E0E0E0' },
  { componentId: 'orderCard_status_completed', iconColor: '#4CAF50' },
  { componentId: 'orderCard_status_cancelled', iconColor: '#FF0000' },
  { componentId: 'orderCard_status_inProgress', iconColor: '#FF9800' },
  { componentId: 'orderCard_date_text', textColor: '#757575' },
  { componentId: 'orderCard_phoneNumber_text', textColor: '#757575' },
  { componentId: 'orderCard_chevronIcon', iconColor: '#757575' },
  { componentId: 'planCarousel_indicatorActive_gradientStart', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'planCarousel_indicatorActive_gradientEnd', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'planCarousel_indicatorInactive', backgroundColor: '#E0E0E0' },
  { componentId: 'offlineBanner_background', backgroundColor: '#FFF9E6' },
  { componentId: 'offlineBanner_icon', iconColor: '#FDC710' },
  { componentId: 'offlineBanner_text', textColor: '#757575' },
  { componentId: 'mainLayout_scaffold_background', backgroundColor: '#FFFFFF' },
  { componentId: 'mainLayout_dialogBarrier', shadowColor: '#88000000' },
  { componentId: 'mainLayout_hamburgerMenu_background', backgroundColor: '#FFFFFF' },
  { componentId: 'startOrder_loadingIndicator_color', iconColor: '#FDC710' },
  { componentId: 'startOrder_loadingText_text', textColor: '#757575' },
  { componentId: 'startOrder_heroTitle_text', textColor: '#212121' },
  { componentId: 'startOrder_heroSubtitle_gradientStart', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'startOrder_heroSubtitle_gradientEnd', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'startOrder_welcomeTitle_text', textColor: '#000000' },
  { componentId: 'startOrder_welcomeSubtitle_text', textColor: '#757575' },
  { componentId: 'startOrder_completeSetup_background', backgroundColor: '#FFF9E6' },
  { componentId: 'startOrder_completeSetup_border', borderColor: '#FFE082' },
  { componentId: 'startOrder_completeSetup_title_text', textColor: '#212121' },
  { componentId: 'startOrder_completeSetup_subtitle_text', textColor: '#757575' },
  { componentId: 'startOrder_completeSetup_indicator', backgroundColor: '#FFE082' },
  { componentId: 'startOrder_availablePlans_title_text', textColor: '#000000' },
  { componentId: 'startOrder_recentOrders_background', backgroundColor: '#F5F5F5' },
  { componentId: 'startOrder_recentOrders_title_text', textColor: '#000000' },
  { componentId: 'startOrder_recentOrders_count_text', textColor: '#757575' },
  { componentId: 'startOrder_viewAllOrders_icon', iconColor: '#014D7D' },
  { componentId: 'startOrder_viewAllOrders_text', textColor: '#014D7D' },
  { componentId: 'startOrder_incompleteOrder_background', backgroundColor: '#FFFFFF' },
  { componentId: 'startOrder_incompleteOrder_border', borderColor: '#E0E0E0' },
  { componentId: 'startOrder_incompleteOrder_shadow', shadowColor: '#0D000000' },
  { componentId: 'startOrder_incompleteOrder_title_text', textColor: '#212121' },
  { componentId: 'startOrder_incompleteOrder_date_text', textColor: '#757575' },
  { componentId: 'startOrder_incompleteOrder_badge_background', backgroundColor: '#FFF3E0' },
  { componentId: 'startOrder_incompleteOrder_badge_text', textColor: '#FF9800' },
  { componentId: 'startOrder_incompleteOrder_infoIcon', iconColor: '#FDC710' },
  { componentId: 'startOrder_incompleteOrder_infoText', textColor: '#212121' },
  { componentId: 'startOrder_incompleteOrder_taskIcon', iconColor: '#FF9800' },
  { componentId: 'startOrder_incompleteOrder_taskText', textColor: '#212121' },
  { componentId: 'startOrder_incompleteOrder_taskMore_text', textColor: '#757575' },
  { componentId: 'startOrder_viewDetailsButton_background', backgroundColor: '#FDC710' },
  { componentId: 'startOrder_viewDetailsButton_text', textColor: '#FFFFFF' },
  { componentId: 'startOrder_viewDetailsButton_icon', iconColor: '#FFFFFF' },
  { componentId: 'startOrder_completeSetupButton_gradientStart', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'startOrder_completeSetupButton_gradientEnd', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'startOrder_completeSetupButton_text', textColor: '#FFFFFF' },
  { componentId: 'startOrder_planDetails_background', backgroundColor: '#00000000' },
  { componentId: 'startOrder_planDetails_barrier', shadowColor: '#8A000000' },
  { componentId: 'startOrder_seePlansButton_background', backgroundColor: '#FF0000' },
  { componentId: 'startOrder_seePlansButton_text', textColor: '#FFFFFF' },
  { componentId: 'addressInfo_errorButton_background', backgroundColor: '#FF0000' },
  { componentId: 'profile_statusIndicator_active', iconColor: '#4CAF50' },
  { componentId: 'profile_statusIndicator_inactive', iconColor: '#FF0000' },
  { componentId: 'profile_notificationBadge_background', backgroundColor: '#FF9800' },
  { componentId: 'profile_errorButton_background', backgroundColor: '#FF0000' },
  { componentId: 'hamburgerMenu_logoutIcon', iconColor: '#FF0000' },
  { componentId: 'hamburgerMenu_logoutText', textColor: '#FF0000' },
  { componentId: 'international_container_background', backgroundColor: '#F5F5F5' },
  { componentId: 'international_container_border', borderColor: '#E0E0E0' },
  { componentId: 'international_button_background', backgroundColor: '#FFFFFF' },
  { componentId: 'international_button_text', textColor: '#757575' },
  { componentId: 'international_searchIcon', iconColor: '#757575' },
  { componentId: 'international_phoneIcon', iconColor: '#FFFFFF' },
  { componentId: 'international_phoneButton_gradientStart', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'international_phoneButton_gradientEnd', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'privacy_icon', iconColor: '#757575' },
  { componentId: 'terms_icon', iconColor: '#757575' },
  { componentId: 'previousOrders_scaffold_background', backgroundColor: '#FFFFFF' },
  { componentId: 'previousOrders_orderCard_border', borderColor: '#E0E0E0' },
  { componentId: 'plansView_modal_background', backgroundColor: '#00000000' },
  { componentId: 'plansView_modal_barrier', shadowColor: '#8A000000' },
  { componentId: 'plansView_modal_content_background', backgroundColor: '#FFFFFF' },
  { componentId: 'plansView_filterIcon', iconColor: '#757575' },
  { componentId: 'plansView_filterTitle_text', textColor: '#424242' },
  { componentId: 'plansView_filterSubtitle_text', textColor: '#757575' },
  { componentId: 'numberPorting_warning_background', backgroundColor: '#FF0000' },
  { componentId: 'porting_warning_background', backgroundColor: '#FF0000' },
  { componentId: 'deviceCompatibility_button_background', backgroundColor: '#00000000' },
  { componentId: 'deviceCompatibility_loadingIndicator', iconColor: '#FFFFFF' },
  { componentId: 'deviceCompatibility_icon', iconColor: '#FFFFFF' },
  { componentId: 'deviceCompatibility_text', textColor: '#FFFFFF' },
  { componentId: 'contactInfo_button_text', textColor: '#FFFFFF' },
  { componentId: 'numberSelection_radio_unselected', borderColor: '#E0E0E0' },
  { componentId: 'numberSelection_radio_selected', borderColor: '#E0E0E0' },
  { componentId: 'numberSelection_availabilityIcon_available', iconColor: '#4CAF50' },
  { componentId: 'numberSelection_availabilityIcon_unavailable', iconColor: '#FF0000' },
  { componentId: 'numberSelection_statusIcon_available', iconColor: '#4CAF50' },
  { componentId: 'numberSelection_statusIcon_unavailable', iconColor: '#FF0000' },
  { componentId: 'numberSelection_warningIcon', iconColor: '#FF9800' },
  { componentId: 'numberSelection_warningText', textColor: '#FF9800' },
  { componentId: 'numberSelection_selectedText', textColor: '#757575' },
  { componentId: 'numberSelection_button_text', textColor: '#FFFFFF' },
  { componentId: 'snackbar-success', backgroundColor: '#4CAF50' },
  { componentId: 'snackbar-error', backgroundColor: '#FF0000' },
  { componentId: 'screen-plans', backgroundColor: '#FFFFFF' },
  { componentId: 'screen-support', backgroundColor: '#FFFFFF' },
  { componentId: 'text-title', textColor: '#000000' },
  { componentId: 'text-body', textColor: '#757575' },
  { componentId: 'text-hint', textColor: '#9E9E9E' },
  { componentId: 'text-secondary', textColor: '#757575' },
  { componentId: 'button-primary', backgroundColor: '#808080', textColor: '#FFFFFF' },
  { componentId: 'button-danger', backgroundColor: '#FF0000', textColor: '#FFFFFF' },
  { componentId: 'button-text', textColor: '#FFFFFF' },
  { componentId: 'icon-secondary', iconColor: '#757575' },
  { componentId: 'link-primary', textColor: '#014D7D' },
  { componentId: 'tab-container', backgroundColor: '#E0E0E0' },
];

// ========== TEXT STRINGS FROM FallbackValues ==========
const componentTexts = [
  // Common UI Text
  { textId: 'buttonNext', text: 'Next Step' },
  { textId: 'buttonBack', text: 'Back' },
  { textId: 'buttonCancel', text: 'Cancel' },
  { textId: 'buttonComplete', text: 'Complete Order' },
  { textId: 'buttonSignOut', text: 'Sign Out' },
  { textId: 'buttonSignIn', text: 'Sign In' },
  { textId: 'buttonSeePlans', text: 'See Available Plans' },
  { textId: 'buttonRetry', text: 'Retry' },
  { textId: 'buttonOpenSettings', text: 'Open Settings' },
  { textId: 'buttonUseOriginal', text: 'Use Original' },
  { textId: 'buttonUseSuggested', text: 'Use Suggested' },
  { textId: 'buttonKeepMyAddress', text: 'Keep My Address' },
  { textId: 'buttonViewDetails', text: 'View Details' },
  { textId: 'buttonCompleteSetup', text: 'Complete Setup' },
  { textId: 'buttonCheckIMEI', text: 'Check your IMEI instead' },
  { textId: 'buttonAutoDetectDevice', text: 'Auto-detect device' },
  { textId: 'buttonReadingDevice', text: 'Reading device info...' },
  
  // Screen Titles
  { textId: 'titleContactInfo', text: 'Contact information' },
  { textId: 'titleShippingAddress', text: 'Shipping address' },
  { textId: 'titleDeviceCompatibility', text: 'Check device compatibility' },
  { textId: 'titleDeviceCompatibilitySubtitle', text: 'Let\'s double-check that your device works with Telgoo5 Mobile.' },
  { textId: 'titleNumberSelection', text: 'Number Selection' },
  { textId: 'titleBillingInfo', text: 'Billing Information' },
  { textId: 'titleSimSetup', text: 'SIM Card Setup' },
  { textId: 'titlePorting', text: 'Number Porting' },
  { textId: 'titleProfile', text: 'Profile' },
  { textId: 'titleSupport', text: 'Contact Support' },
  { textId: 'titlePlans', text: 'Plans made for how you connect.' },
  
  // Messages
  { textId: 'messageLoading', text: 'Loading...' },
  { textId: 'messageNoPlans', text: 'No plans available' },
  { textId: 'messageNoPlansSubtitle', text: 'No plans found for ZIP: {zipCode}' },
  { textId: 'messageDeviceCompatible', text: 'Device is compatible with our network.' },
  { textId: 'messageDeviceNotCompatible', text: 'Device model not found in our catalog. Your device may not be compatible with our network.' },
  { textId: 'messageContactSupport', text: 'Please contact support or try checking your IMEI for compatibility verification.' },
  { textId: 'messageShippingInitiated', text: 'Shipping will be initiated' },
  { textId: 'messageEsimReady', text: 'eSIM Ready for Activation' },
  { textId: 'messagePhysicalSimShipping', text: 'Your physical SIM card will be shipped to:' },
  { textId: 'messageDeliveryInfo', text: 'Delivery Information:' },
  { textId: 'messageShippingDays', text: 'Shipping within 2-3 business days' },
  { textId: 'messageTrackingEmail', text: 'Tracking information will be emailed to you' },
  { textId: 'messageActivateSim', text: 'Activate your SIM once received' },
  { textId: 'messageEsimActivation', text: 'eSIM Activation' },
  { textId: 'messageEsimForDevice', text: 'Is this eSIM for this device or another device?' },
  { textId: 'messageThisDevice', text: 'This Device' },
  { textId: 'messageAnotherDevice', text: 'Another Device' },
  { textId: 'messageEsimActivatedDirectly', text: 'eSIM will be activated directly on this device after order completion.' },
  { textId: 'messageEsimInfo', text: 'eSIM Activation:' },
  { textId: 'messageQrCodeEmailed', text: 'QR code will be emailed to you instantly' },
  { textId: 'messageScanQrCode', text: 'Scan the QR code to activate your eSIM' },
  { textId: 'messageActivationMinutes', text: 'Activation takes just a few minutes' },
  { textId: 'messageDeviceSupportsEsim', text: 'Make sure your device supports eSIM' },
  { textId: 'messageWelcome', text: 'Welcome!' },
  { textId: 'messageSignedInAs', text: 'Signed in as: {email}' },
  { textId: 'messageCanFindDevice', text: 'Can\'t find your device in the list above?' },
  { textId: 'messageDeviceSupportsBoth', text: 'Your device supports both eSIM and physical SIM cards.' },
  { textId: 'messageDeviceSupportsEsimOnly', text: 'Your device only supports eSIM (no physical SIM slot).' },
  { textId: 'messageDeviceSupportsPhysicalOnly', text: 'Your device only supports physical SIM cards (no eSIM).' },
  { textId: 'messageResultsForDevice', text: 'Results for {deviceName}' },
  { textId: 'messageDeviceSupportsEsimText', text: 'Your device supports eSIM.' },
  { textId: 'messageDeviceNotSupportsEsimText', text: 'Your device does not support eSIM.' },
  { textId: 'messageDeviceSupportsPhysicalText', text: 'Your device supports physical SIM card.' },
  { textId: 'messageDeviceNotSupportsPhysicalText', text: 'Your device does not support physical SIM card.' },
  
  // Error Messages
  { textId: 'errorUserNotLoggedIn', text: 'User not logged in' },
  { textId: 'errorPleaseSelectPlan', text: 'Please select a plan' },
  { textId: 'errorFailedToSave', text: 'Failed to save' },
  { textId: 'errorPleaseEnterEmail', text: 'Please enter email and password' },
  { textId: 'errorLocationServicesDisabled', text: 'Location services are disabled. Please enable them in Settings.' },
  { textId: 'errorLocationPermissionsDenied', text: 'Location permissions are denied. Please enable them in Settings.' },
  { textId: 'errorLocationPermanentlyDenied', text: 'Location permissions are permanently denied. Please enable them in Settings.' },
  { textId: 'errorUnableToGetLocation', text: 'Unable to get location. Please enter your address manually.' },
  { textId: 'errorPleaseEnterValidZip', text: 'Please enter a valid ZIP code to auto-fill city and state.' },
  { textId: 'errorPleaseSelectNumberType', text: 'Please select a number type' },
  { textId: 'errorPleaseEnterValidPhone', text: 'Please enter a valid 10-digit phone number' },
  { textId: 'errorPleaseWaitValidation', text: 'Please wait for phone number validation to complete' },
  { textId: 'errorNumberNotEligible', text: 'Number is not eligible for porting' },
  { textId: 'errorPleaseAcceptAgreements', text: 'Please accept all agreements' },
  { textId: 'errorFailedToCreateEnrollment', text: 'Failed to create enrollment. Please try again.' },
  { textId: 'errorServiceAvailabilityCheckFailed', text: 'Service availability check failed: {error}' },
  { textId: 'errorAddressValidationFailed', text: 'Address validation failed' },
  { textId: 'errorCouldNotDetectDevice', text: 'Could not detect device model. Please select your device model manually from the dropdown.' },
  { textId: 'errorDeviceBrandNotSupported', text: 'Device brand not supported. Your device may not be compatible.' },
  { textId: 'errorCouldNotDetectBrand', text: 'Could not detect device brand. Manufacturer: {manufacturer}. Your device may not be compatible.' },
  { textId: 'errorReadingDeviceInfo', text: 'Error reading device info: {error}' },
  { textId: 'errorCreatingOrder', text: 'Error creating order: {error}' },
  { textId: 'errorFailedToSaveContactInfo', text: 'Failed to save contact info' },
  { textId: 'errorFailedToSaveDeviceInfo', text: 'Failed to save device info' },
  { textId: 'errorFailedToSaveNumberSelection', text: 'Failed to save number selection' },
  { textId: 'errorFailedToSaveBillingInfo', text: 'Failed to save billing info' },
  { textId: 'errorFailedToCompleteOrder', text: 'Failed to complete order' },
  { textId: 'errorCouldNotLaunchPhone', text: 'Could not launch phone app' },
  { textId: 'errorCouldNotLaunchEmail', text: 'Could not launch email app' },
  { textId: 'errorFailedToEnableNotifications', text: 'Failed to enable notifications' },
  { textId: 'errorFailedToSavePortIn', text: 'Failed to save port-in information' },
  { textId: 'errorUnableToValidatePortIn', text: 'Unable to validate port-in information. Please try again.' },
  { textId: 'errorFailedToSubmitPortIn', text: 'Failed to submit port-in request. Please check your information and try again.' },
  { textId: 'errorUnableToGetAddress', text: 'Unable to get address from location. Please enter address manually.' },
  { textId: 'errorAddressLookupTimedOut', text: 'Address lookup timed out. Please try again.' },
  { textId: 'errorUnableToGetLocationGps', text: 'Unable to get location. Please ensure GPS is enabled or enter address manually.' },
  
  // Success Messages
  { textId: 'successSignedIn', text: 'Successfully signed in!' },
  { textId: 'successPasswordResetSent', text: 'Password reset email sent. Please check your inbox.' },
  { textId: 'successNotificationsEnabled', text: 'Notifications enabled' },
  { textId: 'successNotificationsDisabled', text: 'Notifications disabled' },
  { textId: 'successAddressValidated', text: 'Address validated successfully' },
  { textId: 'successPortInValidated', text: 'Port-in data validated successfully' },
  { textId: 'successPortInSaved', text: 'Port-in information saved to Firebase successfully' },
  
  // Labels
  { textId: 'labelFirstName', text: 'First Name' },
  { textId: 'labelLastName', text: 'Last Name' },
  { textId: 'labelPhone', text: '(000) 000-0000' },
  { textId: 'labelEmail', text: 'Email' },
  { textId: 'labelStreetAddress', text: 'Street Address' },
  { textId: 'labelAptSuite', text: 'Apt, Suite, etc. (optional)' },
  { textId: 'labelCity', text: 'City' },
  { textId: 'labelState', text: 'State' },
  { textId: 'labelZipCode', text: 'Zip Code' },
  { textId: 'labelCardNumber', text: 'Card Number' },
  { textId: 'labelExpiry', text: 'MM/YY' },
  { textId: 'labelCvv', text: 'CVV' },
  { textId: 'labelBillingAddress', text: 'Billing Address *' },
  { textId: 'labelSameAsShipping', text: 'Same as Shipping Address' },
  { textId: 'labelDeviceBrand', text: 'Device Brand' },
  { textId: 'labelDeviceModel', text: 'Device Model' },
  { textId: 'labelNewNumber', text: 'New Number' },
  { textId: 'labelExistingNumber', text: 'Existing Number' },
  { textId: 'labelPlan', text: 'Plan' },
  { textId: 'labelPlanPrice', text: 'Plan Price' },
  { textId: 'labelPlanTax', text: 'Plan Tax' },
  { textId: 'labelTotal', text: 'Total' },
  
  // Checkbox Labels
  { textId: 'checkboxRecurringCharge', text: 'I authorize Telgoo5 Mobile LLC to charge my card on a recurring basis.' },
  { textId: 'checkboxPrivacyTerms', text: 'I agree to the Privacy Policy and Terms of Use.' },
  { textId: 'checkboxUseCurrentLocation', text: 'Use your current location' },
  
  // Section Titles
  { textId: 'sectionBroadbandFacts', text: 'BROADBAND FACTS' },
  { textId: 'sectionMobileBroadbandDisclosure', text: 'Mobile Broadband Consumer Disclosure' },
  { textId: 'sectionSpeedsProvided', text: 'Speeds Provided with Plan' },
  { textId: 'sectionProviderFees', text: 'Provider Monthly Fees' },
  { textId: 'sectionUnlimitedData', text: 'Unlimited Data Included with Monthly Price' },
  { textId: 'sectionMonthlyPrice', text: 'Monthly Price: ${price}' },
  { textId: 'sectionNotIntroductoryRate', text: 'Not an introductory rate and does not require a contract.' },
  { textId: 'sectionTypicalDownload', text: 'Typical Download: 10-50 Mbps' },
  { textId: 'sectionTypicalUpload', text: 'Typical Upload Speed: 1-10 Mbps' },
  { textId: 'sectionTypicalLatency', text: 'Typical Latency: 19-37 ms' },
  { textId: 'sectionOneTimeFee', text: 'One-Time Fee: $0' },
  { textId: 'sectionDeviceConnectionCharge', text: 'Device Connection Charge: $0' },
  { textId: 'sectionEarlyTerminationFee', text: 'Early Termination Fee: $0' },
  { textId: 'sectionGovernmentTaxes', text: 'Government Taxes: Varies by Location' },
  { textId: 'sectionFirst20GB', text: 'With first 20GB at high speed' },
  { textId: 'sectionChargesAdditionalData', text: 'Charges for Additional Data Usage: $0' },
  { textId: 'sectionResidentialUse', text: '*Residential, non-commercial use only.' },
  
  // Support
  { textId: 'supportContactTitle', text: 'Contact Support' },
  { textId: 'supportContactSubtitle', text: 'Get in touch with our support team' },
  { textId: 'supportPhone', text: 'Phone' },
  { textId: 'supportPhoneNumber', text: '904-596-0304' },
  { textId: 'supportEmail', text: 'Email' },
  { textId: 'supportEmailAddress', text: 'support@linkupmobile.com' },
  { textId: 'supportEmailSubject', text: 'Support Request' },
  
  // Profile
  { textId: 'profileAccountInfo', text: 'Account Information' },
  { textId: 'profileNotificationSettings', text: 'Notification Settings' },
  { textId: 'profileFirstName', text: 'First Name' },
  { textId: 'profileLastName', text: 'Last Name' },
  { textId: 'profileMobileNumber', text: 'Mobile Number' },
  { textId: 'profileEmail', text: 'Email' },
  { textId: 'profileNA', text: 'N/A' },
  
  // Plans
  { textId: 'plansFilterTitle', text: 'No plans available' },
  { textId: 'plansFilterSubtitle', text: 'No plans found for ZIP: {zipCode}' },
  
  // Home
  { textId: 'homeSignedInAs', text: 'Signed in as: {email}' },
  
  // Order Flow
  { textId: 'orderStepContactInfo', text: 'Contact information' },
  { textId: 'orderStepDeviceCompatibility', text: 'Check device compatibility' },
  { textId: 'orderStepSimSelection', text: 'SIM Selection' },
  { textId: 'orderStepNumberSelection', text: 'Number Selection' },
  { textId: 'orderStepBilling', text: 'Billing Information' },
  { textId: 'orderStepSimSetup', text: 'SIM Card Setup' },
  { textId: 'orderCompleteRemainingSteps', text: 'Complete remaining order steps' },
  { textId: 'orderCompletePortingInfo', text: 'Complete number porting information' },
  { textId: 'orderCompleteBillingInfo', text: 'Complete billing information' },
  { textId: 'orderCompleteContactShipping', text: 'Complete contact and shipping information' },
  
  // Start Order View
  { textId: 'startOrderHeroTitle', text: 'CONNECT TO THE WORLD FOR LESS' },
  { textId: 'startOrderHeroSubtitle', text: 'Unlimited talk & text starting at $10 a month' },
  { textId: 'startOrderSeePlanDetails', text: 'See plan details' },
  { textId: 'startOrderWelcomeBack', text: 'Welcome back!' },
  { textId: 'startOrderDashboardSubtitle', text: 'Here\'s your dashboard.' },
  { textId: 'startOrderCompleteSetup', text: 'Complete Your Setup' },
  { textId: 'startOrderCompleteSetupSubtitle', text: 'You have orders that need completion to activate your SIM:' },
  { textId: 'startOrderTasksToComplete', text: 'Tasks to Complete:' },
  { textId: 'startOrderRecentOrders', text: 'Recent Orders' },
  { textId: 'startOrderTotal', text: 'total' },
  { textId: 'startOrderViewAllOrders', text: 'View all orders' },
  { textId: 'startOrderIncomplete', text: 'Incomplete' },
  { textId: 'startOrderStarted', text: 'Started:' },
  { textId: 'startOrderOrderNumber', text: 'Order #' },
  { textId: 'startOrderNumber', text: 'Number:' },
  { textId: 'startOrderSimType', text: 'SIM Type:' },
  { textId: 'startOrderDevice', text: 'Device:' },
  
  // Dialog Titles
  { textId: 'dialogAddressSuggestion', text: 'Address Suggestion' },
  { textId: 'dialogAddressValidation', text: 'Address Validation' },
  { textId: 'dialogFoundStandardizedAddress', text: 'We found a standardized version of your address:' },
  { textId: 'dialogWouldLikeToUse', text: 'Would you like to use this address?' },
  
  // IMEI Check
  { textId: 'imeiDeviceMatches', text: 'Your device matches our network!' },
  { textId: 'imeiDeviceNotCompatible', text: 'Sorry, your device is not compatible.' },
  { textId: 'imeiEnteredNotChecked', text: 'IMEI entered but compatibility not checked.' },
  
  // Port-in
  { textId: 'portInEligible', text: 'Eligible' },
  { textId: 'portInNotEligible', text: 'Not Eligible' },
  { textId: 'portInValidating', text: 'Validating...' },
  
  // Footer Tabs
  { textId: 'tabPlans', text: 'Plans' },
  { textId: 'tabHome', text: 'Home' },
  { textId: 'tabChat', text: 'Chat' },
  { textId: 'tabProfile', text: 'Profile' },
  { textId: 'tabContact', text: 'Contact' },
  
  // Number Selection
  { textId: 'numberSelectionNew', text: 'New Number' },
  { textId: 'numberSelectionExisting', text: 'Existing Number' },
  { textId: 'numberSelectionEnterPhone', text: 'Enter your phone number' },
  
  // Device Compatibility
  { textId: 'deviceCompatibilityCouldNotDetect', text: 'Could not detect device model for {brand}.' },
  { textId: 'deviceCompatibilitySelectManually', text: 'Please select your device model manually from the dropdown above to check compatibility.' },
  { textId: 'deviceCompatibilityBrandNotSupported', text: 'Device brand "{brand}" is not supported.' },
  { textId: 'deviceCompatibilityMayNotCompatible', text: 'Your device may not be compatible with our network. Please contact support or try checking your IMEI for compatibility verification.' },
  
  // Address Validation
  { textId: 'addressValidationMultipleAddresses', text: 'The address could not be validated. You can still proceed with your address, or you may want to provide more specific address details.' },
  { textId: 'addressValidationNotAvailable', text: 'The address could not be validated. You can still proceed with your address, or you may want to check and correct your address information.' },
];

// Get environment variables or command line arguments
function getConfig() {
  const args = process.argv.slice(2);
  let spaceId = process.env.CONTENTFUL_SPACE_ID;
  let token = process.env.CONTENTFUL_MANAGEMENT_TOKEN;

  args.forEach(arg => {
    if (arg.startsWith('--space-id=')) {
      spaceId = arg.split('=')[1];
    } else if (arg.startsWith('--token=')) {
      token = arg.split('=')[1];
    }
  });

  if (!spaceId || !token) {
    console.error('❌ Error: Missing required configuration');
    console.error('');
    console.error('Please provide:');
    console.error('  1. Environment variables:');
    console.error('     - CONTENTFUL_SPACE_ID');
    console.error('     - CONTENTFUL_MANAGEMENT_TOKEN');
    console.error('');
    console.error('  2. Or command line arguments:');
    console.error('     --space-id=YOUR_SPACE_ID --token=YOUR_TOKEN');
    console.error('');
    process.exit(1);
  }

  return { spaceId, token };
}

async function importComponentColors(environment) {
  console.log('🎨 Importing Component Colors...');
  console.log(`   Total colors: ${componentColors.length}`);
  console.log('');

  let created = 0;
  let updated = 0;
  let errors = 0;

  for (const colorData of componentColors) {
    try {
      const { componentId, ...colorFields } = colorData;

      const fields = {
        componentId: { 'en-US': componentId },
      };

      if (colorData.backgroundColor) {
        fields.backgroundColor = { 'en-US': colorData.backgroundColor };
      }
      if (colorData.textColor) {
        fields.textColor = { 'en-US': colorData.textColor };
      }
      if (colorData.borderColor) {
        fields.borderColor = { 'en-US': colorData.borderColor };
      }
      if (colorData.iconColor) {
        fields.iconColor = { 'en-US': colorData.iconColor };
      }
      if (colorData.shadowColor) {
        fields.shadowColor = { 'en-US': colorData.shadowColor };
      }
      if (colorData.gradientStartColor) {
        fields.gradientStartColor = { 'en-US': colorData.gradientStartColor };
      }
      if (colorData.gradientEndColor) {
        fields.gradientEndColor = { 'en-US': colorData.gradientEndColor };
      }

      let entry;
      try {
        const entries = await environment.getEntries({
          content_type: 'componentColor',
          'fields.componentId[en-US]': componentId,
          limit: 1,
        });

        if (entries.items.length > 0) {
          entry = entries.items[0];
          Object.keys(fields).forEach(fieldKey => {
            entry.fields[fieldKey] = fields[fieldKey];
          });
          entry = await entry.update();
          await entry.publish();
          updated++;
          console.log(`   ✅ Updated: ${componentId}`);
        } else {
          throw new Error('Entry not found');
        }
      } catch (error) {
        entry = await environment.createEntry('componentColor', {
          fields: fields,
        });
        await entry.publish();
        created++;
        console.log(`   ✨ Created: ${componentId}`);
      }
    } catch (error) {
      errors++;
      console.error(`   ❌ Error with ${colorData.componentId}: ${error.message}`);
    }
  }

  return { created, updated, errors, total: componentColors.length };
}

async function importComponentTexts(environment) {
  console.log('');
  console.log('📝 Importing Component Texts...');
  console.log(`   Total texts: ${componentTexts.length}`);
  console.log('');

  let created = 0;
  let updated = 0;
  let errors = 0;

  for (const textData of componentTexts) {
    try {
      const { textId, text } = textData;

      const fields = {
        textId: { 'en-US': textId },
        text: { 'en-US': text },
      };

      let entry;
      try {
        const entries = await environment.getEntries({
          content_type: 'componentText',
          'fields.textId[en-US]': textId,
          limit: 1,
        });

        if (entries.items.length > 0) {
          entry = entries.items[0];
          Object.keys(fields).forEach(fieldKey => {
            entry.fields[fieldKey] = fields[fieldKey];
          });
          entry = await entry.update();
          await entry.publish();
          updated++;
          console.log(`   ✅ Updated: ${textId}`);
        } else {
          throw new Error('Entry not found');
        }
      } catch (error) {
        entry = await environment.createEntry('componentText', {
          fields: fields,
        });
        await entry.publish();
        created++;
        console.log(`   ✨ Created: ${textId}`);
      }
    } catch (error) {
      errors++;
      console.error(`   ❌ Error with ${textData.textId}: ${error.message}`);
    }
  }

  return { created, updated, errors, total: componentTexts.length };
}

async function importAll() {
  const { spaceId, token } = getConfig();

  console.log('🚀 Starting Complete Fallback Values Import...');
  console.log(`   Space ID: ${spaceId}`);
  console.log('');

  try {
    const client = contentful.createClient({
      accessToken: token,
    });

    const space = await client.getSpace(spaceId);
    const environment = await space.getEnvironment('master');

    console.log('✅ Connected to Contentful');
    console.log('');

    // Import colors
    const colorResults = await importComponentColors(environment);

    // Import texts
    const textResults = await importComponentTexts(environment);

    // Summary
    console.log('');
    console.log('📊 Import Summary:');
    console.log('');
    console.log('🎨 Component Colors:');
    console.log(`   ✅ Created: ${colorResults.created}`);
    console.log(`   🔄 Updated: ${colorResults.updated}`);
    console.log(`   ❌ Errors: ${colorResults.errors}`);
    console.log(`   📦 Total: ${colorResults.total}`);
    console.log('');
    console.log('📝 Component Texts:');
    console.log(`   ✅ Created: ${textResults.created}`);
    console.log(`   🔄 Updated: ${textResults.updated}`);
    console.log(`   ❌ Errors: ${textResults.errors}`);
    console.log(`   📦 Total: ${textResults.total}`);
    console.log('');
    console.log('🎉 Import completed!');
    console.log('');
    console.log('📋 Next Steps:');
    console.log('   1. Verify entries in Contentful web interface');
    console.log('   2. Test app to ensure values are fetched correctly');
    console.log('   3. Update app code to use ContentfulService for fetching texts');

  } catch (error) {
    console.error('');
    console.error('❌ Import failed:');
    console.error(error.message);
    if (error.response) {
      console.error('Response:', JSON.stringify(error.response, null, 2));
    }
    console.error('');
    process.exit(1);
  }
}

// Run the import
importAll();

