import 'package:flutter/material.dart';
import '../services/contentful_service.dart' show ContentfulService, ContentfulEntry;

/// Model for Component Colors from Contentful
class ComponentColorModel {
  final String componentId;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? shadowColor;
  final Color? gradientStartColor;
  final Color? gradientEndColor;

  ComponentColorModel({
    required this.componentId,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.iconColor,
    this.shadowColor,
    this.gradientStartColor,
    this.gradientEndColor,
  });

  /// Create from Contentful entry
  factory ComponentColorModel.fromContentfulEntry(ContentfulEntry entry) {
    final service = ContentfulService();
    
    // Helper to parse hex color string
    Color? parseColor(String? hex) {
      if (hex == null || hex.isEmpty) return null;
      hex = hex.replaceAll('#', '').trim();
      if (hex.length == 6) {
        hex = 'FF$hex'; // Add alpha if missing
      }
      try {
        return Color(int.parse(hex, radix: 16));
      } catch (e) {
        print('❌ Error parsing color $hex: $e');
        return null;
      }
    }

    return ComponentColorModel(
      componentId: service.getTextField(entry, 'componentId') ?? '',
      backgroundColor: parseColor(service.getTextField(entry, 'backgroundColor')),
      textColor: parseColor(service.getTextField(entry, 'textColor')),
      borderColor: parseColor(service.getTextField(entry, 'borderColor')),
      iconColor: parseColor(service.getTextField(entry, 'iconColor')),
      shadowColor: parseColor(service.getTextField(entry, 'shadowColor')),
      gradientStartColor: parseColor(service.getTextField(entry, 'gradientStartColor')),
      gradientEndColor: parseColor(service.getTextField(entry, 'gradientEndColor')),
    );
  }

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    String? colorToHex(Color? color) {
      if (color == null) return null;
      final hex = color.value.toRadixString(16).padLeft(8, '0');
      return '#${hex.substring(2).toUpperCase()}';
    }

    return {
      'componentId': componentId,
      'backgroundColor': colorToHex(backgroundColor),
      'textColor': colorToHex(textColor),
      'borderColor': colorToHex(borderColor),
      'iconColor': colorToHex(iconColor),
      'shadowColor': colorToHex(shadowColor),
      'gradientStartColor': colorToHex(gradientStartColor),
      'gradientEndColor': colorToHex(gradientEndColor),
    };
  }

  /// Create from JSON (for cache)
  factory ComponentColorModel.fromJson(Map<String, dynamic> json) {
    Color? parseColor(String? hex) {
      if (hex == null || hex.isEmpty) return null;
      hex = hex.replaceAll('#', '').trim();
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      try {
        return Color(int.parse(hex, radix: 16));
      } catch (e) {
        print('❌ Error parsing color $hex: $e');
        return null;
      }
    }

    return ComponentColorModel(
      componentId: json['componentId'] as String? ?? '',
      backgroundColor: parseColor(json['backgroundColor'] as String?),
      textColor: parseColor(json['textColor'] as String?),
      borderColor: parseColor(json['borderColor'] as String?),
      iconColor: parseColor(json['iconColor'] as String?),
      shadowColor: parseColor(json['shadowColor'] as String?),
      gradientStartColor: parseColor(json['gradientStartColor'] as String?),
      gradientEndColor: parseColor(json['gradientEndColor'] as String?),
    );
  }
}

