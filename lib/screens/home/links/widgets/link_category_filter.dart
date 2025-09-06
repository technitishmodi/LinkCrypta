import 'package:flutter/material.dart';

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

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isDarkMode 
                          ? Colors.grey[300] 
                          : const Color(0xFF1E293B),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onCategorySelected?.call(category),
              backgroundColor: isDarkMode 
                  ? const Color(0xFF1E293B) 
                  : Colors.grey[100],
              selectedColor: const Color(0xFF3B82F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isDarkMode 
                      ? const Color(0xFF334155) 
                      : Colors.grey[300]!,
                ),
              ),
              elevation: isSelected ? 2 : 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        },
      ),
    );
  }
}
