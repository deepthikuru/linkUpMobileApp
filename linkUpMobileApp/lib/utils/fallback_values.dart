/// Fallback values for colors and text when Contentful is unavailable
/// This file should be used instead of hardcoding values in the code
/// All hardcoded text strings and default colors should be defined here
class FallbackValues {
  // ========== COLORS ==========
  
  // Primary Colors
  static const String yellowAccent = '#FDC710';
  static const String redAccent = '#FF0000';
  static const String mainBlue = '#014D7D';
  static const String secondBlue = '#0C80C3';
  static const String appBackground = '#FFFFFF';
  static const String appText = '#000000';
  
  // Status Colors
  static const String successColor = '#4CAF50';
  static const String successBackground = '#E8F5E9';
  static const String errorColor = '#F44336';
  static const String errorBackground = '#FFEBEE';
  static const String warningColor = '#FDC710';
  
  // UI Colors
  static const String borderColor = '#E0E0E0';
  static const String borderColorSelected = '#0C80C3';
  static const String textSecondary = '#757575';
  static const String textTertiary = '#9E9E9E';
  static const String disabledBackground = '#F5F5F5';
  static const String dividerColor = '#E0E0E0';
  static const String headerBackground = '#014D7D';
  static const String headerText = '#FFFFFF';
  static const String headerIcon = '#FFFFFF';
  
  // ========== TEXT STRINGS ==========
  
  // Common UI Text
  static const String buttonNext = 'Next Step';
  static const String buttonBack = 'Back';
  static const String buttonCancel = 'Cancel';
  static const String buttonComplete = 'Complete Order';
  static const String buttonSignOut = 'Sign Out';
  static const String buttonSignIn = 'Sign In';
  static const String buttonSeePlans = 'See Available Plans';
  static const String buttonRetry = 'Retry';
  static const String buttonOpenSettings = 'Open Settings';
  static const String buttonUseOriginal = 'Use Original';
  static const String buttonUseSuggested = 'Use Suggested';
  static const String buttonKeepMyAddress = 'Keep My Address';
  static const String buttonViewDetails = 'View Details';
  static const String buttonCompleteSetup = 'Complete Setup';
  static const String buttonCheckIMEI = 'Check your IMEI instead';
  static const String buttonAutoDetectDevice = 'Auto-detect device';
  static const String buttonReadingDevice = 'Reading device info...';
  
  // Screen Titles
  static const String titleContactInfo = 'Contact information';
  static const String titleShippingAddress = 'Shipping address';
  static const String titleDeviceCompatibility = 'Check device compatibility';
  static const String titleDeviceCompatibilitySubtitle = 'Let\'s double-check that your device works with Telgoo5 Mobile.';
  static const String titleNumberSelection = 'Number Selection';
  static const String titleBillingInfo = 'Billing Information';
  static const String titleSimSetup = 'SIM Card Setup';
  static const String titlePorting = 'Number Porting';
  static const String titleProfile = 'Profile';
  static const String titleSupport = 'Contact Support';
  static const String titlePlans = 'Plans made for how you connect.';
  
