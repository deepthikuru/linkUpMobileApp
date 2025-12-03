import 'package:flutter/material.dart';
import '../services/contentful_service.dart' show ContentfulService, ContentfulEntry;

/// Model for App Colors from Contentful
class AppColorsModel {
  final Color yellowAccent;
  final Color redAccent;
  final Color mainBlue;
  final Color secondBlue;
  final Color appBackground;
  final Color appText;
  final Color successColor;
  final Color successBackground;
  final Color errorColor;
  final Color errorBackground;
  final Color warningColor;
  final Color borderColor;
  final Color borderColorSelected;
  final Color textSecondary;
  final Color textTertiary;
  final Color disabledBackground;
  final Color dividerColor;
  final Color headerBackground;
  final Color headerText;
  final Color headerIcon;

  AppColorsModel({
    required this.yellowAccent,
    required this.redAccent,
    required this.mainBlue,
    required this.secondBlue,
    required this.appBackground,
    required this.appText,
    required this.successColor,
    required this.successBackground,
    required this.errorColor,
    required this.errorBackground,
    required this.warningColor,
    required this.borderColor,
    required this.borderColorSelected,
    required this.textSecondary,
    required this.textTertiary,
    required this.disabledBackground,
    required this.dividerColor,
    required this.headerBackground,
    required this.headerText,
    required this.headerIcon,
  });

  /// Create from Contentful entry
  factory AppColorsModel.fromContentfulEntry(ContentfulEntry entry) {
    final service = ContentfulService();
    
    // Helper to parse hex color string
    Color parseColor(String? hex) {
      if (hex == null || hex.isEmpty) return Colors.black;
      hex = hex.replaceAll('#', '').trim();
      if (hex.length == 6) {
        hex = 'FF$hex'; // Add alpha if missing
      }
      try {
        return Color(int.parse(hex, radix: 16));
      } catch (e) {
        print('❌ Error parsing color $hex: $e');
        return Colors.black;
      }
    }

    return AppColorsModel(
      yellowAccent: parseColor(service.getTextField(entry, 'yellowAccent')),
      redAccent: parseColor(service.getTextField(entry, 'redAccent')),
      mainBlue: parseColor(service.getTextField(entry, 'mainBlue')),
      secondBlue: parseColor(service.getTextField(entry, 'secondBlue')),
      appBackground: parseColor(service.getTextField(entry, 'appBackground')),
      appText: parseColor(service.getTextField(entry, 'appText')),
      successColor: parseColor(service.getTextField(entry, 'successColor')),
      successBackground: parseColor(service.getTextField(entry, 'successBackground')),
      errorColor: parseColor(service.getTextField(entry, 'errorColor')),
      errorBackground: parseColor(service.getTextField(entry, 'errorBackground')),
      warningColor: parseColor(service.getTextField(entry, 'warningColor')),
      borderColor: parseColor(service.getTextField(entry, 'borderColor')),
      borderColorSelected: parseColor(service.getTextField(entry, 'borderColorSelected')),
      textSecondary: parseColor(service.getTextField(entry, 'textSecondary')),
      textTertiary: parseColor(service.getTextField(entry, 'textTertiary')),
      disabledBackground: parseColor(service.getTextField(entry, 'disabledBackground')),
      dividerColor: parseColor(service.getTextField(entry, 'dividerColor')),
      headerBackground: parseColor(service.getTextField(entry, 'headerBackground')),
      headerText: parseColor(service.getTextField(entry, 'headerText')),
      headerIcon: parseColor(service.getTextField(entry, 'headerIcon')),
    );
  }

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    String colorToHex(Color color) {
      return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
    }

    return {
      'yellowAccent': colorToHex(yellowAccent),
      'redAccent': colorToHex(redAccent),
      'mainBlue': colorToHex(mainBlue),
      'secondBlue': colorToHex(secondBlue),
      'appBackground': colorToHex(appBackground),
      'appText': colorToHex(appText),
      'successColor': colorToHex(successColor),
      'successBackground': colorToHex(successBackground),
      'errorColor': colorToHex(errorColor),
      'errorBackground': colorToHex(errorBackground),
      'warningColor': colorToHex(warningColor),
      'borderColor': colorToHex(borderColor),
      'borderColorSelected': colorToHex(borderColorSelected),
      'textSecondary': colorToHex(textSecondary),
      'textTertiary': colorToHex(textTertiary),
      'disabledBackground': colorToHex(disabledBackground),
      'dividerColor': colorToHex(dividerColor),
      'headerBackground': colorToHex(headerBackground),
      'headerText': colorToHex(headerText),
      'headerIcon': colorToHex(headerIcon),
    };
  }

  /// Create from JSON (for cache)
  factory AppColorsModel.fromJson(Map<String, dynamic> json) {
    Color parseColor(String? hex) {
      if (hex == null || hex.isEmpty) return Colors.black;
      hex = hex.replaceAll('#', '').trim();
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      try {
        return Color(int.parse(hex, radix: 16));
      } catch (e) {
        print('❌ Error parsing color $hex: $e');
        return Colors.black;
      }
    }

    return AppColorsModel(
      yellowAccent: parseColor(json['yellowAccent'] as String?),
      redAccent: parseColor(json['redAccent'] as String?),
      mainBlue: parseColor(json['mainBlue'] as String?),
      secondBlue: parseColor(json['secondBlue'] as String?),
      appBackground: parseColor(json['appBackground'] as String?),
      appText: parseColor(json['appText'] as String?),
      successColor: parseColor(json['successColor'] as String?),
      successBackground: parseColor(json['successBackground'] as String?),
      errorColor: parseColor(json['errorColor'] as String?),
      errorBackground: parseColor(json['errorBackground'] as String?),
      warningColor: parseColor(json['warningColor'] as String?),
      borderColor: parseColor(json['borderColor'] as String?),
      borderColorSelected: parseColor(json['borderColorSelected'] as String?),
      textSecondary: parseColor(json['textSecondary'] as String?),
      textTertiary: parseColor(json['textTertiary'] as String?),
      disabledBackground: parseColor(json['disabledBackground'] as String?),
      dividerColor: parseColor(json['dividerColor'] as String?),
      headerBackground: parseColor(json['headerBackground'] as String?),
      headerText: parseColor(json['headerText'] as String?),
      headerIcon: parseColor(json['headerIcon'] as String?),
    );
  }

  /// Get default fallback colors (from current hardcoded values)
  factory AppColorsModel.defaultColors() {
    return AppColorsModel(
      yellowAccent: const Color(0xFFFDC710),
      redAccent: const Color(0xFFFF0000),
      mainBlue: const Color(0xFF014D7D),
      secondBlue: const Color(0xFF0C80C3),
      appBackground: const Color(0xFFFFFFFF),
      appText: const Color(0xFF000000),
      successColor: const Color(0xFF4CAF50),
      successBackground: const Color(0xFFE8F5E9),
      errorColor: const Color(0xFFF44336),
      errorBackground: const Color(0xFFFFEBEE),
      warningColor: const Color(0xFFFDC710),
      borderColor: const Color(0xFFE0E0E0),
      borderColorSelected: const Color(0xFF0C80C3),
      textSecondary: const Color(0xFF757575),
      textTertiary: const Color(0xFF9E9E9E),
      disabledBackground: const Color(0xFFF5F5F5),
      dividerColor: const Color(0xFFE0E0E0),
      headerBackground: const Color(0xFF014D7D),
      headerText: const Color(0xFFFFFFFF),
      headerIcon: const Color(0xFFFFFFFF),
    );
  }
}

