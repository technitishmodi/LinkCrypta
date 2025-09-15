# LinkCrypta ��🔐

A secure, feature-rich password and link management application built with Flutter. LinkCrypta provides enterprise-grade security with an intuitive user interface, making password and link management effortless and secure.

## ✨ Features

### 🔒 Core Security
- **End-to-End Encryption**: All data encrypted using AES-256 encryption
- **Firebase Authentication**: Secure user authentication with Google Sign-In
- **Biometric Authentication**: Fingerprint and face recognition support
- **Secure Storage**: Local storage using Hive with encryption
- **Master Password Protection**: Single master password for all your data
- **Auto-lock**: Automatic app locking after inactivity

### 📊 Password Health Dashboard
- **Password Strength Analysis**: Real-time strength scoring and recommendations
- **Duplicate Detection**: Identify and manage duplicate passwords
- **Compromised Password Checking**: Integration with HaveIBeenPwned API
- **Security Insights**: Interactive charts and security metrics
- **Health Score**: Overall password security rating

### 🎲 Advanced Password Generator
- **Multiple Generation Types**:
  - Random passwords with customizable complexity
  - Pronounceable passwords for easy memorization
  - Passphrase generation with word combinations
  - Custom pattern-based generation
- **Real-time Strength Analysis**: Instant feedback on password strength
- **Entropy Calculation**: Mathematical strength measurement
- **Bulk Generation**: Generate multiple passwords at once
- **Customizable Options**: Length, character sets, exclusions

### 🌐 Smart Auto-Fill & Browser Integration
- **URL Matching**: Intelligent website matching with confidence scoring
- **Form Field Detection**: Automatic categorization of login forms
- **Auto-fill Suggestions**: Smart suggestions based on context
- **Clipboard Integration**: Secure copy-paste functionality
- **Subdomain Support**: Matches related domains automatically

### 📈 Data Analytics & Insights
- **Usage Patterns**: Track password usage and access patterns
- **Security Trends**: Monitor security improvements over time
- **Activity Timeline**: Detailed log of all password activities
- **Password Distribution**: Visual breakdown of password strengths
- **Breach Monitoring**: Alerts for compromised accounts

### 🔗 Smart Link Management
- **Secure Link Storage**: Store and organize important links with encryption
- **Category Organization**: Organize links by customizable categories
- **Quick Access**: Fast search and retrieval with intelligent filtering
- **URL Preview**: Smart link previews and metadata extraction
- **Responsive Design**: Optimized for mobile, tablet, and desktop
- **Favorite Links**: Mark important links for quick access

### 🎨 User Experience
- **Modern Material Design**: Beautiful, intuitive Material 3 design system
- **Responsive Layout**: Optimized for mobile, tablet, and desktop devices
- **Dark/Light Themes**: Customizable appearance with system theme support
- **Smooth Animations**: Fluid transitions and micro-interactions
- **Advanced Search**: Powerful search across passwords and links
- **Export/Import**: Secure data backup and restore functionality

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.8.1)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/technitishmodi/vaultmate.git
   cd vaultmate
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate model files**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Platform Setup

#### Android
- Minimum SDK: 21
- Target SDK: 34
- Permissions: Biometric, Internet (for breach checking)

#### iOS
- iOS 12.0+
- Biometric permissions configured
- Network permissions for API calls

#### Windows/Linux/macOS
- Desktop support enabled
- Local authentication configured

## 🏗️ Architecture

### Project Structure
```
lib/
├── models/           # Data models (Hive entities, Password/Link entries)
├── providers/        # State management (Provider pattern)
│   ├── data_provider.dart      # Main app state and data
│   └── theme_provider.dart     # Theme and appearance settings
├── screens/          # UI screens and pages
│   ├── auth/        # Authentication screens (login, signup)
│   ├── home/        # Main app screens
│   │   ├── passwords/   # Password management screens
│   │   ├── links/       # Link management screens
│   │   ├── favorites/   # Favorites screen
│   │   └── profile/     # User profile and settings
│   ├── onboarding/  # First-time user experience
│   └── splash_screen.dart # App launch screen
├── services/         # Business logic and APIs
│   ├── advanced_password_generator.dart
│   ├── auth_service.dart
│   ├── password_health_service.dart
│   └── smart_autofill_service.dart
├── utils/           # Utilities, constants, and helpers
│   ├── responsive.dart     # Responsive design utilities
│   ├── constants.dart      # App constants
│   └── helpers.dart        # Utility functions
└── widgets/         # Reusable UI components
    ├── password_card.dart
    ├── link_card.dart
    └── custom_widgets.dart
```

### Key Services
- **AuthService**: Firebase authentication and biometric login
- **AdvancedPasswordGenerator**: Multi-type password generation algorithms
- **PasswordHealthService**: Password analysis and security scoring
- **SmartAutofillService**: Intelligent form filling functionality
- **AnalyticsService**: Usage analytics and security insights
- **DataProvider**: Main app state management and data persistence

