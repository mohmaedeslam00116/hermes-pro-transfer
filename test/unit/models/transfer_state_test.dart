import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_pro/models/transfer_state.dart';
import 'package:hermes_pro/models/transfer_file.dart';

void main() {
  group('TransferState', () {
    test('default state should have idle status', () {
      final state = TransferState();
      
      expect(state.status, TransferStatus.idle);
      expect(state.mode, isNull);
      expect(state.technology, isNull);
      expect(state.files, isEmpty);
      expect(state.bytesTransferred, 0);
      expect(state.totalBytes, 0);
    });

    test('progress should return 0 when totalBytes is 0', () {
      final state = TransferState();
      
      expect(state.progress, 0);
    });

    test('progress should calculate correctly', () {
      final state = TransferState(
        bytesTransferred: 50,
        totalBytes: 100,
      );
      
      expect(state.progress, 0.5);
    });

    test('progressText should return percentage string', () {
      final state = TransferState(
        bytesTransferred: 50,
        totalBytes: 100,
      );
      
      expect(state.progressText, '50.0%');
    });

    test('transferredText should format bytes correctly', () {
      final state = TransferState(
        bytesTransferred: 1024,
        totalBytes: 2048,
      );
      
      expect(state.transferredText, contains('KB'));
    });

    test('copyWith should create new instance with updated values', () {
      final original = TransferState(
        status: TransferStatus.idle,
      );
      
      final updated = original.copyWith(
        status: TransferStatus.transferring,
        bytesTransferred: 100,
      );
      
      expect(updated.status, TransferStatus.transferring);
      expect(updated.bytesTransferred, 100);
      expect(original.status, TransferStatus.idle); // Original unchanged
    });

    test('copyWith should preserve original values when not specified', () {
      final original = TransferState(
        status: TransferStatus.transferring,
        bytesTransferred: 50,
        totalBytes: 100,
        serverUrl: 'http://test:8080',
      );
      
      final updated = original.copyWith(
        status: TransferStatus.completed,
      );
      
      expect(updated.status, TransferStatus.completed);
      expect(updated.bytesTransferred, 50);
      expect(updated.totalBytes, 100);
      expect(updated.serverUrl, 'http://test:8080');
    });
  });

  group('TransferFile', () {
    test('should create TransferFile with all properties', () {
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

    test('formattedSize should format bytes correctly', () {
      // Test for bytes
      expect(
        TransferFile(name: 'test', path: '', size: 500, mimeType: '').formattedSize,
        '500 B',
      );
      
      // Test for KB
      expect(
        TransferFile(name: 'test', path: '', size: 1024, mimeType: '').formattedSize,
        '1.0 KB',
      );
      
      // Test for MB
      expect(
        TransferFile(name: 'test', path: '', size: 1024 * 1024, mimeType: '').formattedSize,
        '1.0 MB',
      );
    });
  });

  group('TransferStatus enum', () {
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

  group('TransferMode enum', () {
    test('should have send and receive modes', () {
      expect(TransferMode.values, contains(TransferMode.send));
      expect(TransferMode.values, contains(TransferMode.receive));
    });
  });

  group('TransferTechnology enum', () {
    test('should have all transfer technologies', () {
      expect(TransferTechnology.values, contains(TransferTechnology.http));
      expect(TransferTechnology.values, contains(TransferTechnology.wifiDirect));
      expect(TransferTechnology.values, contains(TransferTechnology.webrtc));
    });
  });
}