  // Messages
  static const String messageLoading = 'Loading...';
  static const String messageNoPlans = 'No plans available';
  static const String messageNoPlansSubtitle = 'No plans found for ZIP: {zipCode}';
  static const String messageDeviceCompatible = 'Device is compatible with our network.';
  static const String messageDeviceNotCompatible = 'Device model not found in our catalog. Your device may not be compatible with our network.';
  static const String messageContactSupport = 'Please contact support or try checking your IMEI for compatibility verification.';
  static const String messageShippingInitiated = 'Shipping will be initiated';
  static const String messageEsimReady = 'eSIM Ready for Activation';
  static const String messagePhysicalSimShipping = 'Your physical SIM card will be shipped to:';
  static const String messageDeliveryInfo = 'Delivery Information:';
  static const String messageShippingDays = 'Shipping within 2-3 business days';
  static const String messageTrackingEmail = 'Tracking information will be emailed to you';
  static const String messageActivateSim = 'Activate your SIM once received';
  static const String messageEsimActivation = 'eSIM Activation';
  static const String messageEsimForDevice = 'Is this eSIM for this device or another device?';
  static const String messageThisDevice = 'This Device';
  static const String messageAnotherDevice = 'Another Device';
  static const String messageEsimActivatedDirectly = 'eSIM will be activated directly on this device after order completion.';
  static const String messageEsimInfo = 'eSIM Activation:';
  static const String messageQrCodeEmailed = 'QR code will be emailed to you instantly';
  static const String messageScanQrCode = 'Scan the QR code to activate your eSIM';
  static const String messageActivationMinutes = 'Activation takes just a few minutes';
  static const String messageDeviceSupportsEsim = 'Make sure your device supports eSIM';
  static const String messageWelcome = 'Welcome!';
  static const String messageSignedInAs = 'Signed in as: {email}';
  static const String messageCanFindDevice = 'Can\'t find your device in the list above?';
  static const String messageDeviceSupportsBoth = 'Your device supports both eSIM and physical SIM cards.';
  static const String messageDeviceSupportsEsimOnly = 'Your device only supports eSIM (no physical SIM slot).';
  static const String messageDeviceSupportsPhysicalOnly = 'Your device only supports physical SIM cards (no eSIM).';
  static const String messageResultsForDevice = 'Results for {deviceName}';
  static const String messageDeviceSupportsEsimText = 'Your device supports eSIM.';
  static const String messageDeviceNotSupportsEsimText = 'Your device does not support eSIM.';
  static const String messageDeviceSupportsPhysicalText = 'Your device supports physical SIM card.';
  static const String messageDeviceNotSupportsPhysicalText = 'Your device does not support physical SIM card.';
  
  // Error Messages
  static const String errorUserNotLoggedIn = 'User not logged in';
  static const String errorPleaseSelectPlan = 'Please select a plan';
  static const String errorFailedToSave = 'Failed to save';
  static const String errorPleaseEnterEmail = 'Please enter email and password';
  static const String errorLocationServicesDisabled = 'Location services are disabled. Please enable them in Settings.';
  static const String errorLocationPermissionsDenied = 'Location permissions are denied. Please enable them in Settings.';
  static const String errorLocationPermanentlyDenied = 'Location permissions are permanently denied. Please enable them in Settings.';
  static const String errorUnableToGetLocation = 'Unable to get location. Please enter your address manually.';
  static const String errorPleaseEnterValidZip = 'Please enter a valid ZIP code to auto-fill city and state.';
  static const String errorPleaseSelectNumberType = 'Please select a number type';
  static const String errorPleaseEnterValidPhone = 'Please enter a valid 10-digit phone number';
  static const String errorPleaseWaitValidation = 'Please wait for phone number validation to complete';
  static const String errorNumberNotEligible = 'Number is not eligible for porting';
  static const String errorPleaseAcceptAgreements = 'Please accept all agreements';
  static const String errorFailedToCreateEnrollment = 'Failed to create enrollment. Please try again.';
  static const String errorServiceAvailabilityCheckFailed = 'Service availability check failed: {error}';
  static const String errorAddressValidationFailed = 'Address validation failed';
  static const String errorCouldNotDetectDevice = 'Could not detect device model. Please select your device model manually from the dropdown.';
  static const String errorDeviceBrandNotSupported = 'Device brand not supported. Your device may not be compatible.';
  static const String errorCouldNotDetectBrand = 'Could not detect device brand. Manufacturer: {manufacturer}. Your device may not be compatible.';
  static const String errorReadingDeviceInfo = 'Error reading device info: {error}';
  static const String errorCreatingOrder = 'Error creating order: {error}';
  static const String errorFailedToSaveContactInfo = 'Failed to save contact info';
  static const String errorFailedToSaveDeviceInfo = 'Failed to save device info';
  static const String errorFailedToSaveNumberSelection = 'Failed to save number selection';
  static const String errorFailedToSaveBillingInfo = 'Failed to save billing info';
  static const String errorFailedToCompleteOrder = 'Failed to complete order';
  static const String errorCouldNotLaunchPhone = 'Could not launch phone app';
  static const String errorCouldNotLaunchEmail = 'Could not launch email app';
  static const String errorFailedToEnableNotifications = 'Failed to enable notifications';
  static const String errorFailedToSavePortIn = 'Failed to save port-in information';
  static const String errorUnableToValidatePortIn = 'Unable to validate port-in information. Please try again.';
  static const String errorFailedToSubmitPortIn = 'Failed to submit port-in request. Please check your information and try again.';
  static const String errorUnableToGetAddress = 'Unable to get address from location. Please enter address manually.';
  static const String errorAddressLookupTimedOut = 'Address lookup timed out. Please try again.';
  static const String errorUnableToGetLocationGps = 'Unable to get location. Please ensure GPS is enabled or enter address manually.';
  
