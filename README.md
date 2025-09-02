# VaultMate 🔐

A secure, feature-rich password and link management application built with Flutter. VaultMate provides enterprise-grade security with an intuitive user interface, making password management effortless and secure.

## ✨ Features

### 🔒 Core Security
- **End-to-End Encryption**: All data encrypted using AES-256 encryption
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

### 🔗 Link Management
- **Secure Link Storage**: Store and organize important links
- **Category Organization**: Organize links by categories
- **Quick Access**: Fast search and retrieval
- **Encrypted Storage**: All links encrypted and secured

### 🎨 User Experience
- **Modern UI**: Beautiful, intuitive Material Design interface
- **Dark/Light Themes**: Customizable appearance
- **Smooth Animations**: Fluid transitions and interactions
- **Search & Filter**: Powerful search across all stored data
- **Export/Import**: Secure data backup and restore

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.8.1)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/vaultmate.git
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
├── models/           # Data models (Hive entities)
├── providers/        # State management (Provider pattern)
├── screens/          # UI screens and pages
│   ├── auth/        # Authentication screens
│   ├── home/        # Main app screens
│   └── onboarding/  # First-time user experience
├── services/         # Business logic and APIs
├── utils/           # Utilities and constants
└── widgets/         # Reusable UI components
```

### Key Services
- **EncryptionService**: Handles all encryption/decryption
- **StorageService**: Manages local data storage
- **AuthService**: Authentication and biometrics
- **PasswordHealthService**: Password analysis and security
- **AdvancedPasswordGenerator**: Password generation algorithms
- **SmartAutofillService**: Auto-fill functionality
- **AnalyticsService**: Usage analytics and insights
- **ActivityLogService**: Activity tracking and logging

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

### Firebase Setup (Optional)
For cloud backup and sync:
1. Create a Firebase project
2. Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
3. Enable Authentication and Firestore

## 📱 Usage

### First Time Setup
1. **Welcome Screen**: Introduction to VaultMate features
2. **Master Password**: Create a strong master password
3. **Biometric Setup**: Enable fingerprint/face recognition
4. **Import Data**: Optionally import existing passwords

### Adding Passwords
1. Tap the "+" button on the home screen
2. Enter website, username, and password
3. Use the built-in generator for strong passwords
4. Add notes and categories as needed

### Using Advanced Features
- **Health Dashboard**: Monitor password security from the main menu
- **Password Generator**: Access advanced generation options
- **Auto-fill**: Enable in settings for seamless form filling
- **Analytics**: View usage patterns and security insights

## 🛡️ Security

### Encryption
- **Algorithm**: AES-256-GCM encryption
- **Key Derivation**: PBKDF2 with salt
- **Storage**: Encrypted Hive boxes
- **Memory**: Secure memory handling

### Authentication
- **Master Password**: PBKDF2 hashed with salt
- **Biometric**: Platform-native biometric APIs
- **Session Management**: Automatic timeout and re-authentication

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
- `hive`: Local database
- `encrypt`: Encryption library
- `local_auth`: Biometric authentication
- `provider`: State management

### UI Dependencies
- `fl_chart`: Charts and analytics
- `google_fonts`: Typography
- `lottie`: Animations
- `shimmer`: Loading effects

### Utility Dependencies
- `http`: API requests
- `url_launcher`: External links
- `qr_flutter`: QR code generation
- `clipboard`: Clipboard operations

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter/Dart style guidelines
- Add tests for new features
- Update documentation
- Ensure security best practices

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Common Issues
- **Biometric not working**: Check device permissions and hardware support
- **Data not syncing**: Verify network connection and Firebase configuration
- **App crashes**: Check logs and ensure all dependencies are installed

### Getting Help
- 📧 Email: support@vaultmate.app
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/vaultmate/issues)
- 📖 Documentation: [Wiki](https://github.com/yourusername/vaultmate/wiki)

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
- **v1.0.0**: Initial release with core features
- **v1.1.0**: Advanced password generator
- **v1.2.0**: Health dashboard and analytics
- **v1.3.0**: Smart auto-fill functionality

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Hive team for local storage solution
- HaveIBeenPwned for breach detection API
- Material Design for UI guidelines
- Open source community for inspiration

---

**VaultMate** - Secure your digital life with confidence 🔐
