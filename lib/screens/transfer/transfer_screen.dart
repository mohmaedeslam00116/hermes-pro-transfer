import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/transfer_file.dart';
import '../../providers/transfer_provider.dart';
import '../../services/network_service.dart';
import '../../models/transfer_state.dart' show TransferTechnology;

class TransferScreen extends StatefulWidget {
  final List<TransferFile> files;
  final TransferTechnology technology;
  
  const TransferScreen({
    super.key,
    required this.files,
    required this.technology,
  });

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final NetworkService _networkService = NetworkService();
  String? _serverUrl;
  String? _localIp;
  bool _isServerRunning = false;
  
  @override
  void initState() {
    super.initState();
    _startServer();
  }
  
  Future<void> _startServer() async {
    final provider = context.read<TransferProvider>();
    await provider.prepareSend(widget.files);
    
    final ip = await _networkService.getLocalIpAddress();
    setState(() {
      _localIp = ip;
      _serverUrl = 'http://$ip:8080';
    });
    
    final success = await provider.startServer(widget.technology);
    setState(() {
      _isServerRunning = success;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final totalSize = widget.files.fold<int>(0, (sum, f) => sum + f.size);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sending Files'),
      ),
      body: SafeArea(
        child: Consumer<TransferProvider>(
          builder: (context, provider, _) {
            final state = provider.state;
            
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1565C0).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.qr_code,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Scan to Download',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Use Hermes on another device to scan',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (_serverUrl != null) ...[
                            QrImageView(
                              data: '$_serverUrl?files=true',
                              version: QrVersions.auto,
                              size: 200,
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: _serverUrl!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Link copied!')),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _serverUrl!,
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.copy, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Files to Send',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...widget.files.take(3).map((file) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.file_present),
                            title: Text(file.name),
                            trailing: Text(file.formattedSize),
                          )),
                          if (widget.files.length > 3)
                            Text(
                              '+${widget.files.length - 3} more files',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total:'),
                              Text(
                                _formatBytes(totalSize),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_isServerRunning)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Server Running',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                if (_localIp != null)
                                  Text(
                                    'Waiting for connections...',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      provider.cancel();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
  
  @override
  void dispose() {
    context.read<TransferProvider>().reset();
    super.dispose();
  }
}