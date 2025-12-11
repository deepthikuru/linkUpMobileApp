import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_registration_view_model.dart';
import '../../providers/navigation_state.dart';
import '../../widgets/step_navigation_container.dart';
import '../../widgets/order_step_header.dart';
import '../../utils/theme.dart';
import '../../utils/fallback_values.dart';

class SimSetupView extends StatelessWidget {
  final int currentStep;
  final Function(int) onStepChanged;
  final bool wrapInContainer;

  const SimSetupView({
    super.key,
    required this.currentStep,
    required this.onStepChanged,
    this.wrapInContainer = true,
  });

  void _handleNext(BuildContext context) {
    onStepChanged(5);
  }

  void _handleBack(BuildContext context) {
    onStepChanged(3);
  }

  Widget _buildContent(BuildContext context, UserRegistrationViewModel viewModel) {
    print('[SimSetupView] _buildContent called');
    print('[SimSetupView] simType: "${viewModel.simType}"');
    final isPhysicalSim = viewModel.simType.isNotEmpty && 
        viewModel.simType.toLowerCase() == 'physical';
    print('[SimSetupView] isPhysicalSim: $isPhysicalSim');

    return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            OrderStepHeader(
              title: FallbackValues.titleSimSetup,
              subtitle: isPhysicalSim ? 'Physical SIM Card' : 'eSIM',
            ),
            SizedBox(height: AppTheme.spacingSection),

            // SIM Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isPhysicalSim ? Icons.sim_card : Icons.memory,
                color: AppTheme.accentGold,
                size: 60,
              ),
            ),
            SizedBox(height: AppTheme.spacingSection),

            // Status Text
            Text(
              isPhysicalSim ? FallbackValues.messageShippingInitiated : FallbackValues.messageEsimReady,
              style: AppTheme.sectionTitleStyle.copyWith(
                color: AppTheme.accentGold,
              ),
            ),
            SizedBox(height: AppTheme.spacingSection),

            if (isPhysicalSim) ...[
              // Shipping Address Section
              Container(
                padding: EdgeInsets.all(AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: AppTheme.disabledBackground,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_shipping, color: AppTheme.accentGold),
                        SizedBox(width: AppTheme.spacingSmall),
                        Expanded(
                          child: Text(
                          FallbackValues.messagePhysicalSimShipping,
                          maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          style: AppTheme.bodyStyle.copyWith(
                            fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.spacingItem),
                    Text(
                      '${viewModel.firstName} ${viewModel.lastName}',
                      style: AppTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingSmall),
                    Text(
                      viewModel.street,
                      style: AppTheme.bodyStyle,
                    ),
                    if (viewModel.aptNumber.isNotEmpty) ...[
                      SizedBox(height: AppTheme.spacingSmall),
                      Text(
                        'Apt ${viewModel.aptNumber}',
                        style: AppTheme.bodyStyle,
                      ),
                    ],
                    SizedBox(height: AppTheme.spacingSmall),
                    Text(
                      '${viewModel.city}, ${viewModel.state} ${viewModel.zip}',
                      style: AppTheme.bodyStyle,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppTheme.spacingSection),

              // Delivery Information Section
              Container(
                padding: EdgeInsets.all(AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: AppTheme.disabledBackground,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, color: AppTheme.accentGold),
                          SizedBox(width: AppTheme.spacingSmall),
                          Text(
                            FallbackValues.messageDeliveryInfo,
                            style: AppTheme.bodyStyle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.spacingItem),
                      _buildBulletPoint(FallbackValues.messageShippingDays),
                      SizedBox(height: AppTheme.spacingItem),
                      _buildBulletPoint(FallbackValues.messageTrackingEmail),
                      SizedBox(height: AppTheme.spacingItem),
                      _buildBulletPoint(FallbackValues.messageActivateSim),
                  ],
                ),
              ),
            ] else ...[
              // eSIM Device Selection Section
              Text(
                FallbackValues.messageEsimActivation,
                style: AppTheme.sectionTitleStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppTheme.spacingSmall),
              Text(
                FallbackValues.messageEsimForDevice,
                textAlign: TextAlign.center,
                style: AppTheme.bodyStyle,
              ),
              SizedBox(height: AppTheme.spacingSection),

              // Device Selection Buttons
              Column(
                children: [
                  // "This Device" button
                  _buildDeviceSelectionButton(
                    context: context,
                    title: FallbackValues.messageThisDevice,
                    icon: Icons.phone_android,
                    isSelected: viewModel.isForThisDevice == true,
                    onTap: () {
                      viewModel.isForThisDevice = true;
                      viewModel.showQRCode = false;
                      Provider.of<UserRegistrationViewModel>(context, listen: false).notifyListeners();
                    },
                  ),
                  SizedBox(height: AppTheme.spacingItem),
                  
                  // "Another Device" button
                  _buildDeviceSelectionButton(
                    context: context,
                    title: FallbackValues.messageAnotherDevice,
                    icon: Icons.qr_code_2,
                    isSelected: viewModel.isForThisDevice == false,
                    onTap: () {
                      viewModel.isForThisDevice = false;
                      viewModel.showQRCode = true;
                      Provider.of<UserRegistrationViewModel>(context, listen: false).notifyListeners();
                    },
                  ),
                ],
              ),

              // Show confirmation message if "This Device" is selected
              if (viewModel.isForThisDevice == true) ...[
                SizedBox(height: AppTheme.spacingSection),
                Container(
                  padding: EdgeInsets.all(AppTheme.spacingMedium),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.accentGold,
                        size: 24,
                      ),
                      SizedBox(width: AppTheme.spacingSmall),
                      Expanded(
                        child: Text(
                          FallbackValues.messageEsimActivatedDirectly,
                          style: AppTheme.bodySmallStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Only show eSIM Information section if "Another Device" is selected
              if (viewModel.isForThisDevice != true) ...[
                SizedBox(height: AppTheme.spacingSection),

                // eSIM Information
                Container(
                  padding: EdgeInsets.all(AppTheme.spacingMedium),
                  decoration: BoxDecoration(
                    color: AppTheme.disabledBackground,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusCard),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: AppTheme.accentGold),
                          SizedBox(width: AppTheme.spacingSmall),
                          Text(
                            FallbackValues.messageEsimInfo,
                            style: AppTheme.bodyStyle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.spacingItem),
                      _buildBulletPoint(FallbackValues.messageQrCodeEmailed),
                      SizedBox(height: AppTheme.spacingItem),
                      _buildBulletPoint(FallbackValues.messageScanQrCode),
                      SizedBox(height: AppTheme.spacingItem),
                      _buildBulletPoint(FallbackValues.messageActivationMinutes),
                      SizedBox(height: AppTheme.spacingItem),
                      _buildBulletPoint(FallbackValues.messageDeviceSupportsEsim),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserRegistrationViewModel>(context);
    print('[SimSetupView] build() called');
    print('[SimSetupView] wrapInContainer: $wrapInContainer');

    final content = _buildContent(context, viewModel);

    if (wrapInContainer) {
      // When used standalone (not inside NumberPortingView)
      return StepNavigationContainer(
        currentStep: currentStep,
        totalSteps: 6,
        nextButtonText: FallbackValues.buttonComplete,
        nextButtonAction: () => _handleNext(context),
        backButtonAction: () => _handleBack(context),
        cancelAction: () {
          final navigationState = Provider.of<NavigationState>(context, listen: false);
          navigationState.navigateTo(Destination.startNewOrder);
          navigationState.setFooterTab(FooterTab.home);
          navigationState.orderStartStep = null;
          navigationState.currentOrderId = null;
          onStepChanged(0);
        },
        child: content,
      );
    } else {
      // When used inside NumberPortingView (which already has StepNavigationContainer)
      return content;
    }
  }

  Widget _buildDeviceSelectionButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.accentGold.withOpacity(0.1) 
              : AppTheme.disabledBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.accentGold : AppTheme.borderColor,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppTheme.accentGold : AppTheme.textSecondary,
              size: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                icon,
                color: AppTheme.accentGold,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: TextStyle(
            fontSize: AppTheme.fontSizeBody,
            fontWeight: FontWeight.bold,
            color: AppTheme.appText,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: AppTheme.bodyStyle,
          ),
        ),
      ],
    );
  }
}


