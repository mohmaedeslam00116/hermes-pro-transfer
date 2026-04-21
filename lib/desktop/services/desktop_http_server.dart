import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

class DesktopHttpServer {
  HttpServer? _server;
  String? _currentFilePath;
  String? _currentFileName;
  String? _localIp;
  int _port = 8080;

  String? get localIp => _localIp;
  String? get downloadUrl => _localIp != null 
      ? 'http://$_localIp:$_port/download' 
      : null;
  bool get isRunning => _server != null;
  String? get currentFileName => _currentFileName;

  Future<String> startServer({
    required String filePath,
    required String fileName,
    int port = 8080,
  }) async {
    _port = port;
    _currentFilePath = filePath;
    _currentFileName = fileName;
    _localIp = _getLocalIp();

    final router = Router();

    // Main page with download link
    router.get('/', (Request request) {
      return Response.ok(
        _buildLandingPage(),
        headers: {'Content-Type': 'text/html; charset=utf-8'},
      );
    });

    // Download endpoint
    router.get('/download', (Request request) async {
      final file = File(filePath);
      if (!await file.exists()) {
        return Response.notFound('File not found');
      }

      final fileSize = await file.length();
      
      return Response.ok(
        file.openRead(),
        headers: {
          'Content-Type': 'application/octet-stream',
          'Content-Disposition': 'attachment; filename="$fileName"',
          'Content-Length': fileSize.toString(),
        },
      );
    });

    // File info endpoint (for progress tracking)
    router.get('/info', (Request request) {
      return Response.ok(
        '{"fileName": "$fileName", "ready": true}',
        headers: {'Content-Type': 'application/json'},
      );
    });

    // CORS middleware
    final handler = const Pipeline()
        .addMiddleware(_corsMiddleware())
        .addMiddleware(logRequests())
        .addHandler(router.call);

    _server = await shelf_io.serve(
      handler,
      InternetAddress.anyIPv4,
      port,
    );

    return 'http://$_localIp:$port';
  }

  String _buildLandingPage() {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hermes - File Transfer</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .container {
      background: white;
      padding: 48px;
      border-radius: 24px;
      box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);
      text-align: center;
      max-width: 480px;
    }
    .icon { font-size: 64px; margin-bottom: 24px; }
    h1 { color: #1f2937; margin-bottom: 16px; font-size: 28px; }
    .filename { 
      background: #f3f4f6; 
      padding: 16px; 
      border-radius: 12px; 
      margin: 24px 0;
      font-family: monospace;
      word-break: break-all;
    }
    .download-btn {
      display: inline-block;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      padding: 16px 48px;
      border-radius: 12px;
      text-decoration: none;
      font-size: 18px;
      font-weight: 600;
      transition: transform 0.2s, box-shadow 0.2s;
    }
    .download-btn:hover {
      transform: translateY(-2px);
      box-shadow: 0 10px 20px rgba(102, 126, 234, 0.4);
    }
    .url-box {
      margin-top: 24px;
      padding: 12px;
      background: #f9fafb;
      border-radius: 8px;
      font-family: monospace;
      font-size: 14px;
      color: #6b7280;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="icon">📁</div>
    <h1>Hermes File Transfer</h1>
    <p>A file is waiting for you</p>
    <div class="filename">$_currentFileName</div>
    <a href="/download" class="download-btn">Download File</a>
    <div class="url-box">Powered by Hermes</div>
  </div>
</body>
</html>
''';
  }

  Middleware _corsMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: _corsHeaders);
        }
        final response = await innerHandler(request);
        return response.change(headers: _corsHeaders);
      };
    };
  }

  static const _corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': '*',
  };

  String _getLocalIp() {
    // Use sync fallback that reads /proc/net/tcp directly
    try {
      final file = File('/proc/net/tcp');
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        final lines = content.split('\n');
        for (final line in lines.skip(1)) {
          final parts = line.trim().split(RegExp(r'\s+'));
          if (parts.length > 1) {
            final localAddress = parts[1];
            final ipHex = localAddress.split(':')[0];
            if (ipHex != '0100007F' && ipHex.length == 8) {
              final parts = <int>[];
              for (var i = 6; i >= 0; i -= 2) {
                parts.add(int.parse(ipHex.substring(i, i + 2), radix: 16));
              }
              final ip = parts.join('.');
              if (!ip.startsWith('224.') && !ip.startsWith('169.254')) {
                return ip;
              }
            }
          }
        }
      }
    } catch (e) {
      // Fallback
    }
    return '127.0.0.1';
  }

  Future<void> stopServer() async {
    await _server?.close(force: true);
    _server = null;
    _currentFilePath = null;
    _currentFileName = null;
    _localIp = null;
  }
}
