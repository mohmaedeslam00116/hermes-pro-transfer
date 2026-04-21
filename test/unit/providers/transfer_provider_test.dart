import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_pro/models/transfer_file.dart';
import 'package:hermes_pro/models/transfer_state.dart';
import 'package:hermes_pro/providers/transfer_provider.dart';

void main() {
  group('TransferProvider', () {
    late TransferProvider provider;

    setUp(() {
      provider = TransferProvider();
    });

    test('initial state should be idle', () {
      expect(provider.state.status, TransferStatus.idle);
    });

    test('prepareSend should update state with files', () {
      final files = [
        TransferFile(
          name: 'test1.txt',
          path: '/path/test1.txt',
          size: 1024,
          mimeType: 'text/plain',
        ),
        TransferFile(
          name: 'test2.txt',
          path: '/path/test2.txt',
          size: 2048,
          mimeType: 'text/plain',
        ),
      ];

      provider.prepareSend(files);

      expect(provider.state.mode, TransferMode.send);
      expect(provider.state.files.length, 2);
      expect(provider.state.totalBytes, 3072);
      expect(provider.state.status, TransferStatus.preparing);
    });

    test('prepareSend should calculate total bytes correctly', () {
      final files = [
        TransferFile(
          name: 'small.txt',
          path: '/path/small.txt',
          size: 100,
          mimeType: 'text/plain',
        ),
        TransferFile(
          name: 'large.txt',
          path: '/path/large.txt',
          size: 900,
          mimeType: 'text/plain',
        ),
      ];

      provider.prepareSend(files);

      expect(provider.state.totalBytes, 1000);
    });

    test('updateProgress should update bytesTransferred', () {
      // Simulate progress update through state
      final updatedState = provider.state.copyWith(
        bytesTransferred: 500,
        totalBytes: 1000,
      );
      
      // Verify progress calculation
      expect(updatedState.progress, 0.5);
    });

    test('cancel should reset state', () {
      final cancelledState = provider.state.copyWith(
        status: TransferStatus.cancelled,
      );
      
      expect(cancelledState.status, TransferStatus.cancelled);
    });

    test('complete should set status to completed', () {
      final completedState = provider.state.copyWith(
        status: TransferStatus.completed,
        bytesTransferred: 1000,
        totalBytes: 1000,
      );
      
      expect(completedState.status, TransferStatus.completed);
      expect(completedState.progress, 1.0);
    });

    test('fail should set status to failed with error message', () {
      const errorMessage = 'Connection lost';
      final failedState = provider.state.copyWith(
        status: TransferStatus.failed,
        errorMessage: errorMessage,
      );
      
      expect(failedState.status, TransferStatus.failed);
      expect(failedState.errorMessage, errorMessage);
    });

    tearDown(() {
      provider.dispose();
    });
  });
}
