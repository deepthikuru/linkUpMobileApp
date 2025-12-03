import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_colors_service.dart';
import '../models/app_colors.dart';
import '../services/component_colors_service.dart';

class AppTheme {
  // Static fallback colors (for when service isn't available or for backward compatibility)
  static const Color _defaultYellowAccent = Color(0xFFFDC710);
  static const Color _defaultRedAccent = Color(0xFFFF0000);
  static const Color _defaultMainBlue = Color(0xFF014D7D);
  static const Color _defaultSecondBlue = Color(0xFF0C80C3);
  static const Color _defaultAppBackground = Color(0xFFFFFFFF);
  static const Color _defaultAppText = Color(0xFF000000);
  static const Color _defaultSuccessColor = Color(0xFF4CAF50);
  static const Color _defaultSuccessBackground = Color(0xFFE8F5E9);
  static const Color _defaultErrorColor = Color(0xFFF44336);
  static const Color _defaultErrorBackground = Color(0xFFFFEBEE);
  static const Color _defaultWarningColor = _defaultYellowAccent;
  static const Color _defaultBorderColor = Color(0xFFE0E0E0);
  static const Color _defaultBorderColorSelected = _defaultSecondBlue;
  static const Color _defaultTextSecondary = Color(0xFF757575);
  static const Color _defaultTextTertiary = Color(0xFF9E9E9E);
  static const Color _defaultDisabledBackground = Color(0xFFF5F5F5);
  static const Color _defaultDividerColor = Color(0xFFE0E0E0);
  static const Color _defaultHeaderBackground = Color(0xFF014D7D);
  static const Color _defaultHeaderText = Color(0xFFFFFFFF);
  static const Color _defaultHeaderIcon = Color(0xFFFFFFFF);

  // Backward compatibility: Static const colors (using defaults)
  static const Color yellowAccent = _defaultYellowAccent;
  static const Color redAccent = _defaultRedAccent;
  static const Color mainBlue = _defaultMainBlue;
  static const Color secondBlue = _defaultSecondBlue;
  static const Color appBackground = _defaultAppBackground;
  static const Color appText = _defaultAppText;
  static const Color successColor = _defaultSuccessColor;
  static const Color successBackground = _defaultSuccessBackground;
  static const Color errorColor = _defaultErrorColor;
  static const Color errorBackground = _defaultErrorBackground;
  static const Color warningColor = _defaultWarningColor;
  static const Color borderColor = _defaultBorderColor;
  static const Color borderColorSelected = _defaultBorderColorSelected;
  static const Color textSecondary = _defaultTextSecondary;
  static const Color textTertiary = _defaultTextTertiary;
  static const Color disabledBackground = _defaultDisabledBackground;
  static const Color dividerColor = _defaultDividerColor;
  
  // Legacy names mapped to new colors for backward compatibility
  static const Color accentGold = yellowAccent;
  static const Color appPrimary = mainBlue;
  static const Color appSecondary = secondBlue;

  /// Helper to get color from service or fallback to default
  static Color _getColor(BuildContext? context, Color Function(AppColorsModel) getter, Color fallback) {
    if (context != null) {
      try {
        final service = Provider.of<AppColorsService>(context, listen: false);
        return getter(service.colors);
      } catch (e) {
        // Provider not available, try singleton
      }
    }
    // Try to get from service singleton directly
    try {
      final service = AppColorsService();
      return getter(service.colors);
    } catch (e) {
      return fallback;
    }
  }

  // Dynamic Color Getters (with BuildContext - uses Contentful colors)
  static Color yellowAccentDynamic(BuildContext? context) => 
    _getColor(context, (c) => c.yellowAccent, _defaultYellowAccent);
  
  static Color redAccentDynamic(BuildContext? context) => 
    _getColor(context, (c) => c.redAccent, _defaultRedAccent);
  
  static Color mainBlueDynamic(BuildContext? context) => 
    _getColor(context, (c) => c.mainBlue, _defaultMainBlue);
  
  static Color secondBlueDynamic(BuildContext? context) => 
    _getColor(context, (c) => c.secondBlue, _defaultSecondBlue);
  
