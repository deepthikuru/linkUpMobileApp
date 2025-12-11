import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_registration_view_model.dart';
import '../../providers/navigation_state.dart';
import '../../services/firebase_order_manager.dart';
import '../../services/vcare_api_manager.dart';
import '../../widgets/step_navigation_container.dart';
import '../../widgets/order_step_header.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import '../../utils/theme.dart';
import '../../utils/fallback_values.dart';

class BillingInfoView extends StatefulWidget {
  final int currentStep;
  final Function(int) onStepChanged;

  const BillingInfoView({
    super.key,
    required this.currentStep,
    required this.onStepChanged,
  });

  @override
  State<BillingInfoView> createState() => _BillingInfoViewState();
}

class _BillingInfoViewState extends State<BillingInfoView> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _billingAddressController = TextEditingController();
  bool _isSaving = false;
  bool _useShippingAddress = true;
  bool _recurringChargeAgreement = false;
  bool _privacyTermsAgreement = false;
  bool _showBroadbandFacts = false;
  
  // Plan information state
  String _planName = 'Telgoo5 Mobile Plan';
  double _planPrice = 47.45;
  bool _isLoadingPlanInfo = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadPlanInfo();
  }

  void _loadData() {
    final viewModel = Provider.of<UserRegistrationViewModel>(context, listen: false);
    _cardNumberController.text = viewModel.creditCardNumber;
    _billingAddressController.text = viewModel.address;
    if (viewModel.address.isEmpty && viewModel.street.isNotEmpty) {
      _billingAddressController.text = '${viewModel.street}, ${viewModel.city}, ${viewModel.state} ${viewModel.zip}';
      _useShippingAddress = true;
    }
  }

  Future<void> _loadPlanInfo() async {
    final viewModel = Provider.of<UserRegistrationViewModel>(context, listen: false);
    if (viewModel.orderId == null || viewModel.userId == null) return;
    
    setState(() {
      _isLoadingPlanInfo = true;
    });
    
    try {
      final orderManager = FirebaseOrderManager();
      final orderData = await orderManager.fetchOrderDocument(
        viewModel.userId!,
        viewModel.orderId!,
      );
      
      if (orderData != null && mounted) {
        setState(() {
          if (orderData['planName'] != null) {
            _planName = orderData['planName'].toString();
          }
          
          // Handle planPrice - can be Int or Double
          if (orderData['planPrice'] != null) {
            if (orderData['planPrice'] is int) {
              _planPrice = (orderData['planPrice'] as int).toDouble();
            } else if (orderData['planPrice'] is double) {
              _planPrice = orderData['planPrice'] as double;
            }
          } else if (orderData['amount'] != null) {
            _planPrice = (orderData['amount'] as num).toDouble();
          }
        });
      }
    } catch (e) {
      // Continue with default values
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPlanInfo = false;
        });
      }
    }
  }

  Widget _buildPricingSection() {
    final tax = _planPrice * 0.07;
    final total = _planPrice + tax;

    return Container(
      padding: EdgeInsets.all(AppTheme.paddingCard),
      decoration: BoxDecoration(
        color: AppTheme.disabledBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildPricingRow(FallbackValues.labelPlan, _planName, isBold: false),
          _buildPricingRow(FallbackValues.labelPlanPrice, '\$${_planPrice.toStringAsFixed(2)}', isBold: false),
          _buildPricingRow(FallbackValues.labelPlanTax, '\$${tax.toStringAsFixed(2)}', isBold: false),
          Divider(),
          _buildPricingRow(FallbackValues.labelTotal, '\$${total.toStringAsFixed(2)}', isBold: true),
        ],
      ),
    );
  }

  Widget _buildPricingRow(String label, String value, {required bool isBold}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyStyle.copyWith(
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyStyle.copyWith(
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card Number
        TextFormField(
          controller: _cardNumberController,
          decoration: AppTheme.inputDecoration(FallbackValues.labelCardNumber),
          keyboardType: TextInputType.number,
          inputFormatters: [CreditCardFormatter()],
          validator: Validators.creditCard,
        ),
        SizedBox(height: AppTheme.spacingItem),
        // Expiry and CVV
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryController,
                decoration: AppTheme.inputDecoration(FallbackValues.labelExpiry),
                keyboardType: TextInputType.number,
                inputFormatters: [ExpiryDateFormatter()],
                validator: Validators.expiryDate,
              ),
            ),
            SizedBox(width: AppTheme.spacingItem),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                decoration: AppTheme.inputDecoration(FallbackValues.labelCvv),
                keyboardType: TextInputType.number,
                obscureText: true,
                validator: Validators.cvv,
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacingItem),
        CheckboxListTile(
          title: Text(FallbackValues.labelSameAsShipping, style: AppTheme.bodyStyle),
          value: _useShippingAddress,
          onChanged: (value) {
            setState(() {
              _useShippingAddress = value ?? true;
            });
          },
        ),
        if (!_useShippingAddress) ...[
          SizedBox(height: AppTheme.spacingItem),
          TextFormField(
            controller: _billingAddressController,
            decoration: AppTheme.inputDecoration(FallbackValues.labelBillingAddress),
            maxLines: 2,
            validator: (value) => Validators.required(value, fieldName: FallbackValues.labelBillingAddress),
          ),
        ],
      ],
    );
  }

  Widget _buildAgreementsSection() {
    return Container(
      padding: EdgeInsets.all(AppTheme.paddingCard),
      decoration: BoxDecoration(
        color: AppTheme.disabledBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              FallbackValues.checkboxRecurringCharge,
              style: AppTheme.captionStyle,
            ),
            value: _recurringChargeAgreement,
            onChanged: (value) {
              setState(() {
                _recurringChargeAgreement = value ?? false;
              });
            },
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              FallbackValues.checkboxPrivacyTerms,
              style: AppTheme.captionStyle,
            ),
            value: _privacyTermsAgreement,
            onChanged: (value) {
              setState(() {
                _privacyTermsAgreement = value ?? false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBroadbandFactsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              FallbackValues.sectionBroadbandFacts,
              style: AppTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _showBroadbandFacts = !_showBroadbandFacts;
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppTheme.accentGold,
                  ),
                  SizedBox(width: 4),
                  Icon(
                    _showBroadbandFacts ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: AppTheme.accentGold,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_showBroadbandFacts) ...[
          SizedBox(height: AppTheme.spacingItem),
          Container(
            padding: EdgeInsets.all(AppTheme.paddingCard),
            decoration: BoxDecoration(
              color: AppTheme.disabledBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // First row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FallbackValues.sectionMobileBroadbandDisclosure,
                            style: AppTheme.bodySmallStyle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            FallbackValues.replacePlaceholder(FallbackValues.sectionMonthlyPrice, {'price': _planPrice.toStringAsFixed(2)}),
                            style: AppTheme.captionStyle,
                          ),
                          SizedBox(height: 4),
                          Text(
                            FallbackValues.sectionNotIntroductoryRate,
                            style: AppTheme.captionStyle.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppTheme.spacingItem),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FallbackValues.sectionSpeedsProvided,
                            style: AppTheme.bodySmallStyle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            FallbackValues.sectionTypicalDownload,
                            style: AppTheme.captionStyle,
                          ),
                          SizedBox(height: 4),
                          Text(
                            FallbackValues.sectionTypicalUpload,
                            style: AppTheme.captionStyle,
                          ),
                          SizedBox(height: 4),
                          Text(
                            FallbackValues.sectionTypicalLatency,
                            style: AppTheme.captionStyle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(height: AppTheme.spacingSection),
                // Second row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FallbackValues.sectionProviderFees,
                            style: AppTheme.bodySmallStyle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            FallbackValues.sectionOneTimeFee,
                            style: AppTheme.captionStyle,
                          ),
                          SizedBox(height: 4),
                          Text(
                            FallbackValues.sectionDeviceConnectionCharge,
                            style: AppTheme.captionStyle,
                          ),
                          SizedBox(height: 4),
                          Text(
                            FallbackValues.sectionEarlyTerminationFee,
                            style: AppTheme.captionStyle,
                          ),
                          SizedBox(height: 4),
                          Text(
                            FallbackValues.sectionGovernmentTaxes,
                            style: AppTheme.captionStyle,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppTheme.spacingItem),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FallbackValues.sectionUnlimitedData,
                            style: AppTheme.bodySmallStyle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            FallbackValues.sectionFirst20GB,
                            style: AppTheme.captionStyle,
                          ),
                          SizedBox(height: 4),
                          Text(
                            FallbackValues.sectionChargesAdditionalData,
                            style: AppTheme.captionStyle,
                          ),
                          SizedBox(height: 4),
                          Text(
                            FallbackValues.sectionResidentialUse,
                            style: AppTheme.captionStyle.copyWith(
                              color: AppTheme.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_recurringChargeAgreement || !_privacyTermsAgreement) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(FallbackValues.errorPleaseAcceptAgreements)),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final viewModel = Provider.of<UserRegistrationViewModel>(context, listen: false);
    viewModel.creditCardNumber = _cardNumberController.text;
    viewModel.billingDetails = 'Expiry: ${_expiryController.text}, CVV: ***';
    viewModel.address = _useShippingAddress
        ? '${viewModel.street}, ${viewModel.city}, ${viewModel.state} ${viewModel.zip}'
        : _billingAddressController.text;

    final success = await viewModel.saveBillingInfo();
    
    // Save step progress to Firestore
    if (success && viewModel.userId != null && viewModel.orderId != null) {
      final orderManager = FirebaseOrderManager();
      await orderManager.saveStepProgress(
        userId: viewModel.userId!,
        orderId: viewModel.orderId!,
        step: 5,
      );
      
      // NEW FLOW: Step 5 - Check service availability and create customer
      await _processStep5Enrollment(viewModel.userId!, viewModel.orderId!, viewModel);
      
      // If this is a porting order, mark as pending port-in instead of completed
      final isPortingOrder = viewModel.numberType == 'Existing';
      if (isPortingOrder) {
        await orderManager.markOrderPendingPortIn(viewModel.userId!, viewModel.orderId!);
      }
    }
    
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }

    // DON'T proceed to step 6 - keep user on step 5
    // The success/error message will be shown via the API processing
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? FallbackValues.errorFailedToSaveBillingInfo),
          backgroundColor: AppTheme.getComponentBackgroundColor(
            context,
            'login_errorSnackbar_background',
            fallback: AppTheme.errorColor,
          ),
        ),
      );
    }
  }

  Future<void> _processStep5Enrollment(String userId, String orderId, UserRegistrationViewModel viewModel) async {
    try {
      // Fetch order document to get plan_id and other data
      final orderManager = FirebaseOrderManager();
      final orderData = await orderManager.fetchOrderDocument(userId, orderId);
      
      if (orderData == null) {
        print('❌ Order document not found');
        if (mounted) {
          _showErrorDialog(
            'Order Not Found',
            'Order not found. Please try again.',
          );
        }
        return;
      }

      // Get plan_id - can be Int or String
      int? planId;
      if (orderData['plan_id'] is int) {
        planId = orderData['plan_id'] as int;
      } else if (orderData['plan_id'] is String) {
        planId = int.tryParse(orderData['plan_id'] as String);
      }

      if (planId == null) {
        print('❌ Missing plan_id in order document');
        if (mounted) {
          _showErrorDialog(
            'Plan Information Missing',
            'Plan information not found. Please try again.',
          );
        }
        return;
      }

      // Get order_id from payment (if available)
      int? paymentOrderId;
      if (orderData['payment_order_id'] is int) {
        paymentOrderId = orderData['payment_order_id'] as int;
      } else if (orderData['order_id'] is int) {
        paymentOrderId = orderData['order_id'] as int;
      } else if (orderData['payment_order_id'] is String) {
        paymentOrderId = int.tryParse(orderData['payment_order_id'] as String);
      } else if (orderData['order_id'] is String) {
        paymentOrderId = int.tryParse(orderData['order_id'] as String);
      }

      // Determine if this is a port-in order
      final isPortInOrder = viewModel.numberType == 'Existing';
      
      // Determine enrollment type and SIM type
      final isEsim = viewModel.simType == 'eSIM' ? 'Y' : 'N';
      final enrollmentType = isEsim == 'Y' ? 'SHIPMENT' : 
          (isPortInOrder ? 'HANDOVER' : 'SHIPMENT');

      // Get carrier from order or use default
      final carrier = orderData['carrier'] as String? ?? 'TMBRLY';

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔄 STEP 5: ENROLLMENT PROCESSING');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📋 Order Details:');
      print('   Order ID: $orderId');
      print('   Plan ID: $planId');
      print('   Zip Code: ${viewModel.zip}');
      print('   SIM Type: ${viewModel.simType}');
      print('   Number Type: ${viewModel.numberType}');
      print('   Enrollment Type: $enrollmentType');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // STEP 1: Check service availability to get enrollment_id
      print('📋 Step 1: Checking service availability...');
      final apiManager = VCareAPIManager();
      final checkTransactionId = VCareAPIManager.generateTransactionId(orderId, 'CHECK');
      
      final availabilityData = await apiManager.checkServiceAvailability(
        zipCode: viewModel.zip,
        enrollmentType: 'NON_LIFELINE',
        isEnrollment: 'Y',
        agentId: 'Sushil',
        source: 'WEBSITE',
        externalTransactionId: checkTransactionId,
      );

      if (availabilityData.enrollmentId == null || availabilityData.enrollmentId!.isEmpty) {
        print('❌ Failed to get enrollment_id from service availability check');
        if (mounted) {
          _showErrorDialog(
            'Enrollment Failed',
            'Failed to create enrollment. Please try again.',
          );
        }
        return;
      }

      final enrollmentId = availabilityData.enrollmentId!;
      print('✅ Received enrollment_id: $enrollmentId');

      // Save enrollment_id to order
      await orderManager.saveStepProgress(
        userId: userId,
        orderId: orderId,
        step: 5,
        data: {'enrollment_id': enrollmentId},
      );

      // STEP 2: If not a port-in order, create customer using new API
      if (!isPortInOrder) {
        print('📋 Step 2: Creating customer (non-port-in order)...');
        
        // Build customer info
        final customerInfo = <String, dynamic>{
          'enrollment_type': enrollmentType,
          'is_esim': isEsim,
          'carrier': carrier,
          'email': viewModel.email,
          'first_name': viewModel.firstName,
          'last_name': viewModel.lastName,
          'service_address_one': viewModel.street,
          'service_address_two': viewModel.aptNumber,
          'service_city': viewModel.city,
          'service_state': viewModel.state,
          'service_zip': viewModel.zip,
          'billing_address_one': viewModel.street,
          'billing_address_two': viewModel.aptNumber,
          'billing_city': viewModel.city,
          'billing_state': viewModel.state,
          'billing_zip': viewModel.zip,
          'is_portin': 'N',
        };

        if (viewModel.password.isNotEmpty) {
          customerInfo['password'] = viewModel.password;
        }

        if (viewModel.phoneNumber.isNotEmpty) {
          customerInfo['alternate_phone_number'] = viewModel.phoneNumber;
        }

        final createTransactionId = VCareAPIManager.generateTransactionId(orderId, 'CREATE');
        final responseData = await apiManager.createPrepaidPostpaidCustomerV2(
          enrollmentId: enrollmentId,
          orderId: paymentOrderId,
          planId: planId,
          customerInfo: customerInfo,
          agentId: 'Sushil',
          source: 'WEBSITE',
          externalTransactionId: createTransactionId,
        );

        final response = responseData['response'] as CreateCustomerResponse;
        final rawJson = responseData['rawJson'] as Map<String, dynamic>;

        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('✅ CUSTOMER CREATED SUCCESSFULLY');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('📋 API Response Details:');
        print('   Message: ${response.msg}');
        print('   Message Code: ${response.msgCode}');
        if (response.externalTransactionId != null) {
          print('   External Transaction ID: ${response.externalTransactionId}');
        }

        // Handle response based on order type
        if (response.data != null && response.data!.isNotEmpty) {
          final firstLine = response.data!.first;
          if (firstLine.data != null) {
            final lineData = firstLine.data!;
            
            // Extract eSIM data from raw JSON if available
            Map<String, dynamic>? esimData;
            if (rawJson['data'] != null && rawJson['data'] is List && (rawJson['data'] as List).isNotEmpty) {
              final firstDataItem = (rawJson['data'] as List)[0];
              if (firstDataItem is Map && firstDataItem['data'] is Map) {
                final dataMap = firstDataItem['data'] as Map<String, dynamic>;
                if (dataMap['esim'] != null && dataMap['esim'] is Map) {
                  esimData = dataMap['esim'] as Map<String, dynamic>;
                  print('✅ eSIM data found in response');
                }
              }
            }
            
            // Save customer data to order
            final updateData = <String, dynamic>{};
            if (lineData.custId != null) {
              updateData['cust_id'] = lineData.custId;
            }
            if (lineData.customerId != null) {
              updateData['customer_id'] = lineData.customerId;
            }
            if (lineData.enrollmentId != null) {
              updateData['enrollment_id'] = lineData.enrollmentId;
            }
            if (lineData.mdn != null && lineData.mdn!.isNotEmpty) {
              updateData['mdn'] = lineData.mdn;
            }
            if (lineData.enrollmentType != null) {
              updateData['enrollment_type'] = lineData.enrollmentType;
            }

            // Save eSIM data if available
            if (esimData != null) {
              updateData['esim_qr_activation_code'] = esimData['QR_ACTIVATION_CODE']?.toString();
              updateData['esim_activation_code'] = esimData['ACTIVATION_CODE']?.toString();
              updateData['esim_iccid'] = esimData['ICCID']?.toString();
              updateData['esim_smdp_address'] = esimData['SMDPADDRESS']?.toString() ?? '';
              updateData['esim_enroll_id'] = esimData['ENROLL_ID']?.toString();
              updateData['esim_allocation_success'] = esimData['ESIM_ALLOCATION_SUCCESS']?.toString();
              updateData['esim_status_code'] = esimData['STATUSCODE']?.toString();
              updateData['esim_description'] = esimData['DESCRIPTION']?.toString();
              print('💾 Saving eSIM data to order');
            }

            await orderManager.saveStepProgress(
              userId: userId,
              orderId: orderId,
              step: 5,
              data: updateData,
            );

            // Handle response based on SIM type
            if (isEsim == 'Y') {
              // eSIM order - print eSIM data to terminal
              print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
              print('📱 eSIM ORDER - ALL RESPONSE VALUES:');
              print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
              print('Customer ID: ${lineData.custId ?? "N/A"}');
              print('Customer ID (alt): ${lineData.customerId ?? "N/A"}');
              print('Enrollment ID: ${lineData.enrollmentId ?? "N/A"}');
              print('Enrollment Type: ${lineData.enrollmentType ?? "N/A"}');
              if (esimData != null) {
                print('QR Activation Code: ${esimData['QR_ACTIVATION_CODE'] ?? "N/A"}');
                print('Activation Code: ${esimData['ACTIVATION_CODE'] ?? "N/A"}');
                print('ICCID: ${esimData['ICCID'] ?? "N/A"}');
                print('SMDP Address: ${esimData['SMDPADDRESS'] ?? "N/A"}');
                print('Enroll ID: ${esimData['ENROLL_ID'] ?? "N/A"}');
                print('eSIM Allocation Success: ${esimData['ESIM_ALLOCATION_SUCCESS'] ?? "N/A"}');
                print('Status Code: ${esimData['STATUSCODE'] ?? "N/A"}');
                print('Description: ${esimData['DESCRIPTION'] ?? "N/A"}');
              }
              print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            } else {
              // Physical SIM order - print all values to terminal
              print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
              print('📦 PHYSICAL SIM ORDER - ALL RESPONSE VALUES:');
              print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
              print('Customer ID: ${lineData.custId ?? "N/A"}');
              print('Customer ID (alt): ${lineData.customerId ?? "N/A"}');
              print('Enrollment ID: ${lineData.enrollmentId ?? "N/A"}');
              print('Enrollment Type: ${lineData.enrollmentType ?? "N/A"}');
              print('MDN (Phone Number): ${lineData.mdn ?? "N/A"}');
              print('MSID: ${lineData.msid ?? "N/A"}');
              print('MSL: ${lineData.msl ?? "N/A"}');
              print('Invoice Number: ${lineData.invoiceNumber ?? "N/A"}');
              print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            }
            
            // On success, proceed to step 6
            if (mounted) {
              widget.onStepChanged(6);
            }
          }
        }
      } else {
        // Port-in order - create customer with port-in information
        print('📋 Step 2: Creating customer (port-in order)...');
        print('   Enrollment Type: $enrollmentType');
        
        // Split port-in account holder name into first and last name
        final portName = viewModel.portInAccountHolderName;
        final portNameParts = portName.trim().split(' ');
        final portFirstName = portNameParts.isNotEmpty ? portNameParts[0] : '';
        final portLastName = portNameParts.length > 1 
            ? portNameParts.sublist(1).join(' ') 
            : '';

        print('   Port-In Name Split:');
        print('     Full Name: $portName');
        print('     First Name: $portFirstName');
        print('     Last Name: $portLastName');
        print('   Port Number: ${viewModel.selectedPhoneNumber}');
        print('   Port Carrier: ${viewModel.portInCurrentCarrier}');
        print('   Port Account Number: ${viewModel.portInAccountNumber}');
        print('   Port PIN: ${viewModel.portInPin}');

        // Clean phone number (remove non-digits)
        final cleanPhoneNumber = viewModel.selectedPhoneNumber.replaceAll(RegExp(r'[^\d]'), '');

        // Build customer info with port-in information
        final customerInfo = <String, dynamic>{
          'enrollment_type': enrollmentType,
          'is_esim': isEsim,
          'carrier': carrier,
          'email': viewModel.email,
          'first_name': viewModel.firstName,
          'last_name': viewModel.lastName,
          'service_address_one': viewModel.street,
          'service_address_two': viewModel.aptNumber,
          'service_city': viewModel.city,
          'service_state': viewModel.state,
          'service_zip': viewModel.zip,
          'billing_address_one': viewModel.street,
          'billing_address_two': viewModel.aptNumber,
          'billing_city': viewModel.city,
          'billing_state': viewModel.state,
          'billing_zip': viewModel.zip,
          'is_portin': 'Y',
          'port_current_carrier': viewModel.portInCurrentCarrier,
          'port_first_name': portFirstName,
          'port_last_name': portLastName,
          'port_account_number': viewModel.portInAccountNumber,
          'port_account_password': viewModel.portInPin,
          'port_number': cleanPhoneNumber,
          // Port address - use service address (same as billing)
          'port_address_one': viewModel.street,
          'port_address_two': viewModel.aptNumber,
          'port_city': viewModel.city,
          'port_state': viewModel.state,
          'port_zip_code': viewModel.zip,
        };

        if (viewModel.password.isNotEmpty) {
          customerInfo['password'] = viewModel.password;
        }

        if (viewModel.phoneNumber.isNotEmpty) {
          customerInfo['alternate_phone_number'] = viewModel.phoneNumber;
        }

        final createTransactionId = VCareAPIManager.generateTransactionId(orderId, 'CREATE');
        final responseData = await apiManager.createPrepaidPostpaidCustomerV2(
          enrollmentId: enrollmentId,
          orderId: paymentOrderId,
          planId: planId,
          customerInfo: customerInfo,
          agentId: 'Sushil',
          source: 'WEBSITE',
          externalTransactionId: createTransactionId,
        );

        final response = responseData['response'] as CreateCustomerResponse;
        final rawJson = responseData['rawJson'] as Map<String, dynamic>;

        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('✅ CUSTOMER CREATED SUCCESSFULLY (PORT-IN)');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('📋 API Response Details:');
        print('   Message: ${response.msg}');
        print('   Message Code: ${response.msgCode}');
        if (response.externalTransactionId != null) {
          print('   External Transaction ID: ${response.externalTransactionId}');
        }

        // Handle response based on order type
        if (response.data != null && response.data!.isNotEmpty) {
          final firstLine = response.data!.first;
          if (firstLine.data != null) {
            final lineData = firstLine.data!;
            
            // Extract eSIM data from raw JSON if available
            Map<String, dynamic>? esimData;
            if (rawJson['data'] != null && rawJson['data'] is List && (rawJson['data'] as List).isNotEmpty) {
              final firstDataItem = (rawJson['data'] as List)[0];
              if (firstDataItem is Map && firstDataItem['data'] is Map) {
                final dataMap = firstDataItem['data'] as Map<String, dynamic>;
                if (dataMap['esim'] != null && dataMap['esim'] is Map) {
                  esimData = dataMap['esim'] as Map<String, dynamic>;
                  print('✅ eSIM data found in response');
                }
              }
            }
            
            // Save customer data to order
            final updateData = <String, dynamic>{};
            if (lineData.custId != null) {
              updateData['cust_id'] = lineData.custId;
            }
            if (lineData.customerId != null) {
              updateData['customer_id'] = lineData.customerId;
            }
            if (lineData.enrollmentId != null) {
              updateData['enrollment_id'] = lineData.enrollmentId;
            }
            if (lineData.mdn != null && lineData.mdn!.isNotEmpty) {
              updateData['mdn'] = lineData.mdn;
            }
            if (lineData.enrollmentType != null) {
              updateData['enrollment_type'] = lineData.enrollmentType;
            }

            // Save eSIM data if available
            if (esimData != null) {
              updateData['esim_qr_activation_code'] = esimData['QR_ACTIVATION_CODE']?.toString();
              updateData['esim_activation_code'] = esimData['ACTIVATION_CODE']?.toString();
              updateData['esim_iccid'] = esimData['ICCID']?.toString();
              updateData['esim_smdp_address'] = esimData['SMDPADDRESS']?.toString() ?? '';
              updateData['esim_enroll_id'] = esimData['ENROLL_ID']?.toString();
              updateData['esim_allocation_success'] = esimData['ESIM_ALLOCATION_SUCCESS']?.toString();
              updateData['esim_status_code'] = esimData['STATUSCODE']?.toString();
              updateData['esim_description'] = esimData['DESCRIPTION']?.toString();
              print('💾 Saving eSIM data to order');
            }

            await orderManager.saveStepProgress(
              userId: userId,
              orderId: orderId,
              step: 5,
              data: updateData,
            );

            // Handle response based on SIM type
            if (isEsim == 'Y') {
              // eSIM order - print eSIM data to terminal
              print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
              print('📱 PORT-IN eSIM ORDER - ALL RESPONSE VALUES:');
              print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
              print('Customer ID: ${lineData.custId ?? "N/A"}');
              print('Customer ID (alt): ${lineData.customerId ?? "N/A"}');
              print('Enrollment ID: ${lineData.enrollmentId ?? "N/A"}');
              print('Enrollment Type: ${lineData.enrollmentType ?? "N/A"}');
              if (esimData != null) {
                print('QR Activation Code: ${esimData['QR_ACTIVATION_CODE'] ?? "N/A"}');
                print('Activation Code: ${esimData['ACTIVATION_CODE'] ?? "N/A"}');
                print('ICCID: ${esimData['ICCID'] ?? "N/A"}');
                print('SMDP Address: ${esimData['SMDPADDRESS'] ?? "N/A"}');
                print('Enroll ID: ${esimData['ENROLL_ID'] ?? "N/A"}');
                print('eSIM Allocation Success: ${esimData['ESIM_ALLOCATION_SUCCESS'] ?? "N/A"}');
                print('Status Code: ${esimData['STATUSCODE'] ?? "N/A"}');
                print('Description: ${esimData['DESCRIPTION'] ?? "N/A"}');
              }
              print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            } else {
              // Physical SIM order - print all values to terminal
              print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
              print('📞 PORT-IN ORDER - ALL RESPONSE VALUES:');
              print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
              print('Customer ID: ${lineData.custId ?? "N/A"}');
              print('Customer ID (alt): ${lineData.customerId ?? "N/A"}');
              print('Enrollment ID: ${lineData.enrollmentId ?? "N/A"}');
              print('Enrollment Type: ${lineData.enrollmentType ?? "N/A"}');
              print('MDN (Phone Number): ${lineData.mdn ?? "N/A"}');
              print('MSID: ${lineData.msid ?? "N/A"}');
              print('MSL: ${lineData.msl ?? "N/A"}');
              print('Invoice Number: ${lineData.invoiceNumber ?? "N/A"}');
              print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            }
            
            // On success, proceed to step 6
            if (mounted) {
              widget.onStepChanged(6);
            }
          }
        }
      }

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('✅ STEP 5 COMPLETED SUCCESSFULLY');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
    } catch (e, stackTrace) {
      print('❌ Failed to process step 5 enrollment: $e');
      print('   Stack trace: $stackTrace');
      if (mounted) {
        _showErrorDialog('Failed to process enrollment', e.toString());
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _handleBack() {
    widget.onStepChanged(4);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _billingAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserRegistrationViewModel>(context);

    return StepNavigationContainer(
      currentStep: widget.currentStep,
      totalSteps: 6,
      nextButtonText: FallbackValues.buttonComplete,
      nextButtonAction: _handleNext,
      backButtonAction: _handleBack,
      cancelAction: () {
        // Handle cancel - navigate back to home
        final navigationState = Provider.of<NavigationState>(context, listen: false);
        navigationState.navigateTo(Destination.startNewOrder);
        navigationState.setFooterTab(FooterTab.home);
        navigationState.orderStartStep = null;
        navigationState.currentOrderId = null;
        widget.onStepChanged(0);
      },
      nextButtonDisabled: false,
      isLoading: _isSaving,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              OrderStepHeader(
                title: FallbackValues.titleBillingInfo,
              ),
              SizedBox(height: AppTheme.spacingSection),
              
              // Pricing Section 
              _buildPricingSection(),
              SizedBox(height: AppTheme.spacingSection),
              
              // Payment Section
              _buildPaymentSection(),
              SizedBox(height: AppTheme.spacingSection),
              
              // Agreements Section
              _buildAgreementsSection(),
              SizedBox(height: AppTheme.spacingSection),
              
              // Broadband Facts Section
              _buildBroadbandFactsSection(),
            ],
          ),
        ),
      ),
    );
  }
}

