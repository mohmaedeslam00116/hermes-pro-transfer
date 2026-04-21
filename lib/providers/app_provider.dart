import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/transfer_state.dart';

class AppProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  bool _isFirstLaunch = true;
  bool _isDarkMode = false;
  String _defaultTechnology = AppConstants.techHttp;
  TransferMode? _transferMode;
  TransferTechnology? _selectedTechnology;
  
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isDarkMode => _isDarkMode;
  String get defaultTechnology => _defaultTechnology;
  TransferMode? get transferMode => _transferMode;
  TransferTechnology? get selectedTechnology => _selectedTechnology;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = _prefs?.getBool(AppConstants.keyFirstLaunch) ?? true;
    _isDarkMode = _prefs?.getBool(AppConstants.keyDarkMode) ?? false;
    _defaultTechnology = _prefs?.getString(AppConstants.keyDefaultTechnology) ?? AppConstants.techHttp;
    notifyListeners();
  }
  
  Future<void> completeOnboarding() async {
    _isFirstLaunch = false;
    await _prefs?.setBool(AppConstants.keyFirstLaunch, false);
    notifyListeners();
  }
  
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _prefs?.setBool(AppConstants.keyDarkMode, _isDarkMode);
    notifyListeners();
  }

  // Alias for toggleDarkMode for compatibility
  void toggleTheme() => toggleDarkMode();
  
  void setTransferMode(TransferMode mode) {
    _transferMode = mode;
    notifyListeners();
  }
  
  void setTechnology(TransferTechnology tech) {
    _selectedTechnology = tech;
    notifyListeners();
  }
  
  Future<void> setDefaultTechnology(String tech) async {
    _defaultTechnology = tech;
    await _prefs?.setString(AppConstants.keyDefaultTechnology, tech);
    notifyListeners();
  }
}