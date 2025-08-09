# VaultMate - Secure Password Manager

<p align="center">
  <img src="assets/icons/google_logo.svg" alt="VaultMate Logo" width="100" height="100">
</p>

A secure password and link management app built with Flutter, featuring military-grade encryption and a modern, intuitive user interface.

## Features

### Security
- **AES-256 Encryption**: All your passwords are encrypted using industry-standard AES-256 encryption
- **Biometric Authentication**: Unlock your vault using fingerprint or face recognition (where available)
- **PIN Protection**: Secure access with a custom PIN code
- **Local Storage**: Your data never leaves your device unless you explicitly choose to back it up

### Password Management
- **Secure Storage**: Store unlimited passwords with associated usernames, URLs, and notes
- **Categories**: Organize passwords by custom categories
- **Search & Filter**: Quickly find credentials with powerful search and filtering options
- **Password Generator**: Create strong, unique passwords with customizable parameters
- **Auto-Fill**: Copy passwords with a single tap for easy use

### Link Management
- **Bookmark Storage**: Save and organize important links
- **Quick Access**: Open saved links directly from the app

### User Experience
- **Modern UI**: Clean, intuitive interface with smooth animations
- **Dark Mode**: Choose between light and dark themes
- **Customization**: Personalize your experience with theme colors and text scaling
- **Favorites**: Mark frequently used credentials for quick access

## Getting Started

### Prerequisites

- Flutter SDK (^3.8.1)
- Dart SDK (^3.8.1)
- Android Studio / VS Code with Flutter extensions

### Screenshots

*Coming soon*

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate Hive adapters:
   ```bash
   dart run build_runner build
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Development

### Hot Reload

The app is configured for hot reload. After making changes to the code:

1. Save the file
2. Press `r` in the terminal to hot reload
3. Press `R` to hot restart if needed

### Architecture

VaultMate follows a provider-based architecture for state management:

```
lib/
|-- main.dart                 # App entry point
|-- models/                   # Data models for passwords, links, and user information
|   |-- password_entry.dart   # Password data structure
|   |-- link_entry.dart       # Link data structure
|   `-- user.dart             # User profile data
|-- providers/                # State management using Provider package
|   |-- data_provider.dart    # Manages password and link data
|   `-- theme_provider.dart   # Handles theme and appearance settings
|-- screens/                  # UI screens organized by feature
|   |-- auth/                 # Authentication screens
|   |-- home/                 # Main app screens (passwords, links, favorites, profile)
|   |-- onboarding/           # First-time user experience
|   `-- splash_screen.dart    # App loading screen
|-- services/                 # Core functionality
|   |-- auth_service.dart     # Authentication and biometrics
|   |-- encryption_service.dart # AES-256 encryption implementation
|   |-- onboarding_service.dart # First-time setup
|   `-- storage_service.dart  # Local data persistence
|-- utils/                    # Helper functions and constants
|   |-- constants.dart        # App-wide constants
|   `-- helpers.dart          # Utility functions
`-- widgets/                  # Reusable UI components
    |-- category_filter_widget.dart # Category filtering
    |-- password_card.dart    # Password item display
    `-- search_bar_widget.dart # Search functionality
```

## Troubleshooting

### Common Issues

1. **setState() called during build**: Fixed by using `WidgetsBinding.instance.addPostFrameCallback`
2. **Hot reload not working**: Ensure all dependencies are properly installed
3. **Hive adapter errors**: Run `dart run build_runner build` to regenerate adapters

### Build Issues

If you encounter build issues:

1. Clean the project:
   ```bash
   flutter clean
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Regenerate adapters:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

## Security

- All sensitive data is encrypted using AES-256
- Encryption keys are stored securely using Flutter Secure Storage
- No data is transmitted to external servers
- All data is stored locally on the device

## Dependencies

VaultMate relies on the following key packages:

### Security & Storage
- **flutter_secure_storage**: Securely store encryption keys
- **local_auth**: Handle biometric authentication
- **hive & hive_flutter**: Fast, secure local database
- **encrypt**: AES-256 encryption implementation
- **crypto**: Cryptographic functions

### UI & Experience
- **provider**: State management
- **flutter_slidable**: Swipeable list items
- **flutter_staggered_animations**: UI animations
- **shimmer**: Loading effect animations
- **flutter_svg**: SVG image rendering

### Utilities
- **uuid**: Generate unique identifiers
- **clipboard**: Copy to clipboard functionality
- **url_launcher**: Open URLs in browser
- **qr_flutter**: Generate QR codes
- **permission_handler**: Manage system permissions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

<p align="center">Made with love for secure password management</p>
