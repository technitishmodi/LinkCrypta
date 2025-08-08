import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/data_provider.dart';
import '../../../widgets/password_card.dart';
import '../../../utils/constants.dart';
import '../../../models/link_entry.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Favorites',
          style: AppConstants.titleLarge.copyWith(
            color: isDarkMode ? Colors.white : AppConstants.primaryColor,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppConstants.primaryColor,
          labelColor: AppConstants.primaryColor,
          unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.grey.shade600,
          tabs: const [
            Tab(text: 'Passwords'),
            Tab(text: 'Links'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPasswordsTab(isDarkMode),
          _buildLinksTab(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildPasswordsTab(bool isDarkMode) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final favoritePasswords = dataProvider.favoritePasswords;
        
        if (favoritePasswords.isEmpty) {
          return _buildEmptyState(
            'No Favorite Passwords',
            'Your favorite passwords will appear here',
            AppConstants.iconPassword,
            isDarkMode,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favoritePasswords.length,
          itemBuilder: (context, index) {
            final password = favoritePasswords[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: PasswordCard(
                password: password,
                onTap: () {},
                onFavorite: () {
                  dataProvider.togglePasswordFavorite(password);
                },
                onDelete: () {
                  dataProvider.deletePassword(password);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLinksTab(bool isDarkMode) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final favoriteLinks = dataProvider.favoriteLinks;
        final allLinks = dataProvider.links;
        print('Favorites screen - building links tab with ${favoriteLinks.length} favorite links');
        print('Total filtered links in data provider: ${dataProvider.links.length}');
        print('Total unfiltered links in data provider: ${allLinks.length}');
        print('All unfiltered links in data provider:');
        for (final link in allLinks) {
          print('  - ${link.title} (favorite: ${link.isFavorite})');
        }
        
        if (favoriteLinks.isEmpty) {
          return _buildEmptyState(
            'No Favorite Links',
            'Your favorite links will appear here',
            AppConstants.iconLink,
            isDarkMode,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favoriteLinks.length,
          itemBuilder: (context, index) {
            final link = favoriteLinks[index];
            return _buildFavoriteLinkCard(link, isDarkMode);
          },
        );
      },
    );
  }

  Widget _buildFavoriteLinkCard(LinkEntry link, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            AppConstants.iconLink,
            color: AppConstants.primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          link.title,
          style: AppConstants.titleMedium.copyWith(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              link.description,
              style: AppConstants.bodyMedium.copyWith(
                color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
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
                Icon(
                  AppConstants.iconFavorite,
                  color: AppConstants.warningColor,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
          ),
          onSelected: (value) => _handleLinkAction(value, link),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'favorite',
              child: Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: AppConstants.warningColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text('Remove from favorites'),
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
        ),
        onTap: () => _openLink(link.url),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              icon,
              size: 60,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppConstants.headlineMedium.copyWith(
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppConstants.bodyMedium.copyWith(
              color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

     void _handleLinkAction(String action, LinkEntry link) {
     switch (action) {
       case 'favorite':
         print('Toggling favorite from favorites screen for: ${link.title}');
         context.read<DataProvider>().toggleLinkFavorite(link);
         break;
       case 'delete':
         _showDeleteConfirmation(link);
         break;
     }
   }

  void _showDeleteConfirmation(LinkEntry link) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Link'),
        content: Text('Are you sure you want to delete "${link.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DataProvider>().deleteLink(link);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openLink(String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: $url'),
        backgroundColor: AppConstants.infoColor,
      ),
    );
  }
}
