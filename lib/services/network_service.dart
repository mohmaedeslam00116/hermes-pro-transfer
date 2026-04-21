import 'package:network_info_plus/network_info_plus.dart';

class NetworkService {
  final NetworkInfo _networkInfo = NetworkInfo();
  
  Future<String?> getLocalIpAddress() async {
    try {
      final wifiIP = await _networkInfo.getWifiIP();
      return wifiIP;
    } catch (e) {
      return null;
    }
  }
  
  Future<String?> getWifiName() async {
    try {
      final wifiName = await _networkInfo.getWifiName();
      return wifiName;
    } catch (e) {
      return null;
    }
  }
  
  Future<String?> getWifiBSSID() async {
    try {
      final wifiBSSID = await _networkInfo.getWifiBSSID();
      return wifiBSSID;
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> isWifiConnected() async {
    try {
      final wifiIP = await _networkInfo.getWifiIP();
      return wifiIP != null && wifiIP.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}