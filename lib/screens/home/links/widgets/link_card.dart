import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../../../models/link_entry.dart';
import '../../../../providers/theme_provider.dart';

class LinkCard extends StatelessWidget {
  final LinkEntry link;
  final VoidCallback? onTap;
  final Function(String, LinkEntry)? onAction;

  const LinkCard({
    super.key,
    required this.link,
    this.onTap,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDarkMode 
            ? Border.all(color: const Color(0xFF334155), width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDarkMode),
                const SizedBox(height: 12),
                _buildContent(isDarkMode),
                const SizedBox(height: 16),
                _buildFooter(isDarkMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDarkMode 
                ? const Color(0xFF3B82F6).withOpacity(0.2)
                : const Color(0xFF3B82F6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.link,
            color: const Color(0xFF3B82F6),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (link.isFavorite)
                    Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 18,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                link.category,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode 
                      ? Colors.grey[400] 
                      : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) => onAction?.call(value, link),
          icon: Icon(
            Icons.more_vert,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'open',
              child: Row(
                children: [
                  Icon(Icons.open_in_new, size: 18),
                  SizedBox(width: 12),
                  Text('Open Link'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'copy',
              child: Row(
                children: [
                  Icon(Icons.copy, size: 18),
                  SizedBox(width: 12),
                  Text('Copy URL'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'favorite',
              child: Row(
                children: [
                  Icon(
                    link.isFavorite ? Icons.favorite_border : Icons.favorite,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Text(link.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 12),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (link.description.isNotEmpty) ...[
          Text(
            link.description,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDarkMode 
                ? const Color(0xFF374151)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            link.url,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF3B82F6),
              fontFamily: 'monospace',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(bool isDarkMode) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 14,
          color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
        ),
        const SizedBox(width: 4),
        Text(
          'Added ${_formatDate(link.createdAt)}',
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
          ),
        ),
        const Spacer(),
        if (link.isBookmarked)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Bookmarked',
              style: TextStyle(
                fontSize: 10,
                color: const Color(0xFF10B981),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
