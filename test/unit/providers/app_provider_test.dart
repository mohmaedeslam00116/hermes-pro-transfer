import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_pro/providers/app_provider.dart';
import 'package:hermes_pro/models/transfer_state.dart';

void main() {
  group('AppProvider', () {
    late AppProvider provider;

    setUp(() {
      provider = AppProvider();
    });

    test('initial state should be first launch', () {
      expect(provider.isFirstLaunch, true);
    });

    test('initial dark mode should be false', () {
      expect(provider.isDarkMode, false);
    });

    test('initial default technology should be http', () {
      expect(provider.defaultTechnology, 'http');
    });

    test('initial transfer mode should be null', () {
      expect(provider.transferMode, isNull);
    });

    test('initial selected technology should be null', () {
      expect(provider.selectedTechnology, isNull);
    });

    test('setTransferMode should update mode', () {
      provider.setTransferMode(TransferMode.send);
      expect(provider.transferMode, TransferMode.send);
      
      provider.setTransferMode(TransferMode.receive);
      expect(provider.transferMode, TransferMode.receive);
    });

    test('setTechnology should update technology', () {
      provider.setTechnology(TransferTechnology.http);
      expect(provider.selectedTechnology, TransferTechnology.http);
      
      provider.setTechnology(TransferTechnology.wifiDirect);
      expect(provider.selectedTechnology, TransferTechnology.wifiDirect);
    });

    test('toggleDarkMode should toggle theme', () {
      expect(provider.isDarkMode, false);
      
      provider.toggleDarkMode();
      expect(provider.isDarkMode, true);
      
      provider.toggleDarkMode();
      expect(provider.isDarkMode, false);
    });

    test('toggleTheme should be alias for toggleDarkMode', () {
      expect(provider.isDarkMode, false);
      
      provider.toggleTheme();
      expect(provider.isDarkMode, true);
    });
  });
}
