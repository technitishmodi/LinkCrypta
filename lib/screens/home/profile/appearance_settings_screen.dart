import 'package:flutter/material.dart';
import '../../../providers/theme_provider.dart';
import 'package:provider/provider.dart';

// Modern Light Blue Color Scheme from profile_screen.dart
class ModernColors {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
}

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() => _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  bool _isDarkMode = false;
  bool _useSystemTheme = true;
  double _textScaleFactor = 1.0;
  String _selectedColorScheme = 'Blue';

  @override
  void initState() {
    super.initState();
    // Initialize with current theme settings
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _isDarkMode = themeProvider.isDarkMode;
    _useSystemTheme = themeProvider.useSystemTheme;
    _textScaleFactor = themeProvider.textScaleFactor;
    _selectedColorScheme = themeProvider.colorScheme;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.white,
      appBar: AppBar(
        backgroundColor: ModernColors.white,
        elevation: 0,
        title: Text(
          'Appearance',
          style: TextStyle(
            color: ModernColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: ModernColors.textDark,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Theme'),
            
            // System Theme Toggle
            _buildSettingsSwitch(
              icon: Icons.brightness_auto,
              title: 'Use System Theme',
              subtitle: 'Automatically switch between light and dark mode',
              value: _useSystemTheme,
              onChanged: (value) {
                setState(() {
                  _useSystemTheme = value;
                });
                Provider.of<ThemeProvider>(context, listen: false)
                    .setUseSystemTheme(value);
              },
            ),
            
            // Dark Mode Toggle (only enabled if system theme is off)
            _buildSettingsSwitch(
              icon: Icons.dark_mode_rounded,
              title: 'Dark Mode',
              subtitle: 'Enable dark theme for the app',
              value: _isDarkMode,
              onChanged: _useSystemTheme ? null : (value) {
                setState(() {
                  _isDarkMode = value;
                });
                Provider.of<ThemeProvider>(context, listen: false)
                    .setDarkMode(value);
              },
            ),
            
            const SizedBox(height: 24),
            
            _buildSectionTitle('Color Scheme'),
            
            // Color Scheme Selection
            _buildColorSchemeSelector(),
            
            const SizedBox(height: 24),
            
            _buildSectionTitle('Text Size'),
            
            // Text Size Slider
            _buildTextSizeSlider(),
            
            const SizedBox(height: 24),
            
            _buildSectionTitle('Preview'),
            
            // Theme Preview
            _buildThemePreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ModernColors.textDark,
        ),
      ),
    );
  }

  Widget _buildSettingsSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: ModernColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.lightGrey,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ModernColors.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: ModernColors.primaryBlue,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ModernColors.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: ModernColors.textLight,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: ModernColors.primaryBlue,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildColorSchemeSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.lightGrey,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a color scheme for the app',
            style: TextStyle(
              fontSize: 16,
              color: ModernColors.textLight,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildColorOption('Blue', Color(0xFF2196F3)),
              _buildColorOption('Purple', Color(0xFF9C27B0)),
              _buildColorOption('Green', Color(0xFF4CAF50)),
              _buildColorOption('Orange', Color(0xFFFF9800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(String name, Color color) {
    final isSelected = _selectedColorScheme == name;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColorScheme = name;
        });
        Provider.of<ThemeProvider>(context, listen: false)
            .setColorScheme(name);
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : ModernColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSizeSlider() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.lightGrey,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Text Size',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ModernColors.textDark,
                ),
              ),
              Text(
                '${(_textScaleFactor * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ModernColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.text_decrease,
                color: ModernColors.textLight,
              ),
              Expanded(
                child: Slider(
                  value: _textScaleFactor,
                  min: 0.8,
                  max: 1.4,
                  divisions: 6,
                  activeColor: ModernColors.primaryBlue,
                  inactiveColor: ModernColors.lightGrey,
                  onChanged: (value) {
                    setState(() {
                      _textScaleFactor = value;
                    });
                    Provider.of<ThemeProvider>(context, listen: false)
                        .setTextScaleFactor(value);
                  },
                ),
              ),
              Icon(
                Icons.text_increase,
                color: ModernColors.textLight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemePreview() {
    final isDark = _useSystemTheme
        ? MediaQuery.of(context).platformBrightness == Brightness.dark
        : _isDarkMode;
    
    Color primaryColor;
    switch (_selectedColorScheme) {
      case 'Purple':
        primaryColor = Color(0xFF9C27B0);
        break;
      case 'Green':
        primaryColor = Color(0xFF4CAF50);
        break;
      case 'Orange':
        primaryColor = Color(0xFFFF9800);
        break;
      case 'Blue':
      default:
        primaryColor = Color(0xFF2196F3);
    }
    
    final backgroundColor = isDark ? Color(0xFF121212) : Colors.white;
    final cardColor = isDark ? Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Color(0xFF212121);
    final subtitleColor = isDark ? Color(0xFFBBBBBB) : Color(0xFF757575);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : ModernColors.lightGrey,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    size: 20,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sample Password Entry',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'Last updated: Today',
                        style: TextStyle(
                          fontSize: 14,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.star_border_rounded,
                  color: primaryColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: Size(double.infinity, 0),
            ),
            child: Text(
              'Sample Button',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}