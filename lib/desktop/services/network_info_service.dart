import 'dart:io';

class NetworkInfoService {
  static Future<String?> getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback && !addr.address.startsWith('169.254')) {
            return addr.address;
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<String>> getAllLocalIps() async {
    final ips = <String>[];
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback && !addr.address.startsWith('169.254')) {
            ips.add(addr.address);
          }
        }
      }
    } catch (e) {
      // Ignore
    }
    return ips;
  }
  
  // Synchronous fallback - returns first non-loopback IPv4 address
  static String? getLocalIpSync() {
    try {
      // Scan /proc/net/tcp for local addresses (Linux)
      final file = File('/proc/net/tcp');
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        final lines = content.split('\n');
        for (final line in lines.skip(1)) {
          // Parse IP from hex format
          final parts = line.trim().split(RegExp(r'\s+'));
          if (parts.length > 1) {
            final localAddress = parts[1];
            // Extract IP from "IP:PORT" format
            final ipHex = localAddress.split(':')[0];
            if (ipHex != '0100007F') {
              // Not 127.0.0.1
              final ip = _hexToIp(ipHex);
              if (ip != null) return ip;
            }
          }
        }
      }
    } catch (e) {
      // Ignore
    }
    return '127.0.0.1';
  }
  
  static String? _hexToIp(String hex) {
    try {
      if (hex.length != 8) return null;
      final parts = <int>[];
      for (var i = 6; i >= 0; i -= 2) {
        parts.add(int.parse(hex.substring(i, i + 2), radix: 16));
      }
      final ip = parts.join('.');
      // Validate it's not a multicast/link-local
      if (ip.startsWith('224.') || ip.startsWith('169.254')) {
        return null;
      }
      return ip;
    } catch (e) {
      return null;
    }
  }
}
