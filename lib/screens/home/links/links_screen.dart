import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:flutter/services.dart';

import '../../../providers/data_provider.dart';
import '../../../models/link_entry.dart';
import '../../../utils/helpers.dart';
import 'widgets/link_card.dart';
import 'widgets/link_search_field.dart';
import 'widgets/link_category_filter.dart';
import 'widgets/add_edit_link_dialog.dart';

// Modern unified color scheme matching password screen
class ModernColors {
  // Main colors
  static const Color primary = Color(0xFF6200EE);       // Deep purple
  static const Color secondary = Color(0xFF03DAC6);     // Teal
  static const Color accent = Color(0xFFBB86FC);        // Light purple
  
  // Background colors
  static const Color background = Color(0xFFF5F5F7);    // Light gray background
  static const Color surface = Color(0xFFFFFFFF);       // White surface
  static const Color surfaceVariant = Color(0xFFF3F3F3); // Light gray surface
  
  // Text colors
  static const Color textPrimary = Color(0xFF1F1F1F);   // Almost black
  static const Color textSecondary = Color(0xFF6E6E6E);  // Dark gray
  static const Color textTertiary = Color(0xFF9E9E9E);   // Medium gray
  
  // Utility colors
  static const Color error = Color(0xFFB00020);         // Error red
  static const Color success = Color(0xFF4CAF50);       // Success green
  static const Color warning = Color(0xFFFFA000);       // Warning amber
  static const Color info = Color(0xFF2196F3);          // Info blue
  static const Color divider = Color(0xFFE0E0E0);       // Light gray divider
}

class LinksScreen extends StatefulWidget {
  const LinksScreen({super.key});

  @override
  State<LinksScreen> createState() => _LinksScreenState();
}

class _LinksScreenState extends State<LinksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _showSearchBar = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<DataProvider>(context, listen: false).loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    try {
      final dataProvider = context.read<DataProvider>();
      
      // Check if user can sync with Firebase
      if (dataProvider.canSyncWithFirebase()) {
        // Sync all links to Firebase
        final success = await dataProvider.syncAllToFirebase();
        if (success) {
          // Also sync from Firebase to get any cloud updates
          await dataProvider.syncFromFirebase();
        }
      }
      
      // Load local data
      await dataProvider.loadData();
      
