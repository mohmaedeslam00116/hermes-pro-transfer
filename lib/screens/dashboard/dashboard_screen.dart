import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
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

/// Modern Dashboard Screen
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
                    // Logo
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
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMD),

                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hermes',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Local File Transfer',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppTheme.darkForeground
                                              .withOpacity(0.6)
                                          : AppTheme.lightForeground
                                              .withOpacity(0.6),
                                    ),
                          ),
                        ],
                      ),
                    ),

                    // Settings Button
                    IconButton(
                      onPressed: () => _showSettingsSheet(context),
                      icon: Icon(
                        Icons.settings_outlined,
                        color: isDark
                            ? AppTheme.darkForeground.withOpacity(0.7)
                            : AppTheme.lightForeground.withOpacity(0.7),
                      ),
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

              // Footer
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

  Widget _buildOptionCard(DashboardOption option, Size size, bool isDark) {
    return GestureDetector(
      onTap: () => _navigateToPicker(option.isSend),
      child: Container(
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
                  // Icon
                  Container(
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
                    style:
                        Theme.of(context).textTheme.titleLarge?.copyWith(
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
                              : AppTheme.lightForeground
                                  .withOpacity(0.7),
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
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacingLG),

            // Theme Toggle
            Consumer<AppProvider>(
              builder: (context, appProvider, _) {
                return _buildSettingsTile(
                  icon: isDark ? Icons.dark_mode : Icons.light_mode,
                  title: 'Dark Mode',
                  trailing: Switch(
                    value: appProvider.isDarkMode,
                    onChanged: (value) => appProvider.toggleTheme(),
                    activeColor: AppTheme.primaryColor,
                  ),
                );
              },
            ),

            // Storage Permission
            _buildSettingsTile(
              icon: Icons.folder,
              title: 'Storage Access',
              subtitle: 'Manage file permissions',
              onTap: () {},
            ),

            // About
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'About Hermes',
              subtitle: 'Version 1.0.0-beta.1',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.primaryColor,
      ),
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