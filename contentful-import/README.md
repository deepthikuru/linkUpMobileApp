# Contentful Component Colors Import Guide

This directory contains all the files needed to bulk-import component colors into Contentful.

## 📁 Files Included

1. **`component-colors.csv`** - CSV file for Contentful UI import
2. **`component-colors.json`** - JSON file for Contentful CLI import  
3. **`import-component-colors.js`** - Node.js script for programmatic import
4. **`README.md`** - This file

---

## 🚀 Quick Start (Recommended: CSV Import)

### Step 1: Create Content Type in Contentful

1. Go to Contentful → **Content model**
2. Click **"Add content type"**
3. Name it: `componentColor`
4. Add these fields:
   - `componentId` (Short text, required, unique)
   - `backgroundColor` (Short text, optional)
   - `textColor` (Short text, optional)
   - `borderColor` (Short text, optional)
   - `iconColor` (Short text, optional)
   - `shadowColor` (Short text, optional)
   - `gradientStartColor` (Short text, optional)
   - `gradientEndColor` (Short text, optional)

### Step 2: Import via CSV

1. Go to Contentful → **Content** → **Import**
2. Upload `component-colors.csv`
3. Map CSV columns to your Content Type fields
4. Click **Import**
5. Done! ✅

---

## 📦 Alternative Methods

### Option A: Contentful CLI (JSON Import)

**Prerequisites:**
```bash
npm install -g contentful-cli
```

**Steps:**

1. Login to Contentful:
   ```bash
   contentful login
   ```

2. Import the JSON file:
   ```bash
   contentful space import \
     --space-id YOUR_SPACE_ID \
     --environment-id master \
     --content-file component-colors.json
   ```

**Note:** The JSON file is provided but may need adjustment for your Contentful setup.

---

### Option B: Node.js Script (Recommended for Automation)

**Prerequisites:**
```bash
npm install contentful-management
```

**Usage:**

1. Set environment variables:
   ```bash
   export CONTENTFUL_SPACE_ID="your-space-id"
   export CONTENTFUL_MANAGEMENT_TOKEN="your-management-token"
   ```

2. Or pass as arguments:
   ```bash
   node import-component-colors.js \
     --space-id=YOUR_SPACE_ID \
     --token=YOUR_MANAGEMENT_TOKEN
   ```

3. Run the script:
   ```bash
   node import-component-colors.js
   ```

**Features:**
- ✅ Creates new entries or updates existing ones
- ✅ Auto-publishes all entries
- ✅ Provides detailed progress output
- ✅ Error handling with summary

---

## 🔑 Getting Your Contentful Management Token

1. Go to Contentful → **Settings** → **API keys**
2. Click **Content management tokens**
3. Click **Generate personal token**
4. Copy the token (you'll only see it once!)

---

## 📊 What Gets Imported

The import includes **all component colors** from your documentation:
- ✅ ~150+ component color entries
- ✅ All widgets (buttons, cards, headers, footers, etc.)
- ✅ All screens (login, home, profile, order flow, etc.)
- ✅ Default colors from your App Colors

---

## ⚙️ After Import

1. **Verify entries:**
   - Go to Contentful → **Content**
   - Filter by content type: `componentColor`
   - You should see all your component colors

2. **Publish entries:**
   - If using CSV/JSON import, entries start as drafts
   - Select all → **Publish**
   - Or use the Node.js script (auto-publishes)

3. **Test in app:**
   - The app will automatically fetch colors on next launch
   - Colors are cached locally for offline use
   - Check app logs for: `✅ Successfully loaded X component colors from Contentful`

---

## 🔄 Updating Colors

To update colors later:

1. **Via Contentful UI:**
   - Edit any entry → Change color → Publish

2. **Via Script:**
   - Modify `import-component-colors.js` data
   - Run script again (updates existing entries)

3. **Via CSV:**
   - Export current entries → Modify → Re-import

---

## ⚠️ Important Notes

- **Unique IDs:** Component IDs must be unique
- **Hex Format:** All colors should be in hex format (e.g., `#FFFFFF`)
- **Optional Fields:** Leave fields empty if not needed
- **Gradients:** Gradient entries need both `gradientStartColor` and `gradientEndColor`
- **Fallback:** The app falls back to default colors if Contentful is unavailable

---

## 🐛 Troubleshooting

### Script fails to connect
- ✅ Verify your Management API token is correct
- ✅ Check your Space ID is correct
- ✅ Ensure token has proper permissions

### Entries not showing in app
- ✅ Verify entries are published (not just saved as drafts)
- ✅ Check app logs for Contentful fetch errors
- ✅ Ensure `componentColor` content type ID matches exactly

### Import errors
- ✅ Check CSV/JSON format matches Contentful structure
- ✅ Verify all required fields are present
- ✅ Check for duplicate component IDs

---

## 📚 Additional Resources

- [Contentful Management API Docs](https://www.contentful.com/developers/docs/references/content-management-api/)
- [Contentful CLI Docs](https://github.com/contentful/contentful-cli)
- See `COMPONENT_COLORS_FOR_CONTENTFUL.md` for complete component list

---

## ✅ Quick Checklist

- [ ] Content type `componentColor` created in Contentful
- [ ] All 8 fields added to content type
- [ ] Import method chosen (CSV/JSON/Script)
- [ ] Import completed successfully
- [ ] All entries published
- [ ] App fetches colors successfully

---

**Happy importing! 🎨**

