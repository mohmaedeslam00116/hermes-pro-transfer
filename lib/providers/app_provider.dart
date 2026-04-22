import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/transfer_state.dart';

/// App State Provider with error handling and validation
class AppProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  
  // State
  bool _isFirstLaunch = true;
  bool _isDarkMode = false;
  bool _isInitialized = false;
  
  // Preferences
  String _defaultTechnology = AppConstants.techHttp;
  
  // Transfer state
  TransferMode? _transferMode;
  TransferTechnology? _selectedTechnology;
  
  // Error state
  String? _errorMessage;
  bool _hasError = false;
  
  // Getters
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;
  String get defaultTechnology => _defaultTechnology;
  TransferMode? get transferMode => _transferMode;
  TransferTechnology? get selectedTechnology => _selectedTechnology;
  String? get errorMessage => _errorMessage;
  bool get hasError => _hasError;
  
  /// Initialize provider with error handling
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      
      _isFirstLaunch = _prefs?.getBool(AppConstants.keyFirstLaunch) ?? true;
      _isDarkMode = _prefs?.getBool(AppConstants.keyDarkMode) ?? false;
      _defaultTechnology = _prefs?.getString(AppConstants.keyDefaultTechnology) ?? 
          AppConstants.techHttp;
      
      _isInitialized = true;
      _clearError();
    } catch (e) {
      _handleError('Failed to initialize: ${e.toString()}');
    }
    notifyListeners();
  }
  
  /// Complete onboarding with error handling
  Future<void> completeOnboarding() async {
    try {
      _isFirstLaunch = false;
      await _prefs?.setBool(AppConstants.keyFirstLaunch, false);
      _clearError();
      notifyListeners();
    } catch (e) {
      _handleError('Failed to complete onboarding: ${e.toString()}');
    }
  }
  
  /// Toggle dark mode with persistence
  Future<void> toggleDarkMode() async {
    try {
      _isDarkMode = !_isDarkMode;
      await _prefs?.setBool(AppConstants.keyDarkMode, _isDarkMode);
      _clearError();
      notifyListeners();
    } catch (e) {
      _handleError('Failed to save theme preference: ${e.toString()}');
    }
  }
  
  /// Alias for toggleDarkMode
  void toggleTheme() => toggleDarkMode();
  
  /// Set transfer mode with validation
  void setTransferMode(TransferMode mode) {
    try {
      _transferMode = mode;
      _clearError();
      notifyListeners();
    } catch (e) {
      _handleError('Failed to set transfer mode: ${e.toString()}');
    }
  }
  
  /// Set technology with validation
  void setTechnology(TransferTechnology tech) {
    try {
      // Validate technology
      if (!TransferTechnology.values.contains(tech)) {
        _handleError('Invalid technology selected');
        return;
      }
      
      _selectedTechnology = tech;
      _clearError();
      notifyListeners();
    } catch (e) {
      _handleError('Failed to set technology: ${e.toString()}');
    }
  }
  
  /// Set default technology
  Future<void> setDefaultTechnology(String tech) async {
    try {
      // Validate technology string
      if (![AppConstants.techHttp, AppConstants.techWifiDirect, AppConstants.techWebRtc]
          .contains(tech)) {
        _handleError('Invalid technology: $tech');
        return;
      }
      
      _defaultTechnology = tech;
      await _prefs?.setString(AppConstants.keyDefaultTechnology, tech);
      _clearError();
      notifyListeners();
    } catch (e) {
      _handleError('Failed to save default technology: ${e.toString()}');
    }
  }
  
  /// Clear error state
  void _clearError() {
    _hasError = false;
    _errorMessage = null;
  }
  
  /// Handle error
  void _handleError(String message) {
    _hasError = true;
    _errorMessage = message;
    debugPrint('[AppProvider] Error: $message');
  }
  
  /// Clear current error
  void clearError() {
    _clearError();
    notifyListeners();
  }
  
  /// Reset provider state (kept for API compatibility)
  @visibleForTesting
  void reset() {
    _transferMode = null;
    _selectedTechnology = null;
    _clearError();
    notifyListeners();
  }
}