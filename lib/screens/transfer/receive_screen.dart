import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/transfer_provider.dart';
import '../../models/transfer_state.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  MobileScannerController? _scannerController;
  bool _isScanning = true;
  bool _isConnecting = false;
  
  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }
  
  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }
  
  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning || _isConnecting) return;
    
    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final value = barcode.rawValue;
      if (value != null && (value.startsWith('http://') || value.startsWith('https://'))) {
        setState(() {
          _isScanning = false;
          _isConnecting = true;
        });
        
        _startDownload(value);
        break;
      }
    }
  }
  
  Future<void> _startDownload(String url) async {
    final provider = context.read<TransferProvider>();
    await provider.connectAndDownload(url, '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive Files'),
        actions: [
          IconButton(
            icon: Icon(
              _scannerController?.torchEnabled ?? false
                  ? Icons.flash_on
                  : Icons.flash_off,
            ),
            onPressed: () {
              _scannerController?.toggleTorch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () {
              _scannerController?.switchCamera();
            },
          ),
        ],
      ),
      body: Consumer<TransferProvider>(
        builder: (context, provider, _) {
          final state = provider.state;
          
          if (state.status == TransferStatus.transferring) {
            return _buildTransferProgress(state);
          } else if (state.status == TransferStatus.completed) {
            return _buildCompleted();
          } else if (state.status == TransferStatus.failed) {
            return _buildError(state.errorMessage ?? 'Unknown error');
          }
          
          return _buildScanner();
        },
      ),
    );
  }
  
  Widget _buildScanner() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              MobileScanner(
                controller: _scannerController,
                onDetect: _onDetect,
              ),
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.qr_code_scanner, size: 48, color: Colors.white54),
              const SizedBox(height: 16),
              const Text(
                'Scan QR Code',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Point your camera at the sender\'s QR code',
                style: TextStyle(color: Colors.grey.shade400),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _showManualEntry(context),
                icon: const Icon(Icons.link),
                label: const Text('Enter URL manually'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTransferProgress(TransferState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 32),
          Text(
            'Downloading...',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: state.progress,
          ),
          const SizedBox(height: 8),
          Text(
            '${state.progressText} - ${state.transferredText}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          Text(
            'Remaining: ${state.remainingTime}',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompleted() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 60,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Download Complete!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your files have been saved successfully',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              context.read<TransferProvider>().reset();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildError(String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error,
              size: 60,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Transfer Failed',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              context.read<TransferProvider>().reset();
              setState(() {
                _isScanning = true;
                _isConnecting = false;
              });
            },
            child: const Text('Try Again'),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              context.read<TransferProvider>().reset();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  void _showManualEntry(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'http://192.168.1.x:8080',
            labelText: 'Server URL',
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                Navigator.of(context).pop();
                setState(() {
                  _isScanning = false;
                  _isConnecting = true;
                });
                _startDownload(url);
              }
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}