      if (mounted) {
        AppHelpers.showSnackBar(
          context,
          dataProvider.canSyncWithFirebase() 
              ? 'Links synced with Firebase successfully'
              : 'Links refreshed (local only - sign in to sync with cloud)',
          backgroundColor: ModernColors.success,
        );
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showSnackBar(
          context,
          'Failed to sync: ${e.toString()}',
          backgroundColor: ModernColors.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ModernColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Links',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showSearchBar ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showSearchBar = !_showSearchBar;
                if (!_showSearchBar) {
                  _searchController.clear();
                  context.read<DataProvider>().setSearchQuery('');
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _navigateToAddLink,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar with Animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showSearchBar ? 60 : 0,
            child: _showSearchBar
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: LinkSearchField(
                      controller: _searchController,
                      isDarkMode: false, // Using light theme for unified design
                      onChanged: (query) {
                        context.read<DataProvider>().setSearchQuery(query);
                      },
                      onClear: () {
                        _searchController.clear();
                        context.read<DataProvider>().setSearchQuery('');
                        setState(() => _showSearchBar = false);
                      },
                    ),
                  )
                : const SizedBox(),
          ),

          // Category Filter with Elevation
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Consumer<DataProvider>(
              builder: (context, dataProvider, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: LinkCategoryFilter(
                    categories: dataProvider.linkCategories,
                    selectedCategory: _selectedCategory,
                    isDarkMode: false, // Using light theme for unified design
                    onCategorySelected: (category) {
                      setState(() => _selectedCategory = category);
                      dataProvider.setSelectedLinkCategory(category);
                    },
                  ),
                );
              },
            ),
          ),

          // Scrollable Links List with Refresh and Animations
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final dataProvider = context.read<DataProvider>();
                await dataProvider.loadData();
              },
              color: ModernColors.primary,
              backgroundColor: ModernColors.surface,
              strokeWidth: 2.5,
              child: Consumer<DataProvider>(
                builder: (context, dataProvider, child) {
                  if (dataProvider.isLoading && dataProvider.links.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 20),
                          CircularProgressIndicator(
                            color: ModernColors.primary,
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading links...',
                            style: TextStyle(
                              color: ModernColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final links = dataProvider.links;

                  if (links.isEmpty) {
                    return _buildEmptyState(true);
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: links.length,
                    itemBuilder: (context, index) {
                      final link = links[index];
                      return AnimatedOpacity(
                        duration: Duration(milliseconds: 300 + (index * 30)),
                        opacity: 1.0,
                        curve: Curves.easeInOut,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: LinkCard(
                            link: link,
                            onTap: () => _navigateToLinkDetail(link),
                            onAction: (action, link) => _handleLinkAction(action, link),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16, right: 8),
        child: FloatingActionButton.extended(
          backgroundColor: ModernColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: _navigateToAddLink,
          icon: const Icon(Icons.add, size: 24),
          label: const Text(
            'Add Link',
            style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool noLinks) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: ModernColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  noLinks ? Icons.link_outlined : Icons.search_off_rounded,
                  size: 60,
                  color: ModernColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                noLinks ? 'No Links Yet' : 'No Results Found',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                noLinks
                    ? 'Save and organize your important links in one secure place.'
                    : 'Try a different search term or category filter.',
                style: const TextStyle(
                  fontSize: 16,
                  color: ModernColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (noLinks)
                ElevatedButton.icon(
                  onPressed: _navigateToAddLink,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Your First Link'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ModernColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAddLink() {
    showDialog(
      context: context,
      builder: (context) => const AddEditLinkDialog(),
    );
  }

  void _navigateToLinkDetail(LinkEntry link) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLinkDetailsModal(link),
    );
  }

  Widget _buildLinkDetailsModal(LinkEntry link) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: ModernColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: ModernColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ModernColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.link,
                    color: ModernColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        link.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ModernColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (link.category.isNotEmpty)
                        Text(
                          link.category,
                          style: const TextStyle(
                            fontSize: 14,
                            color: ModernColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: ModernColors.textSecondary),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: ModernColors.divider),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (link.description.isNotEmpty) ...[
                    _buildDetailSection('Description', link.description),
                    const SizedBox(height: 20),
                  ],
                  _buildDetailSection('URL', link.url, isUrl: true),
                  const SizedBox(height: 20),
                  _buildDetailSection('Created', _formatDateTime(link.createdAt)),
                ],
              ),
            ),
          ),
          
          // Actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: ModernColors.divider)),
            ),
            child: Column(
              children: [
                Row(
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
                          _toggleFavorite(link);
                          Navigator.pop(context);
                        },
                        icon: Icon(link.isFavorite ? Icons.favorite_border : Icons.favorite),
                        label: Text(link.isFavorite ? 'Unfavorite' : 'Favorite'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ModernColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Sync button row
                Consumer<DataProvider>(
                  builder: (context, dataProvider, child) {
                    if (!dataProvider.canSyncWithFirebase()) {
                      return const SizedBox.shrink();
                    }
                    
                    return SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _syncLinkToFirebase(link),
                        icon: const Icon(Icons.cloud_upload, size: 18),
                        label: const Text('Sync to Cloud'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: ModernColors.primary),
                          foregroundColor: ModernColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, {bool isUrl = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ModernColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: isUrl ? ModernColors.info : ModernColors.textPrimary,
              fontFamily: isUrl ? 'monospace' : null,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _openLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await url_launcher.canLaunchUrl(uri)) {
        await url_launcher.launchUrl(uri, mode: url_launcher.LaunchMode.externalApplication);
      } else {
        if (mounted) {
          AppHelpers.showSnackBar(
            context,
            'Cannot open this link',
            backgroundColor: ModernColors.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showSnackBar(
          context,
          'Error opening link',
          backgroundColor: ModernColors.error,
        );
      }
    }
  }

  Future<void> _toggleFavorite(LinkEntry link) async {
    final dataProvider = context.read<DataProvider>();
    await dataProvider.toggleLinkFavorite(link);
  }

  Future<void> _deleteLink(LinkEntry link) async {
    final confirmed = await AppHelpers.showConfirmDialog(
      context,
      'Delete Link',
      'Are you sure you want to delete "${link.title}"? This action cannot be undone.',
      confirmText: 'Delete',
    );

    if (confirmed) {
      final dataProvider = context.read<DataProvider>();
      await dataProvider.deleteLink(link);

      if (mounted) {
        AppHelpers.showSnackBar(
          context,
          'Link deleted',
          backgroundColor: ModernColors.error,
        );
      }
    }
  }

  void _handleLinkAction(String action, LinkEntry link) {
    switch (action) {
      case 'open':
        _openLink(link.url);
        break;
      case 'edit':
        _editLink(link);
        break;
      case 'delete':
        _deleteLink(link);
        break;
      case 'favorite':
        _toggleFavorite(link);
        break;
      case 'copy':
        _copyLink(link.url);
        break;
      case 'share':
        _shareLink(link);
        break;
      case 'sync':
        _syncLinkToFirebase(link);
        break;
    }
  }

  void _editLink(LinkEntry link) {
    showDialog(
      context: context,
      builder: (context) => AddEditLinkDialog(linkToEdit: link),
    );
  }

  void _copyLink(String url) {
    Clipboard.setData(ClipboardData(text: url));
    AppHelpers.showSnackBar(
      context,
      'Link copied to clipboard',
      backgroundColor: ModernColors.success,
    );
  }

  void _shareLink(LinkEntry link) {
    // Share functionality would go here
    // For now, just copy to clipboard
    _copyLink(link.url);
  }

  Future<void> _syncLinkToFirebase(LinkEntry link) async {
    try {
      final dataProvider = context.read<DataProvider>();
      final success = await dataProvider.syncLinkToFirebase(link);
      
      if (mounted) {
        if (success) {
          AppHelpers.showSnackBar(
            context,
            'Link "${link.title}" synced to Firebase successfully',
            backgroundColor: ModernColors.success,
          );
        } else {
          AppHelpers.showSnackBar(
            context,
            'Failed to sync link to Firebase',
            backgroundColor: ModernColors.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showSnackBar(
          context,
          'Sync error: ${e.toString()}',
          backgroundColor: ModernColors.error,
        );
      }
    }
  }
}