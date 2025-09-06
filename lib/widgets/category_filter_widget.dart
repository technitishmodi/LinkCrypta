import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CategoryFilterWidget extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const CategoryFilterWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          
          return Container(
            margin: const EdgeInsets.only(right: AppConstants.spacingS),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => onCategoryChanged(category),
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedColor: AppConstants.primaryColor.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected
                    ? AppConstants.primaryColor
                    : Theme.of(context).colorScheme.onSurface,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppConstants.primaryColor
                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
          );
        },
      ),
    );
  }
} 