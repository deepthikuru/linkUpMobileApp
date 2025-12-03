import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for interacting with Contentful CMS
/// Follows the same singleton pattern as other services in the app
class ContentfulService {
  static final ContentfulService _instance = ContentfulService._internal();
  factory ContentfulService() => _instance;
  ContentfulService._internal();

  String? _spaceId;
  String? _accessToken;
  String? _previewAccessToken;
  String _environment = 'master';
  bool _initialized = false;
  bool _usePreview = false;

  /// Base URL for Contentful API
  static const String _baseUrl = 'https://cdn.contentful.com';
  static const String _previewBaseUrl = 'https://preview.contentful.com';

  /// Initialize Contentful client with your credentials
  Future<void> initialize({
    required String spaceId,
    required String accessToken,
    String? previewAccessToken,
    String environment = 'master',
    bool usePreview = false,
  }) async {
    if (_initialized) {
      print('⚠️ ContentfulService already initialized');
      return;
    }

    try {
      _spaceId = spaceId;
      _accessToken = accessToken;
      _previewAccessToken = previewAccessToken;
      _environment = environment;
      _usePreview = usePreview;
      _initialized = true;
      print('✅ ContentfulService initialized successfully');
      print('   Space ID: $spaceId');
      print('   Environment: $environment');
      print('   Using Preview API: $usePreview');
    } catch (e) {
      print('❌ Error initializing ContentfulService: $e');
      rethrow;
    }
  }

  /// Check if service is initialized
  bool get isInitialized => _initialized;

  /// Switch between Content Delivery API and Preview API
  void setUsePreview(bool usePreview) {
    if (!_initialized) {
      throw Exception('ContentfulService not initialized. Call initialize() first.');
    }
    if (usePreview && _previewAccessToken == null) {
      throw Exception('Preview access token not provided during initialization.');
    }
    _usePreview = usePreview;
    print('🔄 Switched to ${usePreview ? "Preview" : "Delivery"} API');
  }

  /// Get the base URL based on preview mode
  String get _apiBaseUrl => _usePreview ? _previewBaseUrl : _baseUrl;

  /// Get the access token based on preview mode
  String get _currentAccessToken => _usePreview 
      ? (_previewAccessToken ?? _accessToken!) 
      : _accessToken!;

  /// Build URL for Contentful API requests
  String _buildUrl(String endpoint, {Map<String, String>? queryParams}) {
    if (!_initialized || _spaceId == null) {
      throw Exception('ContentfulService not initialized. Call initialize() first.');
    }

    final basePath = '/spaces/$_spaceId/environments/$_environment';
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final fullPath = '$basePath$path';

    var uri = Uri.parse('$_apiBaseUrl$fullPath');
    
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    return uri.toString();
  }

