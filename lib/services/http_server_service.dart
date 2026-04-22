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

  /// Security: Allowed base directory for file serving
  static final String _allowedBasePath = '';

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
          // Log error but don't crash
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
      // Security: Decode and sanitize path
      final rawPath = uri.path;
      final path = _sanitizePath(rawPath);

      if (path == null) {
        // Invalid path - potential attack
        await _sendErrorResponse(request, HttpStatus.forbidden, 'Invalid path');
        return;
      }

      // API endpoints
      if (path == '/files' || path == '/api/files') {
        await _handleFilesList(request);
      } else if (path.startsWith('/download/') || path.startsWith('/api/download/')) {
        await _handleFileDownload(request, path, onProgress);
      } else if (path == '/status' || path == '/api/status') {
        await _handleStatus(request);
      } else if (path == '/') {
        // Welcome page
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
    // Remove query string if present
    final pathOnly = rawPath.split('?').first;

    // Check for path traversal attempts
    // Block: ../, ..\, %2e%2e/, etc.
    final normalized = pathOnly.toLowerCase();

    if (normalized.contains('..') ||
        normalized.contains('%2e') ||
        normalized.contains('%2e%2e') ||
        normalized.contains('\\')) {
      return null; // Block the request
    }

    // Remove leading slashes and normalize
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
      }).toList();

      request.response.headers.contentType = ContentType.json;
      request.response.headers.set('Access-Control-Allow-Origin', '*');
      request.response.headers.set('Access-Control-Allow-Methods', 'GET, OPTIONS');

      request.response.write(fileList);
      await request.response.close();
    } catch (e) {
      await _sendErrorResponse(request, HttpStatus.internalServerError, e.toString());
    }
  }

  /// Handle file download with security checks
  Future<void> _handleFileDownload(
    HttpRequest request,
    String path,
    Function(int)? onProgress,
  ) async {
    try {
      // Extract filename from path (last segment)
      final pathParts = path.split('/').where((p) => p.isNotEmpty).toList();
      if (pathParts.isEmpty) {
        await _sendErrorResponse(request, HttpStatus.badRequest, 'Missing filename');
        return;
      }

      final requestedFileName = pathParts.last;

      // Security: Validate filename against allowed files
      final file = _files.firstWhere(
        (f) => f.name == requestedFileName,
        orElse: () => throw Exception('File not found'),
      );

      // Security: Validate file exists and path is safe
      final fileEntity = File(file.path);
      if (!await fileEntity.exists()) {
        await _sendErrorResponse(request, HttpStatus.notFound, 'File not found');
        return;
      }

      // Security: Additional path validation
      final resolvedPath = fileEntity.resolveSymbolicLinksSync();
      if (!resolvedPath.startsWith('/data') && !resolvedPath.startsWith('/storage')) {
        // Unexpected path - block
        await _sendErrorResponse(request, HttpStatus.forbidden, 'Access denied');
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
        // Stream file with proper cleanup
        final fileStream = fileEntity.openRead();

        var receivedBytes = 0;

        await for (final chunk in fileStream) {
          // Safety check: Don't exceed file size
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
      if (e.toString().contains('not found')) {
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

      request.response.write(status);
      await request.response.close();
    } catch (e) {
      await _sendErrorResponse(request, HttpStatus.internalServerError, e.toString());
    }
  }

  /// Handle welcome page
  Future<void> _handleWelcome(HttpRequest request) async {
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
  </style>
</head>
<body>
  <h1>🚀 Hermes File Transfer</h1>
  <div class="card">
    <p><strong>Status:</strong> <span class="status">Running</span></p>
    <p><strong>Files available:</strong> ${_files.length}</p>
    <p><strong>Bytes transferred:</strong> ${_totalBytesTransferred}</p>
  </div>
  <p>Use Hermes app to scan QR code or enter this IP to connect.</p>
</body>
</html>
''';

    request.response.headers.contentType = ContentType.html;
    request.response.headers.set('Access-Control-Allow-Origin', '*');

    request.response.write(html);
    await request.response.close();
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

      final errorJson = {
        'error': message,
        'code': statusCode,
      };

      request.response.write(errorJson);
      await request.response.close();
    } catch (_) {
      // Best effort error response
    }
  }

  /// Security: Sanitize filename for headers
  String _sanitizeFilename(String filename) {
    // Remove any characters that could be malicious
    return filename
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        .replaceAll(RegExp(r'[\x00-\x1F]'), '');
  }

  /// Download file from remote URL
  Future<String?> downloadFile({
    required String url,
    Function(int, int)? onProgress,
  }) async {
    try {
      final dio = Dio();
      final directory = await getApplicationDocumentsDirectory();

      final uri = Uri.parse(url);
      final fileName = uri.queryParameters['file'] ?? 'download';
      final saveFilePath = '${directory.path}/$fileName';

      await dio.download(
        url,
        saveFilePath,
        onReceiveProgress: (received, total) {
          onProgress?.call(received, total);
        },
      );

      return saveFilePath;
    } catch (e) {
      print('Download failed: $e');
      return null;
    }
  }

  /// Stop the server and cleanup resources
  Future<void> stopServer() async {
    _isRunning = false;
    _connectedClients = 0;

    if (_server != null) {
      await _server!.close(force: true);
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