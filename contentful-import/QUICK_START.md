# Quick Start: Import All Fallback Values to Contentful

## Prerequisites

1. **Node.js installed** (check with `node --version`)
2. **Contentful account** with:
   - Space ID
   - Management API token

## Step 1: Install Dependencies

```bash
cd contentful-import
npm install contentful-management
```

## Step 2: Get Your Contentful Credentials

### Get Space ID
1. Go to https://app.contentful.com
2. Select your space
3. Go to **Settings** → **General settings**
4. Copy the **Space ID**

### Get Management Token
1. Go to **Settings** → **API keys**
2. Click **Content management tokens**
3. Click **Generate personal token**
4. Copy the token (you'll only see it once!)

## Step 3: Create Content Types in Contentful

**IMPORTANT:** You must create the content types BEFORE running the import!

See `CONTENTFUL_CONTENT_TYPES.md` for detailed instructions.

Quick summary:
1. Create `componentColor` content type with fields: componentId, backgroundColor, textColor, borderColor, iconColor, shadowColor, gradientStartColor, gradientEndColor
2. Create `componentText` content type with fields: textId, text

## Step 4: Run the Import

### Option A: Using Environment Variables (Recommended)

```bash
export CONTENTFUL_SPACE_ID="your-space-id"
export CONTENTFUL_MANAGEMENT_TOKEN="your-management-token"
node import-all-fallback-values.js
```

### Option B: Using Command Line Arguments

```bash
node import-all-fallback-values.js \
  --space-id=YOUR_SPACE_ID \
  --token=YOUR_MANAGEMENT_TOKEN
```

## What Happens

The script will:
1. ✅ Connect to Contentful
2. ✅ Import ~200+ color entries
3. ✅ Import ~150+ text entries
4. ✅ Auto-publish all entries
5. ✅ Show progress and summary

## Expected Output

```
🚀 Starting Complete Fallback Values Import...
   Space ID: w44htb0sb9sl

✅ Connected to Contentful

🎨 Importing Component Colors...
   Total colors: 200+

   ✨ Created: color_yellowAccent
   ✨ Created: color_redAccent
   ...
   ✅ Updated: main_elevatedButton_background
   ...

📝 Importing Component Texts...
   Total texts: 150+

   ✨ Created: buttonNext
   ✨ Created: buttonBack
   ...

📊 Import Summary:

🎨 Component Colors:
   ✅ Created: 150
   🔄 Updated: 50
   ❌ Errors: 0
   📦 Total: 200

📝 Component Texts:
   ✅ Created: 150
   🔄 Updated: 0
   ❌ Errors: 0
   📦 Total: 150

🎉 Import completed!
```

## Troubleshooting

### "Content type not found"
- Make sure you created both `componentColor` and `componentText` content types
- Check that the API identifiers match exactly

### "Unauthorized"
- Verify your Management API token is correct
- Make sure the token hasn't expired

### "Space not found"
- Verify your Space ID is correct
- Make sure you have access to the space

## Next Steps

After successful import:
1. ✅ Verify entries in Contentful web interface
2. ✅ Test app to ensure values are fetched correctly
3. ✅ Update app code to use ContentfulService for fetching texts (if not already done)

