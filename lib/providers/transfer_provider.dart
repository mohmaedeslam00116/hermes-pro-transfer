import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/transfer_file.dart';
import '../models/transfer_state.dart';
import '../services/http_server_service.dart';
import '../services/network_service.dart';

/// Transfer Provider - manages file transfer state and operations
class TransferProvider extends ChangeNotifier {
  final HttpServerService _httpServer = HttpServerService();
  final NetworkService _networkService = NetworkService();

  TransferState _state = TransferState();
  TransferState get state => _state;

  /// Get current server URL
  String? get serverUrl => _state.serverUrl;

  /// Get transfer progress (0.0 to 1.0)
  double get progress {
    if (_state.totalBytes == 0) return 0;
    return _state.bytesTransferred / _state.totalBytes;
  }

  /// Prepare files for sending
  Future<void> prepareSend(List<TransferFile> files) async {
    _state = TransferState(
      mode: TransferMode.send,
      technology: TransferTechnology.http,
      status: TransferStatus.preparing,
      files: files,
      totalBytes: files.fold(0, (sum, file) => sum + file.size),
    );
    notifyListeners();
  }

  /// Start HTTP server for file transfer
  Future<bool> startServer(TransferTechnology selectedTech) async {
    _state = _state.copyWith(
      technology: selectedTech,
      status: TransferStatus.waitingForConnection,
    );
    
    try {
      // Get local IP address
      final ip = await _networkService.getLocalIpAddress();
      if (ip == null) {
        throw Exception('Could not get local IP address');
      }
      
      // Handle IPv6 addresses
      String cleanIp = ip;
      if (ip.contains(':')) {
        cleanIp = ip.contains('%') ? ip.split('%').first : ip;
        cleanIp = '[$cleanIp]';
      }
      
      final url = 'http://$cleanIp:${AppConstants.httpServerPort}';
      
      _state = _state.copyWith(
        serverUrl: url,
        status: TransferStatus.transferring,
        startedAt: DateTime.now(),
      );
      notifyListeners();
      
      // Start the server
      await _httpServer.startServer(
        port: AppConstants.httpServerPort,
        files: _state.files,
        onProgress: (bytesTransferred) {
          _state = _state.copyWith(bytesTransferred: bytesTransferred);
          notifyListeners();
        },
      );

      return true;
    } catch (e) {
      _state = _state.copyWith(
        status: TransferStatus.failed,
        errorMessage: e.toString(),
      );
      notifyListeners();
      return false;
    }
  }

  /// Connect to server and download files
  Future<bool> connectAndDownload(String url, String savePath) async {
    _state = TransferState(
      mode: TransferMode.receive,
      technology: TransferTechnology.http,
      status: TransferStatus.preparing,
    );
    notifyListeners();
    
    try {
      _state = _state.copyWith(
        status: TransferStatus.transferring,
        startedAt: DateTime.now(),
      );
      notifyListeners();
      
      // Download file from server
      final savedPath = await _httpServer.downloadFile(
        url: url,
        onProgress: (bytesTransferred, totalBytes) {
          _state = _state.copyWith(
            bytesTransferred: bytesTransferred,
            totalBytes: totalBytes,
          );
          notifyListeners();
        },
      );
      
      if (savedPath == null) {
        throw Exception('Download failed - no file received');
      }
      
      _state = _state.copyWith(
        status: TransferStatus.completed,
        completedAt: DateTime.now(),
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        status: TransferStatus.failed,
        errorMessage: e.toString(),
      );
      notifyListeners();
      return false;
    }
  }

  /// Reset transfer state
  void reset() {
    _httpServer.stopServer();
    _state = TransferState();
    notifyListeners();
  }

  /// Cancel current transfer
  void cancel() {
    _httpServer.stopServer();
    _state = _state.copyWith(status: TransferStatus.cancelled);
    notifyListeners();
  }

  /// Cleanup when provider is disposed
  @override
  void dispose() {
    _httpServer.stopServer();
    super.dispose();
  }
}