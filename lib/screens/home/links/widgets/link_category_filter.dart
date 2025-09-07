import 'package:flutter/material.dart';
import '../../../../utils/responsive.dart';

class LinkCategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final bool isDarkMode;
  final ValueChanged<String>? onCategorySelected;

  const LinkCategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.isDarkMode,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.length <= 1) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = ResponsiveBreakpoints.isTablet(context);
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    // Responsive layout based on screen size
    if (isDesktop && screenWidth > ResponsiveBreakpoints.largeDesktop) {
      // Large desktop: Use a wrap layout with more chips per row
      return _buildWrapLayout(context, maxItemsPerRow: 8);
    } else if (isDesktop) {
      // Desktop: Use a wrap layout with moderate chips per row
      return _buildWrapLayout(context, maxItemsPerRow: 6);
    } else if (isTablet) {
      // Tablet: Use a wrap layout with fewer chips per row
      return _buildWrapLayout(context, maxItemsPerRow: 4);
    } else {
      // Mobile: Use horizontal scrollable list
      return _buildHorizontalScrollLayout(context);
    }
  }

  Widget _buildHorizontalScrollLayout(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          
          return Container(
            margin: const EdgeInsets.only(right: 10),
            child: _buildFilterChip(category, isSelected, compact: true, context: context),
          );
        },
      ),
    );
  }

  Widget _buildWrapLayout(BuildContext context, {required int maxItemsPerRow}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveBreakpoints.isLargeDesktop(context) ? 24 : 16,
        vertical: ResponsiveBreakpoints.isDesktop(context) ? 16 : 12,
      ),
      child: Wrap(
        spacing: ResponsiveBreakpoints.isDesktop(context) ? 12 : 8,
        runSpacing: ResponsiveBreakpoints.isDesktop(context) ? 12 : 8,
        alignment: WrapAlignment.start,
        children: categories.map((category) {
          final isSelected = category == selectedCategory;
          return _buildFilterChip(category, isSelected, compact: false, context: context);
        }).toList(),
      ),
    );
  }

  Widget _buildFilterChip(String category, bool isSelected, {required bool compact, required BuildContext context}) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    
    return FilterChip(
      label: Text(
        category,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : isDarkMode 
                  ? Colors.grey[300] 
                  : const Color(0xFF1E293B),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          fontSize: compact ? 14 : (isDesktop ? 16 : 14),
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onCategorySelected?.call(category),
      backgroundColor: isDarkMode 
          ? const Color(0xFF1E293B) 
          : Colors.grey[100],
      selectedColor: const Color(0xFF3B82F6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(compact ? 5 : (isDesktop ? 8 : 6)),
        side: BorderSide(
          color: isDarkMode 
              ? const Color(0xFF334155) 
              : Colors.grey[300]!,
        ),
      ),
      elevation: isSelected ? 2 : 0,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : (isDesktop ? 20 : 16),
        vertical: compact ? 8 : (isDesktop ? 12 : 8),
      ),
    );
  }
}
