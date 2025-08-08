import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Preference keys
  static const String _themeKey = 'theme_mode';
  static const String _useSystemThemeKey = 'use_system_theme';
  static const String _colorSchemeKey = 'color_scheme';
  static const String _textScaleFactorKey = 'text_scale_factor';
  
  // Default values
  ThemeMode _themeMode = ThemeMode.system;
  bool _useSystemTheme = true;
  String _colorScheme = 'Blue';
  double _textScaleFactor = 1.0;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get useSystemTheme => _useSystemTheme;
  String get colorScheme => _colorScheme;
  double get textScaleFactor => _textScaleFactor;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load theme mode
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    
    // Load system theme preference
    _useSystemTheme = prefs.getBool(_useSystemThemeKey) ?? true;
    
    // Load color scheme
    _colorScheme = prefs.getString(_colorSchemeKey) ?? 'Blue';
    
    // Load text scale factor
    _textScaleFactor = prefs.getDouble(_textScaleFactorKey) ?? 1.0;
    
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setUseSystemTheme(bool value) async {
    if (_useSystemTheme == value) return;
    
    _useSystemTheme = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useSystemThemeKey, value);
    
    // If system theme is enabled, update theme mode to system
    if (value) {
      await setThemeMode(ThemeMode.system);
    }
    
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    if (_useSystemTheme) return; // Don't change if system theme is enabled
    
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  Future<void> setColorScheme(String colorScheme) async {
    if (_colorScheme == colorScheme) return;
    
    _colorScheme = colorScheme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_colorSchemeKey, colorScheme);
    notifyListeners();
  }

  Future<void> setTextScaleFactor(double factor) async {
    if (_textScaleFactor == factor) return;
    
    _textScaleFactor = factor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleFactorKey, factor);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_useSystemTheme) {
      // If system theme is enabled, disable it first
      await setUseSystemTheme(false);
    }
    
    final newMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await setThemeMode(newMode);
  }

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  // Get primary color based on selected color scheme
  Color getPrimaryColor() {
    switch (_colorScheme) {
      case 'Purple':
        return const Color(0xFF9C27B0);
      case 'Green':
        return const Color(0xFF4CAF50);
      case 'Orange':
        return const Color(0xFFFF9800);
      case 'Blue':
      default:
        return const Color(0xFF2196F3);
    }
  }
}