import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class AppProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  bool _isFirstLaunch = true;
  bool _isDarkMode = false;
  String _defaultTechnology = AppConstants.techHttp;
  
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isDarkMode => _isDarkMode;
  String get defaultTechnology => _defaultTechnology;
  
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
  
  Future<void> setDefaultTechnology(String tech) async {
    _defaultTechnology = tech;
    await _prefs?.setString(AppConstants.keyDefaultTechnology, tech);
    notifyListeners();
  }
}