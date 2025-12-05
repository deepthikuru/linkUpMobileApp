import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_registration_view_model.dart';
import '../../providers/plans_provider.dart';
import '../../services/firebase_manager.dart';
import '../../models/plan_model.dart';
import '../../widgets/expandable_plan_card.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../providers/navigation_state.dart';
import 'address_info_sheet.dart';

// Helper function to get the allowed plan names (matching start_order_view.dart)
List<String> _getAllowedPlanNames() {
  return [
    'LinkUp \$50 Unlimited',
    'LinkUp \$40 30GB',
    'LinkUp \$30 12GB',
    'LinkUp \$20 Unlimited Talk &amp; Text + 3GB Data',
    'LinkUp \$10 1GB',
  ];
}

// Body-only version for MainLayout
class PlansViewBody extends StatefulWidget {
  const PlansViewBody({super.key});

  @override
  State<PlansViewBody> createState() => _PlansViewBodyState();
}

class _PlansViewBodyState extends State<PlansViewBody> {
  final FirebaseManager _firebaseManager = FirebaseManager();
  
  String _currentZipCode = '';
  int? _expandedPlanId; // Track which plan is expanded

  @override
  void initState() {
    super.initState();
    _loadAddressInfo();
    // Set footer tab to plans when this view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigationState = Provider.of<NavigationState>(context, listen: false);
      navigationState.setFooterTab(FooterTab.plans);
    });
  }

  Future<void> _loadAddressInfo() async {
    final viewModel = Provider.of<UserRegistrationViewModel>(context, listen: false);
    await viewModel.loadUserData();
    
    final previousZipCode = _currentZipCode;
    final newZipCode = viewModel.zip.isNotEmpty ? viewModel.zip : AppConstants.defaultZipCode;
    
    setState(() {
      _currentZipCode = newZipCode;
    });
    
    // Load plans using provider - only loads if zip code changed
    final plansProvider = Provider.of<PlansProvider>(context, listen: false);
    await plansProvider.loadPlans(newZipCode);
  }

  Future<void> _createOrderFromPlan(Plan plan) async {
    final viewModel = Provider.of<UserRegistrationViewModel>(context, listen: false);
    final userId = viewModel.userId;
    
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
      }
      return;
    }

    try {
      final planId = plan.planId;
      final planName = plan.displayName ?? plan.planName;
      final planPrice = plan.totalPlanPrice;
      final carrier = plan.carrier.isNotEmpty 
          ? plan.carrier.first 
          : 'LINKUP';
      final planCode = plan.planId.toString();

      print('🔄 Creating new order for userId: $userId');
      print('   planId: $planId');
      print('   planName: $planName');
      print('   planPrice: $planPrice');
      print('   carrier: $carrier');
      print('   plan_code: $planCode');

      final orderId = await _firebaseManager.createNewOrder(
        userId: userId,
        planId: planId.toString(),
        planName: planName,
        planPrice: planPrice.toDouble(),
        carrier: carrier,
        planCode: planCode,
      );

      print('✅ Order created with ID: $orderId');
      print('🚀 Starting order flow with orderId: $orderId');

      await _firebaseManager.copyContactInfoToOrder(userId, orderId);
      await _firebaseManager.copyShippingAddressToOrder(userId, orderId);

      viewModel.orderId = orderId;

      // Start the order flow
      final navigationState = Provider.of<NavigationState>(context, listen: false);
      navigationState.currentOrderId = orderId;
      navigationState.orderStartStep = 1;
      navigationState.navigateTo(Destination.orderFlow);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating order: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlansProvider>(
      builder: (context, plansProvider, _) {
        final isLoadingPlans = plansProvider.isLoading;
        final availablePlans = plansProvider.availablePlans;
        
        final iconColor = AppTheme.getComponentIconColor(
          context,
          'plansView_filterIcon',
          fallback: Colors.grey,
        );
        final titleColor = AppTheme.getComponentTextColor(
          context,
          'plansView_filterTitle_text',
          fallback: Colors.grey[700]!,
        );
        final bodyColor = AppTheme.getComponentTextColor(
          context,
          'plansView_filterSubtitle_text',
          fallback: Colors.grey[600]!,
        );

        return isLoadingPlans
            ? const Center(child: CircularProgressIndicator())
            : availablePlans.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: iconColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No plans available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No plans found for ZIP: ${_currentZipCode.isEmpty ? AppConstants.defaultZipCode : _currentZipCode}',
                            style: TextStyle(
                              fontSize: 14,
                              color: bodyColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => plansProvider.reloadPlans(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
                        child: Center(
                          child: Text(
                            'Plans made for how you connect.',
                            textAlign: TextAlign.center,
                            style: AppTheme.getDoubleBoldTextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: availablePlans.length,
                          itemBuilder: (context, index) {
                            final plan = availablePlans[index];
                            final isExpanded = _expandedPlanId == plan.planId;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ExpandablePlanCard(
                                plan: plan,
                                isExpanded: isExpanded,
                                showUnlimited: index < 5,
                                onTap: () {
                                  setState(() {
                                    // Toggle expansion: if clicking the same plan, collapse it
                                    _expandedPlanId = isExpanded ? null : plan.planId;
                                  });
                                },
                                onContinue: () {
                                  _createOrderFromPlan(plan);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
      },
      );
  }
}

