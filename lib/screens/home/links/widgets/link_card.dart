import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../../../models/link_entry.dart';
import '../../../../providers/theme_provider.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/helpers.dart';
import '../../../../providers/data_provider.dart';

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
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingS),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Row(
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: const Icon(
                  AppConstants.iconLink,
                  color: AppConstants.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            link.title,
                            style: AppConstants.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (link.isFavorite)
                          const Icon(
                            AppConstants.iconFavorite,
                            color: AppConstants.primaryColor,
                            size: 16,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingXS),
                    if (link.description.isNotEmpty)
                      Text(
                        link.description,
                        style: AppConstants.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: AppConstants.spacingXS),
                    Text(
                      AppHelpers.getDomainFromUrl(link.url),
                      style: AppConstants.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.spacingXS),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingS,
                            vertical: AppConstants.spacingXS,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusS),
                          ),
                          child: Text(
                            link.category,
                            style: AppConstants.bodyMedium.copyWith(
                              color: AppConstants.primaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          AppHelpers.formatDate(link.createdAt),
                          style: AppConstants.bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              Consumer<DataProvider>(
                builder: (context, dataProvider, child) {
                  return PopupMenuButton<String>(
                    onSelected: (value) => onAction?.call(value, link),
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                      // Only show sync option if user is authenticated
                      if (dataProvider.canSyncWithFirebase())
                        const PopupMenuItem(
                          value: 'sync',
                          child: Row(
                            children: [
                              Icon(Icons.cloud_upload, size: 18),
                              SizedBox(width: 12),
                              Text('Sync to Cloud'),
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
                  );
                },
              ),

              // Arrow
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
