import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/constants.dart';
import 'passwords/passwords_screen.dart';
import 'links/links_screen.dart';
import 'favorites/favorites_screen.dart';
import 'advanced_features_screen.dart';
import 'profile/profile_screen.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _colors = {
    'primary': const Color(0xFF6C63FF),
    'secondary': const Color(0xFF4D8AF0),
    'accent': const Color(0xFFF7797D),
    'cardGradient1': const Color(0xFF667eea),
    'cardGradient2': const Color(0xFF764ba2),
    'cardGradient3': const Color(0xFFf093fb),
    'cardGradient4': const Color(0xFFf5576c),
  };

  final List<Widget> _screens = [
    const PasswordsScreen(),
    const LinksScreen(),
    const FavoritesScreen(),
    const AdvancedFeaturesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.animationMedium,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E293B),
                  ]
                : [
                    const Color(0xFFF8F9FA),
                    const Color(0xFFE3F2FD),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              _buildHeader(context, isDarkMode),
              
              // Main Content Area
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    children: _screens,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, isDarkMode),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        children: [
          // App Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    _colors['primary']!,
                    _colors['secondary']!,
                  ],
                ).createShader(bounds),
                child: const Text(
                  'LinkCrypta',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Row(
                children: [
                  _buildThemeToggleButton(isDarkMode),
                  const SizedBox(width: 12),
                  _buildHeaderButton(
                    icon: Icons.notifications_outlined,
                    onTap: () {},
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Stats Cards
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              return SizedBox(
                height: 80, // Fixed height to prevent overflow
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildStatCard(
                      title: 'Passwords',
                      value: dataProvider.passwords.length.toString(),
                      icon: Icons.lock_outline,
                      gradient: [_colors['cardGradient1']!, _colors['cardGradient2']!],
                    ),
                    const SizedBox(width: 8),
                    _buildStatCard(
                      title: 'Links',
                      value: dataProvider.links.length.toString(),
                      icon: Icons.link,
                      gradient: [_colors['cardGradient3']!, _colors['cardGradient4']!],
                    ),
                    const SizedBox(width: 8),
                    _buildStatCard(
                      title: 'Favorites',
                      value: (dataProvider.passwords.where((p) => p.isFavorite).length +
                              dataProvider.links.where((l) => l.isFavorite).length).toString(),
                      icon: Icons.favorite_border,
                      gradient: [_colors['accent']!, _colors['primary']!],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggleButton(bool isDarkMode) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.white : _colors['primary'],
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        );
      },
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: isDarkMode ? Colors.white : _colors['primary']),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: Colors.white),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDarkMode ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.lock_outline, 'Passwords', isDarkMode),
                _buildNavItem(1, Icons.link, 'Links', isDarkMode),
                _buildNavItem(2, Icons.favorite_border, 'Favorites', isDarkMode),
                _buildNavItem(3, Icons.security, 'Advanced', isDarkMode),
                _buildNavItem(4, Icons.person_outline, 'Profile', isDarkMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDarkMode) {
    final isActive = _currentIndex == index;
    final activeColor = _colors['primary']!;
    final inactiveColor = isDarkMode ? Colors.white70 : Colors.grey;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? activeColor.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? activeColor : inactiveColor,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    
    setState(() {
      _currentIndex = index;
    });
    
    _animationController.reset();
    _pageController.animateToPage(
      index,
      duration: AppConstants.animationFast,
      curve: Curves.easeInOut,
    ).then((_) {
      _animationController.forward();
    });
  }
}