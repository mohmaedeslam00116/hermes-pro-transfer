import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/transfer_file.dart';
import '../models/transfer_state.dart';
import '../services/http_server_service.dart';
import '../services/network_service.dart';

class TransferProvider extends ChangeNotifier {
  final HttpServerService _httpServer = HttpServerService();
  final NetworkService _networkService = NetworkService();
  
  TransferState _state = TransferState();
  TransferState get state => _state;
  
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
  
  Future<bool> startServer(TransferTechnology technology) async {
    _state = _state.copyWith(
      technology: technology,
      status: TransferStatus.waitingForConnection,
    );
    
    try {
      final ip = await _networkService.getLocalIpAddress();
      final url = 'http://$ip:${AppConstants.httpServerPort}';
      
      _state = _state.copyWith(
        serverUrl: url,
        status: TransferStatus.transferring,
        startedAt: DateTime.now(),
      );
      
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
        throw Exception('Download failed');
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
  
  void reset() {
    _httpServer.stopServer();
    _state = TransferState();
    notifyListeners();
  }
  
  void cancel() {
    _httpServer.stopServer();
    _state = _state.copyWith(status: TransferStatus.cancelled);
    notifyListeners();
  }
}