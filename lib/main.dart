import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/data_provider.dart';
import 'providers/theme_provider.dart';
import 'services/encryption_service.dart';
import 'services/storage_service.dart';
import 'services/activity_log_service.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/profile/privacy_policy_screen.dart';
import 'screens/home/profile/terms_of_service_screen.dart';
import 'screens/home/profile/about_screen.dart';
import 'screens/home/profile/appearance_settings_screen.dart';
import 'utils/constants.dart';
import 'utils/googlesign.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase initialization removed
  
  try {
    // Initialize Hive
    await Hive.initFlutter();

    await Supabase.initialize(
      url: 'https://vbiztcbdutitmvbxozmz.supabase.co',
      anonKey: 
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZiaXp0Y2JkdXRpdG12Ynhvem16Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU1Mjc4ODksImV4cCI6MjA3MTEwMzg4OX0.6ZIH5I5CQiH3iVmWLKbW9IXWaRuwchYfccGheOJtLe8',
    );
    
    // Initialize services
    await GoogleSignInService.initialize();
    await EncryptionService.initialize();
    await StorageService.initialize();
    await ActivityLogService.initialize();
    
    runApp(const VaultMateApp());
  } catch (e) {
    print('Error initializing app: $e');
    // Still run the app even if services fail to initialize
    runApp(const VaultMateApp());
  }
}

class VaultMateApp extends StatelessWidget {
  const VaultMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // Get the base themes
          final lightTheme = _buildLightTheme();
          final darkTheme = _buildDarkTheme();
          
          // Apply color scheme and text scale factor
          final Color primaryColor = themeProvider.getPrimaryColor();
          final textScaleFactor = themeProvider.textScaleFactor;
          
          // Create modified light theme
          final modifiedLightTheme = lightTheme.copyWith(
            colorScheme: lightTheme.colorScheme.copyWith(
              primary: primaryColor,
              secondary: primaryColor.withOpacity(0.8),
              tertiary: primaryColor.withOpacity(0.6),
            ),
            textTheme: lightTheme.textTheme,
          );
          
          // Create modified dark theme
          final modifiedDarkTheme = darkTheme.copyWith(
            colorScheme: darkTheme.colorScheme.copyWith(
              primary: primaryColor,
              secondary: primaryColor.withOpacity(0.8),
              tertiary: primaryColor.withOpacity(0.6),
            ),
            textTheme: darkTheme.textTheme,
          );
          
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: modifiedLightTheme,
            darkTheme: modifiedDarkTheme,
            themeMode: themeProvider.themeMode,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/home': (context) => const HomeScreen(),
          '/privacy-policy': (context) => const PrivacyPolicyScreen(),
          '/terms-of-service': (context) => const TermsOfServiceScreen(),
          '/about': (context) => const AboutScreen(),
          '/appearance': (context) => const AppearanceSettingsScreen(),
        },
      );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.light,
        background: AppConstants.backgroundColor,
        surface: AppConstants.surfaceColor,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppConstants.primaryColor,
        titleTextStyle: AppConstants.titleLarge.copyWith(
          color: AppConstants.primaryColor,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.dark,
        background: const Color(0xFF0F172A),
        surface: const Color(0xFF1E293B),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: AppConstants.titleLarge.copyWith(
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        color: const Color(0xFF1E293B),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade900,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
