import 'package:network_info_plus/network_info_plus.dart';

/// Network service for getting device network information
class NetworkService {
  final NetworkInfo _networkInfo = NetworkInfo();
  
  /// Get local IP address with timeout
  Future<String?> getLocalIpAddress() async {
    try {
      final wifiIP = await _networkInfo.getWifiIP().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
      return wifiIP;
    } catch (e) {
      return null;
    }
  }
  
  /// Get Wi-Fi network name (SSID)
  Future<String?> getWifiName() async {
    try {
      final wifiName = await _networkInfo.getWifiName().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
      // Remove quotes from SSID if present
      if (wifiName != null && wifiName.startsWith('"') && wifiName.endsWith('"')) {
        return wifiName.substring(1, wifiName.length - 1);
      }
      return wifiName;
    } catch (e) {
      return null;
    }
  }
  
  /// Get Wi-Fi BSSID
  Future<String?> getWifiBSSID() async {
    try {
      final wifiBSSID = await _networkInfo.getWifiBSSID().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
      return wifiBSSID;
    } catch (e) {
      return null;
    }
  }
  
  /// Check if connected to Wi-Fi
  Future<bool> isWifiConnected() async {
    try {
      final wifiIP = await getLocalIpAddress();
      return wifiIP != null && wifiIP.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  /// Dispose of resources
  void dispose() {
    // NetworkInfo doesn't require explicit disposal
    // but we keep this method for consistency
  }
}