  static Color appBackgroundDynamic(BuildContext? context) => 
    _getColor(context, (c) => c.appBackground, _defaultAppBackground);
  
  static Color appTextDynamic(BuildContext? context) => 
    _getColor(context, (c) => c.appText, _defaultAppText);
  
  static Color successColorDynamic(BuildContext? context) => 
    _getColor(context, (c) => c.successColor, _defaultSuccessColor);
  
  static Color successBackgroundDynamic(BuildContext? context) => 
    _getColor(context, (c) => c.successBackground, _defaultSuccessBackground);
  
  static Color errorColorDynamic(BuildContext? context) => 
    _getColor(context, (c) => c.errorColor, _defaultErrorColor);
  
  static Color errorBackgroundDynamic(BuildContext? context) => 
    _getColor(context, (c) => c.errorBackground, _defaultErrorBackground);
  
  static Color warningColorDynamic(BuildContext? context) => 
    _getColor(context, (c) => c.warningColor, _defaultWarningColor);
  
  static Color borderColorDynamic(BuildContext? context) => 
    _getColor(context, (c) => c.borderColor, _defaultBorderColor);
  
  static Color borderColorSelectedDynamic(BuildContext? context) => 
    _getColor(context, (c) => c.borderColorSelected, _defaultBorderColorSelected);
  
  static Color textSecondaryDynamic(BuildContext? context) => 
    _getColor(context, (c) => c.textSecondary, _defaultTextSecondary);
  
  static Color textTertiaryDynamic(BuildContext? context) => 
    _getColor(context, (c) => c.textTertiary, _defaultTextTertiary);
  
  static Color disabledBackgroundDynamic(BuildContext? context) => 
    _getColor(context, (c) => c.disabledBackground, _defaultDisabledBackground);
  
  static Color dividerColorDynamic(BuildContext? context) => 
    _getColor(context, (c) => c.dividerColor, _defaultDividerColor);
  
  static Color headerBackgroundDynamic(BuildContext? context) => 
    _getColor(context, (c) => c.headerBackground, _defaultHeaderBackground);
  
  static Color headerTextDynamic(BuildContext? context) => 
    _getColor(context, (c) => c.headerText, _defaultHeaderText);
  
  static Color headerIconDynamic(BuildContext? context) => 
    _getColor(context, (c) => c.headerIcon, _defaultHeaderIcon);

