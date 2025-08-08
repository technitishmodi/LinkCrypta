import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/password_entry.dart';
import '../../../utils/helpers.dart';
import '../../../providers/data_provider.dart';
import '../../../services/auth_service.dart';
import 'edit_password_screen.dart';

// Modern Light Blue Color Scheme
class ModernColors {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
}

class PasswordDetailScreen extends StatefulWidget {
  final PasswordEntry password;

  const PasswordDetailScreen({
    super.key,
    required this.password,
  });

  @override
  State<PasswordDetailScreen> createState() => _PasswordDetailScreenState();
}

class _PasswordDetailScreenState extends State<PasswordDetailScreen> {
  bool _obscurePassword = true;
  final _colorScheme = const {
    'primary': ModernColors.primaryBlue,
    'secondary': ModernColors.primaryBlue,
    'accent': ModernColors.primaryBlue,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardGradient = isDarkMode
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade900,
              Colors.grey.shade800,
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade100,
            ],
          );

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.password.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_rounded, color: _colorScheme['primary']),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditPasswordScreen(
                    password: widget.password,
                  ),
                ),
              );
              if (result == true) {
                // Refresh the data if edit was successful
                final dataProvider = context.read<DataProvider>();
                await dataProvider.loadData();
                // Update the widget to reflect changes
                setState(() {});
              }
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header Card with Gradient
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _colorScheme['primary']!,
                        _colorScheme['secondary']!,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _colorScheme['primary']!.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.password.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.password.category,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Details Section
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    'DETAILS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: cardGradient,
                    boxShadow: [
                      if (!isDarkMode)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Username
                      _buildModernDetailTile(
                        context,
                        icon: Icons.person_outline_rounded,
                        iconColor: _colorScheme['primary']!,
                        title: 'Username',
                        value: widget.password.username,
                        onTap: () {
                          AppHelpers.copyToClipboard(widget.password.username);
                          AppHelpers.showSnackBar(
                            context,
                            'Username copied',
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),

                      // Password
                      _buildPasswordTile(context),
                      if (widget.password.url.isNotEmpty)
                        const Divider(height: 1, indent: 16, endIndent: 16),

                      // URL
                      if (widget.password.url.isNotEmpty)
                        _buildModernDetailTile(
                          context,
                          icon: Icons.link_rounded,
                          iconColor: _colorScheme['secondary']!,
                          title: 'Website',
                          value: widget.password.url,
                          isUrl: true,
                          onTap: () => AppHelpers.launchUrl(widget.password.url),
                        ),
                      if (widget.password.notes.isNotEmpty)
                        const Divider(height: 1, indent: 16, endIndent: 16),

                      // Notes
                      if (widget.password.notes.isNotEmpty)
                        _buildModernDetailTile(
                          context,
                          icon: Icons.notes_rounded,
                          iconColor: _colorScheme['accent']!,
                          title: 'Notes',
                          value: widget.password.notes,
                          isMultiline: true,
                        ),
                      const Divider(height: 1, indent: 16, endIndent: 16),

                      // Created Date
                      _buildModernDetailTile(
                        context,
                        icon: Icons.calendar_month_rounded,
                        iconColor: Colors.orange.shade400,
                        title: 'Created',
                        value: AppHelpers.formatDateTime(widget.password.createdAt),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),

                      // Updated Date
                      _buildModernDetailTile(
                        context,
                        icon: Icons.update_rounded,
                        iconColor: Colors.teal.shade400,
                        title: 'Updated',
                        value: AppHelpers.formatDateTime(widget.password.updatedAt),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Quick Actions
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    'QUICK ACTIONS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.person_rounded,
                        label: 'Copy Username',
                        color: _colorScheme['primary']!,
                        onTap: () {
                          AppHelpers.copyToClipboard(widget.password.username);
                          AppHelpers.showSnackBar(context, 'Username copied');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.lock_rounded,
                        label: 'Copy Password',
                        color: _colorScheme['secondary']!,
                        onTap: () async {
                          // Authenticate before copying password
                          final authenticated = await AuthService.showAuthDialog(
                            context,
                            reason: 'Authenticate to copy password',
                          );
                          
                          if (authenticated) {
                            final dataProvider = context.read<DataProvider>();
                            final decryptedPassword = dataProvider.getDecryptedPassword(widget.password);
                            AppHelpers.copyToClipboard(decryptedPassword);
                            AppHelpers.showSnackBar(context, 'Password copied');
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.lock_rounded,
                        label: 'Sync Now',
                        color: _colorScheme['secondary']!,
                        onTap: () {
                      
                        },
                      ),
                    ),
                if (widget.password.url.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    icon: Icons.open_in_browser_rounded,
                    label: 'Open Website',
                    color: _colorScheme['accent']!,
                    onTap: () => AppHelpers.launchUrl(widget.password.url),
                    fullWidth: true,
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDetailTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    bool isUrl = false,
    bool isMultiline = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: iconColor,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      subtitle: isUrl
          ? Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _colorScheme['secondary'],
                decoration: TextDecoration.underline,
              ),
            )
          : Text(
              value,
              style: theme.textTheme.bodyMedium,
              maxLines: isMultiline ? null : 1,
              overflow: isMultiline ? null : TextOverflow.ellipsis,
            ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildPasswordTile(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _colorScheme['primary']!.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.lock_rounded,
          size: 20,
          color: _colorScheme['primary'],
        ),
      ),
      title: Text(
        'Password',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      subtitle: Text(
        _obscurePassword ? '••••••••' : widget.password.password,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            splashRadius: 20,
          ),
          IconButton(
            icon: Icon(
              Icons.copy_rounded,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: 20,
            ),
            onPressed: () async {
              // Authenticate before copying password
              final authenticated = await AuthService.showAuthDialog(
                context,
                reason: 'Authenticate to copy password',
              );
              
              if (authenticated) {
                final dataProvider = context.read<DataProvider>();
                final decryptedPassword = dataProvider.getDecryptedPassword(widget.password);
                AppHelpers.copyToClipboard(decryptedPassword);
                AppHelpers.showSnackBar(context, 'Password copied');
              }
            },
            splashRadius: 20,
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}