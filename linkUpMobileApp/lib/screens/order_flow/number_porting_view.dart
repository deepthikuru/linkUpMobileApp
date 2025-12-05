import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/user_registration_view_model.dart';
import '../../services/firebase_order_manager.dart';
import '../../services/vcare_api_manager.dart';
import '../../widgets/step_navigation_container.dart';
import '../../widgets/gradient_button.dart';
import '../../utils/theme.dart';
import 'sim_setup_view.dart';
import 'porting_view.dart';

class NumberPortingView extends StatefulWidget {
  final int currentStep;
  final Function(int) onStepChanged;

  const NumberPortingView({
    super.key,
    required this.currentStep,
    required this.onStepChanged,
  });

  @override
  State<NumberPortingView> createState() => _NumberPortingViewState();
}

class _NumberPortingViewState extends State<NumberPortingView> {
  bool _isCompleting = false;
  bool _showPortingView = false;
  bool _showSimSetup = false;
  bool _isPortingFormValid = false;
  bool _isSimSetupFormValid = false; // Track SIM setup form validity
  bool _qrCodeAlreadyShown = false; // Track if QR code was already shown
  final GlobalKey _portingViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    print('[NumberPortingView] initState called');
    _checkFlow();
  }

  Future<void> _checkFlow() async {
    final viewModel = Provider.of<UserRegistrationViewModel>(context, listen: false);
    
    print('[NumberPortingView] _checkFlow started');
    print('[NumberPortingView] userId: ${viewModel.userId}');
    print('[NumberPortingView] orderId: ${viewModel.orderId}');
    print('[NumberPortingView] numberType from viewModel: "${viewModel.numberType}"');
    print('[NumberPortingView] simType from viewModel: "${viewModel.simType}"');
    print('[NumberPortingView] portInSkipped from viewModel: ${viewModel.portInSkipped}');
    
    // First, try to get data from order if viewModel is not populated yet
    if (viewModel.userId != null && viewModel.orderId != null) {
      print('[NumberPortingView] Fetching order data...');
      final orderManager = FirebaseOrderManager();
      final orderData = await orderManager.fetchOrderDocument(viewModel.userId!, viewModel.orderId!);
      
      if (orderData != null) {
        print('[NumberPortingView] Order data fetched successfully');
        print('[NumberPortingView] Order data keys: ${orderData.keys.toList()}');
        
        // Update viewModel with order data if it's missing
        final numberTypeFromOrder = orderData['numberType'] ?? '';
        final simTypeFromOrder = orderData['simType'] ?? '';
        final portInSkippedFromOrder = orderData['portInSkipped'] ?? false;
        final billingCompleted = orderData['billingCompleted'] ?? false;
        
        print('[NumberPortingView] numberType from order: "$numberTypeFromOrder"');
        print('[NumberPortingView] simType from order: "$simTypeFromOrder"');
        print('[NumberPortingView] portInSkipped from order: $portInSkippedFromOrder');
        print('[NumberPortingView] billingCompleted from order: $billingCompleted');
        
        if (numberTypeFromOrder.isNotEmpty && viewModel.numberType.isEmpty) {
          print('[NumberPortingView] Updating viewModel.numberType from "$viewModel.numberType" to "$numberTypeFromOrder"');
          viewModel.numberType = numberTypeFromOrder;
        }
        if (simTypeFromOrder.isNotEmpty && viewModel.simType.isEmpty) {
          print('[NumberPortingView] Updating viewModel.simType from "$viewModel.simType" to "$simTypeFromOrder"');
          viewModel.simType = simTypeFromOrder;
        }
        if (!viewModel.portInSkipped && portInSkippedFromOrder) {
          print('[NumberPortingView] Updating viewModel.portInSkipped from $viewModel.portInSkipped to $portInSkippedFromOrder');
          viewModel.portInSkipped = portInSkippedFromOrder;
        }
        
        // Determine which view to show
        final shouldShowPorting = numberTypeFromOrder == 'Existing' && !portInSkippedFromOrder;
        
        print('[NumberPortingView] shouldShowPorting: $shouldShowPorting');
        print('[NumberPortingView] will show: ${shouldShowPorting ? "PortingView" : "SimSetupView"}');
        
        if (mounted) {
          setState(() {
            if (shouldShowPorting) {
              _showPortingView = true;
              _showSimSetup = false;
              print('[NumberPortingView] Set _showPortingView=true, _showSimSetup=false');
            } else {
              // For new numbers or skipped port-in, show SIM setup
              // Especially if billing is completed
              _showPortingView = false;
              _showSimSetup = true;
              _isSimSetupFormValid = true; // SimSetupView has no form fields, so always valid
              print('[NumberPortingView] Set _showPortingView=false, _showSimSetup=true');
            }
          });
        }
        
        return; // Exit early after handling from order data
      } else {
        print('[NumberPortingView] Order data is null');
      }
    } else {
      print('[NumberPortingView] userId or orderId is null, cannot fetch order data');
    }
    
    // Fallback: Use viewModel data if order fetch fails or not available
    print('[NumberPortingView] Using fallback: viewModel data');
    print('[NumberPortingView] viewModel.numberType: "${viewModel.numberType}"');
    print('[NumberPortingView] viewModel.portInSkipped: ${viewModel.portInSkipped}');
    
    if (viewModel.numberType == 'Existing' && !viewModel.portInSkipped) {
      print('[NumberPortingView] Fallback: Showing PortingView');
      if (mounted) {
        setState(() {
          _showPortingView = true;
          _showSimSetup = false;
        });
      }
    } else {
      print('[NumberPortingView] Fallback: Showing SimSetupView');
      // If skipped or not existing number, go directly to SIM setup
      if (mounted) {
        setState(() {
          _showPortingView = false;
          _showSimSetup = true;
          _isSimSetupFormValid = true; // SimSetupView has no form fields, so always valid
        });
      }
    }
  }

  Future<void> _handleComplete() async {
    setState(() {
      _isCompleting = true;
    });

    final viewModel = Provider.of<UserRegistrationViewModel>(context, listen: false);
    final success = await viewModel.completeOrder();
    
    setState(() {
      _isCompleting = false;
    });

    if (success && mounted) {
      // Navigate back to home
      widget.onStepChanged(0);
    } else if (mounted) {
      final errorBg = AppTheme.getComponentBackgroundColor(
        context,
        'numberPorting_warning_background',
        fallback: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to complete order'),
          backgroundColor: errorBg,
        ),
      );
    }
  }

  Future<void> _handlePortingContinue() async {
    // This is called when user clicks "Continue to SIM Setup" button
    // Validate, save port-in data, submit port-in APIs, and move to SIM setup
    print('🔄 Continue to SIM Setup button clicked');
    
    setState(() {
      _isCompleting = true;
    });
    
    try {
      final viewModel = Provider.of<UserRegistrationViewModel>(context, listen: false);
      
      // Access the PortingView state through the GlobalKey
    final state = _portingViewKey.currentState;
    if (state != null) {
        // Call validateAndSave which returns true on success
        final dynamic portingState = state;
        final success = await portingState.validateAndSave();
        
        if (success) {
          print('✅ Port-in data validated successfully');
          
          // Now submit port-in APIs if this is a port-in order
          bool portInApiSuccess = true;
          if (viewModel.numberType == 'Existing' && !viewModel.portInSkipped) {
            portInApiSuccess = await _submitPortInAPIs(viewModel);
          }
          
          // Only save to Firebase and navigate if APIs succeeded (or if not a port-in order)
          if (portInApiSuccess) {
            // Save to Firebase now that APIs succeeded
            print('💾 Saving port-in information to Firebase...');
            final saveSuccess = await viewModel.saveNumberSelection();
            
            if (saveSuccess) {
              print('✅ Port-in information saved to Firebase successfully');
              // Now navigate to next page
              _onPortingComplete();
              print('✅ Moving to SIM setup');
            } else {
              print('❌ Failed to save port-in information to Firebase');
              if (mounted) {
                final errorBg = AppTheme.getComponentBackgroundColor(
                  context,
                  'snackbar-error',
                  fallback: Colors.red,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.errorMessage ?? 'Failed to save port-in information'),
                    backgroundColor: errorBg,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            }
          } else {
            print('❌ Port-in APIs failed - preventing save and navigation');
            if (mounted) {
              final errorBg = AppTheme.getComponentBackgroundColor(
                context,
                'snackbar-error',
                fallback: Colors.red,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Failed to submit port-in request. Please check your information and try again.'),
                  backgroundColor: errorBg,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          }
        } else {
          print('❌ Port-in validation failed');
          // Error message is already shown in validateAndSave
        }
      } else {
        print('❌ PortingView state is null - cannot validate and save');
        final errorBg = AppTheme.getComponentBackgroundColor(
          context,
          'snackbar-error',
          fallback: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to validate port-in information. Please try again.'),
            backgroundColor: errorBg,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error calling validateAndSave: $e');
      print('   Stack trace: $stackTrace');
      final errorBg = AppTheme.getComponentBackgroundColor(
        context,
        'numberPorting_warning_background',
        fallback: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save port-in information: $e'),
          backgroundColor: errorBg,
        ),
      );
    } finally {
      setState(() {
        _isCompleting = false;
      });
    }
  }

  /// Submit port-in APIs after port-in details are validated
  /// Follows the API flow: get_list → submit_portin → query_portin
  /// Returns true if all APIs succeed, false otherwise
  Future<bool> _submitPortInAPIs(UserRegistrationViewModel viewModel) async {
    try {
      // Get enrollment_id from order document (saved after customer creation in billing)
      if (viewModel.userId == null || viewModel.orderId == null) {
        print('❌ Cannot submit port-in APIs: userId or orderId is null');
        return false;
      }

      final orderManager = FirebaseOrderManager();
      final orderData = await orderManager.fetchOrderDocument(viewModel.userId!, viewModel.orderId!);
      
      if (orderData == null) {
        print('❌ Cannot submit port-in APIs: Order document not found');
        return false;
      }

      // Get enrollment_id from order (saved after customer creation)
      String? enrollmentId = orderData['enrollment_id'] as String?;
      
      // If enrollment_id is not in order, try to get it from the response data
      if (enrollmentId == null || enrollmentId.isEmpty) {
        // Check if it's in nested response data
        final responseData = orderData['response_data'];
        if (responseData is Map && responseData['enrollment_id'] != null) {
          enrollmentId = responseData['enrollment_id'].toString();
        }
      }

      if (enrollmentId == null || enrollmentId.isEmpty) {
        print('❌ Cannot submit port-in APIs: enrollment_id not found in order');
        print('   Order data keys: ${orderData.keys.toList()}');
        return false;
      }

      // Get plan_id from order (required for create_portin_v2 API)
      int? planId;
      if (orderData['plan_id'] is int) {
        planId = orderData['plan_id'] as int;
      } else if (orderData['plan_id'] is String) {
        planId = int.tryParse(orderData['plan_id'] as String);
      }

      if (planId == null) {
        print('❌ Cannot submit port-in APIs: plan_id not found in order');
        print('   Order data keys: ${orderData.keys.toList()}');
        return false;
      }

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔄 STARTING PORT-IN SUBMISSION FLOW');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📋 Port-In Details:');
      print('   Enrollment ID: $enrollmentId');
      print('   Plan ID: $planId');
      print('   Account Number: ${viewModel.portInAccountNumber}');
      print('   Account Holder: ${viewModel.portInAccountHolderName}');
      print('   Current Carrier: ${viewModel.portInCurrentCarrier}');
      print('   Phone Number: ${viewModel.selectedPhoneNumber}');
      print('   Address: ${viewModel.street}, ${viewModel.city}, ${viewModel.state} ${viewModel.zip}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final apiManager = VCareAPIManager();

      // Step 1: Try to get port-in list first
      print('📋 Step 1: Getting port-in list...');
      final transactionId = VCareAPIManager.generateRandomTransactionId();
      var listResponse = await apiManager.getPortInList(
        enrollId: enrollmentId,
        agentId: 'Sushil',
        source: 'WEBSITE',
        externalTransactionId: transactionId,
      );

      // Check if get_list API succeeded or returned "No Record Found" (RESTAPI110)
      // RESTAPI110 with "No Record Found" is expected for NEWACTIVATION customers
      if (listResponse.msgCode != 'RESTAPI000' && listResponse.msgCode != 'RESTAPI110') {
        print('❌ Get port-in list API failed:');
        print('   Message: ${listResponse.msg}');
        print('   Message Code: ${listResponse.msgCode}');
        return false;
      }

      // If no port-in records found, create one first (customer was created with NEWACTIVATION)
      if (listResponse.records.isEmpty) {
        print('⚠️ No port-in records found. Customer was created with NEWACTIVATION.');
        print('   Creating port-in record using create_portin_v2 API...');
        
        // Split port-in account holder name into first and last name
        final portName = viewModel.portInAccountHolderName;
        final portNameParts = portName.split(' ');
        final portFirstName = portNameParts.isNotEmpty ? portNameParts[0] : '';
        final portLastName = portNameParts.length > 1 
            ? portNameParts.sublist(1).join(' ') 
            : '';

        print('📋 Port-In Name Split:');
        print('   Full Name: $portName');
        print('   First Name: $portFirstName');
        print('   Last Name: $portLastName');

        // Get IMEI and SIM from order if available (needed for certain carriers)
        final imei = orderData['imei'] as String?;
        final sim = orderData['sim'] as String?;

        // Clean phone number (remove non-digits)
        final cleanPhoneNumber = viewModel.selectedPhoneNumber.replaceAll(RegExp(r'[^\d]'), '');

        final createTransactionId = VCareAPIManager.generateRandomTransactionId();
        final createResponse = await apiManager.createPortInV2WhenCreateCustomerWasCalledWithoutPortinTag(
          enrollmentId: enrollmentId,
          firstName: portFirstName,
          lastName: portLastName,
          accountNumber: viewModel.portInAccountNumber,
          zipCode: viewModel.zip,
          state: viewModel.state,
          city: viewModel.city,
          addressOne: viewModel.street,
          addressTwo: viewModel.aptNumber,
          passwordPin: viewModel.portInPin,
          portNumber: cleanPhoneNumber,
          imei: imei,
          sim: sim,
          currentCarrier: viewModel.portInCurrentCarrier,
          agentId: 'Sushil',
          source: 'WEBSITE',
          externalTransactionId: createTransactionId,
        );

        // Check if create_portin_v2 API succeeded
        if (createResponse.msgCode != 'RESTAPI000') {
          print('❌ Create port-in v2 API failed:');
          print('   Message: ${createResponse.msg}');
          print('   Message Code: ${createResponse.msgCode}');
          return false;
        }

        print('✅ Port-in record created successfully');
        print('   Message: ${createResponse.msg}');
        print('   Message Code: ${createResponse.msgCode}');

        // Wait 10 seconds (as per API documentation recommendation)
        print('⏳ Waiting 10 seconds before getting port-in list...');
        await Future.delayed(const Duration(seconds: 10));

        // Get port-in list again to retrieve port_subscriber_id
        print('📋 Getting port-in list after creation...');
        final listTransactionId = VCareAPIManager.generateRandomTransactionId();
        listResponse = await apiManager.getPortInList(
          enrollId: enrollmentId,
          agentId: 'Sushil',
          source: 'WEBSITE',
          externalTransactionId: listTransactionId,
        );

        // Check if get_list API succeeded
        if (listResponse.msgCode != 'RESTAPI000') {
          print('❌ Get port-in list API failed after creation:');
          print('   Message: ${listResponse.msg}');
          print('   Message Code: ${listResponse.msgCode}');
          return false;
        }

        if (listResponse.records.isEmpty) {
          print('❌ No port-in records found after creating port-in record.');
          print('   Enrollment ID used: $enrollmentId');
          return false;
        }
      }

      final portRecord = listResponse.records.first;
      final portSubscriberId = portRecord.portSubscriberId;
      final portInStatus = portRecord.portinStatus;

      // Check if port-in was already submitted (if we just created it, it's already submitted)
      final portInAlreadySubmitted = portInStatus != null && 
          portInStatus.isNotEmpty && 
          portInStatus.toLowerCase() != 'pending';

      if (portInAlreadySubmitted) {
        print('✅ Port-in record found and already submitted');
        print('   Port Status: $portInStatus');
        print('   Skipping submit_portin step (port-in already submitted)');
      } else {
        // Port-in record exists but not yet submitted, need to submit it
        if (portSubscriberId == null) {
          print('❌ port_subscriber_id is null. Cannot submit port-in request.');
          print('   Port record details:');
          print('   - Enrollment ID: ${portRecord.enrollmentId}');
          print('   - Port Status: ${portRecord.portinStatus}');
          return false;
        }

        print('✅ Retrieved port_subscriber_id: $portSubscriberId');

        // Step 2: Submit port-in request
        print('📋 Step 2: Submitting port-in request...');
        
        // Split port-in account holder name into first and last name
        final portName = viewModel.portInAccountHolderName;
        final portNameParts = portName.split(' ');
        final portFirstName = portNameParts.isNotEmpty ? portNameParts[0] : '';
        final portLastName = portNameParts.length > 1 
            ? portNameParts.sublist(1).join(' ') 
            : '';

        print('📋 Port-In Name Split:');
        print('   Full Name: $portName');
        print('   First Name: $portFirstName');
        print('   Last Name: $portLastName');

        final submitTransactionId = VCareAPIManager.generateRandomTransactionId();
        final submitResponse = await apiManager.submitPortIn(
          enrollmentId: enrollmentId,
          portinEnrollmentId: portSubscriberId,
          firstName: portFirstName,
          lastName: portLastName,
          zipCode: viewModel.zip,
          city: viewModel.city,
          state: viewModel.state,
          addressOne: viewModel.street,
          addressTwo: viewModel.aptNumber,
          accountNumber: viewModel.portInAccountNumber,
          passwordPin: viewModel.portInPin,
          portCurrentCarrier: viewModel.portInCurrentCarrier,
          agentId: 'Sushil',
          source: 'WEBSITE',
          externalTransactionId: submitTransactionId,
        );

        // Check if submit_portin API succeeded
        if (submitResponse.msgCode != 'RESTAPI000') {
          print('❌ Submit port-in API failed:');
          print('   Message: ${submitResponse.msg}');
          print('   Message Code: ${submitResponse.msgCode}');
          return false;
        }

        print('✅ Port-in request submitted successfully');
        print('   Message: ${submitResponse.msg}');
        print('   Message Code: ${submitResponse.msgCode}');

        // Wait 10 seconds (as per API documentation recommendation)
        print('⏳ Waiting 10 seconds before querying port-in status...');
        await Future.delayed(const Duration(seconds: 10));
      }

      // Step 3: Query port-in status
      print('📋 Step 3: Querying port-in status...');
      final queryTransactionId = VCareAPIManager.generateRandomTransactionId();
      final queryResponse = await apiManager.queryPortIn(
        enrollmentId: enrollmentId,
        agentId: 'Sushil',
        source: 'WEBSITE',
        externalTransactionId: queryTransactionId,
      );

      // Check if query_portin API succeeded
      if (queryResponse.msgCode != 'RESTAPI000') {
        print('❌ Query port-in API failed:');
        print('   Message: ${queryResponse.msg}');
        print('   Message Code: ${queryResponse.msgCode}');
        return false;
      }

      if (queryResponse.record != null) {
        final record = queryResponse.record!;
        print('✅ Port-in status retrieved:');
        print('   Port-in Status: ${record.portinStatus ?? "nil"}');
        print('   Carrier Response: ${record.carrierResponse ?? "nil"}');
        print('   Status: ${record.status ?? "nil"}');
        
        if (record.resolutionDescription != null && record.resolutionDescription!.isNotEmpty) {
          print('   Resolution Description: ${record.resolutionDescription}');
          print('   ⚠️ Port-in may require resolution. User may need to update port-in information.');
        }

        // Save port-in status to order
        await orderManager.saveStepProgress(
          userId: viewModel.userId!,
          orderId: viewModel.orderId!,
          step: 6,
          data: {
            'portInStatus': record.portinStatus,
            'portInCarrierResponse': record.carrierResponse,
            'portInResolutionDescription': record.resolutionDescription,
          },
        );

        // If port-in status is completed, mark order as completed
        if (record.portinStatus?.toLowerCase() == 'completed') {
          print('🎉 Port-in completed successfully! Marking order as completed.');
          await orderManager.markOrderCompleted(viewModel.userId!, viewModel.orderId!);
        }
      } else {
        print('⚠️ No port-in record found in query response');
        // This is not necessarily a failure - the port-in might still be processing
        // But we'll consider it a success if the API call itself succeeded
      }

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('✅ PORT-IN SUBMISSION FLOW COMPLETED SUCCESSFULLY');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return true; // All APIs succeeded
    } catch (e, stackTrace) {
      print('❌ Failed to submit port-in APIs: $e');
      print('   Stack trace: $stackTrace');
      return false; // Return false on any error
    }
  }

  void _handleBack() async {
    // Check if billing is completed - if so, don't allow going back to steps 1-5
    final viewModel = Provider.of<UserRegistrationViewModel>(context, listen: false);
    if (viewModel.userId != null && viewModel.orderId != null) {
      final orderManager = FirebaseOrderManager();
      final orderData = await orderManager.fetchOrderDocument(viewModel.userId!, viewModel.orderId!);
      final billingCompleted = orderData?['billingCompleted'] ?? false;
      
      // If billing is completed, prevent going back to steps 1-5
      if (billingCompleted) {
        // Don't allow going back if billing is completed
        return;
      }
    }
    
    if (_showPortingView) {
      // If showing porting view, go back to step 5
      widget.onStepChanged(5);
    } else if (_showSimSetup) {
      // If showing SIM setup after porting, go back to porting view
      setState(() {
        _showSimSetup = false;
        _showPortingView = true;
      });
    } else {
      // Otherwise go back to step 5
      widget.onStepChanged(5);
    }
  }

  void _onPortingComplete() {
    setState(() {
      _showPortingView = false;
      _showSimSetup = true;
      _isSimSetupFormValid = true; // SimSetupView has no form fields, so always valid
    });
  }

  void _onPortingSkip() {
    // Navigate to home (step 0) when skip is pressed
    widget.onStepChanged(0);
  }

  Future<void> _onSimSetupComplete() async {
    final viewModel = Provider.of<UserRegistrationViewModel>(context, listen: false);
    
    // For new number orders, activate the number and assign eSIM before showing sheet
    if (viewModel.numberType == 'New' && 
        viewModel.userId != null && 
        viewModel.orderId != null) {
      
      setState(() {
        _isCompleting = true;
      });
      
      try {
        final orderManager = FirebaseOrderManager();
        final orderData = await orderManager.fetchOrderDocument(
          viewModel.userId!,
          viewModel.orderId!,
        );
        
        if (orderData != null) {
          final enrollmentId = orderData['enrollment_id'] as String?;
          
          if (enrollmentId != null && enrollmentId.isNotEmpty) {
            final apiManager = VCareAPIManager();
            
            // Step 1: Activate new number
            print('🔄 Activating new number for customer...');
            try {
              // Wait a bit for customer to be in dispatched status
              await Future.delayed(const Duration(seconds: 3));
              
              final activationTransactionId = VCareAPIManager.generateRandomTransactionId();
              
              // Get IMEI from order if available (needed for certain carriers)
              final imei = orderData['imei'] as String?;
              
              // Activate new number
              final activationResponse = await apiManager.activateNewNumber(
                enrollmentId: enrollmentId,
                zipCode: viewModel.zip,
                sim: null, // For eSIM orders, sim might not be available yet
                imei: imei,
                agentId: 'Sushil', // TODO: Get from user settings or configuration
                source: 'WEBSITE',
                externalTransactionId: activationTransactionId,
              );

              // Save phone number (MDN) to order
              if (activationResponse.data != null && activationResponse.data!.mdn != null) {
                final phoneNumber = activationResponse.data!.mdn!.toString();
                print('✅ New number activated: $phoneNumber');
                
                await orderManager.saveStepProgress(
                  userId: viewModel.userId!,
                  orderId: viewModel.orderId!,
                  step: 6,
                  data: {'mdn': phoneNumber},
                );
                print('✅ Successfully saved phone number to order');
              }
            } catch (e, stackTrace) {
              print('❌ Failed to activate new number: $e');
              print('   Stack trace: $stackTrace');
              // Continue - might already be activated or will be activated later
            }
            
            // Step 2: For eSIM orders, assign eSIM after number activation
            if (viewModel.simType == 'eSIM') {
              print('🔄 Calling assign_esim API for eSIM order...');
              try {
                // Wait a bit after number activation for eSIM processing
                await Future.delayed(const Duration(seconds: 5));
                
                final assignTransactionId = VCareAPIManager.generateRandomTransactionId();
                final assignEsimResponse = await apiManager.assignEsim(
                  enrollmentId: enrollmentId,
                  agentId: 'Sushil', // TODO: Get from user settings or configuration
                  source: 'WEBSITE',
                  externalTransactionId: assignTransactionId,
                );

                // Check if eSIM allocation was successful
                if (assignEsimResponse.statusCode == '00' && 
                    assignEsimResponse.esimAllocationSuccess == 'Y') {
                  print('✅ eSIM allocated successfully');
                  
                  // Save eSIM details to order
                  final esimData = <String, dynamic>{
                    'esim_qr_activation_code': assignEsimResponse.qrActivationCode,
                    'esim_iccid': assignEsimResponse.iccid,
                    'esim_activation_code': assignEsimResponse.activationCode,
                    'esim_smdp_address': assignEsimResponse.smdpAddress,
                    'esim_enroll_id': assignEsimResponse.enrollId,
                    'esim_allocation_success': assignEsimResponse.esimAllocationSuccess,
                  };

                  await orderManager.saveStepProgress(
                    userId: viewModel.userId!,
                    orderId: viewModel.orderId!,
                    step: 6,
                    data: esimData,
                  );
                  print('✅ Successfully saved eSIM data to order');
                  
                  // Small delay to ensure Firestore has committed the write
                  await Future.delayed(const Duration(milliseconds: 500));
                } else {
                  print('⚠️ eSIM allocation was not successful');
                  print('   Status Code: ${assignEsimResponse.statusCode}');
                  print('   Description: ${assignEsimResponse.description}');
                }
              } catch (e, stackTrace) {
                print('❌ Failed to assign eSIM: $e');
                print('   Stack trace: $stackTrace');
                // Continue - eSIM might be assigned later or already assigned
              }
            }
          }
        }
      } catch (e) {
        print('❌ Error in new number activation flow: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isCompleting = false;
          });
        }
      }
    }
    
    // Show appropriate sheet based on SIM type and device selection
    // IMPORTANT: For eSIM, never show shipping sheet
    // simType is still available in viewModel since we haven't called completeOrder() yet
    
    // Check SIM type from viewModel (it will still be available since we haven't called completeOrder yet)
    final simType = viewModel.simType.trim().toLowerCase();
    final isESim = simType == 'esim';
    
    print('[NumberPortingView] SIM type check - isESim: $isESim, viewModel.simType: "${viewModel.simType}", isForThisDevice: ${viewModel.isForThisDevice}');
    
    if (isESim) {
      // For eSIM orders, check if it's for this device or another device
      // Default to false (Another Device) if not explicitly set to true
      if (viewModel.isForThisDevice == true) {
        // Show activation sheet for "This Device"
        print('[NumberPortingView] Showing activation sheet for eSIM - This Device');
        _showActivationSheet();
      } else {
        // Show QR code sheet for "Another Device" 
        // This handles the case when coming from billing completion (card setup view)
        print('[NumberPortingView] Showing QR code sheet for eSIM - Another Device');
        _showQRCodeSheet();
      }
    } else {
      // Show shipping sheet ONLY for Physical SIM
      print('[NumberPortingView] Showing shipping sheet for Physical SIM');
      _showShippingSheet();
    }
  }

  Future<void> _handleReturnToDashboard() async {
    // Complete the order when user clicks "Return to Dashboard"
    setState(() {
      _isCompleting = true;
    });

    final viewModel = Provider.of<UserRegistrationViewModel>(context, listen: false);
    
    // Check if billing is completed and port-in status
    if (viewModel.userId != null && viewModel.orderId != null) {
      final orderManager = FirebaseOrderManager();
      final orderData = await orderManager.fetchOrderDocument(viewModel.userId!, viewModel.orderId!);
      final billingCompleted = orderData?['billingCompleted'] ?? false;
      final isPortInOrder = viewModel.numberType == 'Existing';
      final portInSkipped = viewModel.portInSkipped;
      
      if (billingCompleted && isPortInOrder) {
        if (portInSkipped) {
          // User skipped port-in, mark as pending port-in
          await orderManager.markOrderPendingPortIn(viewModel.userId!, viewModel.orderId!);
        } else {
          // Check if port-in status is completed from API
          final portInStatus = orderData?['portInStatus']?.toString().toLowerCase();
          if (portInStatus == 'completed') {
            // Port-in is completed, mark order as completed
            await orderManager.markOrderCompleted(viewModel.userId!, viewModel.orderId!);
          } else {
            // Port-in is still pending, keep status as pending_port_in
            await orderManager.markOrderPendingPortIn(viewModel.userId!, viewModel.orderId!);
          }
        }
      } else if (billingCompleted && !isPortInOrder) {
        // Not a port-in order, mark as completed
        await orderManager.markOrderCompleted(viewModel.userId!, viewModel.orderId!);
      }
    }
    
    final success = await viewModel.completeOrder();
    
    setState(() {
      _isCompleting = false;
    });

    if (success && mounted) {
      // Navigate back to home
      widget.onStepChanged(0);
    } else if (mounted) {
      // Still navigate even if there's an error, but show the error
      final errorBg = AppTheme.getComponentBackgroundColor(
        context,
        'numberPorting_warning_background',
        fallback: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to complete order'),
          backgroundColor: errorBg,
        ),
      );
      widget.onStepChanged(0);
    }
  }

  void _onFormValidityChanged(bool isValid) {
    setState(() {
      _isPortingFormValid = isValid;
    });
  }

  void _onSimSetupFormValidityChanged(bool isValid) {
    setState(() {
      _isSimSetupFormValid = isValid;
    });
  }

  void _resetQRCodeShown() {
    setState(() {
      _qrCodeAlreadyShown = false;
    });
  }

  void _showQRCodeSheet() {
    final viewModel = Provider.of<UserRegistrationViewModel>(context, listen: false);
    _qrCodeAlreadyShown = true; // Mark that QR code was shown
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.getComponentBackgroundColor(
        context,
        'startOrder_planDetails_background',
        fallback: Colors.transparent,
      ),
      builder: (context) => _QRCodeSheet(
        viewModel: viewModel,
        onReturn: () {
          Navigator.of(context).pop();
          // Complete order and navigate back to home
          _handleReturnToDashboard();
        },
      ),
    );
  }

  void _showActivationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.getComponentBackgroundColor(
        context,
        'startOrder_planDetails_background',
        fallback: Colors.transparent,
      ),
      builder: (context) => _ActivationSheet(
        onReturn: () {
          Navigator.of(context).pop();
          // Complete order and navigate back to home
          _handleReturnToDashboard();
        },
      ),
    );
  }

  void _showShippingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.getComponentBackgroundColor(
        context,
        'startOrder_planDetails_background',
        fallback: Colors.transparent,
      ),
      builder: (context) => _ShippingSheet(
        onReturn: () {
          Navigator.of(context).pop();
          // Complete order and navigate back to home
          _handleReturnToDashboard();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserRegistrationViewModel>(context);
    
    print('[NumberPortingView] build() called');
    print('[NumberPortingView] _showPortingView: $_showPortingView');
    print('[NumberPortingView] _showSimSetup: $_showSimSetup');
    print('[NumberPortingView] viewModel.simType: "${viewModel.simType}"');
    print('[NumberPortingView] viewModel.numberType: "${viewModel.numberType}"');
    
    // Determine next button text and action
    String nextButtonText = 'Complete Order';
    VoidCallback? nextButtonAction;
    bool nextButtonDisabled = _isCompleting;

    if (_showPortingView) {
      nextButtonText = 'Continue to SIM Setup';
      nextButtonAction = _handlePortingContinue;
      nextButtonDisabled = _isCompleting || !_isPortingFormValid;
      print('[NumberPortingView] Button config: PortingView mode');
    } else if (_showSimSetup) {
      nextButtonText = 'Complete Order';
      nextButtonAction = _onSimSetupComplete;
      nextButtonDisabled = _isCompleting || !_isSimSetupFormValid;
      print('[NumberPortingView] Button config: SimSetupView mode');
    } else {
      print('[NumberPortingView] Button config: Default mode (no view selected yet)');
    }

    Widget childWidget;
    if (_showPortingView && !_showSimSetup) {
      print('[NumberPortingView] Rendering: PortingView');
      childWidget = PortingView(
        key: _portingViewKey,
        onPortingComplete: _onPortingComplete,
        onPortingSkip: _onPortingSkip,
        onFormValidityChanged: _onFormValidityChanged,
      );
    } else if (_showSimSetup || viewModel.simType.isNotEmpty) {
      print('[NumberPortingView] Rendering: SimSetupView (without container)');
      childWidget = SimSetupView(
        currentStep: widget.currentStep,
        onStepChanged: widget.onStepChanged,
        wrapInContainer: false, // Don't wrap in container since NumberPortingView already has one
      );
    } else {
      print('[NumberPortingView] Rendering: LoadingIndicator (waiting for data)');
      childWidget = const Center(
        child: CircularProgressIndicator(),
      );
    }

    return StepNavigationContainer(
      currentStep: widget.currentStep,
      totalSteps: 6,
      nextButtonText: nextButtonText,
      nextButtonAction: nextButtonAction ?? () {},
      backButtonAction: _handleBack,
      cancelAction: null, // Step 6 has no cancel button
      nextButtonDisabled: nextButtonDisabled,
      isLoading: _isCompleting,
      child: childWidget,
    );
  }
}

