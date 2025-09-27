# Android Autofill Framework Implementation

## Overview
LinkCrypta now supports Android's Autofill Framework, providing system-level autofill capabilities across all Android apps and websites.

## Features
- **Automatic credential detection**: Detects login forms in any Android app
- **Smart password saving**: Shows popup to save new credentials automatically
- **System-level autofill**: Works across all apps, not just browsers
- **Secure integration**: Uses existing Hive encryption and storage

## Setup Instructions

### 1. Enable Autofill Service
1. Open LinkCrypta app
2. Go to Advanced Features → Autofill Framework
3. Tap "Open Autofill Settings"
4. Select "LinkCrypta" from the list
5. Toggle the switch to enable

### 2. Grant Permissions
The app will request autofill permissions automatically when first used.

## How It Works

### Saving Passwords
1. When you log into any app, LinkCrypta detects the credentials
2. A popup appears asking if you want to save the password
3. Fill in account details and tap "Save Password"
4. Credentials are encrypted and stored securely

### Using Autofill
1. Open any app with a login form
2. Tap on username/password fields
3. Select "LinkCrypta" from autofill suggestions
4. Choose the appropriate account
5. Credentials are filled automatically

## Technical Implementation

### Key Components
- `AutofillService.kt`: Android autofill service implementation
- `AutofillFrameworkService.dart`: Flutter service for platform communication
- `SaveCredentialsDialog.dart`: UI for saving new credentials
- `AutofillFrameworkScreen.dart`: Settings and management UI

### Security
- All passwords encrypted with AES-256
- Local storage only (no cloud sync required)
- Biometric authentication support
- Secure platform channel communication

## Troubleshooting

### Autofill Not Working
1. Check if service is enabled in Android Settings
2. Verify app has autofill permissions
3. Restart the app if needed

### Save Dialog Not Appearing
1. Ensure autofill service is active
2. Check that form fields are properly detected
3. Try logging in again

## Compatibility
- Android 8.0+ (API 26+)
- Works with all Android apps
- Supports web browsers and native apps
