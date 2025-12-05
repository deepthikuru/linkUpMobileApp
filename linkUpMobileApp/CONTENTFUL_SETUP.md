# Contentful Integration Guide

## ✅ What's Already Done

1. **ContentfulService** - Created and initialized in `main.dart`
2. **Content Models** - Created example models in `lib/models/contentful_models.dart`
3. **Example Screen** - Created `lib/screens/contentful_example_screen.dart` as a reference

## 📋 Next Steps

### Step 1: Set Up Content in Contentful Web Interface

1. **Go to your Contentful Space** (not the App details page)
   - Navigate to: https://app.contentful.com/spaces/w44htb0sb9sl
   - You should see "Content model" in the left sidebar

2. **Create a Content Type**
   - Click "Content model" → "Add content type"
   - Example: Create a "Blog Post" content type with fields:
     - `title` (Short text, required)
     - `content` (Long text)
     - `slug` (Short text, unique)
     - `author` (Short text)
     - `publishDate` (Date & time)
     - `image` (Media - single file)
     - `tags` (Short text, list)

3. **Add Content Entries**
   - Click "Content" in the sidebar
   - Click "Add entry"
   - Select your content type
   - Fill in the fields and click "Publish"

### Step 2: Use Contentful in Your App

#### Option A: Test with the Example Screen

Add this to your navigation to test:

```dart
// In your navigation or menu
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ContentfulExampleScreen(),
  ),
);
```

#### Option B: Integrate into Existing Screens

Example: Fetch FAQs for your Support screen:

```dart
import '../services/contentful_service.dart';
import '../models/contentful_models.dart';

// In your widget
final contentfulService = ContentfulService();

// Fetch FAQs
final response = await contentfulService.getEntries('faq');
final faqs = response.items
    .map((entry) => FAQ.fromEntry(entry))
    .toList();

// Display in your UI
ListView.builder(
  itemCount: faqs.length,
  itemBuilder: (context, index) {
    final faq = faqs[index];
    return ListTile(
      title: Text(faq.question),
      subtitle: Text(faq.answer),
    );
  },
);
```

### Step 3: Customize for Your Content Types

1. **Update the content type ID** in `contentful_example_screen.dart`:
   ```dart
   String _contentType = 'yourContentTypeId'; // Change this
   ```

2. **Create custom models** in `lib/models/contentful_models.dart`:
   ```dart
   class YourContentType {
     final String id;
     final String title;
     // Add your fields
     
     factory YourContentType.fromEntry(ContentfulEntry entry) {
       final service = ContentfulService();
       return YourContentType(
         id: entry.id,
         title: service.getTextField(entry, 'title') ?? '',
         // Map your fields
       );
     }
   }
   ```

## 🔧 Common Use Cases

### Fetch All Entries
```dart
final response = await ContentfulService().getEntries('blogPost');
final entries = response.items;
```

### Fetch Single Entry
```dart
final entry = await ContentfulService().getEntry('entry-id-here');
```

### Search Entries
```dart
final response = await ContentfulService().searchEntries({
  'content_type': 'blogPost',
  'fields.tags[in]': 'flutter',
  'order': '-sys.createdAt',
});
```

### Get Image URL
```dart
final imageUrl = await ContentfulService().getImageUrl(entry, 'image');
```

### Use Preview API (for draft content)
```dart
ContentfulService().setUsePreview(true);
final response = await ContentfulService().getEntries('blogPost');
```

## 📝 Important Notes

- **Content Type IDs**: Use the exact ID from Contentful (usually lowercase with no spaces)
- **Field Names**: Match the field IDs exactly as they appear in Contentful
- **Publishing**: Only published content is available via Content Delivery API
- **Preview API**: Use `setUsePreview(true)` to access draft content

## 🐛 Troubleshooting

### "No content found"
- Check that you've created content in Contentful
- Verify the content type ID matches exactly
- Make sure content is published (or use Preview API)

### "Failed to load content"
- Check your internet connection
- Verify Space ID and Access Token in `main.dart`
- Check Contentful API status

### "Field not found"
- Verify field IDs match exactly (case-sensitive)
- Check that the field exists in your content type

## 📚 Resources

- [Contentful API Documentation](https://www.contentful.com/developers/docs/references/content-delivery-api/)
- [Contentful Flutter Examples](https://github.com/contentful/contentful.dart)

