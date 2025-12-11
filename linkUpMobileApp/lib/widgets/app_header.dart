import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../utils/fallback_values.dart';

class AppHeader extends StatelessWidget {
  final double? logoHeight;
  final String? zipCode;
  final VoidCallback? onZipCodeTap;
  final VoidCallback? onMenuTap;
  final bool showGradient;
  final VoidCallback? onBackTap;
  final String? title;

  const AppHeader({
    super.key,
    this.logoHeight = 60,
    this.zipCode,
    this.onZipCodeTap,
    this.onMenuTap,
    this.showGradient = false,
    this.onBackTap,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = showGradient
        ? (AppTheme.getComponentGradient(context, 'appHeader_gradientStart', fallback: AppTheme.blueGradient) ?? AppTheme.blueGradient)
        : null;
    
    return Container(
      decoration: gradient != null
          ? BoxDecoration(
              gradient: gradient,
            )
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      child: SafeArea(
        bottom: false,
        minimum: const EdgeInsets.only(top: 4),
          child: Container(
          height: AppConstants.headerHeight,
          child: Row(
            children: [
              // Left side: Back button or Logo (fixed width)
              SizedBox(
                width: 70,
                child: onBackTap != null
                    ? IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: showGradient
                              ? AppTheme.getComponentIconColor(context, 'appHeader_backIcon_gradient', fallback: Color(int.parse(FallbackValues.headerText.replaceFirst('#', '0xFF'))))
                              : AppTheme.getComponentIconColor(context, 'appHeader_backIcon', fallback: Color(int.parse(FallbackValues.appText.replaceFirst('#', '0xFF')))),
                        ),
                        onPressed: onBackTap,
                        iconSize: 24,
                        padding: EdgeInsets.zero,
                      )
                    : Image.asset(
                        'assets/images/LinkUpLogo2.png',
                        height: 115,
                        width: 189,
                      ),
              ),
              
              // Center: Title or Zip code (centered)
              Expanded(
                child: Center(
                  child: title != null
                      ? Text(
                          title!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: showGradient
                                ? AppTheme.getComponentTextColor(context, 'appHeader_titleText_gradient', fallback: Color(int.parse(FallbackValues.headerText.replaceFirst('#', '0xFF'))))
                                : AppTheme.getComponentTextColor(context, 'appHeader_titleText', fallback: Color(int.parse(FallbackValues.appText.replaceFirst('#', '0xFF')))),
                          ),
                        )
                      : zipCode != null && zipCode!.isNotEmpty
                          ? InkWell(
                              onTap: onZipCodeTap,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    zipCode!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: showGradient
                                          ? AppTheme.getComponentTextColor(context, 'appHeader_zipCodeText_gradient', fallback: Color(int.parse(FallbackValues.headerText.replaceFirst('#', '0xFF'))))
                                          : AppTheme.getComponentTextColor(context, 'appHeader_zipCodeText', fallback: Color(int.parse(FallbackValues.appText.replaceFirst('#', '0xFF')))),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 20,
                                    color: showGradient
                                        ? AppTheme.getComponentIconColor(context, 'appHeader_zipIcon_gradient', fallback: Color(int.parse(FallbackValues.headerText.replaceFirst('#', '0xFF'))))
                                        : AppTheme.getComponentIconColor(context, 'appHeader_zipIcon', fallback: Color(int.parse(FallbackValues.textSecondary.replaceFirst('#', '0xFF')))),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                ),
              ),
              
              // Right side: Empty space (hamburger menu removed)
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}

