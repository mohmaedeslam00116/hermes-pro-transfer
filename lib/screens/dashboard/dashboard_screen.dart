import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/app_provider.dart';
import '../../models/transfer_state.dart';
import '../technology_picker/technology_picker_screen.dart';

/// Option Card Data
class DashboardOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isSend;

  const DashboardOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isSend,
  });
}

/// Modern Dashboard Screen with improved UI/UX
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const List<DashboardOption> _options = [
    DashboardOption(
      icon: Icons.upload_rounded,
      title: 'Send',
      subtitle: 'Share files to another device',
      color: AppTheme.primaryColor,
      isSend: true,
    ),
    DashboardOption(
      icon: Icons.download_rounded,
      title: 'Receive',
      subtitle: 'Get files from another device',
      color: AppTheme.secondaryColor,
      isSend: false,
    ),
  ];

  void _navigateToPicker(bool isSend) {
    final appProvider = context.read<AppProvider>();
    appProvider.setTransferMode(isSend ? TransferMode.send : TransferMode.receive);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TechnologyPickerScreen(
          mode: isSend ? TransferMode.send : TransferMode.receive,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppTheme.darkBackground,
                    AppTheme.darkSurface,
                  ]
                : [
                    AppTheme.lightBackground,
                    AppTheme.lightSurface,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMD),
                child: Row(
                  children: [
                    // Logo with gradient
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingSM),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.secondaryColor,
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMD),

                    // Title with app version
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'v${AppConstants.appVersion}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppTheme.darkForeground
                                              .withOpacity(0.5)
                                          : AppTheme.lightForeground
                                              .withOpacity(0.5),
                                    ),
                          ),
                        ],
                      ),
                    ),

                    // Settings Button
                    _buildIconButton(
                      icon: Icons.settings_outlined,
                      onPressed: () => _showSettingsSheet(context),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMD),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header
                      Text(
                        'What would you like to do?',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingSM),
                      Text(
                        'Choose an option to start transferring files',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppTheme.darkForeground.withOpacity(0.6)
                                  : AppTheme.lightForeground
                                      .withOpacity(0.6),
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingXXL),

                      // Option Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildOptionCard(_options[0], size, isDark),
                          ),
                          const SizedBox(width: AppTheme.spacingMD),
                          Expanded(
                            child: _buildOptionCard(_options[1], size, isDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Footer with network status
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMD),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi,
                      size: 16,
                      color: isDark
                          ? AppTheme.darkForeground.withOpacity(0.5)
                          : AppTheme.lightForeground.withOpacity(0.5),
                    ),
                    const SizedBox(width: AppTheme.spacingSM),
                    Text(
                      'Same Wi-Fi required',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppTheme.darkForeground.withOpacity(0.5)
                                : AppTheme.lightForeground
                                    .withOpacity(0.5),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingSM),
          child: Icon(
            icon,
            color: isDark
                ? AppTheme.darkForeground.withOpacity(0.7)
                : AppTheme.lightForeground.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(DashboardOption option, Size size, bool isDark) {
    return GestureDetector(
      onTap: () => _navigateToPicker(option.isSend),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: size.width * 0.4,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              option.color.withOpacity(isDark ? 0.3 : 0.15),
              option.color.withOpacity(isDark ? 0.15 : 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          border: Border.all(
            color: option.color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: option.color.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMD),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with animated background
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(AppTheme.spacingMD),
                    decoration: BoxDecoration(
                      color: option.color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      option.icon,
                      size: 32,
                      color: option.color,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMD),

                  // Title
                  Text(
                    option.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: option.color,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),

                  // Subtitle
                  Text(
                    option.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppTheme.darkForeground.withOpacity(0.7)
                              : AppTheme.lightForeground.withOpacity(0.7),
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXL),
          ),
        ),
        padding: const EdgeInsets.all(AppTheme.spacingLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLG),

            // Title
            Row(
              children: [
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMD),

            // Theme Toggle
            Consumer<AppProvider>(
              builder: (context, appProvider, _) {
                return _buildSettingsTile(
                  icon: appProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  title: 'Dark Mode',
                  subtitle: appProvider.isDarkMode ? 'On' : 'Off',
                  trailing: Switch(
                    value: appProvider.isDarkMode,
                    onChanged: (value) => appProvider.toggleTheme(),
                    activeColor: AppTheme.primaryColor,
                  ),
                  isDark: isDark,
                );
              },
            ),

            const Divider(height: AppTheme.spacingLG),

            // Storage Permission
            _buildSettingsTile(
              icon: Icons.folder_outlined,
              title: 'Storage Access',
              subtitle: 'Manage file permissions',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showStorageInfo(context),
              isDark: isDark,
            ),

            // Network Info
            _buildSettingsTile(
              icon: Icons.wifi_outlined,
              title: 'Network',
              subtitle: 'Check connection status',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showNetworkInfo(context),
              isDark: isDark,
            ),

            const Divider(height: AppTheme.spacingLG),

            // About - App Info
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'About Hermes',
              subtitle: 'v${AppConstants.appVersion}',
              trailing: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () => _showAboutDialog(context),
              ),
              isDark: isDark,
            ),

            // Version info at bottom
            const SizedBox(height: AppTheme.spacingMD),
            Center(
              child: Text(
                'Made with ❤️ using Flutter',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppTheme.darkForeground.withOpacity(0.4)
                          : AppTheme.lightForeground.withOpacity(0.4),
                    ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingSM),
          ],
        ),
      ),
    );
  }

  void _showStorageInfo(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Storage permissions managed by system'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showNetworkInfo(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connect to Wi-Fi for file transfer'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingSM),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppTheme.spacingMD),
            const Text(AppConstants.appName),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _aboutInfoRow('Version', AppConstants.appVersion),
            _aboutInfoRow('Build', 'Release'),
            const SizedBox(height: AppTheme.spacingMD),
            const Text(
              'Hermes is a fast and secure local file transfer application.'
              '\nTransfer files between devices on the same Wi-Fi network.',
            ),
            const SizedBox(height: AppTheme.spacingMD),
            const Text(
              '© 2024 Hermes Team',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _aboutInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: isDark
                    ? AppTheme.darkForeground.withOpacity(0.6)
                    : AppTheme.lightForeground.withOpacity(0.6),
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}