import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transfer_file.dart';

class HttpServerService {
  HttpServer? _server;
  final List<TransferFile> _files = [];
  bool _isRunning = false;
  int _totalBytesTransferred = 0;
  
  bool get isRunning => _isRunning;
  
  Future<bool> startServer({
    required int port,
    required List<TransferFile> files,
    Function(int)? onProgress,
  }) async {
    _files.clear();
    _files.addAll(files);
    _totalBytesTransferred = 0;
    _isRunning = true;
    
    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
      
      _server!.listen((request) async {
        await _handleRequest(request, onProgress);
      });
      
      return true;
    } catch (e) {
      _isRunning = false;
      return false;
    }
  }
  
  Future<void> _handleRequest(HttpRequest request, Function(int)? onProgress) async {
    try {
      final uri = request.uri;
      final path = Uri.decodeComponent(uri.path);
      
      if (path == '/files' || path == '/api/files') {
        final fileList = _files.map((f) => {
          'name': f.name,
          'size': f.size,
          'mimeType': f.mimeType,
        }).toList();
        
        request.response.headers.contentType = ContentType.json;
        request.response.write(fileList);
        await request.response.close();
      } else if (path.startsWith('/download/') || path.startsWith('/api/download/')) {
        final fileName = path.split('/').last;
        final file = _files.firstWhere(
          (f) => f.name == fileName,
          orElse: () => throw Exception('File not found'),
        );
        
        final fileEntity = File(file.path);
        if (!await fileEntity.exists()) {
          request.response.statusCode = HttpStatus.notFound;
          await request.response.close();
          return;
        }
        
        final totalBytes = file.size;
        
        request.response.headers.contentType = ContentType.parse(file.mimeType);
        request.response.headers.contentLength = totalBytes;
        request.response.headers.set(
          'Content-Disposition', 
          'attachment; filename="${file.name}"'
        );
        
        final fileStream = fileEntity.openRead();
        var receivedBytes = 0;
        
        await for (final chunk in fileStream) {
          request.response.add(chunk);
          receivedBytes += chunk.length;
          _totalBytesTransferred += chunk.length;
          onProgress?.call(receivedBytes);
        }
        
        await request.response.close();
      } else if (path == '/status' || path == '/api/status') {
        request.response.headers.contentType = ContentType.json;
        request.response.write({
          'status': 'running',
          'files': _files.length,
          'bytesTransferred': _totalBytesTransferred,
        });
        await request.response.close();
      } else {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
      }
    } catch (e) {
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.write(e.toString());
      await request.response.close();
    }
  }
  
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
      return null;
    }
  }
  
  Future<void> stopServer() async {
    _isRunning = false;
    await _server?.close(force: true);
    _server = null;
    _files.clear();
    _totalBytesTransferred = 0;
  }
}