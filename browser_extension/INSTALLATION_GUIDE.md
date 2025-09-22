# 🚀 LinkCrypta Browser Extension - Installation Guide

## Quick Setup (5 minutes)

### Step 1: Generate Extension Icons

1. **Open the Icon Generator**
   - Navigate to `browser_extension/create_icons.html`
   - Double-click to open in your browser

2. **Download All Icon Sizes**
   - Click "Download 16x16" → Save as `icon-16.png`
   - Click "Download 32x32" → Save as `icon-32.png` 
   - Click "Download 48x48" → Save as `icon-48.png`
   - Click "Download 128x128" → Save as `icon-128.png`

3. **Place Icons in Folder**
   - Move all downloaded PNG files to `browser_extension/icons/` folder
   - Your icons folder should now contain 4 PNG files

### Step 2: Load Extension in Chrome

1. **Open Chrome Extensions Page**
   ```
   Type in address bar: chrome://extensions/
   ```

2. **Enable Developer Mode**
   - Look for "Developer mode" toggle in top-right corner
   - Click to enable it (should turn blue/green)

3. **Load Unpacked Extension**
   - Click "Load unpacked" button (appears after enabling developer mode)
   - Navigate to your project folder: `d:\flutter\flutter_application_1\browser_extension`
   - Select the `browser_extension` folder and click "Select Folder"

4. **Verify Installation**
   - You should see "LinkCrypta Password Manager" in your extensions list
   - The extension icon should appear in your browser toolbar
   - Status should show "Enabled"

### Step 3: Load Extension in Microsoft Edge

1. **Open Edge Extensions Page**
   ```
   Type in address bar: edge://extensions/
   ```

2. **Enable Developer Mode**
   - Look for "Developer mode" toggle in left sidebar
   - Click to enable it

3. **Load Unpacked Extension**
   - Click "Load unpacked" button
   - Navigate to: `d:\flutter\flutter_application_1\browser_extension`
   - Select the folder and click "Select Folder"

## 📱 Mobile Browser Setup (Android Chrome)

### For Android Chrome:
1. **Enable Desktop Site** (temporary for testing)
   - Open Chrome on Android
   - Go to `chrome://extensions/`
   - Request desktop site if needed

2. **Developer Options** (Advanced)
   - Enable USB debugging on your Android device
   - Use Chrome DevTools for remote debugging
   - Load extension through desktop Chrome connected to mobile

### For iOS Safari:
- Extensions must be distributed through App Store
- Consider creating a Progressive Web App (PWA) version instead

## 🔧 Configuration

### Firebase/Supabase Setup
1. **Update Configuration File**
   - Open `browser_extension/src/shared/firebase-config.js`
   - Replace placeholder values with your actual Firebase/Supabase credentials:

```javascript
const firebaseConfig = {
  apiKey: "your-actual-api-key",
  authDomain: "your-project.firebaseapp.com", 
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",
  appId: "your-app-id"
};
```

2. **OAuth Configuration**
   - Ensure your OAuth client ID matches your Flutter app
   - Add extension origin to authorized domains in Firebase/Supabase console

## ✅ Testing Your Extension

### Basic Functionality Test:
1. **Click Extension Icon** in browser toolbar
2. **Sign In** with Google (should match your Flutter app account)
3. **Add a Test Password** using the "+" button
4. **Search** for passwords using the search bar
5. **Test Auto-fill** on a login form

### Mobile Compatibility Test:
1. **Resize Browser Window** to mobile size (320px width)
2. **Check Touch Targets** - all buttons should be easily tappable
3. **Test Gestures** - scrolling, tapping, swiping should work smoothly
4. **Verify Responsive Layout** - UI should adapt to screen size

## 🚨 Troubleshooting

### Extension Won't Load:
```
❌ Error: "Manifest file is missing or unreadable"
✅ Solution: Ensure manifest.json exists in browser_extension folder
```

```
❌ Error: "Icons not found" 
✅ Solution: Generate and place all 4 icon sizes in icons/ folder
```

### Extension Loads But Doesn't Work:
```
❌ Issue: Popup shows blank screen
✅ Solution: Check browser console (F12) for JavaScript errors
```

```
❌ Issue: Can't sign in
✅ Solution: Update firebase-config.js with correct credentials
```

### Auto-fill Not Working:
```
❌ Issue: No auto-fill suggestions
✅ Solution: Check content script injection and website permissions
```

## 📋 File Checklist

Before loading extension, ensure these files exist:

```
browser_extension/
├── ✅ manifest.json
├── ✅ icons/
│   ├── ✅ icon-16.png
│   ├── ✅ icon-32.png  
│   ├── ✅ icon-48.png
│   └── ✅ icon-128.png
├── ✅ src/popup/popup.html
├── ✅ src/popup/popup.css
├── ✅ src/popup/popup.js
└── ✅ src/shared/firebase-config.js (configured)
```

## 🎯 Next Steps

1. **Test Extension** with your VaultMate Flutter app
2. **Sync Data** between extension and mobile app
3. **Test Auto-fill** on various websites
4. **Customize Settings** as needed
5. **Consider Publishing** to Chrome Web Store (optional)

## 📞 Support

If you encounter issues:
1. Check browser console for errors (F12 → Console)
2. Verify all files are in correct locations
3. Test in incognito mode to rule out conflicts
4. Ensure Firebase/Supabase credentials are correct

---

**🎉 Congratulations!** Your LinkCrypta browser extension should now be running and ready to sync with your VaultMate Flutter app!
