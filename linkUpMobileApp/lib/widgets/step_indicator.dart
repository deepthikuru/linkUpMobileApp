import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = AppConstants.totalOrderSteps,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = AppTheme.getComponentGradient(context, 'stepIndicator_gradientStart', fallback: AppTheme.blueGradient) ?? AppTheme.blueGradient;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Step $currentStep of $totalSteps',
        style: TextStyle(
          color: AppTheme.getComponentTextColor(context, 'stepIndicator_text', fallback: Colors.white),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

