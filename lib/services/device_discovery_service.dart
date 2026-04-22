import 'dart:async';
import 'dart:io';

/// Device Discovery Service using UDP broadcast
/// Discovers Hermes devices on the local network without manual IP entry
/// 
/// Note: Using ports 41234/41235 to avoid mDNS/Avahi conflicts (ports 5353/5354)
class DeviceDiscoveryService {
  // Use custom ports to avoid mDNS conflicts
  static const int broadcastPort = 41234;
  static const int discoveryPort = 41235;
  static const String broadcastAddress = '255.255.255.255';
  static const String discoveryMessage = 'HERMES_DISCOVERY';
  static const String discoveryResponse = 'HERMES_RESPONSE';
  static const Duration discoveryTimeout = Duration(seconds: 5);

  RawDatagramSocket? _socket;
  RawDatagramSocket? _senderSocket;
  bool _isListening = false;
  final List<DiscoveredDevice> _discoveredDevices = [];
  StreamSubscription<RawSocketEvent>? _subscription;
  Timer? _cleanupTimer;

  List<DiscoveredDevice> get devices => List.unmodifiable(_discoveredDevices);
  bool get isListening => _isListening;

  /// Start listening for device discovery broadcasts
  Future<bool> startListening() async {
    if (_isListening) return true;

    try {
      // Bind to discovery port
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        discoveryPort,
        reuseAddress: true,
        reusePort: true,
      );

      _socket!.broadcast = true;
      _isListening = true;
      _discoveredDevices.clear();

      // Listen for incoming broadcasts
      _subscription = _socket!.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = _socket!.receive();
          if (datagram != null) {
            _handleBroadcast(datagram);
          }
        }
      });

      return true;
    } catch (e) {
      print('Failed to start discovery listener: $e');
      _isListening = false;
      return false;
    }
  }

  /// Handle incoming device broadcast
  void _handleBroadcast(Datagram datagram) {
    try {
      final data = String.fromCharCodes(datagram.data);
      final address = datagram.address;

      // Ignore our own broadcasts
      if (address == InternetAddress.anyIPv4 ||
          address == InternetAddress.loopbackIPv4) {
        return;
      }

      // Parse device info from message
      // Format: HERMES_RESPONSE|{ip}|{port}|{name}
      if (data.startsWith(discoveryResponse)) {
        final parts = data.split('|');
        if (parts.length >= 4) {
          final deviceIp = parts[1];
          final devicePort = int.tryParse(parts[2]) ?? 8080;
          final deviceName = parts[3];

          // Add or update device
          _updateDevice(
            DiscoveredDevice(
              ip: deviceIp,
              port: devicePort,
              name: deviceName,
              lastSeen: DateTime.now(),
            ),
          );
        }
      }
    } catch (e) {
      print('Error handling broadcast: $e');
    }
  }

  /// Update or add device to list
  void _updateDevice(DiscoveredDevice device) {
    final existingIndex = _discoveredDevices.indexWhere((d) => d.ip == device.ip);
    if (existingIndex >= 0) {
      _discoveredDevices[existingIndex] = device;
    } else {
      _discoveredDevices.add(device);
    }
  }

  /// Discover devices on the network by broadcasting
  Future<List<DiscoveredDevice>> discoverDevices() async {
    _discoveredDevices.clear();

    if (!_isListening) {
      final started = await startListening();
      if (!started) return [];
    }

    // Send broadcast discovery message
    await _sendBroadcast();

    // Wait for responses
    await Future.delayed(discoveryTimeout);

    // Return discovered devices
    return devices;
  }

  /// Send broadcast discovery message
  Future<void> _sendBroadcast() async {
    try {
      // Create and store UDP socket for sending broadcast
      _senderSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0, // Let system choose port
      );

      _senderSocket!.broadcast = true;

      final message = '$discoveryMessage|8080|Hermes';
      _senderSocket!.send(
        message.codeUnits,
        InternetAddress(broadcastAddress),
        broadcastPort,
      );

      // Schedule cleanup after short delay
      _cleanupTimer?.cancel();
      _cleanupTimer = Timer(const Duration(milliseconds: 200), () {
        _closeSenderSocket();
      });
    } catch (e) {
      print('Broadcast error: $e');
      _closeSenderSocket();
    }
  }

  void _closeSenderSocket() {
    try {
      _senderSocket?.close();
      _senderSocket = null;
    } catch (_) {
      _senderSocket = null;
    }
  }

  /// Announce our presence to the network
  Future<void> announcePresence({
    int port = 8080,
    String deviceName = 'Hermes',
  }) async {
    try {
      if (!_isListening) {
        await startListening();
      }

      // Use existing socket or create new one
      RawDatagramSocket socket;
      bool shouldClose = false;
      
      if (_senderSocket == null) {
        socket = await RawDatagramSocket.bind(
          InternetAddress.anyIPv4,
          0,
        );
        shouldClose = true;
      } else {
        socket = _senderSocket!;
      }

      socket.broadcast = true;
      final localIp = await _getLocalIp();
      final message = '$discoveryResponse|$localIp|$port|$deviceName';
      
      socket.send(
        message.codeUnits,
        InternetAddress(broadcastAddress),
        broadcastPort,
      );

      // Close if we created a new socket
      if (shouldClose) {
        _cleanupTimer?.cancel();
        _cleanupTimer = Timer(const Duration(milliseconds: 200), () {
          socket.close();
        });
      }
    } catch (e) {
      print('Announce error: $e');
    }
  }

  /// Get local IP address
  Future<String> _getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 &&
              !addr.isLoopback &&
              !addr.isEmpty) {
            return addr.address;
          }
        }
      }
    } catch (_) {}

    return '127.0.0.1';
  }

  /// Stop listening and cleanup
  Future<void> stopListening() async {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    
    _subscription?.cancel();
    _subscription = null;

    if (_socket != null) {
      try {
        _socket!.close();
      } catch (_) {}
      _socket = null;
    }

    _closeSenderSocket();
    _isListening = false;
  }

  /// Cleanup
  void dispose() {
    stopListening();
    _discoveredDevices.clear();
  }
}

/// Discovered device model
class DiscoveredDevice {
  final String ip;
  final int port;
  final String name;
  final DateTime lastSeen;

  DiscoveredDevice({
    required this.ip,
    required this.port,
    required this.name,
    required this.lastSeen,
  });

  String get url => 'http://$ip:$port';

  bool get isOnline {
    return DateTime.now().difference(lastSeen).inSeconds < 30;
  }

  @override
  String toString() => 'DiscoveredDevice($name at $ip:$port)';
}