  // Success Messages
  static const String successSignedIn = 'Successfully signed in!';
  static const String successPasswordResetSent = 'Password reset email sent. Please check your inbox.';
  static const String successNotificationsEnabled = 'Notifications enabled';
  static const String successNotificationsDisabled = 'Notifications disabled';
  static const String successAddressValidated = 'Address validated successfully';
  static const String successPortInValidated = 'Port-in data validated successfully';
  static const String successPortInSaved = 'Port-in information saved to Firebase successfully';
  
  // Labels
  static const String labelFirstName = 'First Name';
  static const String labelLastName = 'Last Name';
  static const String labelPhone = '(000) 000-0000';
  static const String labelEmail = 'Email';
  static const String labelStreetAddress = 'Street Address';
  static const String labelAptSuite = 'Apt, Suite, etc. (optional)';
  static const String labelCity = 'City';
  static const String labelState = 'State';
  static const String labelZipCode = 'Zip Code';
  static const String labelCardNumber = 'Card Number';
  static const String labelExpiry = 'MM/YY';
  static const String labelCvv = 'CVV';
  static const String labelBillingAddress = 'Billing Address *';
  static const String labelSameAsShipping = 'Same as Shipping Address';
  static const String labelDeviceBrand = 'Device Brand';
  static const String labelDeviceModel = 'Device Model';
  static const String labelNewNumber = 'New Number';
  static const String labelExistingNumber = 'Existing Number';
  static const String labelPlan = 'Plan';
  static const String labelPlanPrice = 'Plan Price';
  static const String labelPlanTax = 'Plan Tax';
  static const String labelTotal = 'Total';
  
  // Checkbox Labels
  static const String checkboxRecurringCharge = 'I authorize Telgoo5 Mobile LLC to charge my card on a recurring basis.';
  static const String checkboxPrivacyTerms = 'I agree to the Privacy Policy and Terms of Use.';
  static const String checkboxUseCurrentLocation = 'Use your current location';
  
  // Section Titles
  static const String sectionBroadbandFacts = 'BROADBAND FACTS';
  static const String sectionMobileBroadbandDisclosure = 'Mobile Broadband Consumer Disclosure';
  static const String sectionSpeedsProvided = 'Speeds Provided with Plan';
  static const String sectionProviderFees = 'Provider Monthly Fees';
  static const String sectionUnlimitedData = 'Unlimited Data Included with Monthly Price';
  static const String sectionMonthlyPrice = 'Monthly Price: \${price}';
  static const String sectionNotIntroductoryRate = 'Not an introductory rate and does not require a contract.';
  static const String sectionTypicalDownload = 'Typical Download: 10-50 Mbps';
  static const String sectionTypicalUpload = 'Typical Upload Speed: 1-10 Mbps';
  static const String sectionTypicalLatency = 'Typical Latency: 19-37 ms';
  static const String sectionOneTimeFee = 'One-Time Fee: \$0';
  static const String sectionDeviceConnectionCharge = 'Device Connection Charge: \$0';
  static const String sectionEarlyTerminationFee = 'Early Termination Fee: \$0';
  static const String sectionGovernmentTaxes = 'Government Taxes: Varies by Location';
  static const String sectionFirst20GB = 'With first 20GB at high speed';
  static const String sectionChargesAdditionalData = 'Charges for Additional Data Usage: \$0';
  static const String sectionResidentialUse = '*Residential, non-commercial use only.';
  
  // Support
  static const String supportContactTitle = 'Contact Support';
  static const String supportContactSubtitle = 'Get in touch with our support team';
  static const String supportPhone = 'Phone';
  static const String supportPhoneNumber = '904-596-0304';
  static const String supportEmail = 'Email';
  static const String supportEmailAddress = 'support@linkupmobile.com';
  static const String supportEmailSubject = 'Support Request';
  
  // Profile
  static const String profileAccountInfo = 'Account Information';
  static const String profileNotificationSettings = 'Notification Settings';
  static const String profileFirstName = 'First Name';
  static const String profileLastName = 'Last Name';
  static const String profileMobileNumber = 'Mobile Number';
  static const String profileEmail = 'Email';
  static const String profileNA = 'N/A';
  
