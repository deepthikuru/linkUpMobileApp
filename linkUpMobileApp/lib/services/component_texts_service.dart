import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/contentful_service.dart';

/// Service for managing component text strings from Contentful with local caching
class ComponentTextsService extends ChangeNotifier {
  static final ComponentTextsService _instance = ComponentTextsService._internal();
  factory ComponentTextsService() => _instance;
  ComponentTextsService._internal();

  static const String _cacheKeyPrefix = 'component_texts_';
  static const String _cacheTimestampKey = 'component_texts_cache_timestamp';
  static const Duration _cacheValidityDuration = Duration(hours: 24);

  final Map<String, String> _textStrings = {};
  bool _isLoading = false;
  bool _isOffline = false;

  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;

  /// Initialize and load text strings (from cache first, then fetch)
  Future<void> initialize() async {
    print('📝 Initializing ComponentTextsService...');
    
    // Load from cache first for instant UI
    await _loadFromCache();
    
    // Check connectivity
    _isOffline = !await _checkConnectivity();
    
    // Try to fetch from Contentful (will use cache if offline or fails)
    await refreshStrings();
  }

  /// Refresh text strings from Contentful (with fallback to cache)
  Future<void> refreshStrings({bool force = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Check connectivity
      _isOffline = !await _checkConnectivity();

      if (_isOffline && !force) {
        print('📴 Offline - using cached text strings');
        await _loadFromCache();
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Try to fetch from Contentful
      print('📡 Fetching text strings from Contentful...');
      final contentfulService = ContentfulService();
      
      if (!contentfulService.isInitialized) {
        print('⚠️ Contentful not initialized, using cached/default text strings');
        await _loadFromCache();
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch all Component Text entries
      // Adjust the content type ID based on your Contentful setup
      final response = await contentfulService.getEntries(
        'componentText', // Content type ID from Contentful
        limit: 1000,
      );

      if (response.items.isNotEmpty) {
        final newStrings = <String, String>{};
        
        for (var entry in response.items) {
          final service = ContentfulService();
          final textId = service.getTextField(entry, 'textId');
          final textValue = service.getTextField(entry, 'text');
          
          if (textId != null && textValue != null) {
            newStrings[textId] = textValue;
          }
        }
        
        _textStrings.clear();
        _textStrings.addAll(newStrings);
        
        // Save to cache
        await _saveToCache();
        
        print('✅ Successfully loaded ${_textStrings.length} text strings from Contentful');
      } else {
        print('⚠️ No text strings found in Contentful, using cache/default');
        await _loadFromCache();
      }
    } catch (e) {
      print('❌ Error fetching text strings from Contentful: $e');
      print('   Falling back to cached text strings...');
      await _loadFromCache();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load text strings from local cache
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampStr = prefs.getString(_cacheTimestampKey);

      // Check if cache is still valid
      if (timestampStr != null) {
        final timestamp = DateTime.parse(timestampStr);
        final age = DateTime.now().difference(timestamp);
        
        if (age >= _cacheValidityDuration) {
          print('⚠️ Text strings cache expired, will refresh from Contentful when online');
          return;
        }
      }

      // Load all cached text strings
      final keys = prefs.getKeys().where((key) => key.startsWith(_cacheKeyPrefix));
      _textStrings.clear();
      
      for (var key in keys) {
        final cachedJson = prefs.getString(key);
        if (cachedJson != null) {
          try {
            final cachedData = jsonDecode(cachedJson) as Map<String, dynamic>;
            final textId = cachedData['textId'] as String?;
            final textValue = cachedData['text'] as String?;
            if (textId != null && textValue != null) {
              _textStrings[textId] = textValue;
            }
          } catch (e) {
            print('❌ Error loading text string from cache for key $key: $e');
          }
        }
      }

      if (_textStrings.isNotEmpty) {
        print('✅ Loaded ${_textStrings.length} text strings from cache');
      } else {
        print('ℹ️ No cached text strings found');
      }
    } catch (e) {
      print('❌ Error loading text strings from cache: $e');
    }
  }

  /// Save text strings to local cache
  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove old cache entries
      final keysToRemove = prefs.getKeys().where((key) => key.startsWith(_cacheKeyPrefix));
      for (var key in keysToRemove) {
        await prefs.remove(key);
      }
      
      // Save all text strings
      for (var entry in _textStrings.entries) {
        final key = '$_cacheKeyPrefix${entry.key}';
        final jsonString = jsonEncode({
          'textId': entry.key,
          'text': entry.value,
        });
        await prefs.setString(key, jsonString);
      }
      
      // Save timestamp
      await prefs.setString(_cacheTimestampKey, DateTime.now().toIso8601String());
      
      print('💾 Text strings cached successfully');
    } catch (e) {
      print('❌ Error saving text strings to cache: $e');
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

  /// Get text string by text ID
  /// Returns null if not found (caller should use fallback)
  String? getString(String textId) {
    return _textStrings[textId];
  }

  /// Check if a text string exists
  bool hasString(String textId) {
    return _textStrings.containsKey(textId);
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
      _textStrings.clear();
      print('🗑️ Text strings cache cleared');
    } catch (e) {
      print('❌ Error clearing text strings cache: $e');
    }
  }
}

