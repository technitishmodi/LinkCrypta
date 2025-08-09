import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/password_entry.dart';
import '../../../utils/helpers.dart';
import '../../../providers/data_provider.dart';
import '../../../services/auth_service.dart';
import 'edit_password_screen.dart';

class PasswordDetailScreen extends StatefulWidget {
  final PasswordEntry password;
  const PasswordDetailScreen({super.key, required this.password});

  @override
  State<PasswordDetailScreen> createState() => _PasswordDetailScreenState();
}

class _PasswordDetailScreenState extends State<PasswordDetailScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.password.name,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_rounded, color: primary),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditPasswordScreen(password: widget.password),
                ),
              );
              if (result == true) {
                await context.read<DataProvider>().loadData();
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderCard(context, primary),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'DETAILS'),
          const SizedBox(height: 12),
          _buildDetailsCard(context, isDark, primary),
          const SizedBox(height: 32),
          _buildSectionTitle(context, 'QUICK ACTIONS'),
          const SizedBox(height: 12),
          _buildQuickActions(context, primary),
          if (widget.password.url.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildActionButton(context,
                icon: Icons.open_in_browser_rounded,
                label: 'Open Website',
                color: theme.colorScheme.secondary,
                fullWidth: true,
                onTap: () => AppHelpers.launchUrl(widget.password.url)),
          ]
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, Color primary) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Icon(Icons.lock_rounded, size: 36, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(widget.password.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(widget.password.category,
                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, bool isDark, Color primary) {
    final cardColor = isDark ? Colors.grey.shade900 : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailTile(context, Icons.person_outline_rounded, primary, 'Username',
              widget.password.username, onTap: () {
            AppHelpers.copyToClipboard(widget.password.username);
            AppHelpers.showSnackBar(context, 'Username copied');
          }),
          _buildDivider(),
          _buildPasswordTile(context, primary),
          if (widget.password.url.isNotEmpty) _buildDivider(),
          if (widget.password.url.isNotEmpty)
            _buildDetailTile(context, Icons.link_rounded, primary, 'Website',
                widget.password.url, isUrl: true,
                onTap: () => AppHelpers.launchUrl(widget.password.url)),
          if (widget.password.notes.isNotEmpty) _buildDivider(),
          if (widget.password.notes.isNotEmpty)
            _buildDetailTile(context, Icons.notes_rounded, primary, 'Notes',
                widget.password.notes, isMultiline: true),
          _buildDivider(),
          _buildDetailTile(context, Icons.calendar_month_rounded, Colors.orange, 'Created',
              AppHelpers.formatDateTime(widget.password.createdAt)),
          _buildDivider(),
          _buildDetailTile(context, Icons.update_rounded, Colors.teal, 'Updated',
              AppHelpers.formatDateTime(widget.password.updatedAt)),
        ],
      ),
    );
  }

  Widget _buildDivider() => const Divider(height: 1, indent: 16, endIndent: 16);

  Widget _buildDetailTile(BuildContext context, IconData icon, Color iconColor, String title,
      String value,
      {bool isUrl = false, bool isMultiline = false, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(radius: 20, backgroundColor: iconColor.withOpacity(0.1), child: Icon(icon, color: iconColor, size: 20)),
      title: Text(title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              )),
      subtitle: Text(value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isUrl ? iconColor : null,
              decoration: isUrl ? TextDecoration.underline : null),
          maxLines: isMultiline ? null : 1,
          overflow: isMultiline ? null : TextOverflow.ellipsis),
    );
  }

  Widget _buildPasswordTile(BuildContext context, Color primary) {
    return ListTile(
      leading: CircleAvatar(radius: 20, backgroundColor: primary.withOpacity(0.1), child: Icon(Icons.lock_rounded, color: primary, size: 20)),
      title: Text('Password',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
      subtitle: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Text(
          _obscurePassword ? '••••••••' : widget.password.password,
          key: ValueKey<bool>(_obscurePassword),
        ),
      ),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        IconButton(
          icon: const Icon(Icons.copy_rounded),
          onPressed: () async {
            if (await AuthService.showAuthDialog(context, reason: 'Authenticate to copy password')) {
              final decrypted = context.read<DataProvider>().getDecryptedPassword(widget.password);
              AppHelpers.copyToClipboard(decrypted);
              AppHelpers.showSnackBar(context, 'Password copied');
            }
          },
        ),
      ]),
    );
  }

  Widget _buildQuickActions(BuildContext context, Color primary) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(context,
              icon: Icons.person_rounded,
              label: 'Copy Username',
              color: primary,
              onTap: () {
            AppHelpers.copyToClipboard(widget.password.username);
            AppHelpers.showSnackBar(context, 'Username copied');
          }),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(context,
              icon: Icons.lock_rounded,
              label: 'Copy Password',
              color: Colors.purple,
              onTap: () async {
            if (await AuthService.showAuthDialog(context, reason: 'Authenticate to copy password')) {
              final decrypted = context.read<DataProvider>().getDecryptedPassword(widget.password);
              AppHelpers.copyToClipboard(decrypted);
              AppHelpers.showSnackBar(context, 'Password copied');
            }
          }),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap,
      bool fullWidth = false}) {
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
              children: [
                Icon(icon, color: color),
                const SizedBox(height: 6),
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String text) {
    return Text(text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ));
  }
}
