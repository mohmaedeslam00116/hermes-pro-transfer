import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/desktop_theme.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final _urlController = TextEditingController();
  final _dio = Dio();
  
  bool _isDownloading = false;
  double _progress = 0;
  String? _statusMessage;
  String? _downloadedFileName;
  String? _errorMessage;

  @override
  void dispose() {
    _urlController.dispose();
    _dio.close();
    super.dispose();
  }

  Future<void> _downloadFile() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a download URL';
      });
      return;
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      setState(() {
        _errorMessage = 'Invalid URL format';
      });
      return;
    }

    try {
      setState(() {
        _isDownloading = true;
        _progress = 0;
        _errorMessage = null;
        _statusMessage = 'Connecting...';
        _downloadedFileName = null;
      });

      // First, try to get file info
      final infoResponse = await _dio.head(url);
      final contentDisposition = infoResponse.headers.value('content-disposition');
      
      String fileName = 'hermes_download';
      if (contentDisposition != null) {
        final match = RegExp(r'filename="?([^";\n]+)"?').firstMatch(contentDisposition);
        if (match != null) {
          fileName = match.group(1) ?? fileName;
        }
      }

      // Get downloads directory
      final dir = await getDownloadsDirectory() ?? Directory.current;
      final savePath = '${dir.path}/$fileName';

      setState(() {
        _downloadedFileName = fileName;
        _statusMessage = 'Downloading...';
      });

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && mounted) {
            setState(() {
              _progress = received / total;
            });
          }
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 30),
        ),
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _statusMessage = 'Download complete!';
          _progress = 1.0;
        });
        
        _showSuccessDialog(savePath);
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _errorMessage = _getErrorMessage(e);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _errorMessage = 'Download failed: $e';
        });
      }
    }
  }

  void _showSuccessDialog(String path) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesktopTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: DesktopTheme.success.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: DesktopTheme.success,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Download Complete!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _downloadedFileName ?? 'File',
              style: TextStyle(
                color: DesktopTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              path,
              style: TextStyle(
                color: DesktopTheme.textSecondary.withOpacity(0.7),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _urlController.clear();
                    },
                    child: const Text('Download Another'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out';
      case DioExceptionType.receiveTimeout:
        return 'Download timed out';
      case DioExceptionType.badResponse:
        return 'Server error: ${e.response?.statusCode}';
      case DioExceptionType.connectionError:
        return 'Could not connect to server';
      default:
        return 'Download failed: ${e.message}';
    }
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
                  color: DesktopTheme.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.download_rounded,
                  color: DesktopTheme.accent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Receive Files',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Download files from other devices on your network',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Main content
          Expanded(
            child: _isDownloading ? _buildDownloadingPanel() : _buildUrlInput(),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlInput() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: DesktopTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.link_rounded,
                size: 64,
                color: DesktopTheme.accent,
              ),
            ),
            const SizedBox(height: 32),

            // Title
            const Text(
              'Enter Download Link',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Paste the link shared by the sender',
              style: TextStyle(
                color: DesktopTheme.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),

            // URL input
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'http://192.168.1.x:8080/download',
                prefixIcon: const Icon(Icons.link),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste),
                  onPressed: () async {
                    final data = await Clipboard.getData('text/plain');
                    if (data?.text != null) {
                      _urlController.text = data!.text!;
                    }
                  },
                  tooltip: 'Paste from clipboard',
                ),
                errorText: _errorMessage,
              ),
              style: const TextStyle(
                fontFamily: 'monospace',
              ),
              onSubmitted: (_) => _downloadFile(),
              enabled: !_isDownloading,
            ),
            const SizedBox(height: 24),

            // Download button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _downloadFile,
                icon: const Icon(Icons.download_rounded),
                label: const Text('Download'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesktopTheme.accent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Instructions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: DesktopTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: DesktopTheme.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'How it works',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStep(1, 'Sender selects a file and starts sharing'),
                  const SizedBox(height: 12),
                  _buildStep(2, 'Share the download link with you'),
                  const SizedBox(height: 12),
                  _buildStep(3, 'Paste the link above to download'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: DesktopTheme.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              color: DesktopTheme.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: DesktopTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadingPanel() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated progress circle
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 8,
                      backgroundColor: DesktopTheme.surfaceLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        DesktopTheme.accent,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(_progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _statusMessage ?? 'Downloading...',
                        style: TextStyle(
                          color: DesktopTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // File name
            if (_downloadedFileName != null) ...[
              Text(
                _downloadedFileName!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],

            // Progress bar (alternative view)
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: DesktopTheme.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        DesktopTheme.primaryColor,
                        DesktopTheme.accent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
