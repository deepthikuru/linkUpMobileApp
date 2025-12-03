import 'package:flutter/material.dart';
import '../services/contentful_service.dart';
import '../models/contentful_models.dart';
import '../utils/theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// Example screen demonstrating how to fetch and display Contentful content
/// Replace this with your actual content types and customize as needed
class ContentfulExampleScreen extends StatefulWidget {
  const ContentfulExampleScreen({super.key});

  @override
  State<ContentfulExampleScreen> createState() => _ContentfulExampleScreenState();
}

class _ContentfulExampleScreenState extends State<ContentfulExampleScreen> {
  final ContentfulService _contentfulService = ContentfulService();
  List<ContentfulContent> _content = [];
  bool _isLoading = true;
  String? _error;
  String _contentType = 'blogPost'; // Change this to your content type ID

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch entries from Contentful
      final response = await _contentfulService.getEntries(
        _contentType,
        limit: 20,
        order: '-sys.createdAt', // Sort by creation date, newest first
      );

      // Convert to generic content model
      final content = response.items
          .map((entry) => ContentfulContent.fromEntry(entry))
          .toList();

      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load content: $e';
        _isLoading = false;
      });
      print('❌ Error loading Contentful content: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contentful Content'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContent,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: AppTheme.getComponentTextColor(
                  context,
                  'text-secondary',
                  fallback: Colors.grey[600],
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadContent,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_content.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppTheme.getComponentIconColor(
                context,
                'icon-secondary',
                fallback: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No content found',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: AppTheme.getComponentTextColor(
                  context,
                  'text-secondary',
                  fallback: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Make sure you have created content in Contentful\nwith content type: $_contentType',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: AppTheme.getComponentTextColor(
                  context,
                  'text-hint',
                  fallback: Colors.grey[500],
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadContent,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _content.length,
        itemBuilder: (context, index) {
          final item = _content[index];
          return _buildContentCard(item);
        },
      ),
    );
  }

  Widget _buildContentCard(ContentfulContent content) {
    // Get common fields (adjust field names based on your content type)
    final title = content.getTextField('title') ?? 
                  content.getTextField('name') ?? 
                  'Untitled';
    final description = content.getTextField('description') ?? 
                       content.getTextField('summary') ?? 
                       content.getTextField('excerpt');
    final slug = content.getTextField('slug');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to detail page or show details
          _showContentDetails(content);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.mainBlue,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: AppTheme.getComponentTextColor(
                    context,
                    'text-title',
                    fallback: Colors.grey[700],
                  ),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Type: ${content.contentTypeId}',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: AppTheme.getComponentTextColor(
                  context,
                  'text-hint',
                  fallback: Colors.grey[500],
                ),
                    ),
                  ),
                  const Spacer(),
                  if (slug != null)
                    Text(
                      'Slug: $slug',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: AppTheme.getComponentTextColor(
                  context,
                  'text-hint',
                  fallback: Colors.grey[500],
                ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContentDetails(ContentfulContent content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.getComponentBorderColor(
                        context,
                        'planCard_divider',
                        fallback: Colors.grey[300],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  content.getTextField('title') ?? 
                  content.getTextField('name') ?? 
                  'Content Details',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.mainBlue,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Content Type', content.contentTypeId),
                _buildDetailRow('ID', content.id),
                _buildDetailRow('Created', _formatDate(content.createdAt)),
                _buildDetailRow('Updated', _formatDate(content.updatedAt)),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'All Fields:',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...content.fields.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${entry.key}:',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.getComponentTextColor(
                    context,
                    'text-title',
                    fallback: Colors.grey[700],
                  ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            entry.value.toString(),
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: AppTheme.getComponentTextColor(
                  context,
                  'text-secondary',
                  fallback: Colors.grey[600],
                ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: AppTheme.getComponentTextColor(
                  context,
                  'text-title',
                  fallback: Colors.grey[900],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

