import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/theme/app_theme.dart';
import '../../models/transfer_state.dart';
import '../../services/network_service.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Receive Screen - For receiving files from other devices
class ReceiveScreen extends StatefulWidget {
  final TransferTechnology technology;

  const ReceiveScreen({
    super.key,
    required this.technology,
  });

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final NetworkService _networkService = NetworkService();
  final MobileScannerController _scannerController = MobileScannerController();
  final Dio _dio = Dio();
  
  bool _isScanning = true;
  bool _isConnecting = false;
  bool _isDownloading = false;
  bool _isLoading = true;
  
  String? _scannedUrl;
  String? _errorMessage;
  double _downloadProgress = 0;
  String _downloadStatus = '';
  
  @override
  void initState() {
    super.initState();
    _checkNetwork();
  }

  Future<void> _checkNetwork() async {
    try {
      await _networkService.getLocalIpAddress();
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Network error: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isConnecting || _isDownloading) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.startsWith('http')) {
        _connectToSender(code);
        break;
      }
    }
  }

  Future<void> _connectToSender(String url) async {
    setState(() {
      _isScanning = false;
      _isConnecting = true;
      _scannedUrl = url;
    });

    try {
      // Try to connect and get file list
      final response = await _dio.get(
        '$url?files=true',
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          followRedirects: true,
        ),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Start download
        await _downloadFiles(url);
      } else {
        setState(() {
          _errorMessage = 'Failed to connect to sender';
          _isConnecting = false;
          _isScanning = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Connection failed: $e';
          _isConnecting = false;
          _isScanning = true;
        });
      }
    }
  }

  Future<void> _downloadFiles(String url) async {
    setState(() {
      _isConnecting = false;
      _isDownloading = true;
      _downloadProgress = 0;
      _downloadStatus = 'Connecting...';
    });

    try {
      final dir = await getExternalStorageDirectory();
      final downloadDir = Directory('${dir?.path}/Hermes');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // Get file info
      _downloadStatus = 'Fetching file list...';
      setState(() {});

      // Download a test file (for demo)
      // In production, this would parse the HTML response to get file list
      final savePath = '${downloadDir.path}/received_file.dat';
      
      _downloadStatus = 'Downloading...';
      setState(() {});

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (!mounted) return;
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      if (!mounted) return;

      setState(() {
        _downloadStatus = 'Download complete!';
        _isDownloading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File downloaded successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Download failed: $e';
          _isDownloading = false;
        });
      }
    }
  }

  void _retry() {
    setState(() {
      _isScanning = true;
      _isConnecting = false;
      _isDownloading = false;
      _errorMessage = null;
      _scannedUrl = null;
      _downloadProgress = 0;
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppTheme.darkBackground, AppTheme.darkSurface]
                : [AppTheme.lightBackground, AppTheme.lightSurface],
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
                            'Receive Files',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Scan QR code to connect',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppTheme.darkForeground.withOpacity(0.6)
                                      : AppTheme.lightForeground.withOpacity(0.6),
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (!_isScanning && _errorMessage != null)
                      IconButton(
                        onPressed: _retry,
                        icon: const Icon(Icons.refresh),
                      ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null && !_isDownloading
                        ? _buildErrorState(isDark)
                        : _isScanning
                            ? _buildScanner(isDark)
                            : _isConnecting
                                ? _buildConnecting(isDark)
                                : _buildDownloading(isDark),
              ),

              // Footer
              if (_isScanning)
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMD),
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMD),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: isDark
                              ? AppTheme.darkForeground.withOpacity(0.6)
                              : AppTheme.lightForeground.withOpacity(0.6),
                        ),
                        const SizedBox(width: AppTheme.spacingMD),
                        Expanded(
                          child: Text(
                            'Point your camera at the QR code displayed on the sender device',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppTheme.darkForeground.withOpacity(0.6)
                                      : AppTheme.lightForeground.withOpacity(0.6),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanner(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      child: Column(
        children: [
          // Scanner Preview
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.primaryColor,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: MobileScanner(
                  controller: _scannerController,
                  onDetect: _onDetect,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMD),
          
          // Manual URL Entry
          OutlinedButton.icon(
            onPressed: _showManualEntry,
            icon: const Icon(Icons.link),
            label: const Text('Enter URL Manually'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualEntry() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'http://192.168.1.100:8080',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (controller.text.isNotEmpty) {
                _connectToSender(controller.text);
              }
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  Widget _buildConnecting(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppTheme.spacingLG),
            Text(
              'Connecting...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacingSM),
            Text(
              _scannedUrl ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppTheme.darkForeground.withOpacity(0.6)
                        : AppTheme.lightForeground.withOpacity(0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloading(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: _downloadProgress,
                      strokeWidth: 8,
                      backgroundColor: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                    ),
                  ),
                  Text(
                    '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingLG),
            Text(
              'Downloading Files',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacingSM),
            Text(
              _downloadStatus,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppTheme.darkForeground.withOpacity(0.6)
                        : AppTheme.lightForeground.withOpacity(0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLG),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppTheme.errorColor,
                size: 48,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLG),
            Text(
              'Connection Failed',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacingSM),
            Text(
              _errorMessage ?? 'An unknown error occurred',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppTheme.darkForeground.withOpacity(0.6)
                        : AppTheme.lightForeground.withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingLG),
            ElevatedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