  /// Make authenticated request to Contentful API
  Future<Map<String, dynamic>> _makeRequest(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final url = _buildUrl(endpoint, queryParams: queryParams);
      print('📡 Contentful API Request: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_currentAccessToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ Contentful API Response: ${response.statusCode}');
        return jsonData;
      } else {
        print('❌ Contentful API Error: ${response.statusCode}');
        print('   Response: ${response.body}');
        throw Exception(
          'Contentful API request failed with status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error making Contentful request: $e');
      rethrow;
    }
  }

  /// Fetch entries by content type
  /// Example: getEntries('blogPost') or getEntries('faq')
  Future<ContentfulResponse> getEntries(
    String contentTypeId, {
    int limit = 100,
    int skip = 0,
    Map<String, dynamic>? query,
    String? order,
  }) async {
    try {
      print('📡 Fetching entries for content type: $contentTypeId');

      final queryParams = <String, String>{
        'content_type': contentTypeId,
        'limit': limit.toString(),
        'skip': skip.toString(),
        if (order != null) 'order': order,
      };

      // Add custom query parameters
      if (query != null) {
        query.forEach((key, value) {
          queryParams[key] = value.toString();
        });
      }

      final response = await _makeRequest('/entries', queryParams: queryParams);
      final contentfulResponse = ContentfulResponse.fromJson(response);

      print('✅ Retrieved ${contentfulResponse.items.length} entries');
      return contentfulResponse;
    } catch (e) {
      print('❌ Error fetching entries: $e');
      rethrow;
    }
  }

  /// Get a single entry by ID
  Future<ContentfulEntry?> getEntry(String entryId) async {
    try {
      print('📡 Fetching entry: $entryId');
      final response = await _makeRequest('/entries/$entryId');
      
      if (response.containsKey('sys') && response.containsKey('fields')) {
        final entry = ContentfulEntry.fromJson(response);
        print('✅ Retrieved entry: ${entry.id}');
        return entry;
      }
      return null;
    } catch (e) {
      print('❌ Error fetching entry: $e');
      return null;
    }
  }

  /// Get assets (images, videos, etc.)
  Future<ContentfulAssetResponse> getAssets({
    int limit = 100,
    int skip = 0,
  }) async {
    try {
      print('📡 Fetching assets');
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'skip': skip.toString(),
      };

      final response = await _makeRequest('/assets', queryParams: queryParams);
      final assetResponse = ContentfulAssetResponse.fromJson(response);

      print('✅ Retrieved ${assetResponse.items.length} assets');
      return assetResponse;
    } catch (e) {
      print('❌ Error fetching assets: $e');
      rethrow;
    }
  }

  /// Get a single asset by ID
  Future<ContentfulAsset?> getAsset(String assetId) async {
    try {
      print('📡 Fetching asset: $assetId');
      final response = await _makeRequest('/assets/$assetId');
      
      if (response.containsKey('sys') && response.containsKey('fields')) {
        final asset = ContentfulAsset.fromJson(response);
        print('✅ Retrieved asset: ${asset.id}');
        return asset;
      }
      return null;
    } catch (e) {
      print('❌ Error fetching asset: $e');
      return null;
    }
  }

  /// Search entries with custom query
  /// Example: searchEntries({'content_type': 'blogPost', 'fields.tags[in]': 'flutter'})
  Future<ContentfulResponse> searchEntries(Map<String, dynamic> query) async {
    try {
      print('📡 Searching entries with query: $query');
      
      final queryParams = <String, String>{};
      query.forEach((key, value) {
        queryParams[key] = value.toString();
      });

      final response = await _makeRequest('/entries', queryParams: queryParams);
      final contentfulResponse = ContentfulResponse.fromJson(response);

      print('✅ Found ${contentfulResponse.items.length} entries');
      return contentfulResponse;
    } catch (e) {
      print('❌ Error searching entries: $e');
      rethrow;
    }
  }

  /// Get asset URL (helper method)
  String? getAssetUrl(ContentfulAsset asset) {
    try {
      if (asset.fields.containsKey('file')) {
        final file = asset.fields['file'] as Map<String, dynamic>;
        if (file.containsKey('url')) {
          final url = file['url'] as String;
          // Prepend https: if URL starts with //
          if (url.startsWith('//')) {
            return 'https:$url';
          }
          return url;
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting asset URL: $e');
      return null;
    }
  }

  /// Get field value from entry (helper method)
  dynamic getFieldValue(ContentfulEntry entry, String fieldName) {
    try {
      if (entry.fields.containsKey(fieldName)) {
        return entry.fields[fieldName];
      }
      return null;
    } catch (e) {
      print('❌ Error getting field value: $e');
      return null;
    }
  }

  /// Get text field value (simplified)
  String? getTextField(ContentfulEntry entry, String fieldName) {
    final value = getFieldValue(entry, fieldName);
    if (value is String) {
      return value;
    }
    return null;
  }

  /// Get image URL from asset reference in entry
  Future<String?> getImageUrl(ContentfulEntry entry, String fieldName) async {
    try {
      final fieldValue = getFieldValue(entry, fieldName);
      
      if (fieldValue is Map && fieldValue.containsKey('sys')) {
        final sys = fieldValue['sys'] as Map<String, dynamic>;
        if (sys.containsKey('id')) {
          final assetId = sys['id'] as String;
          final asset = await getAsset(assetId);
          if (asset != null) {
            return getAssetUrl(asset);
          }
        }
      }
      
      // Handle direct asset object
      if (fieldValue is Map && fieldValue.containsKey('fields')) {
        // This might be an embedded asset
        try {
          final asset = ContentfulAsset.fromJson(fieldValue as Map<String, dynamic>);
          return getAssetUrl(asset);
        } catch (e) {
          // Not an asset, continue
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Error getting image URL: $e');
      return null;
    }
  }
}

/// Response model for Contentful entries
class ContentfulResponse {
  final List<ContentfulEntry> items;
  final int total;
  final int limit;
  final int skip;
  final Map<String, dynamic>? includes;

  ContentfulResponse({
    required this.items,
    required this.total,
    required this.limit,
    required this.skip,
    this.includes,
  });

  factory ContentfulResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>?)
            ?.map((item) => ContentfulEntry.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return ContentfulResponse(
      items: items,
      total: json['total'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
      skip: json['skip'] as int? ?? 0,
      includes: json['includes'] as Map<String, dynamic>?,
    );
  }
}

/// Entry model for Contentful content
class ContentfulEntry {
  final String id;
  final String contentTypeId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final Map<String, dynamic> fields;

  ContentfulEntry({
    required this.id,
    required this.contentTypeId,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.fields,
  });

  factory ContentfulEntry.fromJson(Map<String, dynamic> json) {
    final sys = json['sys'] as Map<String, dynamic>;
    final contentType = sys['contentType'] as Map<String, dynamic>?;
    
    return ContentfulEntry(
      id: sys['id'] as String,
      contentTypeId: contentType?['sys']?['id'] as String? ?? '',
      createdAt: DateTime.parse(sys['createdAt'] as String),
      updatedAt: DateTime.parse(sys['updatedAt'] as String),
      version: sys['revision'] as int? ?? 0,
      fields: json['fields'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// Asset response model
class ContentfulAssetResponse {
  final List<ContentfulAsset> items;
  final int total;
  final int limit;
  final int skip;

  ContentfulAssetResponse({
    required this.items,
    required this.total,
    required this.limit,
    required this.skip,
  });

  factory ContentfulAssetResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>?)
            ?.map((item) => ContentfulAsset.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return ContentfulAssetResponse(
      items: items,
      total: json['total'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
      skip: json['skip'] as int? ?? 0,
    );
  }
}

/// Asset model for Contentful media
class ContentfulAsset {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final Map<String, dynamic> fields;

  ContentfulAsset({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.fields,
  });

  factory ContentfulAsset.fromJson(Map<String, dynamic> json) {
    final sys = json['sys'] as Map<String, dynamic>;

    return ContentfulAsset(
      id: sys['id'] as String,
      createdAt: DateTime.parse(sys['createdAt'] as String),
      updatedAt: DateTime.parse(sys['updatedAt'] as String),
      version: sys['revision'] as int? ?? 0,
      fields: json['fields'] as Map<String, dynamic>? ?? {},
    );
  }
}

