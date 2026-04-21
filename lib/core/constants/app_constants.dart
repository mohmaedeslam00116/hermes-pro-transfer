class AppConstants {
  static const String appName = 'Hermes';
  static const String appVersion = '1.0.0';
  
  // Server configuration
  static const int httpServerPort = 8080;
  static const int webRtcPort = 8081;
  
  // Transfer states
  static const String transferIdle = 'idle';
  static const String transferInProgress = 'in_progress';
  static const String transferCompleted = 'completed';
  static const String transferFailed = 'failed';
  
  // Transfer modes
  static const String modeSend = 'send';
  static const String modeReceive = 'receive';
  
  // Transfer technologies
  static const String techHttp = 'http';
  static const String techWifiDirect = 'wifi_direct';
  static const String techWebRtc = 'webrtc';
  
  // Shared preferences keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyDarkMode = 'dark_mode';
  static const String keyDefaultTechnology = 'default_technology';
  static const String keyTransferHistory = 'transfer_history';
  
  // File size limits
  static const int maxFileSizeMB = 500;
  static const int chunkSize = 1024 * 1024; // 1MB chunks
}