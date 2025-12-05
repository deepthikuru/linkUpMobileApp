import 'package:flutter/foundation.dart';
import '../models/plan_model.dart';
import '../services/firebase_manager.dart';
import '../services/vcare_api_manager.dart';
import '../utils/constants.dart';

class PlansProvider extends ChangeNotifier {
  final VCareAPIManager _apiManager = VCareAPIManager();
  final FirebaseManager _firebaseManager = FirebaseManager();
  
  List<Plan> _availablePlans = [];
  bool _isLoading = false;
  String _currentZipCode = '';
  String? _errorMessage;
  
  // Getters
  List<Plan> get availablePlans => _availablePlans;
  bool get isLoading => _isLoading;
  String get currentZipCode => _currentZipCode;
  String? get errorMessage => _errorMessage;
  
  // Helper function to get allowed plan names
  List<String> _getAllowedPlanNames() {
    return [
      'LinkUp \$50 Unlimited',
      'LinkUp \$40 30GB',
      'LinkUp \$30 12GB',
      'LinkUp \$20 Unlimited Talk &amp; Text + 3GB Data',
      'LinkUp \$10 1GB',
    ];
  }
  
  // Map plan names to display names
  String _getDisplayName(String planName) {
    final cleanedName = planName.replaceAll('&amp;', '&');
    if (cleanedName.contains('LinkUp \$10 1GB')) return 'STARTER';
    if (cleanedName.contains('LinkUp \$20')) return 'EXPLORE';
    if (cleanedName.contains('LinkUp \$30 12GB')) return 'PREMIUM';
    if (cleanedName.contains('LinkUp \$40 30GB')) return 'UNLIMITED';
    if (cleanedName.contains('LinkUp \$50 Unlimited')) return 'UNLIMITED PLUS';
    return planName;
  }
  
  /// Load plans for a given zip code
  /// Only calls API if plans aren't cached for that zip code
  Future<void> loadPlans(String zipCode) async {
    // Use default zip code if empty
    final zipCodeToUse = zipCode.isNotEmpty ? zipCode : AppConstants.defaultZipCode;
    
    // If zip code hasn't changed and we already have plans, don't reload
    if (_currentZipCode == zipCodeToUse && _availablePlans.isNotEmpty) {
      print('✅ Plans already loaded for zip code: $zipCodeToUse');
      return;
    }
    
    // If zip code changed, clear current plans
    if (_currentZipCode != zipCodeToUse) {
      _currentZipCode = zipCodeToUse;
      _availablePlans = [];
      notifyListeners();
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      const enrollmentType = 'NON_LIFELINE';
      const isFamilyPlan = 'N';
      
      // First, try to get plans from Firestore
      final cachedPlansData = await _firebaseManager.getPlans(
        zipCode: zipCodeToUse,
        enrollmentType: enrollmentType,
        isFamilyPlan: isFamilyPlan,
      );
      
      List<Plan> allPlans = [];
      
      if (cachedPlansData != null && cachedPlansData.isNotEmpty) {
        // Plans found in Firestore, use them
        allPlans = cachedPlansData
            .map((planData) => Plan.fromJson(planData))
            .toList();
        
        print('✅ Loaded ${allPlans.length} plans from Firestore for zip code: $zipCodeToUse');
      } else {
        // Plans not in Firestore, fetch from API
        print('📡 Plans not found in Firestore, fetching from API for zip code: $zipCodeToUse');
        allPlans = await _apiManager.getPlanList(zipCode: zipCodeToUse);
        
        // Save plans to Firestore for future use
        if (allPlans.isNotEmpty) {
          try {
            final plansData = allPlans.map((plan) {
              return {
                'plan_id': plan.planId,
                'plan_name': plan.planName,
                'plan_price': plan.planPrice,
                'total_plan_price': plan.totalPlanPrice,
                'plan_description': plan.planDescription,
                'display_name': plan.displayName,
                'display_description': plan.displayDescription,
                'display_features_description': plan.displayFeaturesDescription,
                'data': plan.data,
                'talk': plan.talk,
                'text': plan.text,
                'is_unlimited_plan': plan.isUnlimitedPlan,
                'is_familyplan': plan.isFamilyPlan,
                'is_prepaid_postpaid': plan.isPrepaidPostpaid,
                'plan_expiry_days': plan.planExpiryDays,
                'plan_expiry_type': plan.planExpiryType,
                'carrier': plan.carrier,
                'plan_discount_details': plan.planDiscountDetails,
                'autopay_discount': plan.autopayDiscount,
              };
            }).toList();
            
            await _firebaseManager.savePlans(
              zipCode: zipCodeToUse,
              enrollmentType: enrollmentType,
              isFamilyPlan: isFamilyPlan,
              plans: plansData,
            );
            print('✅ Plans saved to Firestore for zip code: $zipCodeToUse');
          } catch (e) {
            print('⚠️ Failed to save plans to Firestore: $e');
          }
        }
        
        print('✅ Loaded ${allPlans.length} plans from API for zip code: $zipCodeToUse');
      }
      
      // Filter to show only the 5 hardcoded plans by name
      final allowedPlanNames = _getAllowedPlanNames();
      final filteredPlans = allPlans
          .where((plan) {
            final planName = plan.planName;
            return allowedPlanNames.any((allowed) => planName == allowed);
          })
          .map((plan) {
            final originalPlanName = plan.planName;
            final displayName = _getDisplayName(originalPlanName);
            
            return Plan(
              planId: plan.planId,
              planName: originalPlanName.replaceAll('&amp;', '&'),
              planPrice: plan.planPrice,
              totalPlanPrice: plan.totalPlanPrice,
              planDescription: plan.planDescription,
              displayName: displayName,
              displayDescription: plan.displayDescription,
              displayFeaturesDescription: plan.displayFeaturesDescription,
              data: plan.data,
              talk: plan.talk,
              text: plan.text,
              isUnlimitedPlan: plan.isUnlimitedPlan,
              isFamilyPlan: plan.isFamilyPlan,
              isPrepaidPostpaid: plan.isPrepaidPostpaid,
              planExpiryDays: plan.planExpiryDays,
              planExpiryType: plan.planExpiryType,
              carrier: plan.carrier,
              planDiscountDetails: plan.planDiscountDetails,
              autopayDiscount: plan.autopayDiscount,
            );
          })
          .toList();
      
      // Sort by price to maintain consistent order (10, 20, 30, 40, 50)
      filteredPlans.sort((a, b) => a.planPrice.compareTo(b.planPrice));
      
      _availablePlans = filteredPlans;
      print('✅ Filtered to ${filteredPlans.length} hardcoded plans');
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ Failed to load plans: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Force reload plans (useful for retry scenarios)
  Future<void> reloadPlans() async {
    _availablePlans = [];
    await loadPlans(_currentZipCode);
  }
  
  /// Clear cached plans (useful when user logs out)
  void clearPlans() {
    _availablePlans = [];
    _currentZipCode = '';
    _errorMessage = null;
    notifyListeners();
  }
}

