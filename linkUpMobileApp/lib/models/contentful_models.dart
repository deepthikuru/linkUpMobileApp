import '../services/contentful_service.dart';

/// Example model for a blog post or article
class BlogPost {
  final String id;
  final String title;
  final String? content;
  final String? author;
  final DateTime? publishDate;
  final String? imageUrl;
  final List<String>? tags;
  final String? slug;

  BlogPost({
    required this.id,
    required this.title,
    this.content,
    this.author,
    this.publishDate,
    this.imageUrl,
    this.tags,
    this.slug,
  });

  factory BlogPost.fromEntry(ContentfulEntry entry) {
    final service = ContentfulService();
    
    return BlogPost(
      id: entry.id,
      title: service.getTextField(entry, 'title') ?? '',
      content: service.getTextField(entry, 'content') ?? 
               service.getTextField(entry, 'body'),
      author: service.getTextField(entry, 'author'),
      publishDate: entry.fields['publishDate'] != null
          ? DateTime.tryParse(entry.fields['publishDate'] as String)
          : null,
      slug: service.getTextField(entry, 'slug'),
      tags: entry.fields['tags'] != null
          ? List<String>.from(entry.fields['tags'] as List)
          : null,
    );
  }

  /// Load image URL asynchronously
  Future<void> loadImageUrl(ContentfulEntry entry) async {
    final service = ContentfulService();
    imageUrl = await service.getImageUrl(entry, 'image') ?? 
               await service.getImageUrl(entry, 'featuredImage') ??
               await service.getImageUrl(entry, 'thumbnail');
  }
}

/// Example model for FAQ
class FAQ {
  final String id;
  final String question;
  final String answer;
  final String? category;
  final int? order;

  FAQ({
    required this.id,
    required this.question,
    required this.answer,
    this.category,
    this.order,
  });

  factory FAQ.fromEntry(ContentfulEntry entry) {
    final service = ContentfulService();
    
    return FAQ(
      id: entry.id,
      question: service.getTextField(entry, 'question') ?? '',
      answer: service.getTextField(entry, 'answer') ?? '',
      category: service.getTextField(entry, 'category'),
      order: entry.fields['order'] != null
          ? (entry.fields['order'] as num).toInt()
          : null,
    );
  }
}

/// Example model for a page or content block
class ContentPage {
  final String id;
  final String title;
  final String? content;
  final String? slug;
  final String? metaDescription;
  final String? imageUrl;

  ContentPage({
    required this.id,
    required this.title,
    this.content,
    this.slug,
    this.metaDescription,
    this.imageUrl,
  });

  factory ContentPage.fromEntry(ContentfulEntry entry) {
    final service = ContentfulService();
    
    return ContentPage(
      id: entry.id,
      title: service.getTextField(entry, 'title') ?? '',
      content: service.getTextField(entry, 'content') ?? 
               service.getTextField(entry, 'body'),
      slug: service.getTextField(entry, 'slug'),
      metaDescription: service.getTextField(entry, 'metaDescription'),
    );
  }

  /// Load image URL asynchronously
  Future<void> loadImageUrl(ContentfulEntry entry) async {
    final service = ContentfulService();
    imageUrl = await service.getImageUrl(entry, 'image') ?? 
               await service.getImageUrl(entry, 'heroImage') ??
               await service.getImageUrl(entry, 'thumbnail');
  }
}

/// Generic content model that can be used for any content type
class ContentfulContent {
  final String id;
  final String contentTypeId;
  final Map<String, dynamic> fields;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContentfulContent({
    required this.id,
    required this.contentTypeId,
    required this.fields,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContentfulContent.fromEntry(ContentfulEntry entry) {
    return ContentfulContent(
      id: entry.id,
      contentTypeId: entry.contentTypeId,
      fields: entry.fields,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    );
  }

  /// Get a field value by name
  dynamic getField(String fieldName) {
    return fields[fieldName];
  }

  /// Get a text field value
  String? getTextField(String fieldName) {
    final value = fields[fieldName];
    if (value is String) {
      return value;
    }
    return null;
  }

  /// Get a number field value
  num? getNumberField(String fieldName) {
    final value = fields[fieldName];
    if (value is num) {
      return value;
    }
    return null;
  }

  /// Get a boolean field value
  bool? getBooleanField(String fieldName) {
    final value = fields[fieldName];
    if (value is bool) {
      return value;
    }
    return null;
  }

  /// Get a date field value
  DateTime? getDateField(String fieldName) {
    final value = fields[fieldName];
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

