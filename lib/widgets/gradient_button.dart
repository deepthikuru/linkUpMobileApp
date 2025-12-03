import 'package:flutter/material.dart';
import '../utils/theme.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    
    final gradient = isDisabled 
        ? null 
        : (AppTheme.getComponentGradient(context, 'gradientButton_gradientStart', fallback: AppTheme.blueGradient) ?? AppTheme.blueGradient);
    
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        color: isDisabled 
            ? AppTheme.getComponentBackgroundColor(context, 'gradientButton_disabledBackground', fallback: Colors.grey.shade500)
            : null,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusButton),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusButton),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.getComponentIconColor(context, 'gradientButton_loadingIndicator', fallback: Colors.white),
                      ),
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      color: AppTheme.getComponentTextColor(context, 'gradientButton_text', fallback: Colors.white),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

