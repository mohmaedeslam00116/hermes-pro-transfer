import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transfer_file.dart';

/// HTTP File Transfer Server Service
/// Provides secure file sharing over LAN with path traversal protection
class HttpServerService {
  HttpServer? _server;
  final List<TransferFile> _files = [];
  bool _isRunning = false;
  int _totalBytesTransferred = 0;
  int _connectedClients = 0;

  bool get isRunning => _isRunning;
  int get connectedClients => _connectedClients;
  int get bytesTransferred => _totalBytesTransferred;

  /// Start the HTTP server on specified port
  Future<bool> startServer({
    required int port,
    required List<TransferFile> files,
    Function(int)? onProgress,
  }) async {
    _files.clear();
    _files.addAll(files);
    _totalBytesTransferred = 0;
    _connectedClients = 0;
    _isRunning = true;

    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, port);

      _server!.listen(
        (request) async {
          await _handleRequest(request, onProgress);
        },
        onError: (error) {
          print('Server error: $error');
        },
      );

      return true;
    } catch (e) {
      _isRunning = false;
      print('Failed to start server: $e');
      return false;
    }
  }

  /// Handle incoming HTTP requests with security checks
  Future<void> _handleRequest(
    HttpRequest request,
    Function(int)? onProgress,
  ) async {
    try {
      final uri = request.uri;
      final rawPath = uri.path;
      final path = _sanitizePath(rawPath);

      if (path == null) {
        await _sendErrorResponse(request, HttpStatus.forbidden, 'Invalid path');
        return;
      }

      // Parse query parameters
      final queryParams = uri.queryParameters;
      
      // API endpoints
      if (path == '/files' || path == '/api/files') {
        await _handleFilesList(request);
      } else if (path.startsWith('/download/') || path.startsWith('/api/download/')) {
        // Extract filename from path
        final pathParts = path.split('/').where((p) => p.isNotEmpty).toList();
        final filename = pathParts.last;
        await _handleFileDownload(request, filename, onProgress);
      } else if (queryParams.containsKey('file')) {
        // Alternative: /download?file=filename
        await _handleFileDownload(request, queryParams['file']!, onProgress);
      } else if (path == '/status' || path == '/api/status') {
        await _handleStatus(request);
      } else if (path == '/') {
        await _handleWelcome(request);
      } else {
        await _sendErrorResponse(request, HttpStatus.notFound, 'Not found');
      }
    } catch (e) {
      await _sendErrorResponse(
        request,
        HttpStatus.internalServerError,
        'Server error: ${e.toString()}',
      );
    }
  }

  /// Security: Sanitize paths to prevent path traversal attacks
  String? _sanitizePath(String rawPath) {
    final pathOnly = rawPath.split('?').first;
    final normalized = pathOnly.toLowerCase();

    if (normalized.contains('..') ||
        normalized.contains('%2e') ||
        normalized.contains('%2e%2e') ||
        normalized.contains('\\\\')) {
      return null;
    }

    final cleanPath = pathOnly.replaceAll(RegExp(r'^/+'), '/');
    return cleanPath;
  }

  /// Handle /files endpoint - return list of available files
  Future<void> _handleFilesList(HttpRequest request) async {
    try {
      final fileList = _files.map((f) => {
        'name': f.name,
        'size': f.size,
        'mimeType': f.mimeType,
        'downloadUrl': '/download/${Uri.encodeComponent(f.name)}',
      }).toList();

      request.response.headers.contentType = ContentType.json;
      request.response.headers.set('Access-Control-Allow-Origin', '*');
      request.response.headers.set('Access-Control-Allow-Methods', 'GET, OPTIONS');

      request.response.write(fileList.toString());
      await request.response.close();
    } catch (e) {
      await _sendErrorResponse(request, HttpStatus.internalServerError, e.toString());
    }
  }

  /// Handle file download with security checks
  Future<void> _handleFileDownload(
    HttpRequest request,
    String filename,
    Function(int)? onProgress,
  ) async {
    TransferFile? file;
    
    try {
      // Decode filename if URL encoded
      final decodedFilename = Uri.decodeComponent(filename);

      // Security: Validate filename against allowed files
      try {
        file = _files.firstWhere((f) => f.name == decodedFilename);
      } catch (_) {
        await _sendErrorResponse(request, HttpStatus.notFound, 'File not found');
        return;
      }

      // Security: Validate file exists
      final fileEntity = File(file.path);
      if (!await fileEntity.exists()) {
        await _sendErrorResponse(request, HttpStatus.notFound, 'File not found on disk');
        return;
      }

      final totalBytes = file.size;

      // Set appropriate headers
      request.response.headers.contentType = ContentType.parse(file.mimeType);
      request.response.headers.contentLength = totalBytes;
      request.response.headers.set(
        'Content-Disposition',
        'attachment; filename="${_sanitizeFilename(file.name)}"',
      );
      request.response.headers.set('Access-Control-Allow-Origin', '*');
      request.response.headers.set('Accept-Ranges', 'bytes');

      _connectedClients++;

      try {
        final fileStream = fileEntity.openRead();
        var receivedBytes = 0;

        await for (final chunk in fileStream) {
          if (receivedBytes + chunk.length > totalBytes) {
            break;
          }

          request.response.add(chunk);
          receivedBytes += chunk.length;
          _totalBytesTransferred += chunk.length;
          onProgress?.call(receivedBytes);
        }

        await request.response.close();
      } finally {
        _connectedClients = (_connectedClients - 1).clamp(0, 999999);
      }
    } catch (e) {
      if (file == null) {
        await _sendErrorResponse(request, HttpStatus.notFound, 'File not found');
      } else {
        await _sendErrorResponse(request, HttpStatus.internalServerError, e.toString());
      }
    }
  }

  /// Handle /status endpoint
  Future<void> _handleStatus(HttpRequest request) async {
    try {
      final status = {
        'status': _isRunning ? 'running' : 'stopped',
        'files': _files.length,
        'bytesTransferred': _totalBytesTransferred,
        'connectedClients': _connectedClients,
        'version': '1.0.0',
      };

      request.response.headers.contentType = ContentType.json;
      request.response.headers.set('Access-Control-Allow-Origin', '*');

      request.response.write(status.toString());
      await request.response.close();
    } catch (e) {
      await _sendErrorResponse(request, HttpStatus.internalServerError, e.toString());
    }
  }

  /// Handle welcome page
  Future<void> _handleWelcome(HttpRequest request) async {
    final fileListHtml = _files.map((f) => 
      '<li><a href="/download/${Uri.encodeComponent(f.name)}">${f.name}</a> (${_formatBytes(f.size)})</li>'
    ).join('\n');

    final html = '''
<!DOCTYPE html>
<html>
<head>
  <title>Hermes File Transfer</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }
    .card { border: 1px solid #ddd; border-radius: 8px; padding: 20px; margin: 20px 0; }
    h1 { color: #0d9488; }
    .status { display: inline-block; padding: 5px 10px; border-radius: 4px; background: #d1fae5; color: #065f46; }
    ul { list-style: none; padding: 0; }
    li { padding: 8px; border-bottom: 1px solid #eee; }
    a { color: #0d9488; text-decoration: none; }
    a:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <h1>🚀 Hermes File Transfer</h1>
  <div class="card">
    <p><strong>Status:</strong> <span class="status">Running</span></p>
    <p><strong>Files available:</strong> ${_files.length}</p>
    <p><strong>Bytes transferred:</strong> ${_totalBytesTransferred}</p>
  </div>
  ${_files.isNotEmpty ? '<h2>Available Files</h2><ul>$fileListHtml</ul>' : '<p>No files available</p>'}
  <p>Use Hermes app to scan QR code or enter this IP to connect.</p>
</body>
</html>
''';

    request.response.headers.contentType = ContentType.html;
    request.response.headers.set('Access-Control-Allow-Origin', '*');

    request.response.write(html);
    await request.response.close();
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Send error response
  Future<void> _sendErrorResponse(
    HttpRequest request,
    int statusCode,
    String message,
  ) async {
    try {
      request.response.statusCode = statusCode;
      request.response.headers.contentType = ContentType.text;

      request.response.write('{"error": "$message", "code": $statusCode}');
      await request.response.close();
    } catch (_) {
      // Best effort
    }
  }

  /// Security: Sanitize filename for headers
  String _sanitizeFilename(String filename) {
    return filename
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll('\n', '')
        .replaceAll('\r', '');
  }

  /// Download file from remote URL
  Future<String?> downloadFile({
    required String url,
    Function(int, int)? onProgress,
  }) async {
    try {
      final dio = Dio();
      final directory = await getApplicationDocumentsDirectory();

      // Parse URL to get filename
      final uri = Uri.parse(url);
      String saveFilePath;
      
      if (uri.queryParameters.containsKey('file')) {
        final fileName = uri.queryParameters['file']!;
        saveFilePath = '${directory.path}/${Uri.decodeComponent(fileName)}';
      } else {
        // Try to extract filename from path
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          final fileName = pathSegments.last;
          saveFilePath = '${directory.path}/${Uri.decodeComponent(fileName)}';
        } else {
          saveFilePath = '${directory.path}/download';
        }
      }

      await dio.download(
        url,
        saveFilePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress?.call(received, total);
          }
        },
      );

      return saveFilePath;
    } catch (e) {
      print('Download failed: $e');
      return null;
    }
  }

  /// Stop the server and cleanup resources (sync version)
  void stopServer() {
    _isRunning = false;
    _connectedClients = 0;

    if (_server != null) {
      _server!.close(force: true);
      _server = null;
    }

    _files.clear();
    _totalBytesTransferred = 0;
  }

  /// Reset transfer statistics
  void resetStats() {
    _totalBytesTransferred = 0;
    _connectedClients = 0;
  }
}
