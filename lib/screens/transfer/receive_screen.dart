import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/theme/app_theme.dart';
import '../../models/transfer_state.dart';
import '../../services/device_discovery_service.dart';
import '../../services/network_service.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
  final DeviceDiscoveryService _discoveryService = DeviceDiscoveryService();
  MobileScannerController? _scannerController;
  bool _isLoading = true;
  bool _isDownloading = false;
  bool _isCompleted = false;
  bool _isScanning = true;
  bool _torchEnabled = false;
  String? _errorMessage;
  String? _downloadUrl;
  double _downloadProgress = 0;
  final String _downloadSpeed = '0 B/s';
  int _downloadedFiles = 0;
  int get _totalFiles => 1;
  List<DiscoveredDevice> _discoveredDevices = [];

  @override
  void initState() {
    super.initState();
    _initScanner();
    _checkNetwork();
  }

  void _initScanner() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  Future<void> _checkNetwork() async {
    try {
      await _networkService.getLocalIpAddress();
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Try to discover devices automatically
      _discoveredDevices = await _discoveryService.discoverDevices();
      if (_discoveredDevices.isNotEmpty) {
        // Show discovered devices
        setState(() {
          _isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Network error: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isDownloading || _isCompleted) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.startsWith('http')) {
        setState(() {
          _downloadUrl = code;
          _isDownloading = true;
        });

        await _downloadFile(code);
        break;
      }
    }
  }

  /// Connect to discovered device by IP
  Future<void> _connectToDevice(DiscoveredDevice device) async {
    setState(() {
      _downloadUrl = device.url;
      _isDownloading = true;
    });

    await _downloadFile(device.url);
  }

  /// Manual IP entry
  void _showManualEntryDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Server IP'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            hintText: '192.168.1.100:8080',
            labelText: 'Server Address',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final ip = controller.text.trim();
              if (ip.isNotEmpty) {
                final url = ip.startsWith('http') ? ip : 'http://$ip';
                _downloadFile(url);
              }
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadFile(String url) async {
    try {
      final dio = Dio();
      final dir = await getExternalStorageDirectory();
      final savePath = dir?.path ?? '/storage/emulated/0/Download/Hermes';

      final saveDir = Directory(savePath);
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }

      await dio.download(
        url,
        '$savePath/hermes_file_${DateTime.now().millisecondsSinceEpoch}',
        onReceiveProgress: (received, total) {
          if (!mounted) return;
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isCompleted = true;
          _downloadedFiles = 1;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Download failed: $e';
          _isDownloading = false;
        });
      }
    }
  }

  void _toggleTorch() async {
    await _scannerController?.toggleTorch();
    setState(() {
      _torchEnabled = !_torchEnabled;
    });
  }

  void _rescan() async {
    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });

    // Discover devices
    _discoveredDevices = await _discoveryService.discoverDevices();

    if (!mounted) return;

    setState(() {
      if (_discoveredDevices.isNotEmpty) {
        _isScanning = false;
      }
    });
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _discoveryService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('Receive Files'),
        backgroundColor:
            isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        foregroundColor:
            isDark ? AppTheme.darkForeground : AppTheme.lightForeground,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_torchEnabled ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleTorch,
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => _scannerController?.switchCamera(),
          ),
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Preparing scanner...',
              style: TextStyle(
                color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
              ),
            ),
          ],
        ),
      );
    }

    if (_isCompleted) {
      return _buildCompletedView(isDark);
    }

    if (_isDownloading) {
      return _buildDownloadingView(isDark);
    }

    if (_errorMessage != null) {
      return _buildErrorView(isDark);
    }

    // Show discovered devices if any
    if (!_isScanning && _discoveredDevices.isNotEmpty) {
      return _buildDiscoveredDevicesView(isDark);
    }

    return _buildScannerView(isDark);
  }

  Widget _buildDiscoveredDevicesView(bool isDark) {
    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Icon(
                Icons.devices,
                size: 64,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Devices Found',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color:
                      isDark ? AppTheme.darkForeground : AppTheme.lightForeground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a device to receive files from',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: _discoveredDevices.length,
                  itemBuilder: (context, index) {
                    final device = _discoveredDevices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.smartphone,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        title: Text(device.name),
                        subtitle: Text(device.ip),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _connectToDevice(device),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              OutlinedButton.icon(
                onPressed: _rescan,
                icon: const Icon(Icons.refresh),
                label: const Text('Scan Again'),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _showManualEntryDialog,
                icon: const Icon(Icons.keyboard),
                label: const Text('Enter IP Manually'),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isScanning = true;
                  });
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR Code'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScannerView(bool isDark) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.3),
                    AppTheme.primaryColor.withOpacity(0.1),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  if (_scannerController != null)
                    MobileScanner(
                      controller: _scannerController!,
                      onDetect: _onDetect,
                    ),
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.primaryColor,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: _buildCorners(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Scan QR Code',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark ? AppTheme.darkForeground : AppTheme.lightForeground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Point camera at sender's QR code to start receiving files",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTechnologyInfo(isDark),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _showManualEntryDialog,
                  icon: const Icon(Icons.keyboard),
                  label: const Text('Enter IP Manually'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCorners() {
    const cornerSize = 30.0;
    const strokeWidth = 4.0;
    final color = AppTheme.primaryColor;

    return [
      Positioned(
        top: -2,
        left: -2,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: strokeWidth),
              left: BorderSide(color: color, width: strokeWidth),
            ),
          ),
        ),
      ),
      Positioned(
        top: -2,
        right: -2,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: strokeWidth),
              right: BorderSide(color: color, width: strokeWidth),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: -2,
        left: -2,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: strokeWidth),
              left: BorderSide(color: color, width: strokeWidth),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: -2,
        right: -2,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: strokeWidth),
              right: BorderSide(color: color, width: strokeWidth),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildTechnologyInfo(bool isDark) {
    IconData icon;
    String name;
    String description;

    switch (widget.technology) {
      case TransferTechnology.http:
        icon = Icons.wifi;
        name = 'HTTP Server';
        description = 'Fast and reliable transfer via local network';
        break;
      case TransferTechnology.wifiDirect:
        icon = Icons.wifi;
        name = 'Wi-Fi Direct';
        description = 'Direct device-to-device connection';
        break;
      case TransferTechnology.webrtc:
        icon = Icons.link;
        name = 'WebRTC';
        description = 'Peer-to-peer secure connection';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppTheme.darkForeground
                        : AppTheme.lightForeground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadingView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: _downloadProgress,
                    strokeWidth: 8,
                    backgroundColor:
                        isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                    valueColor:
                        const AlwaysStoppedAnimation(AppTheme.primaryColor),
                  ),
                  Center(
                    child: Text(
                      '${(_downloadProgress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Downloading...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkForeground : AppTheme.lightForeground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Speed: $_downloadSpeed',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_downloadedFiles / $_totalFiles files',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Transfer Complete!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkForeground : AppTheme.lightForeground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_downloadedFiles files received successfully',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.home),
              label: const Text('Back to Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 80,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkForeground : AppTheme.lightForeground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _isDownloading = false;
                  _isScanning = true;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}