### State Management
- **Provider Pattern**: Reactive state management
- **DataProvider**: Main app state and data
- **ThemeProvider**: Theme and appearance settings

## 🔧 Configuration

### Environment Setup
Create a `.env` file in the root directory:
```env
HAVEIBEENPWNED_API_KEY=your_api_key_here
ENCRYPTION_KEY=your_encryption_key
```

### Firebase Setup
LinkCrypta uses Firebase for authentication and cloud storage:
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
3. Enable Authentication with Google Sign-In
4. Enable Firestore Database for cloud storage
5. Configure authentication settings in the Firebase console

## 📱 Usage

### First Time Setup
1. **Splash Screen**: LinkCrypta welcome screen
2. **Authentication**: Sign in with Google or create account
3. **Biometric Setup**: Enable fingerprint/face recognition (optional)
4. **Tutorial**: Interactive guide through main features

### Adding Passwords
1. Navigate to the Passwords tab
2. Tap the "+" button to add new password
3. Enter website, username, and password details
4. Use the advanced generator for strong passwords
5. Categorize and add notes as needed
6. Save securely to encrypted storage

### Managing Links
1. Go to the Links tab
2. Add new links with URL and description
3. Organize by custom categories
4. Use quick search to find links
5. Mark favorites for easy access

### Using Advanced Features
- **Health Dashboard**: Monitor password security from the analytics tab
- **Advanced Password Generator**: Access 4 generation types (Random, Pronounceable, Passphrase, Pattern)
- **Smart Auto-fill**: Enable in settings for seamless form filling
- **Responsive Design**: Works perfectly on mobile, tablet, and desktop
- **Categories**: Organize passwords and links with custom categories

## 🛡️ Security

### Encryption
- **Algorithm**: AES-256-GCM encryption
- **Key Derivation**: PBKDF2 with salt
- **Storage**: Encrypted Hive boxes
- **Memory**: Secure memory handling

### Authentication
- **Firebase Auth**: Secure Google Sign-In integration
- **Biometric**: Platform-native biometric APIs (fingerprint, face ID)
- **Session Management**: Automatic timeout and re-authentication
- **Secure Token Handling**: JWT tokens with automatic refresh

### Privacy
- **Local Storage**: All data stored locally by default
- **No Tracking**: No user analytics or tracking
- **Open Source**: Transparent security implementation

## 🧪 Testing

Run tests with:
```bash
flutter test
```

For integration tests:
```bash
flutter drive --target=test_driver/app.dart
```

## 📦 Dependencies

### Core Dependencies
- `flutter`: UI framework
- `hive`: Local database with encryption
- `encrypt`: Encryption library for data security
- `local_auth`: Biometric authentication
- `provider`: State management
- `firebase_core`: Firebase integration
- `firebase_auth`: Authentication services
- `cloud_firestore`: Cloud database
- `google_sign_in`: Google authentication

### UI Dependencies
- `fl_chart`: Charts and analytics visualization
- `google_fonts`: Typography and custom fonts
- `lottie`: Smooth animations and micro-interactions
- `shimmer`: Loading effects and placeholders
- `flutter_staggered_animations`: List animations
- `smooth_page_indicator`: Page indicators

### Utility Dependencies
- `http`: API requests and network calls
- `url_launcher`: External link handling
- `qr_flutter`: QR code generation for sharing
- `clipboard`: Secure clipboard operations
- `file_picker`: File selection and import
- `permission_handler`: Device permissions
- `flutter_secure_storage`: Secure local storage

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request to the main repository

### Development Guidelines
- Follow Flutter/Dart style guidelines
- Add tests for new features
- Update documentation
- Ensure security best practices

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Getting Help
- 📧 Email: support@linkcrypta.app
- 🐛 Issues: [GitHub Issues](https://github.com/technitishmodi/vaultmate/issues)
- 📖 Documentation: [Wiki](https://github.com/technitishmodi/vaultmate/wiki)
- 💬 Discussions: [GitHub Discussions](https://github.com/technitishmodi/vaultmate/discussions)

## 🚧 Roadmap

### Upcoming Features
- [ ] Cloud synchronization
- [ ] Team sharing capabilities
- [ ] Browser extensions
- [ ] Two-factor authentication
- [ ] Secure notes
- [ ] Password sharing
- [ ] Advanced breach monitoring

### Version History
- **v1.0.0**: Initial release with core password and link management
- **v1.0.1**: Advanced password generator with 4 generation types
- **v1.0.2**: Responsive design for mobile, tablet, and desktop
- **v1.0.3**: Firebase integration and Google authentication
- **v1.0.4**: Enhanced UI with Material 3 design system

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Hive team for local storage solution
- HaveIBeenPwned for breach detection API
- Material Design for UI guidelines
- Open source community for inspiration

---

**LinkCrypta** - Secure your digital life with confidence 🔗🔐