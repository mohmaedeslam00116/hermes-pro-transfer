import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import '../services/desktop_http_server.dart';
import '../services/network_info_service.dart';
import '../widgets/desktop_theme.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final _server = DesktopHttpServer();
  final _urlController = TextEditingController();
  
  List<File>? _selectedFiles;
  bool _isServerRunning = false;
  bool _isDragging = false;
  String? _localIp;
  String? _downloadUrl;
  // ignore: unused_field
  int _connectedDevices = 0;
  void initState() {
    super.initState();
    _localIp = NetworkInfoService.getLocalIpSync();
  }

  @override
  void dispose() {
    _server.stopServer();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _selectFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFiles = result.files
            .where((f) => f.path != null)
            .map((f) => File(f.path!))
            .toList();
      });
    }
  }

  String _getFileName(File file) {
    return file.path.split('/').last;
  }

  int _getFileSize(File file) {
    try {
      return file.statSync().size;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _startSharing() async {
    if (_selectedFiles == null || _selectedFiles!.isEmpty) return;

    final firstFile = _selectedFiles!.first;
    final url = await _server.startServer(
      filePath: firstFile.path,
      fileName: _getFileName(firstFile),
    );

    setState(() {
      _downloadUrl = '$url/download';
      _isServerRunning = true;
      _connectedDevices = 0;
    });
  }

  Future<void> _stopSharing() async {
    await _server.stopServer();
    setState(() {
      _isServerRunning = false;
      _downloadUrl = null;
    });
  }

  void _copyToClipboard() {
    if (_downloadUrl != null) {
      Clipboard.setData(ClipboardData(text: _downloadUrl!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: DesktopTheme.success),
              SizedBox(width: 12),
              Text('Link copied to clipboard!'),
            ],
          ),
          backgroundColor: DesktopTheme.cardColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DesktopTheme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.upload_file_rounded,
                  color: DesktopTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Send Files',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedFiles?.isNotEmpty == true
                        ? '${_selectedFiles!.length} file(s) selected'
                        : 'Select files to share over LAN',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const Spacer(),
              if (_localIp != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: DesktopTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wifi_rounded,
                        size: 16,
                        color: DesktopTheme.success,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _localIp!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 40),

          // Main content
          Expanded(
            child: _isServerRunning ? _buildSharingPanel() : _buildFileSelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildFileSelector() {
    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: (details) {
        setState(() {
          _selectedFiles = details.files.map((x) => File(x.path)).toList();
          _isDragging = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isDragging
              ? DesktopTheme.primaryColor.withOpacity(0.1)
              : DesktopTheme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isDragging
                ? DesktopTheme.primaryColor
                : Colors.white.withOpacity(0.05),
            width: 2,
          ),
        ),
        child: _selectedFiles?.isNotEmpty == true
            ? _buildSelectedFiles()
            : _buildDropZone(),
      ),
    );
  }

  Widget _buildDropZone() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: _isDragging
                  ? DesktopTheme.primaryColor.withOpacity(0.2)
                  : DesktopTheme.surfaceLight,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              _isDragging ? Icons.file_download : Icons.cloud_upload_rounded,
              size: 64,
              color: _isDragging
                  ? DesktopTheme.primaryColor
                  : DesktopTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _isDragging ? 'Drop files here' : 'Drag & drop files here',
            style: TextStyle(
              color: _isDragging
                  ? DesktopTheme.primaryColor
                  : DesktopTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'or browse from your computer',
            style: TextStyle(
              color: DesktopTheme.textSecondary.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _selectFiles,
            icon: const Icon(Icons.folder_open_rounded),
            label: const Text('Browse Files'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFiles() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header with file count
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: DesktopTheme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.folder_zip_rounded,
                      size: 16,
                      color: DesktopTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedFiles!.length} file(s)',
                      style: const TextStyle(
                        color: DesktopTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => _selectedFiles = null),
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Clear'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _startSharing,
                icon: const Icon(Icons.share_rounded),
                label: const Text('Start Sharing'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // File list
          Expanded(
            child: ListView.separated(
              itemCount: _selectedFiles!.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final file = _selectedFiles![index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DesktopTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                    child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: DesktopTheme.primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getFileIcon(_getFileName(file)),
                          color: DesktopTheme.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getFileName(file),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatFileSize(_getFileSize(file)),
                              style: TextStyle(
                                color: DesktopTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharingPanel() {
    return Column(
      children: [
        // Sharing card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DesktopTheme.primaryColor.withOpacity(0.2),
                DesktopTheme.accent.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: DesktopTheme.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              // Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: DesktopTheme.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: DesktopTheme.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Sharing Active',
                      style: TextStyle(
                        color: DesktopTheme.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // File info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: DesktopTheme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getFileIcon(_server.currentFileName ?? ''),
                      size: 48,
                      color: DesktopTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _server.currentFileName ?? 'File',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ready to download',
                        style: TextStyle(
                          color: DesktopTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Download URL
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: DesktopTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Download Link',
                      style: TextStyle(
                        color: DesktopTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            _downloadUrl ?? '',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 16,
                              color: DesktopTheme.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: _copyToClipboard,
                          icon: const Icon(Icons.copy_rounded),
                          tooltip: 'Copy link',
                          style: IconButton.styleFrom(
                            backgroundColor: DesktopTheme.primaryColor.withOpacity(0.1),
                            foregroundColor: DesktopTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Instructions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DesktopTheme.surfaceLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: DesktopTheme.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Open this link on any device connected to the same network',
                        style: TextStyle(
                          color: DesktopTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Stop sharing button
        OutlinedButton.icon(
          onPressed: _stopSharing,
          icon: const Icon(Icons.stop_circle_rounded),
          label: const Text('Stop Sharing'),
          style: OutlinedButton.styleFrom(
            foregroundColor: DesktopTheme.error,
            side: const BorderSide(color: DesktopTheme.error),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ],
    );
  }

  IconData _getFileIcon(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image_rounded;
      case 'mp4':
      case 'mkv':
      case 'avi':
        return Icons.video_file_rounded;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Icons.audio_file_rounded;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }
}
