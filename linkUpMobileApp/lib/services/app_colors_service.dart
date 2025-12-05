import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/app_colors.dart';
import 'contentful_service.dart';

/// Service for managing app colors from Contentful with local caching
class AppColorsService extends ChangeNotifier {
  static final AppColorsService _instance = AppColorsService._internal();
  factory AppColorsService() => _instance;
  AppColorsService._internal();

  static const String _cacheKey = 'app_colors_cache';
  static const String _cacheTimestampKey = 'app_colors_cache_timestamp';
  static const Duration _cacheValidityDuration = Duration(hours: 24);

  AppColorsModel _colors = AppColorsModel.defaultColors();
  bool _isLoading = false;
  bool _isOffline = false;
  DateTime? _lastFetchTime;

  AppColorsModel get colors => _colors;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;

  /// Initialize and load colors (from cache first, then fetch)
  Future<void> initialize() async {
    print('🎨 Initializing AppColorsService...');
    
    // Load from cache first for instant UI
    await _loadFromCache();
    
    // Check connectivity
    _isOffline = !await _checkConnectivity();
    
    // Try to fetch from Contentful (will use cache if offline or fails)
    await refreshColors();
  }

  /// Refresh colors from Contentful (with fallback to cache)
  Future<void> refreshColors({bool force = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Check connectivity
      _isOffline = !await _checkConnectivity();

      if (_isOffline && !force) {
        print('📴 Offline - using cached colors');
        await _loadFromCache();
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Try to fetch from Contentful
      print('📡 Fetching app colors from Contentful...');
      final contentfulService = ContentfulService();
      
      if (!contentfulService.isInitialized) {
        print('⚠️ Contentful not initialized, using cached/default colors');
        await _loadFromCache();
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch App Colors entry (content type should be 'appColors')
      // You may need to adjust the content type ID based on your Contentful setup
      final response = await contentfulService.getEntries(
        'appColors', // Content type ID from Contentful
        limit: 1,
      );

      if (response.items.isNotEmpty) {
        final entry = response.items.first;
        final newColors = AppColorsModel.fromContentfulEntry(entry);
        
        _colors = newColors;
        _lastFetchTime = DateTime.now();
        
        // Save to cache
        await _saveToCache(newColors);
        
        print('✅ Successfully loaded colors from Contentful');
      } else {
        print('⚠️ No app colors found in Contentful, using cache/default');
        await _loadFromCache();
      }
    } catch (e) {
      print('❌ Error fetching colors from Contentful: $e');
      print('   Falling back to cached colors...');
      await _loadFromCache();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load colors from local cache
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      final timestampStr = prefs.getString(_cacheTimestampKey);

      if (cachedJson != null) {
        final cachedData = jsonDecode(cachedJson) as Map<String, dynamic>;
        final cachedColors = AppColorsModel.fromJson(cachedData);

        // Check if cache is still valid
        if (timestampStr != null) {
          final timestamp = DateTime.parse(timestampStr);
          final age = DateTime.now().difference(timestamp);
          
          if (age < _cacheValidityDuration) {
            _colors = cachedColors;
            print('✅ Loaded colors from cache (age: ${age.inMinutes}m)');
            return;
          } else {
            print('⚠️ Cache expired, will refresh from Contentful when online');
          }
        } else {
          // Old cache without timestamp - still use it but will refresh
          _colors = cachedColors;
          print('✅ Loaded colors from cache (no timestamp)');
          return;
        }
      }

      // No cache or expired - use defaults
      print('ℹ️ No valid cache found, using default colors');
      _colors = AppColorsModel.defaultColors();
    } catch (e) {
      print('❌ Error loading from cache: $e');
      _colors = AppColorsModel.defaultColors();
    }
  }

  /// Save colors to local cache
  Future<void> _saveToCache(AppColorsModel colors) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(colors.toJson());
      
      await prefs.setString(_cacheKey, jsonString);
      await prefs.setString(_cacheTimestampKey, DateTime.now().toIso8601String());
      
      print('💾 Colors cached successfully');
    } catch (e) {
      print('❌ Error saving to cache: $e');
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

  /// Clear cache (useful for testing or force refresh)
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimestampKey);
      print('🗑️ Cache cleared');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }

  /// Get color by name (helper method)
  Color getColor(String name) {
    switch (name.toLowerCase()) {
      case 'yellowaccent':
        return _colors.yellowAccent;
      case 'redaccent':
        return _colors.redAccent;
      case 'mainblue':
        return _colors.mainBlue;
      case 'secondblue':
        return _colors.secondBlue;
      case 'appbackground':
        return _colors.appBackground;
      case 'apptext':
        return _colors.appText;
      case 'successcolor':
        return _colors.successColor;
      case 'successbackground':
        return _colors.successBackground;
      case 'errorcolor':
        return _colors.errorColor;
      case 'errorbackground':
        return _colors.errorBackground;
      case 'warningcolor':
        return _colors.warningColor;
      case 'bordercolor':
        return _colors.borderColor;
      case 'bordercolorselected':
        return _colors.borderColorSelected;
      case 'textsecondary':
        return _colors.textSecondary;
      case 'texttertiary':
        return _colors.textTertiary;
      case 'disabledbackground':
        return _colors.disabledBackground;
      case 'dividercolor':
        return _colors.dividerColor;
      case 'headerbackground':
        return _colors.headerBackground;
      case 'headertext':
        return _colors.headerText;
      case 'headericon':
        return _colors.headerIcon;
      default:
        return Colors.black;
    }
  }
}

