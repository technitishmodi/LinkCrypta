import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../../../utils/constants.dart';
import '../../../providers/data_provider.dart';
import '../../../models/link_entry.dart';
import '../../../services/storage_service.dart';
import '../../../providers/theme_provider.dart';
import 'package:flutter/services.dart';

class LinksScreen extends StatefulWidget {
  const LinksScreen({super.key});

  @override
  State<LinksScreen> createState() => _LinksScreenState();
}

class _LinksScreenState extends State<LinksScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _isSearchVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
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
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: isDarkMode 
          ? const Color(0xFF0F172A) 
          : colorScheme.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showAddLinkDialog(context);
        },
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: isDarkMode ? 2 : 4,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(Icons.add_rounded, size: 24),
        label: Text(
          'Add Link',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        heroTag: 'add_link_fab',
      ),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: isDarkMode 
            ? const Color(0xFF1E293B) 
            : colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        title: _isSearchVisible
            ? _buildSearchField()
            : FadeTransition(
                opacity: _fadeAnimation,
                child: Row(
                  children: [
                    Icon(
                      Icons.link_rounded,
                      color: isDarkMode ? Colors.white : colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Links',
                      style: AppConstants.titleLarge.copyWith(
                        color: isDarkMode ? Colors.white : colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
        actions: [
          if (!_isSearchVisible) ...[            
            IconButton(
              icon: Icon(
                Icons.search_rounded,
                color: isDarkMode ? Colors.white70 : colorScheme.primary,
              ),
              tooltip: 'Search links',
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _isSearchVisible = true);
              },
              style: IconButton.styleFrom(
                foregroundColor: colorScheme.primary,
                backgroundColor: isDarkMode 
                    ? Colors.white.withOpacity(0.05) 
                    : colorScheme.primaryContainer.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                Icons.add_rounded,
                color: isDarkMode ? Colors.white70 : colorScheme.primary,
              ),
              tooltip: 'Add new link',
              onPressed: () {
                HapticFeedback.mediumImpact();
                _showAddLinkDialog(context);
              },
              style: IconButton.styleFrom(
                foregroundColor: colorScheme.primary,
                backgroundColor: isDarkMode 
                    ? Colors.white.withOpacity(0.05) 
                    : colorScheme.primaryContainer.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: isDarkMode ? Colors.white70 : colorScheme.primary,
              ),
              tooltip: 'Refresh links',
              onPressed: () {
                HapticFeedback.lightImpact();
                context.read<DataProvider>().setSearchQuery('');
                context.read<DataProvider>().setSelectedLinkCategory('All');
                context.read<DataProvider>().loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.refresh_rounded, color: colorScheme.onPrimaryContainer, size: 18),
                        const SizedBox(width: 8),
                        const Text('Links refreshed'),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: colorScheme.primaryContainer,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              style: IconButton.styleFrom(
                foregroundColor: colorScheme.primary,
                backgroundColor: isDarkMode 
                    ? Colors.white.withOpacity(0.05) 
                    : colorScheme.primaryContainer.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: isDarkMode ? Colors.white70 : colorScheme.primary,
              ),
              tooltip: 'More options',
              onSelected: (value) {
                if (value == 'clear') {
                  HapticFeedback.mediumImpact();
                  _showClearConfirmationDialog(context, isDarkMode, colorScheme);
                }
              },
              position: PopupMenuPosition.under,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: isDarkMode ? const Color(0xFF1E293B) : colorScheme.surface,
              elevation: 3,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep_rounded, color: colorScheme.error, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Clear all links', 
                        style: TextStyle(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[            
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: isDarkMode ? Colors.white70 : colorScheme.primary,
              ),
              tooltip: 'Cancel search',
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _isSearchVisible = false;
                  _searchController.clear();
                });
                context.read<DataProvider>().setSearchQuery('');
              },
              style: IconButton.styleFrom(
                foregroundColor: colorScheme.primary,
                backgroundColor: isDarkMode 
                    ? Colors.white.withOpacity(0.05) 
                    : colorScheme.primaryContainer.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ],
      ),
             body: Consumer<DataProvider>(
         builder: (context, dataProvider, child) {
           final links = dataProvider.links;
           print('Links screen: Building with ${links.length} filtered links');
           print('Links screen: Search query: "${dataProvider.searchQuery}"');
           print('Links screen: Selected category: "${dataProvider.selectedLinkCategory}"');
           
           if (links.isEmpty) {
             return _buildEmptyState(context, isDarkMode);
           }

          return Column(
            children: [
              _buildCategoryFilter(dataProvider, isDarkMode),
              Expanded(
                child: _buildLinksList(links, isDarkMode),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    final theme = Theme.of(context);
    final isDarkMode = context.read<ThemeProvider>().isDarkMode;
    final colorScheme = theme.colorScheme;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.grey.shade800.withOpacity(0.3) 
            : colorScheme.surfaceContainerHighest.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode 
              ? Colors.grey.shade700 
              : colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search links...',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          hintStyle: AppConstants.bodyMedium.copyWith(
            color: isDarkMode ? Colors.grey.shade400 : colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
          prefixIcon: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.search_rounded,
              color: isDarkMode ? Colors.grey.shade400 : colorScheme.primary.withOpacity(0.7),
              size: 20,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.clear_rounded,
              color: isDarkMode ? Colors.grey.shade400 : colorScheme.primary,
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              _searchController.clear();
              context.read<DataProvider>().setSearchQuery('');
              setState(() => _isSearchVisible = false);
            },
            tooltip: 'Clear search',
            style: IconButton.styleFrom(
              foregroundColor: colorScheme.primary,
              backgroundColor: isDarkMode 
                  ? Colors.grey.shade800.withOpacity(0.3) 
                  : colorScheme.surfaceContainerHighest.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        style: AppConstants.bodyLarge.copyWith(
          color: isDarkMode ? Colors.white : colorScheme.onSurface,
        ),
        onChanged: (value) {
          context.read<DataProvider>().setSearchQuery(value);
        },
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            HapticFeedback.selectionClick();
          }
        },
      ),
    );
  }

  Widget _buildCategoryFilter(DataProvider dataProvider, bool isDarkMode) {
    final categories = dataProvider.linkCategories;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? const Color(0xFF1E293B).withOpacity(0.7) 
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected 
                    ? Colors.white 
                    : (isDarkMode ? Colors.white70 : AppConstants.primaryColor),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (selected) {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = category);
                dataProvider.setSelectedLinkCategory(category);
              },
              backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
              selectedColor: AppConstants.primaryColor,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected 
                  ? AppConstants.primaryColor 
                  : (isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              elevation: isSelected ? 1 : 0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLinksList(List<LinkEntry> links, bool isDarkMode) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ListView.builder(
        key: ValueKey<int>(links.length),
        padding: const EdgeInsets.all(16),
        itemCount: links.length,
        itemBuilder: (context, index) {
          final link = links[index];
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final delay = index * 0.1;
              final slideAnimation = Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    delay.clamp(0, 0.9),
                    (delay + 0.4).clamp(0, 1.0),
                    curve: Curves.easeOutQuart,
                  ),
                ),
              );
              
              return FadeTransition(
                opacity: Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      delay.clamp(0, 0.9),
                      (delay + 0.4).clamp(0, 1.0),
                      curve: Curves.easeOut,
                    ),
                  ),
                ),
                child: SlideTransition(
                  position: slideAnimation,
                  child: child,
                ),
              );
            },
            child: _buildLinkCard(link, isDarkMode),
          );
        },
      ),
    );
  }

  Widget _buildLinkCard(LinkEntry link, bool isDarkMode) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showLinkDetails(link, isDarkMode),
          splashColor: AppConstants.primaryColor.withOpacity(0.1),
          highlightColor: AppConstants.primaryColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryColor.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        AppConstants.iconLink,
                        color: AppConstants.primaryColor,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            link.title,
                            style: AppConstants.titleMedium.copyWith(
                              color: isDarkMode ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            link.description,
                            style: AppConstants.bodyMedium.copyWith(
                              color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Icon(
                          link.isFavorite ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey<bool>(link.isFavorite),
                          color: link.isFavorite
                              ? AppConstants.warningColor
                              : isDarkMode
                                  ? Colors.white70
                                  : Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.read<DataProvider>().toggleLinkFavorite(link);
                      },
                      tooltip: link.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppConstants.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        link.category,
                        style: AppConstants.bodyMedium.copyWith(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.open_in_new_rounded,
                        color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                        size: 20,
                      ),
                      onPressed: () => _openLink(link.url),
                      tooltip: 'Open link',
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                        size: 20,
                      ),
                      onPressed: () {
                        final RenderBox button = context.findRenderObject() as RenderBox;
                        final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                        final RelativeRect position = RelativeRect.fromRect(
                          Rect.fromPoints(
                            button.localToGlobal(Offset.zero, ancestor: overlay),
                            button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                          ),
                          Offset.zero & overlay.size,
                        );
                        
                        showMenu<String>(
                          context: context,
                          position: position,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                          color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                          items: [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(AppConstants.iconEdit, size: 20),
                                  const SizedBox(width: 8),
                                  const Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(AppConstants.iconDelete, color: AppConstants.errorColor, size: 20),
                                  const SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: AppConstants.errorColor)),
                                ],
                              ),
                            ),
                          ],
                        ).then((value) {
                          if (value != null) {
                            _handleLinkAction(value, link);
                          }
                        });
                      },
                      tooltip: 'More options',
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: child,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? colorScheme.primaryContainer.withOpacity(0.2) 
                    : colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppConstants.iconLink,
                size: 64,
                color: isDarkMode ? Colors.white70 : colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No links yet',
              style: AppConstants.headlineMedium.copyWith(
                color: isDarkMode ? Colors.white : colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Save and organize your important links here for easy access',
                style: AppConstants.bodyMedium.copyWith(
                  color: isDarkMode ? Colors.white70 : colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _showAddLinkDialog(context);
              },
              icon: Icon(AppConstants.iconAdd),
              label: const Text('Add Your First Link'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLinkDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final urlController = TextEditingController();
    String selectedCategory = 'General';
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          'Add New Link',
          style: AppConstants.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : colorScheme.onSurface,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  prefixIcon: Icon(Icons.title_rounded, color: colorScheme.primary),
                  filled: true,
                  fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  prefixIcon: Icon(Icons.description_rounded, color: colorScheme.primary),
                  filled: true,
                  fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: 'URL',
                  labelStyle: TextStyle(color: colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  prefixIcon: Icon(Icons.link_rounded, color: colorScheme.primary),
                  filled: true,
                  fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  prefixIcon: Icon(Icons.category_rounded, color: colorScheme.primary),
                  filled: true,
                  fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ),
                dropdownColor: isDarkMode ? const Color(0xFF1E293B) : colorScheme.surface,
                items: AppConstants.defaultLinkCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(
                      category,
                      style: TextStyle(color: isDarkMode ? Colors.white : colorScheme.onSurface),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  selectedCategory = value ?? 'General';
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
            ),
            child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          FilledButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              if (titleController.text.isNotEmpty && urlController.text.isNotEmpty) {
                context.read<DataProvider>().addLink(
                  title: titleController.text,
                  description: descriptionController.text,
                  url: urlController.text,
                  category: selectedCategory,
                );
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Link added successfully'),
                    backgroundColor: colorScheme.primaryContainer,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                // Show error if fields are empty
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Title and URL are required'),
                    backgroundColor: colorScheme.errorContainer,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

     void _handleLinkAction(String action, LinkEntry link) {
     switch (action) {
       case 'favorite':
         print('Toggling favorite from popup menu for: ${link.title}');
         context.read<DataProvider>().toggleLinkFavorite(link);
         break;
       case 'edit':
         _showEditLinkDialog(context, link);
         break;
       case 'delete':
         _showDeleteConfirmation(link);
         break;
     }
   }

  void _showDeleteConfirmation(LinkEntry link) {
    final theme = Theme.of(context);
    final isDarkMode = context.read<ThemeProvider>().isDarkMode;
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Link',
          style: AppConstants.titleMedium.copyWith(
            color: isDarkMode ? Colors.white : colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${link.title}"?',
          style: AppConstants.bodyMedium.copyWith(
            color: isDarkMode ? Colors.white70 : colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: isDarkMode ? Colors.white70 : colorScheme.onSurface.withOpacity(0.7),
            ),
            child: Text(
              'Cancel',
              style: AppConstants.labelLarge,
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              context.read<DataProvider>().deleteLink(link);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '"${link.title}" deleted',
                    style: TextStyle(color: colorScheme.onErrorContainer),
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: colorScheme.errorContainer,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.error,
            ),
            child: Text(
              'Delete',
              style: AppConstants.labelLarge,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmationDialog(BuildContext context, bool isDarkMode, ColorScheme colorScheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear All Links',
          style: AppConstants.titleMedium.copyWith(
            color: isDarkMode ? Colors.white : colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete all links? This action cannot be undone.',
          style: AppConstants.bodyMedium.copyWith(
            color: isDarkMode ? Colors.white70 : colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: isDarkMode ? Colors.white70 : colorScheme.onSurface.withOpacity(0.7),
            ),
            child: Text(
              'Cancel',
              style: AppConstants.labelLarge,
            ),
          ),
          TextButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              await StorageService.clearAllData();
              context.read<DataProvider>().loadData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'All links cleared',
                    style: TextStyle(color: colorScheme.onErrorContainer),
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: colorScheme.errorContainer,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.error,
            ),
            child: Text(
              'Clear All',
              style: AppConstants.labelLarge,
            ),
          ),
        ],
      ),
    );
  }

     void _showLinkDetails(LinkEntry link, bool isDarkMode) {
     final theme = Theme.of(context);
     final colorScheme = theme.colorScheme;
     
     showModalBottomSheet(
       context: context,
       isScrollControlled: true,
       backgroundColor: Colors.transparent,
       builder: (context) => Container(
         height: MediaQuery.of(context).size.height * 0.7,
         decoration: BoxDecoration(
           color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
           boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.2),
               blurRadius: 10,
               spreadRadius: 0,
             ),
           ],
         ),
         child: Column(
           children: [
             Container(
               width: 40,
               height: 4,
               margin: const EdgeInsets.symmetric(vertical: 12),
               decoration: BoxDecoration(
                 color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
                 borderRadius: BorderRadius.circular(2),
               ),
             ),
             Expanded(
               child: SingleChildScrollView(
                 padding: const EdgeInsets.all(20),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Row(
                       children: [
                         Container(
                           width: 60,
                           height: 60,
                           decoration: BoxDecoration(
                             color: AppConstants.primaryColor.withOpacity(0.15),
                             borderRadius: BorderRadius.circular(16),
                             boxShadow: [
                               BoxShadow(
                                 color: AppConstants.primaryColor.withOpacity(0.1),
                                 blurRadius: 8,
                                 offset: const Offset(0, 2),
                               ),
                             ],
                           ),
                           child: Icon(
                             AppConstants.iconLink,
                             color: AppConstants.primaryColor,
                             size: 30,
                           ),
                         ),
                         const SizedBox(width: 16),
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 link.title,
                                 style: AppConstants.titleLarge.copyWith(
                                   color: isDarkMode ? Colors.white : colorScheme.onSurface,
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                               const SizedBox(height: 4),
                               Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                 decoration: BoxDecoration(
                                   color: AppConstants.primaryColor.withOpacity(0.15),
                                   borderRadius: BorderRadius.circular(20),
                                   border: Border.all(
                                     color: AppConstants.primaryColor.withOpacity(0.3),
                                     width: 1,
                                   ),
                                 ),
                                 child: Text(
                                   link.category,
                                   style: AppConstants.bodyMedium.copyWith(
                                     color: AppConstants.primaryColor,
                                     fontWeight: FontWeight.w600,
                                   ),
                                 ),
                               ),
                             ],
                           ),
                         ),
                                                   IconButton(
                            onPressed: () {
                              print('Toggling favorite from details view for: ${link.title}');
                              context.read<DataProvider>().toggleLinkFavorite(link);
                              Navigator.pop(context);
                            },
                           icon: Icon(
                             link.isFavorite ? Icons.favorite : Icons.favorite_border,
                             color: link.isFavorite ? AppConstants.warningColor : Colors.grey,
                             size: 28,
                           ),
                         ),
                       ],
                     ),
                     const SizedBox(height: 24),
                     _buildDetailSection(
                       'Description',
                       link.description.isNotEmpty ? link.description : 'No description',
                       isDarkMode,
                     ),
                     const SizedBox(height: 20),
                     _buildDetailSection(
                       'URL',
                       link.url,
                       isDarkMode,
                       isUrl: true,
                     ),
                     const SizedBox(height: 20),
                     _buildDetailSection(
                       'Created',
                       _formatDate(link.createdAt),
                       isDarkMode,
                     ),
                     const SizedBox(height: 20),
                     _buildDetailSection(
                       'Last Updated',
                       _formatDate(link.updatedAt),
                       isDarkMode,
                     ),
                     const SizedBox(height: 32),
                     Row(
                       children: [
                         Expanded(
                           child: FilledButton.icon(
                             onPressed: () {
                               HapticFeedback.mediumImpact();
                               Navigator.pop(context);
                               _showEditLinkDialog(context, link);
                             },
                             icon: const Icon(Icons.edit_rounded),
                             label: const Text('Edit', style: TextStyle(fontWeight: FontWeight.w600)),
                             style: FilledButton.styleFrom(
                               backgroundColor: colorScheme.primary,
                               foregroundColor: colorScheme.onPrimary,
                               padding: const EdgeInsets.symmetric(vertical: 14),
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(16),
                               ),
                             ),
                           ),
                         ),
                         const SizedBox(width: 12),
                         Expanded(
                           child: FilledButton.icon(
                             onPressed: () {
                               HapticFeedback.mediumImpact();
                               Navigator.pop(context);
                               _openLink(link.url);
                             },
                             icon: const Icon(Icons.open_in_new_rounded),
                             label: const Text('Open', style: TextStyle(fontWeight: FontWeight.w600)),
                             style: FilledButton.styleFrom(
                               backgroundColor: colorScheme.secondaryContainer,
                               foregroundColor: colorScheme.onSecondaryContainer,
                               padding: const EdgeInsets.symmetric(vertical: 14),
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(16),
                               ),
                             ),
                           ),
                         ),
                       ],
                     ),
                   ],
                 ),
               ),
             ),
           ],
         ),
       ),
     );
   }

   Widget _buildDetailSection(String title, String content, bool isDarkMode, {bool isUrl = false}) {
     final theme = Theme.of(context);
     final colorScheme = theme.colorScheme;
     
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(
           title,
           style: AppConstants.labelLarge.copyWith(
             color: isDarkMode ? Colors.white70 : colorScheme.onSurface.withOpacity(0.7),
             fontWeight: FontWeight.w600,
           ),
         ),
         const SizedBox(height: 8),
         Container(
           width: double.infinity,
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(
             color: isDarkMode ? const Color(0xFF2A3749) : colorScheme.surfaceContainerHighest.withOpacity(0.5),
             borderRadius: BorderRadius.circular(16),
             border: Border.all(
               color: isDarkMode ? Colors.grey.shade700 : colorScheme.outline.withOpacity(0.3),
               width: 1.5,
             ),
             boxShadow: [
               if (!isDarkMode)
                 BoxShadow(
                   color: Colors.black.withOpacity(0.03),
                   blurRadius: 4,
                   offset: const Offset(0, 2),
                 ),
             ],
           ),
           child: isUrl
               ? InkWell(
                   onTap: () {
                     HapticFeedback.lightImpact();
                     _openLink(content);
                   },
                   borderRadius: BorderRadius.circular(12),
                   child: Padding(
                     padding: const EdgeInsets.symmetric(vertical: 4),
                     child: Row(
                       children: [
                         Icon(
                           Icons.link_rounded,
                           size: 18,
                           color: colorScheme.primary,
                         ),
                         const SizedBox(width: 8),
                         Expanded(
                           child: Text(
                             content,
                             style: AppConstants.bodyLarge.copyWith(
                               color: colorScheme.primary,
                               fontWeight: FontWeight.w500,
                             ),
                           ),
                         ),
                         Container(
                           padding: const EdgeInsets.all(6),
                           decoration: BoxDecoration(
                             color: colorScheme.primary.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: Icon(
                             Icons.open_in_new_rounded,
                             size: 16,
                             color: colorScheme.primary,
                           ),
                         ),
                       ],
                     ),
                   ),
                 )
               : Text(
                   content,
                   style: AppConstants.bodyLarge.copyWith(
                     color: isDarkMode ? Colors.white : colorScheme.onSurface,
                   ),
                 ),
         ),
       ],
     );
   }

   String _formatDate(DateTime date) {
     return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
   }

   void _showEditLinkDialog(BuildContext context, LinkEntry link) {
     final titleController = TextEditingController(text: link.title);
     final descriptionController = TextEditingController(text: link.description);
     final urlController = TextEditingController(text: link.url);
     String selectedCategory = link.category;
     
     final theme = Theme.of(context);
     final colorScheme = theme.colorScheme;
     final isDarkMode = theme.brightness == Brightness.dark;

     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         backgroundColor: isDarkMode ? const Color(0xFF1E293B) : colorScheme.surface,
         surfaceTintColor: Colors.transparent,
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
         title: Text(
           'Edit Link',
           style: AppConstants.titleLarge.copyWith(
             fontWeight: FontWeight.bold,
             color: isDarkMode ? Colors.white : colorScheme.onSurface,
           ),
         ),
         content: SingleChildScrollView(
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               TextField(
                 controller: titleController,
                 decoration: InputDecoration(
                   labelText: 'Title',
                   labelStyle: TextStyle(color: colorScheme.primary),
                   border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(16),
                     borderSide: BorderSide(color: colorScheme.outline),
                   ),
                   focusedBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(16),
                     borderSide: BorderSide(color: colorScheme.primary, width: 2),
                   ),
                   prefixIcon: Icon(Icons.title_rounded, color: colorScheme.primary),
                   filled: true,
                   fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : colorScheme.surfaceContainerHighest.withOpacity(0.3),
                 ),
               ),
               const SizedBox(height: 16),
               TextField(
                 controller: descriptionController,
                 decoration: InputDecoration(
                   labelText: 'Description',
                   labelStyle: TextStyle(color: colorScheme.primary),
                   border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(16),
                     borderSide: BorderSide(color: colorScheme.outline),
                   ),
                   focusedBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(16),
                     borderSide: BorderSide(color: colorScheme.primary, width: 2),
                   ),
                   prefixIcon: Icon(Icons.description_rounded, color: colorScheme.primary),
                   filled: true,
                   fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : colorScheme.surfaceContainerHighest.withOpacity(0.3),
                 ),
                 maxLines: 3,
               ),
               const SizedBox(height: 16),
               TextField(
                 controller: urlController,
                 decoration: InputDecoration(
                   labelText: 'URL',
                   labelStyle: TextStyle(color: colorScheme.primary),
                   border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(16),
                     borderSide: BorderSide(color: colorScheme.outline),
                   ),
                   focusedBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(16),
                     borderSide: BorderSide(color: colorScheme.primary, width: 2),
                   ),
                   prefixIcon: Icon(Icons.link_rounded, color: colorScheme.primary),
                   filled: true,
                   fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : colorScheme.surfaceContainerHighest.withOpacity(0.3),
                 ),
               ),
               const SizedBox(height: 16),
               DropdownButtonFormField<String>(
                 value: selectedCategory,
                 decoration: InputDecoration(
                   labelText: 'Category',
                   labelStyle: TextStyle(color: colorScheme.primary),
                   border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(16),
                     borderSide: BorderSide(color: colorScheme.outline),
                   ),
                   focusedBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(16),
                     borderSide: BorderSide(color: colorScheme.primary, width: 2),
                   ),
                   prefixIcon: Icon(Icons.category_rounded, color: colorScheme.primary),
                   filled: true,
                   fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : colorScheme.surfaceContainerHighest.withOpacity(0.3),
                 ),
                 dropdownColor: isDarkMode ? const Color(0xFF1E293B) : colorScheme.surface,
                 items: AppConstants.defaultLinkCategories.map((category) {
                   return DropdownMenuItem(
                     value: category,
                     child: Text(
                       category,
                       style: TextStyle(color: isDarkMode ? Colors.white : colorScheme.onSurface),
                     ),
                   );
                 }).toList(),
                 onChanged: (value) {
                   HapticFeedback.selectionClick();
                   selectedCategory = value ?? 'General';
                 },
               ),
             ],
           ),
         ),
         actions: [
           TextButton(
             onPressed: () {
               HapticFeedback.lightImpact();
               Navigator.pop(context);
             },
             style: TextButton.styleFrom(
               foregroundColor: colorScheme.primary,
             ),
             child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
           ),
           FilledButton(
             onPressed: () {
               HapticFeedback.mediumImpact();
               if (titleController.text.isNotEmpty && urlController.text.isNotEmpty) {
                 final updatedLink = link.copyWith(
                   title: titleController.text,
                   description: descriptionController.text,
                   url: urlController.text,
                   category: selectedCategory,
                   updatedAt: DateTime.now(),
                 );
                 context.read<DataProvider>().updateLink(updatedLink);
                 Navigator.pop(context);
                 
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: const Text('Link updated successfully'),
                     backgroundColor: colorScheme.primaryContainer,
                     behavior: SnackBarBehavior.floating,
                   ),
                 );
               } else {
                 // Show error if fields are empty
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: const Text('Title and URL are required'),
                     backgroundColor: colorScheme.errorContainer,
                     behavior: SnackBarBehavior.floating,
                   ),
                 );
               }
             },
             style: FilledButton.styleFrom(
               backgroundColor: colorScheme.primary,
               foregroundColor: colorScheme.onPrimary,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
             ),
             child: const Text('Update', style: TextStyle(fontWeight: FontWeight.w600)),
           ),
         ],
       ),
     );
   }

   void _openLink(String url) async {
     final theme = Theme.of(context);
     final colorScheme = theme.colorScheme;
     
     // Add http:// prefix if missing
     String launchUrl = url;
     if (!launchUrl.startsWith('http://') && !launchUrl.startsWith('https://')) {
       launchUrl = 'https://$launchUrl';
     }
     
     try {
       HapticFeedback.mediumImpact();
       final canLaunch = await url_launcher.canLaunchUrl(Uri.parse(launchUrl));
       
       if (canLaunch) {
         await url_launcher.launchUrl(Uri.parse(launchUrl), mode: url_launcher.LaunchMode.externalApplication);
         
         // Show success message
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text('Opening: $launchUrl'),
               backgroundColor: colorScheme.primaryContainer,
               behavior: SnackBarBehavior.floating,
               action: SnackBarAction(
                 label: 'Copy URL',
                 textColor: colorScheme.primary,
                 onPressed: () {
                   Clipboard.setData(ClipboardData(text: launchUrl));
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                       content: const Text('URL copied to clipboard'),
                       backgroundColor: colorScheme.secondaryContainer,
                       behavior: SnackBarBehavior.floating,
                     ),
                   );
                 },
               ),
             ),
           );
         }
       } else {
         // Show error message if URL can't be launched
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text('Could not open URL: $launchUrl'),
               backgroundColor: colorScheme.errorContainer,
               behavior: SnackBarBehavior.floating,
             ),
           );
         }
       }
     } catch (e) {
       // Show error message if there's an exception
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Error opening URL: ${e.toString()}'),
             backgroundColor: colorScheme.errorContainer,
             behavior: SnackBarBehavior.floating,
           ),
         );
       }
     }
  }
}