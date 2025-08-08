# VaultMate

A secure password and link management app built with Flutter.

## Features

- **Password Management**: Store and manage passwords securely
- **Link Management**: Save and organize important links
- **Favorites**: Mark passwords and links as favorites for quick access
- **Search & Filter**: Find items quickly with search and category filtering
- **Secure Storage**: All data is encrypted and stored locally
- **Modern UI**: Beautiful Material Design 3 interface

## Getting Started

### Prerequisites

- Flutter SDK (3.8.0 or higher)
- Dart SDK (3.8.0 or higher)

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

### Code Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── providers/                # State management
├── screens/                  # UI screens
├── services/                 # Business logic
├── utils/                    # Utilities and constants
└── widgets/                  # Reusable widgets
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
