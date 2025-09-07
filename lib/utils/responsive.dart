import 'package:flutter/material.dart';

/// Responsive breakpoints and utilities for different screen sizes
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
  static const double largeDesktop = 1920;
  
  static bool isMobile(BuildContext context) => 
    MediaQuery.of(context).size.width < mobile;
  
  static bool isTablet(BuildContext context) => 
    MediaQuery.of(context).size.width >= mobile && 
    MediaQuery.of(context).size.width < desktop;
  
  static bool isDesktop(BuildContext context) => 
    MediaQuery.of(context).size.width >= desktop;
    
  static bool isLargeDesktop(BuildContext context) => 
    MediaQuery.of(context).size.width >= largeDesktop;
    
  /// Get responsive value based on screen size
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    if (isLargeDesktop(context) && largeDesktop != null) return largeDesktop;
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }
  
  /// Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
    EdgeInsets? largeDesktop,
  }) {
    return responsive<EdgeInsets>(
      context,
      mobile: mobile ?? const EdgeInsets.all(16),
      tablet: tablet ?? const EdgeInsets.all(20),
      desktop: desktop ?? const EdgeInsets.all(24),
      largeDesktop: largeDesktop ?? const EdgeInsets.all(32),
    );
  }
  
  /// Get responsive font size
  static double responsiveFontSize(BuildContext context, {
    double mobile = 14,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    return responsive<double>(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile + 2,
      desktop: desktop ?? mobile + 4,
      largeDesktop: largeDesktop ?? mobile + 6,
    );
  }
  
  /// Get responsive columns for grid layouts
  static int responsiveColumns(BuildContext context, {
    int mobile = 1,
    int? tablet,
    int? desktop,
    int? largeDesktop,
  }) {
    return responsive<int>(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 2,
      desktop: desktop ?? mobile * 3,
      largeDesktop: largeDesktop ?? mobile * 4,
    );
  }
}

/// Responsive Builder Widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;
  
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });
  
  @override
  Widget build(BuildContext context) {
    return ResponsiveBreakpoints.responsive<Widget>(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile,
      desktop: desktop ?? tablet ?? mobile,
      largeDesktop: largeDesktop ?? desktop ?? tablet ?? mobile,
    );
  }
}

/// Responsive Layout Widget for complex responsive layouts
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;
  final bool centerContent;
  
  const ResponsiveLayout({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
    this.centerContent = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final responsivePadding = padding ?? ResponsiveBreakpoints.responsivePadding(context);
    final screenMaxWidth = maxWidth ?? ResponsiveBreakpoints.responsive<double>(
      context,
      mobile: double.infinity,
      tablet: 800,
      desktop: 1200,
      largeDesktop: 1400,
    );
    
    Widget content = Container(
      constraints: BoxConstraints(maxWidth: screenMaxWidth),
      padding: responsivePadding,
      child: child,
    );
    
    if (centerContent && ResponsiveBreakpoints.isDesktop(context)) {
      content = Center(child: content);
    }
    
    return content;
  }
}

/// Grid responsive configuration
class ResponsiveGridConfig {
  final int columns;
  final double spacing;
  final double runSpacing;
  final double childAspectRatio;
  
  const ResponsiveGridConfig({
    required this.columns,
    this.spacing = 16,
    this.runSpacing = 16,
    this.childAspectRatio = 1.0,
  });
  
  static ResponsiveGridConfig adaptive(BuildContext context, {
    int mobileColumns = 1,
    int? tabletColumns,
    int? desktopColumns,
    int? largeDesktopColumns,
    double spacing = 16,
    double runSpacing = 16,
    double childAspectRatio = 1.0,
  }) {
    final columns = ResponsiveBreakpoints.responsive<int>(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns ?? mobileColumns * 2,
      desktop: desktopColumns ?? mobileColumns * 3,
      largeDesktop: largeDesktopColumns ?? mobileColumns * 4,
    );
    
    return ResponsiveGridConfig(
      columns: columns,
      spacing: spacing,
      runSpacing: runSpacing,
      childAspectRatio: childAspectRatio,
    );
  }
}
