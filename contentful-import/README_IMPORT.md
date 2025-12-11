# Import All Fallback Values to Contentful

## Quick Start

### Step 1: Get Your Management API Token

⚠️ **You need a Management API token** (different from Delivery/Preview tokens)

1. Go to: https://app.contentful.com/spaces/w44htb0sb9sl/settings/api-keys
2. Scroll down to **"Content management tokens"** section
3. Click **"Generate personal token"**
4. Copy the token (you'll only see it once!)

See `GET_MANAGEMENT_TOKEN.md` for detailed instructions.

### Step 2: Create Content Types (if not already created)

Before importing, you need to create two content types in Contentful:

1. **componentColor** - for color values
2. **componentText** - for text strings

See `CONTENTFUL_CONTENT_TYPES.md` for detailed field definitions.

**Quick Setup:**
- Go to Contentful → **Content model** → **Add content type**
- Create `componentColor` with fields: componentId, backgroundColor, textColor, borderColor, iconColor, shadowColor, gradientStartColor, gradientEndColor
- Create `componentText` with fields: textId, text

### Step 3: Run the Import

**Option A: Using the helper script (easiest)**

```bash
cd contentful-import
./run-import-all.sh YOUR_MANAGEMENT_TOKEN
```

**Option B: Using environment variables**

```bash
cd contentful-import
export CONTENTFUL_SPACE_ID="w44htb0sb9sl"
export CONTENTFUL_MANAGEMENT_TOKEN="your-management-token"
node import-all-fallback-values.js
```

**Option C: Using command line arguments**

```bash
cd contentful-import
node import-all-fallback-values.js \
  --space-id=w44htb0sb9sl \
  --token=YOUR_MANAGEMENT_TOKEN
```

## What Gets Imported

- **~200+ Color Entries** - All colors from FallbackValues
- **~150+ Text Entries** - All text strings from FallbackValues

All entries are automatically published after import.

## Verification

After import, verify in Contentful:
1. Go to **Content** → Filter by `componentColor` (should see ~200 entries)
2. Go to **Content** → Filter by `componentText` (should see ~150 entries)
3. All entries should be in "Published" status

## Troubleshooting

### "Content type not found"
- Make sure you created both `componentColor` and `componentText` content types
- Check that API identifiers match exactly (case-sensitive)

### "Unauthorized" or "Forbidden"
- Verify your Management API token is correct
- Make sure you're using the Management API token, not Delivery/Preview tokens
- Check that the token hasn't expired

### "Space not found"
- Verify Space ID: `w44htb0sb9sl`
- Make sure you have access to the space

## Your Current Setup

- **Space ID:** `w44htb0sb9sl`
- **Content Delivery Token:** `rm5ph3ht3B4U-6PG9zM_opMFnoVojXmHOe3T9R9C8JQ` (for reading content)
- **Content Preview Token:** `wdRyb5ysWZkGDt9IXM-O2BaLCQiiZxW-ZIoBTdhcxMc` (for previewing drafts)
- **Management Token:** ⚠️ **Need to generate** (for creating/updating content)

