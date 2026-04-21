import 'transfer_file.dart';

enum TransferStatus {
  idle,
  preparing,
  waitingForConnection,
  transferring,
  completed,
  failed,
  cancelled,
}

enum TransferMode {
  send,
  receive,
}

enum TransferTechnology {
  http,
  wifiDirect,
  webrtc,
}

class TransferState {
  final TransferMode? mode;
  final TransferTechnology? technology;
  final TransferStatus status;
  final List<TransferFile> files;
  final int currentFileIndex;
  final int bytesTransferred;
  final int totalBytes;
  final String? errorMessage;
  final String? serverUrl;
  final String? peerAddress;
  final DateTime? startedAt;
  final DateTime? completedAt;
  
  TransferState({
    this.mode,
    this.technology,
    this.status = TransferStatus.idle,
    this.files = const [],
    this.currentFileIndex = 0,
    this.bytesTransferred = 0,
    this.totalBytes = 0,
    this.errorMessage,
    this.serverUrl,
    this.peerAddress,
    this.startedAt,
    this.completedAt,
  });
  
  double get progress {
    if (totalBytes == 0) return 0;
    return bytesTransferred / totalBytes;
  }
  
  String get progressText {
    return '${(progress * 100).toStringAsFixed(1)}%';
  }
  
  String get transferredText {
    final transferred = _formatBytes(bytesTransferred);
    final total = _formatBytes(totalBytes);
    return '$transferred / $total';
  }
  
  String get remainingTime {
    if (status != TransferStatus.transferring || bytesTransferred == 0) {
      return '--:--';
    }
    final elapsed = DateTime.now().difference(startedAt!);
    final speed = bytesTransferred / elapsed.inSeconds;
    if (speed == 0) return '--:--';
    final remaining = totalBytes - bytesTransferred;
    final seconds = (remaining / speed).round();
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      final minutes = (seconds / 60).round();
      return '${minutes}m';
    } else {
      final hours = (seconds / 3600).round();
      return '${hours}h';
    }
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
  
  TransferState copyWith({
    TransferMode? mode,
    TransferTechnology? technology,
    TransferStatus? status,
    List<TransferFile>? files,
    int? currentFileIndex,
    int? bytesTransferred,
    int? totalBytes,
    String? errorMessage,
    String? serverUrl,
    String? peerAddress,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return TransferState(
      mode: mode ?? this.mode,
      technology: technology ?? this.technology,
      status: status ?? this.status,
      files: files ?? this.files,
      currentFileIndex: currentFileIndex ?? this.currentFileIndex,
      bytesTransferred: bytesTransferred ?? this.bytesTransferred,
      totalBytes: totalBytes ?? this.totalBytes,
      errorMessage: errorMessage ?? this.errorMessage,
      serverUrl: serverUrl ?? this.serverUrl,
      peerAddress: peerAddress ?? this.peerAddress,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}