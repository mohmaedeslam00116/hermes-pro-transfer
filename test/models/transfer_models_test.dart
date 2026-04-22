import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_pro/models/transfer_file.dart';
import 'package:hermes_pro/models/transfer_state.dart';

void main() {
  group('TransferFile', () {
    test('should create TransferFile with required parameters', () {
      final file = TransferFile(
        name: 'test.txt',
        path: '/path/to/test.txt',
        size: 1024,
        mimeType: 'text/plain',
      );

      expect(file.name, 'test.txt');
      expect(file.path, '/path/to/test.txt');
      expect(file.size, 1024);
      expect(file.mimeType, 'text/plain');
    });

    test('should format file size correctly', () {
      final file1KB = TransferFile(
        name: 'test.txt',
        path: '/test.txt',
        size: 512,
        mimeType: 'text/plain',
      );
      expect(file1KB.formattedSize, '512 B');

      final file10KB = TransferFile(
        name: 'test.txt',
        path: '/test.txt',
        size: 10240,
        mimeType: 'text/plain',
      );
      expect(file10KB.formattedSize, '10.0 KB');

      final file1MB = TransferFile(
        name: 'test.txt',
        path: '/test.txt',
        size: 1048576,
        mimeType: 'text/plain',
      );
      expect(file1MB.formattedSize, '1.0 MB');

      final file2GB = TransferFile(
        name: 'test.txt',
        path: '/test.txt',
        size: 2147483648,
        mimeType: 'text/plain',
      );
      expect(file2GB.formattedSize, '2.00 GB');
    });

    test('should serialize and deserialize correctly', () {
      final original = TransferFile(
        name: 'test.txt',
        path: '/test.txt',
        size: 1024,
        mimeType: 'text/plain',
      );

      final json = original.toJson();
      final restored = TransferFile.fromJson(json);

      expect(restored.name, original.name);
      expect(restored.path, original.path);
      expect(restored.size, original.size);
      expect(restored.mimeType, original.mimeType);
    });
  });

  group('TransferState', () {
    test('should calculate progress correctly', () {
      final state = TransferState(
        status: TransferStatus.transferring,
        bytesTransferred: 500,
        totalBytes: 1000,
      );

      expect(state.progress, 0.5);
      expect(state.progressText, '50.0%');
      expect(state.transferredText, '500.0 B / 1000.0 B');
    });

    test('should handle zero total bytes', () {
      final state = TransferState(
        status: TransferStatus.idle,
        bytesTransferred: 0,
        totalBytes: 0,
      );

      expect(state.progress, 0);
    });

    test('should copyWith preserve unmodified fields', () {
      final original = TransferState(
        mode: TransferMode.send,
        technology: TransferTechnology.http,
        status: TransferStatus.preparing,
        totalBytes: 1000,
      );

      final modified = original.copyWith(
        status: TransferStatus.transferring,
        bytesTransferred: 500,
      );

      expect(modified.mode, TransferMode.send);
      expect(modified.technology, TransferTechnology.http);
      expect(modified.status, TransferStatus.transferring);
      expect(modified.totalBytes, 1000);
    });
  });

  group('TransferStatus', () {
    test('should have all expected values', () {
      expect(TransferStatus.values, contains(TransferStatus.idle));
      expect(TransferStatus.values, contains(TransferStatus.preparing));
      expect(TransferStatus.values, contains(TransferStatus.waitingForConnection));
      expect(TransferStatus.values, contains(TransferStatus.transferring));
      expect(TransferStatus.values, contains(TransferStatus.completed));
      expect(TransferStatus.values, contains(TransferStatus.failed));
      expect(TransferStatus.values, contains(TransferStatus.cancelled));
    });
  });

  group('TransferMode', () {
    test('should have send and receive modes', () {
      expect(TransferMode.send, isNotNull);
      expect(TransferMode.receive, isNotNull);
    });
  });

  group('TransferTechnology', () {
    test('should have all transfer technologies', () {
      expect(TransferTechnology.http, isNotNull);
      expect(TransferTechnology.wifiDirect, isNotNull);
      expect(TransferTechnology.webrtc, isNotNull);
    });
  });
}