  // Gradient builders (can use dynamic or static)
  static LinearGradient get goldGradient => const LinearGradient(
        colors: [mainBlue, secondBlue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient goldGradientDynamic(BuildContext? context) => LinearGradient(
        colors: [mainBlueDynamic(context), secondBlueDynamic(context)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get blueGradient => const LinearGradient(
        colors: [mainBlue, secondBlue],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  static LinearGradient blueGradientDynamic(BuildContext? context) => LinearGradient(
        colors: [mainBlueDynamic(context), secondBlueDynamic(context)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  // Font Sizes
  static const double fontSizeTitle = 22.0;
  static const double fontSizeSubtitle = 14.0;
  static const double fontSizeBody = 16.0;
  static const double fontSizeBodySmall = 14.0;
  static const double fontSizeCaption = 12.0;
  static const double fontSizeButton = 16.0;
  static const double fontSizeOptionTitle = 18.0;
  static const double fontSizeSectionTitle = 22.0;

  // Font Weights
  static const FontWeight fontWeightTitle = FontWeight.bold;
  static const FontWeight fontWeightSubtitle = FontWeight.normal;
  static const FontWeight fontWeightBody = FontWeight.normal;
  static const FontWeight fontWeightButton = FontWeight.w600;
  static const FontWeight fontWeightOptionTitle = FontWeight.bold;
  static const FontWeight fontWeightSectionTitle = FontWeight.bold;

  // Spacing
  static const double spacingTitleSubtitle = 8.0;
  static const double spacingSection = 12.0;
  static const double spacingItem = 12.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 32.0;

  // Border Radius
  static const double borderRadiusButton = 10.0;
  static const double borderRadiusCard = 12.0;
  static const double borderRadiusInput = 8.0;
  static const double borderRadiusOption = 25.0;

  // Border Widths
  static const double borderWidthDefault = 1.0;
  static const double borderWidthSelected = 2.0;

  // Icon Sizes
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeOption = 40.0;

  // Padding
  static const double paddingInput = 16.0;
  static const double paddingCard = 16.0;
  static const double paddingOption = 16.0;
  static const double paddingButtonVertical = 12.0;
  static const double paddingButtonHorizontal = 24.0;

  // Button Styles
  static ButtonStyle get gradientButtonStyle => ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusButton),
          ),
        ),
      );

  static ButtonStyle gradientButtonStyleDynamic(BuildContext? context) => ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusButton),
          ),
        ),
      );

  // Input Decoration Helper
  static InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusInput),
        borderSide: const BorderSide(color: borderColor, width: borderWidthDefault),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusInput),
        borderSide: const BorderSide(color: borderColor, width: borderWidthDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusInput),
        borderSide: const BorderSide(color: secondBlue, width: borderWidthSelected),
      ),
      contentPadding: const EdgeInsets.all(paddingInput),
      filled: true,
      fillColor: appBackground,
    );
  }

  static InputDecoration inputDecorationDynamic(BuildContext? context, String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusInput),
        borderSide: BorderSide(color: borderColorDynamic(context), width: borderWidthDefault),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusInput),
        borderSide: BorderSide(color: borderColorDynamic(context), width: borderWidthDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusInput),
        borderSide: BorderSide(color: borderColorSelectedDynamic(context), width: borderWidthSelected),
      ),
      contentPadding: const EdgeInsets.all(paddingInput),
      filled: true,
      fillColor: appBackgroundDynamic(context),
    );
  }

  // Text Styles
  static TextStyle get titleStyle => const TextStyle(
        fontSize: fontSizeTitle,
        fontWeight: fontWeightTitle,
        color: appText,
      );

  static TextStyle titleStyleDynamic(BuildContext? context) => TextStyle(
        fontSize: fontSizeTitle,
        fontWeight: fontWeightTitle,
        color: appTextDynamic(context),
      );

  static TextStyle get subtitleStyle => const TextStyle(
        fontSize: fontSizeSubtitle,
        fontWeight: fontWeightSubtitle,
        color: textSecondary,
      );

  static TextStyle subtitleStyleDynamic(BuildContext? context) => TextStyle(
        fontSize: fontSizeSubtitle,
        fontWeight: fontWeightSubtitle,
        color: textSecondaryDynamic(context),
      );

  static TextStyle get bodyStyle => const TextStyle(
        fontSize: fontSizeBody,
        fontWeight: fontWeightBody,
        color: appText,
      );

  static TextStyle bodyStyleDynamic(BuildContext? context) => TextStyle(
        fontSize: fontSizeBody,
        fontWeight: fontWeightBody,
        color: appTextDynamic(context),
      );

  static TextStyle get bodySmallStyle => const TextStyle(
        fontSize: fontSizeBodySmall,
        fontWeight: fontWeightBody,
        color: textSecondary,
      );

  static TextStyle bodySmallStyleDynamic(BuildContext? context) => TextStyle(
        fontSize: fontSizeBodySmall,
        fontWeight: fontWeightBody,
        color: textSecondaryDynamic(context),
      );

  static TextStyle get captionStyle => const TextStyle(
        fontSize: fontSizeCaption,
        fontWeight: fontWeightBody,
        color: textTertiary,
      );

  static TextStyle captionStyleDynamic(BuildContext? context) => TextStyle(
        fontSize: fontSizeCaption,
        fontWeight: fontWeightBody,
        color: textTertiaryDynamic(context),
      );

  static TextStyle get buttonStyle => const TextStyle(
        fontSize: fontSizeButton,
        fontWeight: fontWeightButton,
        color: Colors.white,
      );

  static TextStyle get optionTitleStyle => const TextStyle(
        fontSize: fontSizeOptionTitle,
        fontWeight: fontWeightOptionTitle,
        color: appText,
      );

  static TextStyle optionTitleStyleDynamic(BuildContext? context) => TextStyle(
        fontSize: fontSizeOptionTitle,
        fontWeight: fontWeightOptionTitle,
        color: appTextDynamic(context),
      );

  static TextStyle get optionTitleSelectedStyle => const TextStyle(
        fontSize: fontSizeOptionTitle,
        fontWeight: fontWeightOptionTitle,
        color: Colors.white,
      );

  static TextStyle get optionDescriptionStyle => const TextStyle(
        fontSize: fontSizeBodySmall,
        fontWeight: fontWeightBody,
        color: textSecondary,
      );

  static TextStyle optionDescriptionStyleDynamic(BuildContext? context) => TextStyle(
        fontSize: fontSizeBodySmall,
        fontWeight: fontWeightBody,
        color: textSecondaryDynamic(context),
      );

  static TextStyle get optionDescriptionSelectedStyle => const TextStyle(
        fontSize: fontSizeBodySmall,
        fontWeight: fontWeightBody,
        color: Colors.white70,
      );

  static TextStyle get sectionTitleStyle => const TextStyle(
        fontSize: fontSizeSectionTitle,
        fontWeight: fontWeightSectionTitle,
        color: appText,
      );

  static TextStyle sectionTitleStyleDynamic(BuildContext? context) => TextStyle(
        fontSize: fontSizeSectionTitle,
        fontWeight: fontWeightSectionTitle,
        color: appTextDynamic(context),
      );

  // Component Color Helpers
  /// Get component color by component ID and color type
  /// Falls back to provided fallback color or default if not found
  static Color getComponentColor(
    BuildContext? context,
    String componentId,
    String colorType, {
    Color? fallback,
  }) {
    if (context != null) {
      try {
        final service = Provider.of<ComponentColorsService>(context, listen: false);
        final color = service.getComponentColor(componentId, colorType);
        if (color != null) return color;
      } catch (e) {
        // Provider not available, try singleton
      }
    }
    
    // Try to get from service singleton directly
    try {
      final service = ComponentColorsService();
      final color = service.getComponentColor(componentId, colorType);
      if (color != null) return color;
    } catch (e) {
      // Service not available
    }
    
    // Return fallback or black as last resort
    return fallback ?? Colors.black;
  }

  /// Get component background color
  static Color getComponentBackgroundColor(
    BuildContext? context,
    String componentId, {
    Color? fallback,
  }) {
    return getComponentColor(context, componentId, 'background', fallback: fallback);
  }

  /// Get component text color
  static Color getComponentTextColor(
    BuildContext? context,
    String componentId, {
    Color? fallback,
  }) {
    return getComponentColor(context, componentId, 'text', fallback: fallback);
  }

  /// Get component border color
  static Color getComponentBorderColor(
    BuildContext? context,
    String componentId, {
    Color? fallback,
  }) {
    return getComponentColor(context, componentId, 'border', fallback: fallback);
  }

  /// Get component icon color
  static Color getComponentIconColor(
    BuildContext? context,
    String componentId, {
    Color? fallback,
  }) {
    return getComponentColor(context, componentId, 'icon', fallback: fallback);
  }

  /// Get component shadow color
  static Color getComponentShadowColor(
    BuildContext? context,
    String componentId, {
    Color? fallback,
  }) {
    return getComponentColor(context, componentId, 'shadow', fallback: fallback);
  }

  /// Get component gradient colors
  static LinearGradient? getComponentGradient(
    BuildContext? context,
    String componentId, {
    AlignmentGeometry begin = Alignment.centerLeft,
    AlignmentGeometry end = Alignment.centerRight,
    LinearGradient? fallback,
  }) {
    try {
      Color? startColor;
      Color? endColor;
      
      if (context != null) {
        final service = Provider.of<ComponentColorsService>(context, listen: false);
        startColor = service.getComponentColor(componentId, 'gradientStart');
        endColor = service.getComponentColor(componentId, 'gradientEnd');
      } else {
        final service = ComponentColorsService();
        startColor = service.getComponentColor(componentId, 'gradientStart');
        endColor = service.getComponentColor(componentId, 'gradientEnd');
      }
      
      if (startColor != null && endColor != null) {
        return LinearGradient(
          colors: [startColor, endColor],
          begin: begin,
          end: end,
        );
      }
    } catch (e) {
      // Service not available
    }
    
    return fallback;
  }
}
