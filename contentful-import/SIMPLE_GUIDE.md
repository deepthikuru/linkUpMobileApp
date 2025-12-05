# Simple Import Guide

## ✅ Easiest Way: Node.js Script

Since Contentful's Import UI might not be visible, use this automated script instead!

---

## 📋 Step-by-Step Instructions

### Step 1: Get Your Management API Token (2 minutes)

1. In Contentful, click the **⚙️ Settings** icon (top right corner)
2. Click **"API keys"** in the left sidebar
3. Click the tab **"Content management tokens"**
4. Click **"Generate personal token"**
5. **Copy the token immediately** (you can only see it once!)
   - Give it a name like "Component Colors Import"
   - Copy the entire token string

### Step 2: Run the Import Script (1 minute)

Open Terminal and run:

```bash
cd /Users/k_l_deepthi/Documents/LinkUpMobileApp/contentful-import

npm install contentful-management

node import-component-colors.js \
  --space-id=w44htb0sb9sl \
  --token=PASTE_YOUR_TOKEN_HERE
```

**Replace `PASTE_YOUR_TOKEN_HERE` with the token you copied.**

### Step 3: Wait for Import (2-3 minutes)

The script will:
- ✅ Connect to Contentful
- ✅ Create all 176 component color entries
- ✅ Auto-publish everything
- ✅ Show progress as it works
- ✅ Give you a summary

---

## 🎯 All-in-One Command

Or use the helper script:

```bash
cd /Users/k_l_deepthi/Documents/LinkUpMobileApp/contentful-import
./run-import.sh YOUR_MANAGEMENT_TOKEN
```

---

## ✅ What You Need

- ✅ Content type `componentColor` already exists (I see you have entries!)
- ✅ Space ID: `w44htb0sb9sl` (from your URL)
- ⏳ Management API Token (get from Settings → API keys)

---

## 🚨 Important Notes

- **The Management API Token is different from regular API keys**
- It's found under "Content management tokens" tab
- You need this to create/update entries programmatically
- Keep it secure - don't share it publicly

---

## 📊 After Import

You'll see all entries in Contentful → Content → Filter by "componentColor"

All 176 entries will be:
- ✅ Created
- ✅ Published
- ✅ Ready to use in your app

Your app will automatically fetch them on next launch!

---

## 💡 Alternative: Manual Entry Creation

If you prefer to create entries manually:
1. Go to Content → "+ Add entry"
2. Select "componentColor"
3. Fill in componentId and color fields
4. Repeat for all 176 entries... 😅

**That's why the script is better!** 😉

---

**Ready? Get your token and run the script!** 🚀

