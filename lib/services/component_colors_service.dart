import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/component_colors.dart';
import 'contentful_service.dart';

/// Service for managing component-level colors from Contentful with local caching
class ComponentColorsService extends ChangeNotifier {
  static final ComponentColorsService _instance = ComponentColorsService._internal();
  factory ComponentColorsService() => _instance;
  ComponentColorsService._internal();

  static const String _cacheKeyPrefix = 'component_colors_';
  static const String _cacheTimestampKey = 'component_colors_cache_timestamp';
  static const Duration _cacheValidityDuration = Duration(hours: 24);

  final Map<String, ComponentColorModel> _componentColors = {};
  bool _isLoading = false;
  bool _isOffline = false;

  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;

  /// Initialize and load component colors (from cache first, then fetch)
  Future<void> initialize() async {
    print('🎨 Initializing ComponentColorsService...');
    
    // Load from cache first for instant UI
    await _loadFromCache();
    
    // Check connectivity
    _isOffline = !await _checkConnectivity();
    
    // Try to fetch from Contentful (will use cache if offline or fails)
    await refreshColors();
  }

  /// Refresh component colors from Contentful (with fallback to cache)
  Future<void> refreshColors({bool force = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Check connectivity
      _isOffline = !await _checkConnectivity();

      if (_isOffline && !force) {
        print('📴 Offline - using cached component colors');
        await _loadFromCache();
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Try to fetch from Contentful
      print('📡 Fetching component colors from Contentful...');
      final contentfulService = ContentfulService();
      
      if (!contentfulService.isInitialized) {
        print('⚠️ Contentful not initialized, using cached/default component colors');
        await _loadFromCache();
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch all Component Colors entries
      // Adjust the content type ID based on your Contentful setup
      final response = await contentfulService.getEntries(
        'componentColor', // Content type ID from Contentful
        limit: 1000, // Adjust based on your needs
      );

      if (response.items.isNotEmpty) {
        final newColors = <String, ComponentColorModel>{};
        
        for (var entry in response.items) {
          final componentColor = ComponentColorModel.fromContentfulEntry(entry);
          if (componentColor.componentId.isNotEmpty) {
            newColors[componentColor.componentId] = componentColor;
          }
        }
        
        _componentColors.clear();
        _componentColors.addAll(newColors);
        
        // Save to cache
        await _saveToCache();
        
        print('✅ Successfully loaded ${_componentColors.length} component colors from Contentful');
      } else {
        print('⚠️ No component colors found in Contentful, using cache/default');
        await _loadFromCache();
      }
    } catch (e) {
      print('❌ Error fetching component colors from Contentful: $e');
      print('   Falling back to cached colors...');
      await _loadFromCache();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load component colors from local cache
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampStr = prefs.getString(_cacheTimestampKey);

      // Check if cache is still valid
      if (timestampStr != null) {
        final timestamp = DateTime.parse(timestampStr);
        final age = DateTime.now().difference(timestamp);
        
        if (age >= _cacheValidityDuration) {
          print('⚠️ Component colors cache expired, will refresh from Contentful when online');
          return;
        }
      }

      // Load all cached component colors
      final keys = prefs.getKeys().where((key) => key.startsWith(_cacheKeyPrefix));
      _componentColors.clear();
      
      for (var key in keys) {
        final cachedJson = prefs.getString(key);
        if (cachedJson != null) {
          try {
            final cachedData = jsonDecode(cachedJson) as Map<String, dynamic>;
            final componentColor = ComponentColorModel.fromJson(cachedData);
            if (componentColor.componentId.isNotEmpty) {
              _componentColors[componentColor.componentId] = componentColor;
            }
          } catch (e) {
            print('❌ Error loading component color from cache for key $key: $e');
          }
        }
      }

      if (_componentColors.isNotEmpty) {
        print('✅ Loaded ${_componentColors.length} component colors from cache');
      } else {
        print('ℹ️ No cached component colors found');
      }
    } catch (e) {
      print('❌ Error loading component colors from cache: $e');
    }
  }

  /// Save component colors to local cache
  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove old cache entries
      final keysToRemove = prefs.getKeys().where((key) => key.startsWith(_cacheKeyPrefix));
      for (var key in keysToRemove) {
        await prefs.remove(key);
      }
      
      // Save all component colors
      for (var entry in _componentColors.entries) {
        final key = '$_cacheKeyPrefix${entry.key}';
        final jsonString = jsonEncode(entry.value.toJson());
        await prefs.setString(key, jsonString);
      }
      
      // Save timestamp
      await prefs.setString(_cacheTimestampKey, DateTime.now().toIso8601String());
      
      print('💾 Component colors cached successfully');
    } catch (e) {
      print('❌ Error saving component colors to cache: $e');
    }
  }

  /// Check network connectivity
  Future<bool> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('❌ Error checking connectivity: $e');
      return false;
    }
  }

  /// Get component color by component ID and color type
  /// Returns null if not found
  Color? getComponentColor(String componentId, String colorType) {
    final componentColor = _componentColors[componentId];
    if (componentColor == null) return null;

    switch (colorType.toLowerCase()) {
      case 'background':
      case 'backgroundcolor':
        return componentColor.backgroundColor;
      case 'text':
      case 'textcolor':
        return componentColor.textColor;
      case 'border':
      case 'bordercolor':
        return componentColor.borderColor;
      case 'icon':
      case 'iconcolor':
        return componentColor.iconColor;
      case 'shadow':
      case 'shadowcolor':
        return componentColor.shadowColor;
      case 'gradientstart':
      case 'gradientstartcolor':
        return componentColor.gradientStartColor;
      case 'gradientend':
      case 'gradientendcolor':
        return componentColor.gradientEndColor;
      default:
        return null;
    }
  }

  /// Check if a component color exists
  bool hasComponentColor(String componentId) {
    return _componentColors.containsKey(componentId);
  }

  /// Clear cache (useful for testing or force refresh)
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keysToRemove = prefs.getKeys().where((key) => 
        key.startsWith(_cacheKeyPrefix) || key == _cacheTimestampKey
      );
      for (var key in keysToRemove) {
        await prefs.remove(key);
      }
      _componentColors.clear();
      print('🗑️ Component colors cache cleared');
    } catch (e) {
      print('❌ Error clearing component colors cache: $e');
    }
  }
}

