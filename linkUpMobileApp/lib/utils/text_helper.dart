import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/component_texts_service.dart';
import 'fallback_values.dart';

/// Helper class for getting text strings from Contentful or fallback values
/// Priority: Contentful first, then fallback values
class AppText {
  /// Get text string - tries Contentful first, then fallback
  static String getString(BuildContext? context, String textId, {String? fallback}) {
    // Try to get from Contentful service
    if (context != null) {
      try {
        final service = Provider.of<ComponentTextsService>(context, listen: false);
        final contentfulValue = service.getString(textId);
        if (contentfulValue != null) {
          return contentfulValue;
        }
      } catch (e) {
        // Provider not available, try singleton
      }
    }
    
    try {
      final service = ComponentTextsService();
      final contentfulValue = service.getString(textId);
      if (contentfulValue != null) {
        return contentfulValue;
      }
    } catch (e) {
      // Service not available
    }
    
    // Only use fallback if Contentful data is unavailable
    return fallback ?? _getFallbackValue(textId) ?? '';
  }
  
  /// Get fallback value by textId
  static String? _getFallbackValue(String textId) {
    // Map textId to FallbackValues constants
    switch (textId) {
      // Common UI Text
      case 'buttonNext': return FallbackValues.buttonNext;
      case 'buttonBack': return FallbackValues.buttonBack;
      case 'buttonCancel': return FallbackValues.buttonCancel;
      case 'buttonComplete': return FallbackValues.buttonComplete;
      case 'buttonSignOut': return FallbackValues.buttonSignOut;
      case 'buttonSignIn': return FallbackValues.buttonSignIn;
      case 'buttonSeePlans': return FallbackValues.buttonSeePlans;
      case 'buttonRetry': return FallbackValues.buttonRetry;
      case 'buttonOpenSettings': return FallbackValues.buttonOpenSettings;
      case 'buttonUseOriginal': return FallbackValues.buttonUseOriginal;
      case 'buttonUseSuggested': return FallbackValues.buttonUseSuggested;
      case 'buttonKeepMyAddress': return FallbackValues.buttonKeepMyAddress;
      case 'buttonViewDetails': return FallbackValues.buttonViewDetails;
      case 'buttonCompleteSetup': return FallbackValues.buttonCompleteSetup;
      case 'buttonCheckIMEI': return FallbackValues.buttonCheckIMEI;
      case 'buttonAutoDetectDevice': return FallbackValues.buttonAutoDetectDevice;
      case 'buttonReadingDevice': return FallbackValues.buttonReadingDevice;
      
      // Screen Titles
      case 'titleContactInfo': return FallbackValues.titleContactInfo;
      case 'titleShippingAddress': return FallbackValues.titleShippingAddress;
      case 'titleDeviceCompatibility': return FallbackValues.titleDeviceCompatibility;
      case 'titleDeviceCompatibilitySubtitle': return FallbackValues.titleDeviceCompatibilitySubtitle;
      case 'titleNumberSelection': return FallbackValues.titleNumberSelection;
      case 'titleBillingInfo': return FallbackValues.titleBillingInfo;
      case 'titleSimSetup': return FallbackValues.titleSimSetup;
      case 'titlePorting': return FallbackValues.titlePorting;
      case 'titleProfile': return FallbackValues.titleProfile;
      case 'titleSupport': return FallbackValues.titleSupport;
      case 'titlePlans': return FallbackValues.titlePlans;
      
      // Messages
      case 'messageLoading': return FallbackValues.messageLoading;
      case 'messageNoPlans': return FallbackValues.messageNoPlans;
      case 'messageNoPlansSubtitle': return FallbackValues.messageNoPlansSubtitle;
      case 'messageDeviceCompatible': return FallbackValues.messageDeviceCompatible;
      case 'messageDeviceNotCompatible': return FallbackValues.messageDeviceNotCompatible;
      case 'messageContactSupport': return FallbackValues.messageContactSupport;
      case 'messageShippingInitiated': return FallbackValues.messageShippingInitiated;
      case 'messageEsimReady': return FallbackValues.messageEsimReady;
      case 'messagePhysicalSimShipping': return FallbackValues.messagePhysicalSimShipping;
      case 'messageDeliveryInfo': return FallbackValues.messageDeliveryInfo;
      case 'messageShippingDays': return FallbackValues.messageShippingDays;
      case 'messageTrackingEmail': return FallbackValues.messageTrackingEmail;
      case 'messageActivateSim': return FallbackValues.messageActivateSim;
      case 'messageEsimActivation': return FallbackValues.messageEsimActivation;
      case 'messageEsimForDevice': return FallbackValues.messageEsimForDevice;
      case 'messageThisDevice': return FallbackValues.messageThisDevice;
      case 'messageAnotherDevice': return FallbackValues.messageAnotherDevice;
      case 'messageEsimActivatedDirectly': return FallbackValues.messageEsimActivatedDirectly;
      case 'messageEsimInfo': return FallbackValues.messageEsimInfo;
      case 'messageQrCodeEmailed': return FallbackValues.messageQrCodeEmailed;
      case 'messageScanQrCode': return FallbackValues.messageScanQrCode;
      case 'messageActivationMinutes': return FallbackValues.messageActivationMinutes;
      case 'messageDeviceSupportsEsim': return FallbackValues.messageDeviceSupportsEsim;
      case 'messageWelcome': return FallbackValues.messageWelcome;
      case 'messageSignedInAs': return FallbackValues.messageSignedInAs;
      case 'messageCanFindDevice': return FallbackValues.messageCanFindDevice;
      case 'messageDeviceSupportsBoth': return FallbackValues.messageDeviceSupportsBoth;
      case 'messageDeviceSupportsEsimOnly': return FallbackValues.messageDeviceSupportsEsimOnly;
      case 'messageDeviceSupportsPhysicalOnly': return FallbackValues.messageDeviceSupportsPhysicalOnly;
      case 'messageResultsForDevice': return FallbackValues.messageResultsForDevice;
      case 'messageDeviceSupportsEsimText': return FallbackValues.messageDeviceSupportsEsimText;
      case 'messageDeviceNotSupportsEsimText': return FallbackValues.messageDeviceNotSupportsEsimText;
      case 'messageDeviceSupportsPhysicalText': return FallbackValues.messageDeviceSupportsPhysicalText;
      case 'messageDeviceNotSupportsPhysicalText': return FallbackValues.messageDeviceNotSupportsPhysicalText;
      
      // Error Messages
      case 'errorUserNotLoggedIn': return FallbackValues.errorUserNotLoggedIn;
      case 'errorPleaseSelectPlan': return FallbackValues.errorPleaseSelectPlan;
      case 'errorFailedToSave': return FallbackValues.errorFailedToSave;
      case 'errorPleaseEnterEmail': return FallbackValues.errorPleaseEnterEmail;
      case 'errorLocationServicesDisabled': return FallbackValues.errorLocationServicesDisabled;
      case 'errorLocationPermissionsDenied': return FallbackValues.errorLocationPermissionsDenied;
      case 'errorLocationPermanentlyDenied': return FallbackValues.errorLocationPermanentlyDenied;
      case 'errorUnableToGetLocation': return FallbackValues.errorUnableToGetLocation;
      case 'errorPleaseEnterValidZip': return FallbackValues.errorPleaseEnterValidZip;
      case 'errorPleaseSelectNumberType': return FallbackValues.errorPleaseSelectNumberType;
      case 'errorPleaseEnterValidPhone': return FallbackValues.errorPleaseEnterValidPhone;
      case 'errorPleaseWaitValidation': return FallbackValues.errorPleaseWaitValidation;
      case 'errorNumberNotEligible': return FallbackValues.errorNumberNotEligible;
      case 'errorPleaseAcceptAgreements': return FallbackValues.errorPleaseAcceptAgreements;
      case 'errorFailedToCreateEnrollment': return FallbackValues.errorFailedToCreateEnrollment;
      case 'errorServiceAvailabilityCheckFailed': return FallbackValues.errorServiceAvailabilityCheckFailed;
      case 'errorAddressValidationFailed': return FallbackValues.errorAddressValidationFailed;
      case 'errorCouldNotDetectDevice': return FallbackValues.errorCouldNotDetectDevice;
      case 'errorDeviceBrandNotSupported': return FallbackValues.errorDeviceBrandNotSupported;
      case 'errorCouldNotDetectBrand': return FallbackValues.errorCouldNotDetectBrand;
      case 'errorReadingDeviceInfo': return FallbackValues.errorReadingDeviceInfo;
      case 'errorCreatingOrder': return FallbackValues.errorCreatingOrder;
      case 'errorFailedToSaveContactInfo': return FallbackValues.errorFailedToSaveContactInfo;
      case 'errorFailedToSaveDeviceInfo': return FallbackValues.errorFailedToSaveDeviceInfo;
      case 'errorFailedToSaveNumberSelection': return FallbackValues.errorFailedToSaveNumberSelection;
      case 'errorFailedToSaveBillingInfo': return FallbackValues.errorFailedToSaveBillingInfo;
      case 'errorFailedToCompleteOrder': return FallbackValues.errorFailedToCompleteOrder;
      case 'errorCouldNotLaunchPhone': return FallbackValues.errorCouldNotLaunchPhone;
      case 'errorCouldNotLaunchEmail': return FallbackValues.errorCouldNotLaunchEmail;
      case 'errorFailedToEnableNotifications': return FallbackValues.errorFailedToEnableNotifications;
      case 'errorFailedToSavePortIn': return FallbackValues.errorFailedToSavePortIn;
      case 'errorUnableToValidatePortIn': return FallbackValues.errorUnableToValidatePortIn;
      case 'errorFailedToSubmitPortIn': return FallbackValues.errorFailedToSubmitPortIn;
      case 'errorUnableToGetAddress': return FallbackValues.errorUnableToGetAddress;
      case 'errorAddressLookupTimedOut': return FallbackValues.errorAddressLookupTimedOut;
      case 'errorUnableToGetLocationGps': return FallbackValues.errorUnableToGetLocationGps;
      
      // Success Messages
      case 'successSignedIn': return FallbackValues.successSignedIn;
      case 'successPasswordResetSent': return FallbackValues.successPasswordResetSent;
      case 'successNotificationsEnabled': return FallbackValues.successNotificationsEnabled;
      case 'successNotificationsDisabled': return FallbackValues.successNotificationsDisabled;
      case 'successAddressValidated': return FallbackValues.successAddressValidated;
      case 'successPortInValidated': return FallbackValues.successPortInValidated;
      case 'successPortInSaved': return FallbackValues.successPortInSaved;
      
      // Labels
      case 'labelFirstName': return FallbackValues.labelFirstName;
      case 'labelLastName': return FallbackValues.labelLastName;
      case 'labelPhone': return FallbackValues.labelPhone;
      case 'labelEmail': return FallbackValues.labelEmail;
      case 'labelStreetAddress': return FallbackValues.labelStreetAddress;
      case 'labelAptSuite': return FallbackValues.labelAptSuite;
      case 'labelCity': return FallbackValues.labelCity;
      case 'labelState': return FallbackValues.labelState;
      case 'labelZipCode': return FallbackValues.labelZipCode;
      case 'labelCardNumber': return FallbackValues.labelCardNumber;
      case 'labelExpiry': return FallbackValues.labelExpiry;
      case 'labelCvv': return FallbackValues.labelCvv;
      case 'labelBillingAddress': return FallbackValues.labelBillingAddress;
      case 'labelSameAsShipping': return FallbackValues.labelSameAsShipping;
      case 'labelDeviceBrand': return FallbackValues.labelDeviceBrand;
      case 'labelDeviceModel': return FallbackValues.labelDeviceModel;
      case 'labelNewNumber': return FallbackValues.labelNewNumber;
      case 'labelExistingNumber': return FallbackValues.labelExistingNumber;
      case 'labelPlan': return FallbackValues.labelPlan;
      case 'labelPlanPrice': return FallbackValues.labelPlanPrice;
      case 'labelPlanTax': return FallbackValues.labelPlanTax;
      case 'labelTotal': return FallbackValues.labelTotal;
      
      // Checkbox Labels
      case 'checkboxRecurringCharge': return FallbackValues.checkboxRecurringCharge;
      case 'checkboxPrivacyTerms': return FallbackValues.checkboxPrivacyTerms;
      case 'checkboxUseCurrentLocation': return FallbackValues.checkboxUseCurrentLocation;
      
      // Section Titles
      case 'sectionBroadbandFacts': return FallbackValues.sectionBroadbandFacts;
      case 'sectionMobileBroadbandDisclosure': return FallbackValues.sectionMobileBroadbandDisclosure;
      case 'sectionSpeedsProvided': return FallbackValues.sectionSpeedsProvided;
      case 'sectionProviderFees': return FallbackValues.sectionProviderFees;
      case 'sectionUnlimitedData': return FallbackValues.sectionUnlimitedData;
      case 'sectionMonthlyPrice': return FallbackValues.sectionMonthlyPrice;
      case 'sectionNotIntroductoryRate': return FallbackValues.sectionNotIntroductoryRate;
      case 'sectionTypicalDownload': return FallbackValues.sectionTypicalDownload;
      case 'sectionTypicalUpload': return FallbackValues.sectionTypicalUpload;
      case 'sectionTypicalLatency': return FallbackValues.sectionTypicalLatency;
      case 'sectionOneTimeFee': return FallbackValues.sectionOneTimeFee;
      case 'sectionDeviceConnectionCharge': return FallbackValues.sectionDeviceConnectionCharge;
      case 'sectionEarlyTerminationFee': return FallbackValues.sectionEarlyTerminationFee;
      case 'sectionGovernmentTaxes': return FallbackValues.sectionGovernmentTaxes;
      case 'sectionFirst20GB': return FallbackValues.sectionFirst20GB;
      case 'sectionChargesAdditionalData': return FallbackValues.sectionChargesAdditionalData;
      case 'sectionResidentialUse': return FallbackValues.sectionResidentialUse;
      
      // Support
      case 'supportContactTitle': return FallbackValues.supportContactTitle;
      case 'supportContactSubtitle': return FallbackValues.supportContactSubtitle;
      case 'supportPhone': return FallbackValues.supportPhone;
      case 'supportPhoneNumber': return FallbackValues.supportPhoneNumber;
      case 'supportEmail': return FallbackValues.supportEmail;
      case 'supportEmailAddress': return FallbackValues.supportEmailAddress;
      case 'supportEmailSubject': return FallbackValues.supportEmailSubject;
      
      // Profile
      case 'profileAccountInfo': return FallbackValues.profileAccountInfo;
      case 'profileNotificationSettings': return FallbackValues.profileNotificationSettings;
      case 'profileFirstName': return FallbackValues.profileFirstName;
      case 'profileLastName': return FallbackValues.profileLastName;
      case 'profileMobileNumber': return FallbackValues.profileMobileNumber;
      case 'profileEmail': return FallbackValues.profileEmail;
      case 'profileNA': return FallbackValues.profileNA;
      
      // Plans
      case 'plansFilterTitle': return FallbackValues.plansFilterTitle;
      case 'plansFilterSubtitle': return FallbackValues.plansFilterSubtitle;
      
      // Home
      case 'homeSignedInAs': return FallbackValues.homeSignedInAs;
      
      // Order Flow
      case 'orderStepContactInfo': return FallbackValues.orderStepContactInfo;
      case 'orderStepDeviceCompatibility': return FallbackValues.orderStepDeviceCompatibility;
      case 'orderStepSimSelection': return FallbackValues.orderStepSimSelection;
      case 'orderStepNumberSelection': return FallbackValues.orderStepNumberSelection;
      case 'orderStepBilling': return FallbackValues.orderStepBilling;
      case 'orderStepSimSetup': return FallbackValues.orderStepSimSetup;
      case 'orderCompleteRemainingSteps': return FallbackValues.orderCompleteRemainingSteps;
      case 'orderCompletePortingInfo': return FallbackValues.orderCompletePortingInfo;
      case 'orderCompleteBillingInfo': return FallbackValues.orderCompleteBillingInfo;
      case 'orderCompleteContactShipping': return FallbackValues.orderCompleteContactShipping;
      
      // Start Order View
      case 'startOrderHeroTitle': return FallbackValues.startOrderHeroTitle;
      case 'startOrderHeroSubtitle': return FallbackValues.startOrderHeroSubtitle;
      case 'startOrderSeePlanDetails': return FallbackValues.startOrderSeePlanDetails;
      case 'startOrderWelcomeBack': return FallbackValues.startOrderWelcomeBack;
      case 'startOrderDashboardSubtitle': return FallbackValues.startOrderDashboardSubtitle;
      case 'startOrderCompleteSetup': return FallbackValues.startOrderCompleteSetup;
      case 'startOrderCompleteSetupSubtitle': return FallbackValues.startOrderCompleteSetupSubtitle;
      case 'startOrderTasksToComplete': return FallbackValues.startOrderTasksToComplete;
      case 'startOrderRecentOrders': return FallbackValues.startOrderRecentOrders;
      case 'startOrderTotal': return FallbackValues.startOrderTotal;
      case 'startOrderViewAllOrders': return FallbackValues.startOrderViewAllOrders;
      case 'startOrderIncomplete': return FallbackValues.startOrderIncomplete;
      case 'startOrderStarted': return FallbackValues.startOrderStarted;
      case 'startOrderOrderNumber': return FallbackValues.startOrderOrderNumber;
      case 'startOrderNumber': return FallbackValues.startOrderNumber;
      case 'startOrderSimType': return FallbackValues.startOrderSimType;
      case 'startOrderDevice': return FallbackValues.startOrderDevice;
      
      // Dialog Titles
      case 'dialogAddressSuggestion': return FallbackValues.dialogAddressSuggestion;
      case 'dialogAddressValidation': return FallbackValues.dialogAddressValidation;
      case 'dialogFoundStandardizedAddress': return FallbackValues.dialogFoundStandardizedAddress;
      case 'dialogWouldLikeToUse': return FallbackValues.dialogWouldLikeToUse;
      
      // IMEI Check
      case 'imeiDeviceMatches': return FallbackValues.imeiDeviceMatches;
      case 'imeiDeviceNotCompatible': return FallbackValues.imeiDeviceNotCompatible;
      case 'imeiEnteredNotChecked': return FallbackValues.imeiEnteredNotChecked;
      
      // Port-in
      case 'portInEligible': return FallbackValues.portInEligible;
      case 'portInNotEligible': return FallbackValues.portInNotEligible;
      case 'portInValidating': return FallbackValues.portInValidating;
      
      // Footer Tabs
      case 'tabPlans': return FallbackValues.tabPlans;
      case 'tabHome': return FallbackValues.tabHome;
      case 'tabChat': return FallbackValues.tabChat;
      case 'tabProfile': return FallbackValues.tabProfile;
      case 'tabContact': return FallbackValues.tabContact;
      
      // Number Selection
      case 'numberSelectionNew': return FallbackValues.numberSelectionNew;
      case 'numberSelectionExisting': return FallbackValues.numberSelectionExisting;
      case 'numberSelectionEnterPhone': return FallbackValues.numberSelectionEnterPhone;
      
      // Device Compatibility
      case 'deviceCompatibilityCouldNotDetect': return FallbackValues.deviceCompatibilityCouldNotDetect;
      case 'deviceCompatibilitySelectManually': return FallbackValues.deviceCompatibilitySelectManually;
      case 'deviceCompatibilityBrandNotSupported': return FallbackValues.deviceCompatibilityBrandNotSupported;
      case 'deviceCompatibilityMayNotCompatible': return FallbackValues.deviceCompatibilityMayNotCompatible;
      
      // Address Validation
      case 'addressValidationMultipleAddresses': return FallbackValues.addressValidationMultipleAddresses;
      case 'addressValidationNotAvailable': return FallbackValues.addressValidationNotAvailable;
      
      default:
        return null;
    }
  }
}

