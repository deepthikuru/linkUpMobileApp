import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/user_registration_view_model.dart';
import '../../providers/plans_provider.dart';
import '../../services/firebase_manager.dart';
import '../../services/firebase_order_manager.dart';
import '../../models/plan_model.dart';
import '../../models/order_models.dart' as models;
import '../../widgets/app_footer.dart';
import '../../widgets/order_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/mesh_background.dart';
import 'plans_view.dart';
import 'address_info_sheet.dart';
import '../order_flow/contact_info_view.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../screens/profile/previous_orders_view.dart';
import '../../providers/navigation_state.dart';
import '../order_flow/order_detail_view.dart';

// Shared content widget containing all common logic
class _StartOrderContent extends StatefulWidget {
  final bool isNewUser;
  final Function(String)? onStart;
  final Function(String, int)? onResume;
  final bool isBodyOnly;

  _StartOrderContent({
    super.key,
    required this.isNewUser,
    this.onStart,
    this.onResume,
    this.isBodyOnly = false,
  });

  @override
  State<_StartOrderContent> createState() => _StartOrderContentState();
}

class _StartOrderContentState extends State<_StartOrderContent> {
  final FirebaseManager _firebaseManager = FirebaseManager();
  final FirebaseOrderManager _orderManager = FirebaseOrderManager();
  
