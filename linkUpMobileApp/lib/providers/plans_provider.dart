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
      // First, try to get plans from Firestore (cached by zip code only)
      final cachedPlansData = await _firebaseManager.getPlans(
        zipCode: zipCodeToUse,
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
        
        // Get IP address (optional)
        final ipAddress = await _apiManager.getDeviceIPAddress();
        
        // Fetch plans from API with new structure
        allPlans = await _apiManager.getPlanList(
          zipCode: zipCodeToUse,
          ipAddress: ipAddress,
          isFamilyPlan: 'BOTH', // Use BOTH as per new API structure
        );
        
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
              plans: plansData,
            );
            print('✅ Plans saved to Firestore for zip code: $zipCodeToUse');
          } catch (e) {
            print('⚠️ Failed to save plans to Firestore: $e');
          }
        }
        
        print('✅ Loaded ${allPlans.length} plans from API for zip code: $zipCodeToUse');
      }
      
      // Use all plans from API (no filtering)
      _availablePlans = allPlans;
      print('✅ Loaded ${allPlans.length} plans');
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ Failed to load plans: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Force reload plans (clears cache and fetches fresh from API)
  Future<void> reloadPlans() async {
    _availablePlans = [];
    
    // Clear Firestore cache to force fresh API call
    if (_currentZipCode.isNotEmpty) {
      try {
        await _firebaseManager.clearPlansCache(zipCode: _currentZipCode);
        print('🗑️ Cleared plans cache for zip code: $_currentZipCode');
      } catch (e) {
        print('⚠️ Failed to clear plans cache: $e');
      }
    }
    
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