  // Plans
  static const String plansFilterTitle = 'No plans available';
  static const String plansFilterSubtitle = 'No plans found for ZIP: {zipCode}';
  
  // Home
  static const String homeSignedInAs = 'Signed in as: {email}';
  
  // Order Flow
  static const String orderStepContactInfo = 'Contact information';
  static const String orderStepDeviceCompatibility = 'Check device compatibility';
  static const String orderStepSimSelection = 'SIM Selection';
  static const String orderStepNumberSelection = 'Number Selection';
  static const String orderStepBilling = 'Billing Information';
  static const String orderStepSimSetup = 'SIM Card Setup';
  static const String orderCompleteRemainingSteps = 'Complete remaining order steps';
  static const String orderCompletePortingInfo = 'Complete number porting information';
  static const String orderCompleteBillingInfo = 'Complete billing information';
  static const String orderCompleteContactShipping = 'Complete contact and shipping information';
  
  // Start Order View
  static const String startOrderHeroTitle = 'CONNECT TO THE WORLD FOR LESS';
  static const String startOrderHeroSubtitle = 'Unlimited talk & text starting at \$10 a month';
  static const String startOrderSeePlanDetails = 'See plan details';
  static const String startOrderWelcomeBack = 'Welcome back!';
  static const String startOrderDashboardSubtitle = 'Here\'s your dashboard.';
  static const String startOrderCompleteSetup = 'Complete Your Setup';
  static const String startOrderCompleteSetupSubtitle = 'You have orders that need completion to activate your SIM:';
  static const String startOrderTasksToComplete = 'Tasks to Complete:';
  static const String startOrderRecentOrders = 'Recent Orders';
  static const String startOrderTotal = 'total';
  static const String startOrderViewAllOrders = 'View all orders';
  static const String startOrderIncomplete = 'Incomplete';
  static const String startOrderStarted = 'Started:';
  static const String startOrderOrderNumber = 'Order #';
  static const String startOrderNumber = 'Number:';
  static const String startOrderSimType = 'SIM Type:';
  static const String startOrderDevice = 'Device:';
  
  // Dialog Titles
  static const String dialogAddressSuggestion = 'Address Suggestion';
  static const String dialogAddressValidation = 'Address Validation';
  static const String dialogFoundStandardizedAddress = 'We found a standardized version of your address:';
  static const String dialogWouldLikeToUse = 'Would you like to use this address?';
  
  // IMEI Check
  static const String imeiDeviceMatches = 'Your device matches our network!';
  static const String imeiDeviceNotCompatible = 'Sorry, your device is not compatible.';
  static const String imeiEnteredNotChecked = 'IMEI entered but compatibility not checked.';
  
  // Port-in
  static const String portInEligible = 'Eligible';
  static const String portInNotEligible = 'Not Eligible';
  static const String portInValidating = 'Validating...';
  
  // Footer Tabs
  static const String tabPlans = 'Plans';
  static const String tabHome = 'Home';
  static const String tabChat = 'Chat';
  static const String tabProfile = 'Profile';
  static const String tabContact = 'Contact';
  
  // Number Selection
  static const String numberSelectionNew = 'New Number';
  static const String numberSelectionExisting = 'Existing Number';
  static const String numberSelectionEnterPhone = 'Enter your phone number';
  
  // Device Compatibility
  static const String deviceCompatibilityCouldNotDetect = 'Could not detect device model for {brand}.';
  static const String deviceCompatibilitySelectManually = 'Please select your device model manually from the dropdown above to check compatibility.';
  static const String deviceCompatibilityBrandNotSupported = 'Device brand "{brand}" is not supported.';
  static const String deviceCompatibilityMayNotCompatible = 'Your device may not be compatible with our network. Please contact support or try checking your IMEI for compatibility verification.';
  
  // Address Validation
  static const String addressValidationMultipleAddresses = 'The address could not be validated. You can still proceed with your address, or you may want to provide more specific address details.';
  static const String addressValidationNotAvailable = 'The address could not be validated. You can still proceed with your address, or you may want to check and correct your address information.';
  
  // Helper method to replace placeholders
  static String replacePlaceholder(String text, Map<String, String> replacements) {
    String result = text;
    replacements.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}

