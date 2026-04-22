import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/transfer_file.dart';
import '../../models/transfer_state.dart';
import '../transfer/transfer_screen.dart';
import '../transfer/receive_screen.dart';

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

/// Modern Technology Picker Screen with improved UI/UX
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
  List<TransferFile> _selectedFiles = [];
  bool _isLoading = false;
  String? _errorMessage;

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
      _errorMessage = null;
    });
  }

  Future<void> _pickFiles() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        final files = result.files.map((file) {
          return TransferFile(
            name: file.name,
            path: file.path ?? '',
            size: file.size,
            mimeType: _getMimeType(file.extension ?? ''),
          );
        }).toList();

        setState(() {
          _selectedFiles = files;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick files: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearFiles() {
    setState(() {
      _selectedFiles = [];
    });
  }

  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'mp3':
        return 'audio/mpeg';
      case 'mp4':
        return 'video/mp4';
      case 'zip':
        return 'application/zip';
      default:
        return 'application/octet-stream';
    }
  }

  bool get _canProceed {
    // Must select a technology
    if (_selectedTechnology == null) return false;
    
    // For send mode, need at least one file selected
    if (widget.mode == TransferMode.send && _selectedFiles.isEmpty) return false;
    
    return true;
  }

  void _startTransfer() {
    // Validate before proceeding
    if (!_canProceed) {
      if (_selectedTechnology == null) {
        setState(() {
          _errorMessage = 'Please select a transfer method';
        });
        return;
      }
      if (widget.mode == TransferMode.send && _selectedFiles.isEmpty) {
        setState(() {
          _errorMessage = 'Please select files to send';
        });
        return;
      }
      return;
    }

    final appProvider = context.read<AppProvider>();
    appProvider.setTechnology(_selectedTechnology!);

    if (widget.mode == TransferMode.send) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TransferScreen(
            files: _selectedFiles,
            technology: _selectedTechnology!,
            mode: widget.mode,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReceiveScreen(
            technology: _selectedTechnology!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSend = widget.mode == TransferMode.send;
    final selectedTech = _technologies.firstWhere(
      (t) => t.technology == _selectedTechnology,
      orElse: () => _technologies.first,
    );

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
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            isSend
                                ? 'Select files to share'
                                : 'Connect to sender',
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
                        isSend
                            ? 'Select how you want to send your files'
                            : 'Select how you want to receive files',
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

                      // Error message
                      if (_errorMessage != null) ...[
                        const SizedBox(height: AppTheme.spacingMD),
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingMD),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium),
                            border: Border.all(
                              color: AppTheme.errorColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppTheme.errorColor,
                                size: 20,
                              ),
                              const SizedBox(width: AppTheme.spacingSM),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: AppTheme.errorColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom Section
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMD),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.darkSurface.withOpacity(0.8)
                      : AppTheme.lightSurface.withOpacity(0.8),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusXL),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // File Selection (for Send mode)
                    if (isSend && _selectedTechnology != null) ...[
                      // Selected files list
                      if (_selectedFiles.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppTheme.spacingMD),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.darkMuted.withOpacity(0.3)
                                : AppTheme.lightMuted,
                            borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_selectedFiles.length} file(s) selected',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: _clearFiles,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spacingSM),
                              Text(
                                _selectedFiles
                                    .map((f) => f.name)
                                    .join(', '),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: isDark
                                          ? AppTheme.darkForeground
                                              .withOpacity(0.6)
                                          : AppTheme.lightForeground
                                              .withOpacity(0.6),
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingMD),
                      ],
                      
                      // File Picker Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _pickFiles,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppTheme.spacingMD),
                          ),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  _selectedFiles.isEmpty
                                      ? Icons.add
                                      : Icons.add_circle_outline,
                                ),
                          label: Text(
                            _selectedFiles.isEmpty
                                ? 'Pick Files to Send'
                                : 'Add More Files',
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMD),
                    ],

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canProceed ? _startTransfer : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _technologies
                              .firstWhere(
                                (t) => t.technology == _selectedTechnology,
                                orElse: () => _technologies.first,
                              )
                              .color,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacingMD),
                          disabledBackgroundColor: isDark
                              ? AppTheme.darkMuted
                              : AppTheme.lightMuted,
                        ),
                        child: Text(
                          isSend ? 'Send Files' : 'Continue',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    
                    // Hint text
                    const SizedBox(height: AppTheme.spacingSM),
                    Text(
                      isSend
                          ? 'Select at least one file to continue'
                          : 'Select a transfer method to continue',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppTheme.darkForeground
                                    .withOpacity(0.4)
                                : AppTheme.lightForeground
                                    .withOpacity(0.4),
                          ),
                      textAlign: TextAlign.center,
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
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

                  // Radio indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
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