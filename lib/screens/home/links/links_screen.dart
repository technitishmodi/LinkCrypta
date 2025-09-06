import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:flutter/services.dart';

import '../../../utils/constants.dart';
import '../../../providers/data_provider.dart';
import '../../../models/link_entry.dart';
import '../../../providers/theme_provider.dart';
import 'widgets/link_card.dart';
import 'widgets/link_empty_state.dart';
import 'widgets/link_search_field.dart';
import 'widgets/link_category_filter.dart';
import 'widgets/add_edit_link_dialog.dart';

class LinksScreen extends StatefulWidget {
  const LinksScreen({super.key});

  @override
  State<LinksScreen> createState() => _LinksScreenState();
}

class _LinksScreenState extends State<LinksScreen> 
    with SingleTickerProviderStateMixin {
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
          _showAddLinkDialog();
        },
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: isDarkMode ? 2 : 4,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        label: const Text(
          'Add Link',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        icon: const Icon(Icons.add),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _OptimizedLinksBody(
          searchController: _searchController,
          selectedCategory: _selectedCategory,
          isSearchVisible: _isSearchVisible,
          onCategorySelected: (category) {
            setState(() => _selectedCategory = category);
            Provider.of<DataProvider>(context, listen: false).setSelectedLinkCategory(category);
          },
          onSearchToggled: () {
            setState(() {
              _isSearchVisible = !_isSearchVisible;
              if (!_isSearchVisible) {
                _searchController.clear();
                Provider.of<DataProvider>(context, listen: false).setSearchQuery('');
              }
            });
          },
          onAddLinkPressed: _showAddLinkDialog,
          onLinkTap: (link) => _showLinkDetails(link, isDarkMode),
          onLinkAction: _handleLinkAction,
          isDarkMode: isDarkMode,
        ),
      ),
    );
  }

  void _showAddLinkDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddEditLinkDialog(),
    );
  }

  void _showLinkDetails(LinkEntry link, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailHeader(link, isDarkMode),
              _buildDetailContent(link, isDarkMode),
              _buildDetailActions(link, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailHeader(LinkEntry link, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? const Color(0xFF3B82F6).withOpacity(0.1)
            : const Color(0xFF3B82F6).withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.link,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        link.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    if (link.isFavorite)
                      const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  link.category,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContent(LinkEntry link, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (link.description.isNotEmpty) ...[
            _buildDetailSection('Description', link.description, isDarkMode),
            const SizedBox(height: 20),
          ],
          _buildDetailSection('URL', link.url, isDarkMode, isUrl: true),
          const SizedBox(height: 20),
          _buildDetailSection(
            'Created', 
            _formatDateTime(link.createdAt), 
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, bool isDarkMode, {bool isUrl = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: isDarkMode 
                ? Border.all(color: const Color(0xFF4B5563))
                : null,
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: isUrl 
                  ? const Color(0xFF3B82F6)
                  : isDarkMode ? Colors.white : const Color(0xFF1E293B),
              fontFamily: isUrl ? 'monospace' : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailActions(LinkEntry link, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: () => _openLink(link.url),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open Link'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Toggling favorite from details view for: ${link.title}
                Provider.of<DataProvider>(context, listen: false)
                    .toggleLinkFavorite(link);
                Navigator.of(context).pop();
              },
              icon: Icon(link.isFavorite ? Icons.favorite_border : Icons.favorite),
              label: Text(link.isFavorite ? 'Unfavorite' : 'Favorite'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLinkAction(String action, LinkEntry link) {
    switch (action) {
      case 'open':
        _openLink(link.url);
        break;
      case 'copy':
        Clipboard.setData(ClipboardData(text: link.url));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('URL copied to clipboard'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'favorite':
        // Toggling favorite from popup menu for: ${link.title}
        Provider.of<DataProvider>(context, listen: false).toggleLinkFavorite(link);
        break;
      case 'edit':
        showDialog(
          context: context,
          builder: (context) => AddEditLinkDialog(linkToEdit: link),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(link);
        break;
    }
  }

  void _showDeleteConfirmation(LinkEntry link) {
    final isDarkMode = context.read<ThemeProvider>().isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Link',
          style: TextStyle(
            color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${link.title}"? This action cannot be undone.',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<DataProvider>(context, listen: false).deleteLink(link);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Link deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _openLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await url_launcher.canLaunchUrl(uri)) {
        await url_launcher.launchUrl(uri, mode: url_launcher.LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open the link'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Optimized widget that isolates expensive rebuilds
class _OptimizedLinksBody extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedCategory;
  final bool isSearchVisible;
  final Function(String) onCategorySelected;
  final VoidCallback onSearchToggled;
  final VoidCallback onAddLinkPressed;
  final Function(LinkEntry) onLinkTap;
  final Function(String, LinkEntry) onLinkAction;
  final bool isDarkMode;

  const _OptimizedLinksBody({
    required this.searchController,
    required this.selectedCategory,
    required this.isSearchVisible,
    required this.onCategorySelected,
    required this.onSearchToggled,
    required this.onAddLinkPressed,
    required this.onLinkTap,
    required this.onLinkAction,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final links = dataProvider.links;
        final categories = dataProvider.linkCategories;

        return CustomScrollView(
          slivers: [
            _OptimizedAppBar(
              isDarkMode: isDarkMode,
              linkCount: links.length,
              isSearchVisible: isSearchVisible,
              onSearchToggled: onSearchToggled,
            ),
            if (isSearchVisible)
              SliverToBoxAdapter(
                child: LinkSearchField(
                  controller: searchController,
                  isDarkMode: isDarkMode,
                  onChanged: (query) {
                    dataProvider.setSearchQuery(query);
                  },
                  onClear: () {
                    dataProvider.setSearchQuery('');
                  },
                ),
              ),
            SliverToBoxAdapter(
              child: LinkCategoryFilter(
                categories: categories,
                selectedCategory: selectedCategory,
                isDarkMode: isDarkMode,
                onCategorySelected: onCategorySelected,
              ),
            ),
            if (links.isEmpty)
              SliverFillRemaining(
                child: LinkEmptyState(
                  isDarkMode: isDarkMode,
                  onAddPressed: onAddLinkPressed,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final link = links[index];
                      return LinkCard(
                        link: link,
                        onTap: () => onLinkTap(link),
                        onAction: onLinkAction,
                      );
                    },
                    childCount: links.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 100), // FAB padding
            ),
          ],
        );
      },
    );
  }
}

// Optimized AppBar widget
class _OptimizedAppBar extends StatelessWidget {
  final bool isDarkMode;
  final int linkCount;
  final bool isSearchVisible;
  final VoidCallback onSearchToggled;

  const _OptimizedAppBar({
    required this.isDarkMode,
    required this.linkCount,
    required this.isSearchVisible,
    required this.onSearchToggled,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: isDarkMode 
          ? const Color(0xFF0F172A) 
          : Theme.of(context).colorScheme.surface,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Links',
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            if (linkCount > 0)
              Text(
                '$linkCount ${linkCount == 1 ? 'link' : 'links'}',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isSearchVisible ? Icons.search_off : Icons.search,
            color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
          ),
          onPressed: onSearchToggled,
        ),
        if (linkCount > 0)
          _ClearAllButton(isDarkMode: isDarkMode),
      ],
    );
  }
}

// Optimized Clear All Button widget
class _ClearAllButton extends StatelessWidget {
  final bool isDarkMode;

  const _ClearAllButton({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
      ),
      onSelected: (value) {
        if (value == 'clear_all') {
          _showClearConfirmationDialog(context);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'clear_all',
          child: Row(
            children: [
              Icon(Icons.clear_all, color: Colors.red),
              SizedBox(width: 12),
              Text('Clear All Links', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _showClearConfirmationDialog(BuildContext context) {
    final isDarkMode = context.read<ThemeProvider>().isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear All Links',
          style: TextStyle(
            color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        content: Text(
          'Are you sure you want to delete all links? This action cannot be undone.',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final dataProvider = Provider.of<DataProvider>(context, listen: false);
              final links = List.from(dataProvider.allLinks);
              for (final link in links) {
                await dataProvider.deleteLink(link);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All links cleared'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
