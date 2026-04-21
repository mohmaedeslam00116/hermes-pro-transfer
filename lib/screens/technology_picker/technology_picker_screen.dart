import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/transfer_file.dart';
import '../../models/transfer_state.dart';
import '../transfer/transfer_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final isSend = widget.mode == TransferMode.send;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isSend ? 'Send Files' : 'Receive Files'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose Transfer Technology',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select how you want to transfer your files',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildTechnologyCard(
                      technology: TransferTechnology.http,
                      icon: Icons.http,
                      title: 'HTTP Server',
                      description: 'Simple and reliable. Works on any network.',
                      color: const Color(0xFF1565C0),
                      features: const [
                        'Works everywhere',
                        'No configuration needed',
                        'Cross-platform support',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTechnologyCard(
                      technology: TransferTechnology.wifiDirect,
                      icon: Icons.wifi_tethering,
                      title: 'Wi-Fi Direct',
                      description: 'Peer-to-peer connection without router.',
                      color: const Color(0xFF00BFA5),
                      features: const [
                        'Direct device-to-device',
                        'No internet needed',
                        'Very fast speeds',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTechnologyCard(
                      technology: TransferTechnology.webrtc,
                      icon: Icons.cast,
                      title: 'WebRTC',
                      description: 'Modern P2P technology with low latency.',
                      color: const Color(0xFFE53935),
                      features: const [
                        'Low latency',
                        'Secure encryption',
                        'Adaptive routing',
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (isSend) ...[
                _buildFileSelector(),
                const SizedBox(height: 16),
              ],
              ElevatedButton(
                onPressed: _selectedTechnology != null && (isSend ? _selectedFiles.isNotEmpty : true)
                    ? () => _startTransfer()
                    : null,
                child: Text(isSend ? 'Start Sending' : 'Start Receiving'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTechnologyCard({
    required TransferTechnology technology,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required List<String> features,
  }) {
    final isSelected = _selectedTechnology == technology;
    
    return Card(
      color: isSelected ? color.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() => _selectedTechnology = technology);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: features.map((f) => Chip(
                        label: Text(f, style: const TextStyle(fontSize: 10)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )).toList(),
                    ),
                  ],
                ),
              ),
              Radio<TransferTechnology>(
                value: technology,
                groupValue: _selectedTechnology,
                onChanged: (value) {
                  setState(() => _selectedTechnology = value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFileSelector() {
    return Card(
      child: InkWell(
        onTap: _pickFiles,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.attach_file,
                  color: Color(0xFF1565C0),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedFiles.isEmpty
                          ? 'Select Files'
                          : '${_selectedFiles.length} file(s) selected',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_selectedFiles.isNotEmpty)
                      Text(
                        _selectedFiles
                            .map((f) => f.name)
                            .take(3)
                            .join(', ') +
                            (_selectedFiles.length > 3
                                ? ' +${_selectedFiles.length - 3}'
                                : ''),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _pickFiles() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );
      
      if (result != null) {
        setState(() {
          _selectedFiles = result.files.map((file) {
            return TransferFile(
              name: file.name,
              path: file.path ?? '',
              size: file.size,
              mimeType: _getMimeType(file.name),
            );
          }).toList();
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  String _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    final mimeTypes = {
      'pdf': 'application/pdf',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'mp4': 'video/mp4',
      'mp3': 'audio/mpeg',
      'zip': 'application/zip',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    };
    return mimeTypes[ext] ?? 'application/octet-stream';
  }
  
  void _startTransfer() {
    if (widget.mode == TransferMode.send) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TransferScreen(
            files: _selectedFiles,
            technology: _selectedTechnology ?? TransferTechnology.http,
          ),
        ),
      );
    }
  }
}