  // Helper method to safely update state on main thread
  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(fn);
      }
    });
  }
  
  Plan? _selectedPlan;
  List<models.Order> _incompleteOrders = [];
  List<Map<String, dynamic>> _incompleteOrderDetails = [];
  List<models.Order> _recentOrders = [];
  int _totalOrdersCount = 0;
  bool _isLoading = false;
  String _currentZipCode = '';
  int _currentOrderIndex = 0;
  PageController? _orderPageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadData();
    // Set footer tab to home when this view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigationState = Provider.of<NavigationState>(context, listen: false);
      navigationState.setFooterTab(FooterTab.home);
    });
  }

  @override
  void dispose() {
    _orderPageController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final viewModel = Provider.of<UserRegistrationViewModel>(context, listen: false);
    await viewModel.loadUserData();
    
    final previousZipCode = _currentZipCode;
    final newZipCode = viewModel.zip.isNotEmpty ? viewModel.zip : AppConstants.defaultZipCode;
    
    if (!mounted) return;
    setState(() {
      _currentZipCode = newZipCode;
    });

    // Load plans using provider - only loads if zip code changed
    final plansProvider = Provider.of<PlansProvider>(context, listen: false);
    await plansProvider.loadPlans(newZipCode);

    // Load orders for all users to determine order count
      await Future.wait([
      _loadIncompleteOrders(),
      _loadRecentOrders(),
      ]);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }


  Future<void> _loadIncompleteOrders() async {
    final viewModel = Provider.of<UserRegistrationViewModel>(context, listen: false);
    final userId = viewModel.userId;
    
    if (userId == null) return;

    try {
      final db = FirebaseFirestore.instance;
      final snapshot = await db
          .collection("users")
          .doc(userId)
          .collection("orders")
          .where("portInSkipped", isEqualTo: true)
          .get();
      
      final List<models.Order> incompleteOrders = [];
      final List<Map<String, dynamic>> orderDetails = [];
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        
        final order = models.Order(
          id: doc.id,
          userId: userId,
          planName: data['planName'] ?? '',
          amount: (data['amount'] ?? 0).toDouble(),
          orderDate: (data['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          status: models.OrderStatus.values.firstWhere(
            (e) => e.name == (data['status'] ?? 'pending'),
            orElse: () => models.OrderStatus.pending,
          ),
          billingCompleted: data['billingCompleted'] ?? false,
          phoneNumber: data['phoneNumber'] ?? data['selectedPhoneNumber'],
          simType: data['simType'] ?? '',
          currentStep: data['currentStep'],
        );
        
        incompleteOrders.add(order);
        orderDetails.add(data);
      }
      
      if (!mounted) return;
      _safeSetState(() {
        _incompleteOrders = incompleteOrders;
        _incompleteOrderDetails = orderDetails;
      });
    } catch (e) {
      print('Error loading incomplete orders: $e');
    }
  }

  Future<void> _loadRecentOrders() async {
    final viewModel = Provider.of<UserRegistrationViewModel>(context, listen: false);
    final userId = viewModel.userId;
    
    if (userId == null) return;

    try {
      final orders = await _orderManager.fetchUserOrders(userId);
      if (!mounted) return;
      _safeSetState(() {
        _totalOrdersCount = orders.length;
        _recentOrders = orders.take(3).toList();
      });
    } catch (e) {
      // Handle error
    }
  }

  List<String> _determineMissingTasks(Map<String, dynamic> orderData) {
    final List<String> tasks = [];
    
    final portInAccountNumber = orderData['portInAccountNumber'] as String? ?? '';
    final portInPin = orderData['portInPin'] as String? ?? '';
    final portInCurrentCarrier = orderData['portInCurrentCarrier'] as String? ?? '';
    final portInAccountHolderName = orderData['portInAccountHolderName'] as String? ?? '';
    
    if (portInAccountNumber.isEmpty || portInPin.isEmpty || 
        portInCurrentCarrier.isEmpty || portInAccountHolderName.isEmpty) {
      tasks.add('Complete number porting information');
    }
    
    final creditCardNumber = orderData['creditCardNumber'] as String? ?? '';
    final billingDetails = orderData['billingDetails'] as String? ?? '';
    
    if (creditCardNumber.isEmpty || billingDetails.isEmpty) {
      tasks.add('Complete billing information');
    }
    
    final firstName = orderData['firstName'] as String? ?? '';
    final lastName = orderData['lastName'] as String? ?? '';
    final street = orderData['street'] as String? ?? '';
    
    if (firstName.isEmpty || lastName.isEmpty || street.isEmpty) {
      tasks.add('Complete contact and shipping information');
    }
    
    return tasks.isEmpty ? ['Complete remaining order steps'] : tasks;
  }

  Future<void> _createNewOrder() async {
    if (_selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a plan')),
      );
      return;
    }

    final viewModel = Provider.of<UserRegistrationViewModel>(context, listen: false);
    final userId = viewModel.userId;
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      final planId = _selectedPlan!.planId;
      final planName = _selectedPlan!.displayName ?? _selectedPlan!.planName;
      final planPrice = _selectedPlan!.totalPlanPrice;
      final carrier = _selectedPlan!.carrier.isNotEmpty 
          ? _selectedPlan!.carrier.first 
          : 'LINKUP';
      final planCode = _selectedPlan!.planId.toString();

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

      // Check if contact info exists (for new users)
      final hasContactInfo = viewModel.firstName.isNotEmpty && 
                            viewModel.lastName.isNotEmpty &&
                            viewModel.phoneNumber.isNotEmpty;

      if (widget.onStart != null) {
        widget.onStart!(orderId);
      } else if (widget.isNewUser && !hasContactInfo) {
        // Navigate to contact info view for new users without contact info
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ContactInfoView(
              currentStep: 1,
              onStepChanged: (step) {
                // Handle step change
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating order: $e')),
        );
      }
    }
  }


  String get currentZipCode => _currentZipCode;
  void reloadData() => _loadData();

  @override
  Widget build(BuildContext context) {
    if (widget.isBodyOnly) {
      return _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 24.0,
                    bottom: 0.0,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: _buildContent(),
                        ),
                      );
                    },
                            );
                          } else {
      final loadingColor = AppTheme.getComponentIconColor(
        context,
        'startOrder_loadingIndicator_color',
        fallback: AppTheme.accentGold,
      );
      final loadingTextColor = AppTheme.getComponentTextColor(
        context,
        'startOrder_loadingText_text',
        fallback: Colors.grey,
      );
      
      return _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading...',
                            style: TextStyle(
                              fontSize: 16,
                              color: loadingTextColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: _buildContent(),
                          ),
                        );
                      },
                    );
    }
  }

  Widget _buildContent() {
    // Get component colors for start order view
    final heroTitleColor = AppTheme.getComponentTextColor(
      context,
      'startOrder_heroTitle_text',
      fallback: Colors.white,
    );
    final heroSubtitleGradient = AppTheme.getComponentGradient(
      context,
      'startOrder_heroSubtitle_gradientStart',
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      fallback: AppTheme.blueGradient,
    );
    final welcomeTitleColor = AppTheme.getComponentTextColor(
      context,
      'startOrder_welcomeTitle_text',
      fallback: Colors.black,
    );
    final welcomeSubtitleColor = AppTheme.getComponentTextColor(
      context,
      'startOrder_welcomeSubtitle_text',
      fallback: Colors.grey,
    );
    
    return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
              // Hero Section - Content aligned to top
              if (_totalOrdersCount == 0) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/OrgCoral_Eco-01_Concept-06.jpg',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'CONNECT TO THE WORLD FOR LESS',
                        style: AppTheme.getDoubleBoldTextStyle(
                          color: Colors.white,
                          fontSize: 36,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Unlimited talk & text starting at \$10 a month',
                        style: AppTheme.getDoubleBoldTextStyle(
                          color: AppTheme.accentGold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            final navigationState = Provider.of<NavigationState>(context, listen: false);
                            navigationState.navigateToTab(FooterTab.plans);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.getComponentBackgroundColor(
                              context,
                              'startOrder_seePlansButton_background',
                              fallback: AppTheme.redAccent,
                            ),
                            foregroundColor: AppTheme.getComponentTextColor(
                              context,
                              'startOrder_seePlansButton_text',
                              fallback: Colors.white,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'See plan details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Consumer<UserRegistrationViewModel>(
                  builder: (context, viewModel, _) {
                    final heading = viewModel.homeHeadingForExistingUser.isNotEmpty
                        ? viewModel.homeHeadingForExistingUser
                        : 'Welcome back!';
                    
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              heading,
                            textAlign: TextAlign.center,
                            style: AppTheme.getDoubleBoldTextStyle(
                              color: Colors.white,
                              fontSize: 32,
                            ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Here\'s your dashboard.',
                            textAlign: TextAlign.center,
                              style: AppTheme.getDoubleBoldTextStyle(
                                color: AppTheme.accentGold,
                                fontSize: 16,
                              ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                final navigationState = Provider.of<NavigationState>(context, listen: false);
                                navigationState.navigateToTab(FooterTab.plans);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.getComponentBackgroundColor(
                                  context,
                                  'startOrder_seePlansButton_background',
                                  fallback: AppTheme.redAccent,
                              ),
                                foregroundColor: AppTheme.getComponentTextColor(
                                  context,
                                  'startOrder_seePlansButton_text',
                                  fallback: Colors.white,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                        ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'See plan details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              
              // Complete Your Setup Section - only for users with orders
              if (_totalOrdersCount > 0 && _incompleteOrders.isNotEmpty) ...[
                const SizedBox(height: 24),
                        Builder(
                          builder: (context) {
                            final completeSetupBg = AppTheme.getComponentBackgroundColor(
                              context,
                              'startOrder_completeSetup_background',
                              fallback: Color.lerp(AppTheme.accentGold, Colors.white, 0.85) ?? AppTheme.accentGold,
                            );
                            final completeSetupBorder = AppTheme.getComponentBorderColor(
                              context,
                              'startOrder_completeSetup_border',
                              fallback: AppTheme.accentGold,
                            );
                            final completeSetupTitleColor = AppTheme.getComponentTextColor(
                              context,
                              'startOrder_completeSetup_title_text',
                              fallback: Colors.black87,
                            );
                            final completeSetupSubtitleColor = AppTheme.getComponentTextColor(
                              context,
                              'startOrder_completeSetup_subtitle_text',
                              fallback: Colors.grey,
                            );
                            
                            return Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: completeSetupBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: completeSetupBorder,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Complete Your Setup',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: completeSetupTitleColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'You have orders that need completion to activate your SIM:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: completeSetupSubtitleColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 360,
                                child: PageView.builder(
                                  controller: _orderPageController,
                                  itemCount: _incompleteOrders.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentOrderIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return _buildIncompleteOrderCard(index);
                                  },
                                ),
                              ),
                              if (_incompleteOrders.length > 1) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    _incompleteOrders.length,
                                    (index) => Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppTheme.getComponentBackgroundColor(
                                          context,
                                          'startOrder_completeSetup_indicator',
                                          fallback: AppTheme.accentGold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                          },
                        ),
                const SizedBox(height: 24),
              ],
              
              // Recent Orders Section - only for users with orders
              if (_totalOrdersCount > 0 && _recentOrders.isNotEmpty) ...[
                const SizedBox(height: 32),
                        Builder(
                          builder: (context) {
                            final recentOrdersBg = AppTheme.getComponentBackgroundColor(
                              context,
                              'startOrder_recentOrders_background',
                              fallback: Colors.grey[100],
                            );
                            final recentOrdersTitleColor = AppTheme.getComponentTextColor(
                              context,
                              'startOrder_recentOrders_title_text',
                              fallback: Colors.black,
                            );
                            final recentOrdersCountColor = AppTheme.getComponentTextColor(
                              context,
                              'startOrder_recentOrders_count_text',
                              fallback: Colors.grey,
                            );
                            
                            return Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: recentOrdersBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Recent Orders',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: recentOrdersTitleColor,
                                    ),
                                  ),
                                  Text(
                                    '$_totalOrdersCount total',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: recentOrdersCountColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ..._recentOrders.map((order) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: OrderCard(
                                  order: order,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OrderDetailView(orderId: order.id),
                                      ),
                                    );
                                  },
                                ),
                              )),
                              if (_totalOrdersCount > 3) ...[
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const PreviousOrdersView(),
                                      ),
                                    );
                                  },
                                  child: Builder(
                                    builder: (context) {
                                      final viewAllOrdersIconColor = AppTheme.getComponentIconColor(
                                        context,
                                        'startOrder_viewAllOrders_icon',
                                        fallback: AppTheme.mainBlue,
                                      );
                                      final viewAllOrdersTextColor = AppTheme.getComponentTextColor(
                                        context,
                                        'startOrder_viewAllOrders_text',
                                        fallback: AppTheme.mainBlue,
                                      );
                                      
                                      return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.visibility_outlined,
                                        color: viewAllOrdersIconColor,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'View all orders',
                                        style: TextStyle(
                                          color: viewAllOrdersTextColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                          },
                        ),
                if (!widget.isBodyOnly) const SizedBox(height: 24),
                if (widget.isBodyOnly) const SizedBox(height: 16),
              ],
            ],
        ),
      );
  }

  // New method to build compact plan cards for homepage
  Widget _buildCompactPlanCard(Plan plan) {
    // Format data
    String dataText = '';
    if (plan.isUnlimitedPlan == 'Y' || (plan.data >= 20000)) {
      dataText = 'UNLIMITED';
    } else if (plan.data >= 1000) {
      dataText = '${plan.data ~/ 1000}GB';
    } else {
      dataText = '${plan.data}MB';
    }
    
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {}, // Plan details now shown in expandable card
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Plan name badge - light blue with white text
              if (plan.displayName != null && plan.displayName!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    plan.displayName!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              if (plan.displayName != null && plan.displayName!.isNotEmpty)
                const SizedBox(height: 12),
              // Price - large blue text
              Text(
                '\$${plan.totalPlanPrice}/mo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.mainBlue,
                ),
              ),
              const Spacer(),
              // Data amount - grey text
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  dataText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              // Details link with arrow
              Row(
                children: [
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppTheme.mainBlue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.mainBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppTheme.getComponentIconColor(
              context,
              'numberSelection_statusIcon_available',
              fallback: Colors.green,
            ),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncompleteOrderCard(int index) {
    final order = _incompleteOrders[index];
    final orderData = index < _incompleteOrderDetails.length
        ? _incompleteOrderDetails[index]
        : <String, dynamic>{};
    
    final phoneNumber = orderData['selectedPhoneNumber'] as String? ?? 
                       orderData['phoneNumber'] as String? ?? 
                       'N/A';
    final simTypeFromData = orderData['simType'] as String?;
    final simType = simTypeFromData ?? 
                  (order.simType.isNotEmpty ? order.simType : 'Physical SIM');
    final deviceBrand = orderData['deviceBrand'] as String? ?? 'Unknown';
    final deviceModel = orderData['deviceModel'] as String? ?? 'Unknown';
    final createdAt = orderData['createdAt'] != null
        ? (orderData['createdAt'] as Timestamp).toDate()
        : order.orderDate;
    final missingTasks = _determineMissingTasks(orderData);
    
    final incompleteOrderBg = AppTheme.getComponentBackgroundColor(
      context,
      'startOrder_incompleteOrder_background',
      fallback: Colors.white,
    );
    final incompleteOrderBorder = AppTheme.getComponentBorderColor(
      context,
      'startOrder_incompleteOrder_border',
      fallback: Colors.grey[300]!,
    );
    final incompleteOrderShadow = AppTheme.getComponentShadowColor(
      context,
      'startOrder_incompleteOrder_shadow',
      fallback: Colors.black.withOpacity(0.05),
    );
    final incompleteOrderTitleColor = AppTheme.getComponentTextColor(
      context,
      'startOrder_incompleteOrder_title_text',
      fallback: Colors.black87,
    );
    final incompleteOrderDateColor = AppTheme.getComponentTextColor(
      context,
      'startOrder_incompleteOrder_date_text',
      fallback: Colors.grey,
    );
    final incompleteOrderBadgeBg = AppTheme.getComponentBackgroundColor(
      context,
      'startOrder_incompleteOrder_badge_background',
      fallback: Colors.orange.withOpacity(0.2),
    );
    final incompleteOrderBadgeText = AppTheme.getComponentTextColor(
      context,
      'startOrder_incompleteOrder_badge_text',
      fallback: Colors.orange,
    );
    final incompleteOrderTaskIconColor = AppTheme.getComponentIconColor(
      context,
      'startOrder_incompleteOrder_taskIcon',
      fallback: Colors.orange,
    );
    final incompleteOrderTaskTextColor = AppTheme.getComponentTextColor(
      context,
      'startOrder_incompleteOrder_taskText',
      fallback: Colors.black87,
    );
    final incompleteOrderTaskMoreColor = AppTheme.getComponentTextColor(
      context,
      'startOrder_incompleteOrder_taskMore_text',
      fallback: Colors.grey,
    );
    final incompleteOrderInfoIconColor = AppTheme.getComponentIconColor(
      context,
      'startOrder_incompleteOrder_infoIcon',
      fallback: Colors.orange,
    );
    final incompleteOrderInfoTextColor = AppTheme.getComponentTextColor(
      context,
      'startOrder_incompleteOrder_infoText',
      fallback: Colors.black87,
    );
    final viewDetailsButtonBg = AppTheme.getComponentBackgroundColor(
      context,
      'startOrder_viewDetailsButton_background',
      fallback: AppTheme.redAccent
    );
    final viewDetailsButtonText = AppTheme.getComponentTextColor(
      context,
      'startOrder_viewDetailsButton_text',
      fallback: Colors.white,
    );
    final viewDetailsButtonIcon = AppTheme.getComponentIconColor(
      context,
      'startOrder_viewDetailsButton_icon',
      fallback: Colors.white,
    );
    final completeSetupButtonGradient = AppTheme.getComponentGradient(
      context,
      'startOrder_completeSetupButton_gradientStart',
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      fallback: AppTheme.blueGradient,
    );
    final completeSetupButtonText = AppTheme.getComponentTextColor(
      context,
      'startOrder_completeSetupButton_text',
      fallback: Colors.white,
    );
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: incompleteOrderBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: incompleteOrderBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: incompleteOrderShadow,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        constraints: const BoxConstraints(
          minHeight: 320,
          maxHeight: 360,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, 8)}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: incompleteOrderTitleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Started: ${_formatDate(createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: incompleteOrderDateColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: incompleteOrderBadgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Incomplete',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: incompleteOrderBadgeText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (phoneNumber.isNotEmpty && phoneNumber != 'N/A' && phoneNumber != 'Unknown') ...[
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: AppTheme.accentGold,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(
                      'Number: $phoneNumber',
                      style: TextStyle(
                        fontSize: 14,
                        color: incompleteOrderInfoTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            Row(
              children: [
                Icon(
                  Icons.sim_card,
                  size: 16,
                  color: incompleteOrderInfoIconColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'SIM Type: $simType',
                    style: TextStyle(
                      fontSize: 14,
                      color: incompleteOrderInfoTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (deviceBrand != 'Unknown') ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.smartphone,
                    size: 16,
                    color: incompleteOrderInfoIconColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Device: $deviceBrand $deviceModel',
                      style: TextStyle(
                        fontSize: 14,
                        color: incompleteOrderInfoTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (missingTasks.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Tasks to Complete:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: incompleteOrderTaskTextColor,
                ),
              ),
              const SizedBox(height: 4),
              ...missingTasks.take(2).map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error,
                      size: 16,
                      color: incompleteOrderTaskIconColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task,
                        style: TextStyle(
                          fontSize: 12,
                          color: incompleteOrderTaskTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
              if (missingTasks.length > 2)
                Padding(
                  padding: const EdgeInsets.only(left: 24, top: 4),
                  child: Text(
                    '+${missingTasks.length - 2} more task${missingTasks.length - 2 == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 10,
                      color: incompleteOrderTaskMoreColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
            const Spacer(),
            const SizedBox(height: 8),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailView(orderId: order.id),
                        ),
                      );
                    },
                    icon: Icon(Icons.info_outline, size: 18, color: viewDetailsButtonIcon),
                    label: Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: viewDetailsButtonText,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: viewDetailsButtonText,
                      side: BorderSide.none,
                      backgroundColor: viewDetailsButtonBg,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: completeSetupButtonGradient ?? AppTheme.blueGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (widget.onResume != null) {
                        final orderManager = FirebaseOrderManager();
                        final viewModel = Provider.of<UserRegistrationViewModel>(context, listen: false);
                        final userId = viewModel.userId;
                        
                        if (userId != null) {
                          final orderData = await orderManager.fetchOrderDocument(userId, order.id);
                          
                          final missingTasksList = _determineMissingTasks(orderData ?? {});
                          
                          final numberType = orderData?['numberType'] as String? ?? '';
                          final isPortInOrder = numberType == 'Existing' || numberType.toLowerCase() == 'existing';
                          
                          final portInAccountNumber = orderData?['portInAccountNumber'] as String? ?? '';
                          final portInPin = orderData?['portInPin'] as String? ?? '';
                          final portInCurrentCarrier = orderData?['portInCurrentCarrier'] as String? ?? '';
                          final portInAccountHolderName = orderData?['portInAccountHolderName'] as String? ?? '';
                          final hasMissingPortInInfo = portInAccountNumber.isEmpty || 
                                                       portInPin.isEmpty || 
                                                       portInCurrentCarrier.isEmpty || 
                                                       portInAccountHolderName.isEmpty;
                          
                          int targetStep = order.currentStep ?? 1;
                          
                          if (isPortInOrder && hasMissingPortInInfo) {
                            targetStep = 6;
                            
                            await orderManager.saveStepProgress(
                              userId: userId,
                              orderId: order.id,
                              step: 6,
                              data: {'portInSkipped': false},
                            );
                          } else {
                            final billingCompleted = orderData?['billingCompleted'] ?? false;
                            if (billingCompleted) {
                              targetStep = 6;
                            } else {
                              targetStep = order.currentStep ?? 1;
                            }
                          }
                          
                          widget.onResume!(
                            order.id,
                            targetStep,
                          );
                        } else {
                          widget.onResume!(
                            order.id,
                            order.currentStep ?? 1,
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: Text(
                      'Complete Setup',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: completeSetupButtonText,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: completeSetupButtonText,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class StartOrderView extends StatefulWidget {
  final bool isNewUser;
  final Function(String)? onStart;
  final Function(String, int)? onResume;

  const StartOrderView({
    super.key,
    required this.isNewUser,
    this.onStart,
    this.onResume,
  });

  @override
  State<StartOrderView> createState() => _StartOrderViewState();
}

class _StartOrderViewState extends State<StartOrderView> {
  final GlobalKey<_StartOrderContentState> _contentKey = GlobalKey<_StartOrderContentState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MeshBackground(
        animated: true,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                  child: _StartOrderContent(
                    key: _contentKey,
                    isNewUser: widget.isNewUser,
                    onStart: widget.onStart,
                    onResume: widget.onResume,
                    isBodyOnly: false,
                  ),
                ),
              Consumer<NavigationState>(
                builder: (context, navigationState, _) {
                  return AppFooter(
                    currentTab: navigationState.currentFooterTab,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Body-only version for MainLayout
class StartOrderViewBody extends StatefulWidget {
  final bool isNewUser;
  final Function(String)? onStart;
  final Function(String, int)? onResume;

  const StartOrderViewBody({
    super.key,
    required this.isNewUser,
    this.onStart,
    this.onResume,
  });

  @override
  State<StartOrderViewBody> createState() => _StartOrderViewBodyState();
}

class _StartOrderViewBodyState extends State<StartOrderViewBody> {
  @override
  Widget build(BuildContext context) {
    return _StartOrderContent(
      isNewUser: widget.isNewUser,
      onStart: widget.onStart,
      onResume: widget.onResume,
      isBodyOnly: true,
    );
  }
}
