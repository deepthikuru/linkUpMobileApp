# Quick Import Guide - Component Colors

## 🚀 Fastest Method: Use the Node.js Script

Since Contentful's Import UI might not be visible, use the automated script instead!

### Step 1: Get Your Management API Token

1. Go to Contentful → **Settings** (gear icon in top right)
2. Click **API keys** in the left sidebar
3. Click the tab **"Content management tokens"**
4. Click **"Generate personal token"**
5. **Copy the token** (you'll only see it once!)

### Step 2: Find Your Space ID

From the URL in your browser: `app.contentful.com/spaces/w44htb0sb9sl/...`

Your Space ID is: **`w44htb0sb9sl`**

### Step 3: Run the Script

Open terminal in the `contentful-import` folder and run:

```bash
cd contentful-import

# Install the package (one time only)
npm install contentful-management

# Run the import script
node import-component-colors.js \
  --space-id=w44htb0sb9sl \
  --token=YOUR_MANAGEMENT_TOKEN_HERE
```

Replace `YOUR_MANAGEMENT_TOKEN_HERE` with the token you copied in Step 1.

### Step 4: Watch It Import!

The script will:
- ✅ Create all 176 component color entries
- ✅ Auto-publish them
- ✅ Show progress as it goes
- ✅ Give you a summary at the end

---

## 🔍 Alternative: Find Import in Contentful UI

If you want to try the UI method:

1. Go to **Content** → Look for **"Actions"** or **"..."** menu
2. Or check **Settings** → Look for **"Import/Export"** or **"Content Import"**
3. Some Contentful plans require the **"Import"** app to be installed:
   - Go to **Apps** in the top nav
   - Search for "Import"
   - Install if available

---

## ✅ What You Need Before Running Script

- [ ] Content type `componentColor` already created (I see you have entries!)
- [ ] Management API token (from Settings → API keys → Content management tokens)
- [ ] Space ID: `w44htb0sb9sl` (from your URL)

---

## 🎯 Quick Command Reference

```bash
# Navigate to import folder
cd /Users/k_l_deepthi/Documents/LinkUpMobileApp/contentful-import

# Install dependencies (one time)
npm install contentful-management

# Run import (replace YOUR_TOKEN with actual token)
node import-component-colors.js --space-id=w44htb0sb9sl --token=YOUR_TOKEN
```

---

## 📊 Expected Output

You'll see:
```
🚀 Starting Component Colors Import...
   Space ID: w44htb0sb9sl

✅ Connected to Contentful

   ✨ Created: main_elevatedButton_background
   ✨ Created: main_elevatedButton_text
   ✨ Created: home_scaffold_background
   ... (continues for all 176 entries)

📊 Import Summary:
   ✅ Created: 176
   🔄 Updated: 0
   ❌ Errors: 0
   📦 Total: 176

🎉 Import completed!
```

---

**That's it! The script does everything automatically.** 🎨