// QR Code Sheet Widget
class _QRCodeSheet extends StatefulWidget {
  final UserRegistrationViewModel viewModel;
  final VoidCallback onReturn;

  const _QRCodeSheet({
    required this.viewModel,
    required this.onReturn,
  });

  @override
  State<_QRCodeSheet> createState() => __QRCodeSheetState();
}

class __QRCodeSheetState extends State<_QRCodeSheet> {
  String? _qrActivationCode;
  String? _iccid;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEsimData();
  }

  Future<void> _loadEsimData() async {
    if (widget.viewModel.userId == null || widget.viewModel.orderId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final orderManager = FirebaseOrderManager();
      final orderData = await orderManager.fetchOrderDocument(
        widget.viewModel.userId!,
        widget.viewModel.orderId!,
      );

      if (orderData != null && mounted) {
        setState(() {
          _qrActivationCode = orderData['esim_qr_activation_code']?.toString();
          _iccid = orderData['esim_iccid']?.toString();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Failed to load eSIM data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.appBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'eSIM QR Code',
              style: AppTheme.sectionTitleStyle,
            ),
            SizedBox(height: 16),
            Text(
              'Scan this QR code with your other device to activate the eSIM',
              textAlign: TextAlign.center,
              style: AppTheme.bodyStyle,
            ),
            SizedBox(height: 24),
            
            // QR Code Display
            if (_isLoading)
              Container(
                width: 250,
                height: 250,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_qrActivationCode != null && _qrActivationCode!.isNotEmpty)
              // Display actual QR code using qr_flutter package
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                  color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.getComponentShadowColor(
                      context,
                      'orderCard_background',
                      fallback: Colors.black.withOpacity(0.1),
                    ),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
                padding: EdgeInsets.all(16),
                child: QrImageView(
                  data: _qrActivationCode!,
                  version: QrVersions.auto,
                  size: 218.0,
                  backgroundColor: Colors.white,
                ),
              )
            else
              // Fallback to static image if QR code not available
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: AppTheme.getComponentBackgroundColor(
                    context,
                    'orderCard_background',
                    fallback: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/esim_qr_code.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Show activation code as text if available
            if (_qrActivationCode != null && _qrActivationCode!.isNotEmpty) ...[
            SizedBox(height: 16),
            Text(
                'Activation Code:',
                style: AppTheme.bodySmallStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              SelectableText(
                _qrActivationCode!,
              style: AppTheme.bodySmallStyle,
                textAlign: TextAlign.center,
              ),
            ],
            
            // Show ICCID if available
            if (_iccid != null && _iccid!.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                'ICCID: $_iccid',
                style: AppTheme.bodySmallStyle.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            SizedBox(height: 16),
            Text(
              'Order #: ${widget.viewModel.orderId ?? "N/A"}',
              style: AppTheme.bodySmallStyle,
            ),
            
            SizedBox(height: 24),
            
            // Setup Instructions
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Setup Instructions:',
                    style: AppTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildInstructionStep(context, 1, 'Open Camera app on your other device'),
                  _buildInstructionStep(context, 2, 'Point camera at this QR code'),
                  _buildInstructionStep(context, 3, 'Tap the notification to add cellular plan'),
                  _buildInstructionStep(context, 4, 'Follow the prompts to complete activation'),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            GradientButton(
              text: 'Return to Dashboard',
              onPressed: widget.onReturn,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(BuildContext context, int number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.accentGold,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: AppTheme.getComponentTextColor(
                    context,
                    'stepIndicator_text',
                    fallback: Colors.white,
                  ),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodySmallStyle,
            ),
          ),
        ],
      ),
    );
  }
}

// Activation Sheet Widget (for "This Device")
class _ActivationSheet extends StatelessWidget {
  final VoidCallback onReturn;

  const _ActivationSheet({
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.appBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 56,
            color: AppTheme.accentGold,
          ),
          SizedBox(height: 16),
          Text(
            'Activated on This Device',
            style: AppTheme.sectionTitleStyle,
          ),
          SizedBox(height: 16),
          Text(
            'Your eSIM has been successfully activated on this device.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyStyle,
          ),
          SizedBox(height: 24),
          GradientButton(
            text: 'Return to Dashboard',
            onPressed: onReturn,
          ),
        ],
      ),
    );
  }
}

// Shipping Sheet Widget (for Physical SIM)
class _ShippingSheet extends StatelessWidget {
  final VoidCallback onReturn;

  const _ShippingSheet({
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.appBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_shipping,
            size: 56,
            color: AppTheme.accentGold,
          ),
          SizedBox(height: 16),
          Text(
            'Order Complete',
            style: AppTheme.sectionTitleStyle,
          ),
          SizedBox(height: 16),
          Text(
            'Your order is complete. Your physical SIM will be shipped shortly.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyStyle,
          ),
          SizedBox(height: 24),
          GradientButton(
            text: 'Return to Dashboard',
            onPressed: onReturn,
          ),
        ],
      ),
    );
  }
}

