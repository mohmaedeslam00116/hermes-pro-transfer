import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/transfer_state.dart';
import '../transfer/transfer_screen.dart';

/// Technology Option Data
class TechnologyOption {
  final TransferTechnology technology;
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final List<String> features;

  const TechnologyOption({
    required this.technology,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.features,
  });
}

/// Modern Technology Picker Screen
class TechnologyPickerScreen extends StatefulWidget {
  final TransferMode mode;

  const TechnologyPickerScreen({
    super.key,
    required this.mode,
  });

  @override
  State<TechnologyPickerScreen> createState() => _TechnologyPickerScreenState();
}

class _TechnologyPickerScreenState extends State<TechnologyPickerScreen> {
  TransferTechnology? _selectedTechnology;

  static const List<TechnologyOption> _technologies = [
    TechnologyOption(
      technology: TransferTechnology.http,
      icon: Icons.language,
      title: 'HTTP Server',
      description: 'Simple and reliable. Works on any Wi-Fi network.',
      color: AppTheme.primaryColor,
      features: [
        '✓ Works everywhere',
        '✓ No configuration',
        '✓ Cross-platform',
      ],
    ),
    TechnologyOption(
      technology: TransferTechnology.wifiDirect,
      icon: Icons.wifi_tethering,
      title: 'Wi-Fi Direct',
      description: 'Direct connection between nearby devices.',
      color: AppTheme.secondaryColor,
      features: [
        '✓ Peer-to-peer',
        '✓ No router needed',
        '✓ Fast speeds',
      ],
    ),
    TechnologyOption(
      technology: TransferTechnology.webrtc,
      icon: Icons.cast_connected,
      title: 'WebRTC',
      description: 'Modern P2P with low latency and encryption.',
      color: AppTheme.accentColor,
      features: [
        '✓ Low latency',
        '✓ Secure P2P',
        '✓ Adaptive',
      ],
    ),
  ];

  void _selectTechnology(TechnologyOption option) {
    setState(() {
      _selectedTechnology = option.technology;
    });
  }

  void _startTransfer() {
    if (_selectedTechnology == null) return;

    final appProvider = context.read<AppProvider>();
    appProvider.setTechnology(_selectedTechnology!);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransferScreen(
          files: const [],
          technology: _selectedTechnology!,
          mode: widget.mode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSend = widget.mode == TransferMode.send;

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
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: AppTheme.spacingSM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSend ? 'Send Files' : 'Receive Files',
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          Text(
                            isSend ? 'Select files to share' : 'Connect to sender',
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
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppTheme.spacingMD),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'Choose Transfer Method',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppTheme.spacingSM),
                      Text(
                        'Select how you want to transfer your files',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppTheme.darkForeground.withOpacity(0.6)
                                  : AppTheme.lightForeground
                                      .withOpacity(0.6),
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacingLG),

                      // Technology Cards
                      ..._technologies.map(
                        (tech) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppTheme.spacingMD,
                          ),
                          child: _buildTechnologyCard(tech, isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Button
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMD),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _selectedTechnology != null ? _startTransfer : null,
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppTheme.spacingSM),
                      child: Text(
                        isSend ? 'Select Files & Continue' : 'Continue',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTechnologyCard(TechnologyOption option, bool isDark) {
    final isSelected = _selectedTechnology == option.technology;

    return GestureDetector(
      onTap: () => _selectTechnology(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? option.color.withOpacity(isDark ? 0.2 : 0.15)
              : isDark
                  ? AppTheme.darkSurface
                  : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: isSelected
                ? option.color
                : isDark
                    ? AppTheme.darkBorder.withOpacity(0.3)
                    : AppTheme.lightBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: option.color.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMD),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMD),
                    decoration: BoxDecoration(
                      color: option.color.withOpacity(isDark ? 0.3 : 0.2),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Icon(
                      option.icon,
                      color: option.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMD),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? option.color : null,
                              ),
                        ),
                        const SizedBox(height: AppTheme.spacingXS),
                        Text(
                          option.description,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? AppTheme.darkForeground
                                            .withOpacity(0.7)
                                        : AppTheme.lightForeground
                                            .withOpacity(0.7),
                                  ),
                        ),
                        const SizedBox(height: AppTheme.spacingSM),
                        Wrap(
                          spacing: AppTheme.spacingSM,
                          runSpacing: AppTheme.spacingXS,
                          children: option.features
                              .map(
                                (f) => Text(
                                  f,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: option.color.withOpacity(0.8),
                                      ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                  // Radio
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? option.color
                            : isDark
                                ? AppTheme.darkMuted
                                : AppTheme.lightMuted,
                        width: 2,
                      ),
                      color: isSelected ? option.color : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}