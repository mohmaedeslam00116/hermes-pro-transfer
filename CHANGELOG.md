# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0-beta.1] - 2026-04-21

### Added
- **Onboarding Screen**: First-run experience with permission requests
- **Dashboard**: Main screen with Send and Receive options
- **Technology Picker**: Selection screen for transfer methods
- **Send Screen**: QR code generation for file sharing
- **Receive Screen**: QR code scanner for receiving files
- **HTTP Server Transfer**: Simple and reliable file transfer via HTTP
- **Wi-Fi Direct Support**: Ready for peer-to-peer connections
- **WebRTC Support**: Ready for modern P2P transfers
- **Dark/Light Theme**: Theme switching support
- **File Selection**: Multi-file selection with file picker
- **Progress Tracking**: Real-time transfer progress indicators
- **Manual URL Entry**: Option to enter server URL manually

### Technical Features
- **Provider State Management**: Clean architecture with Provider
- **Material Design 3**: Modern UI components
- **Android SDK 26+**: Support for Android 8.0 Oreo and above
- **CI/CD Pipeline**: GitHub Actions for automated builds
- **Code Analysis**: Flutter analyze in CI pipeline

### Dependencies
- `provider: ^6.1.2` - State management
- `dio: ^5.4.0` - HTTP client
- `file_picker: ^8.0.0` - File selection
- `permission_handler: ^11.3.0` - Runtime permissions
- `network_info_plus: ^6.0.0` - Network utilities
- `qr_flutter: ^4.1.0` - QR code generation
- `mobile_scanner: ^5.1.0` - QR code scanning
- `shared_preferences: ^2.2.3` - Local storage
- `flutter_webrtc: ^0.11.0` - WebRTC support
- `path_provider: ^2.1.3` - File paths

### Known Issues
- Wi-Fi Direct requires additional platform-specific implementation
- WebRTC signaling server not included in this release
- Large file transfer (>1GB) may experience memory issues

### Roadmap
- [ ] Full Wi-Fi Direct implementation
- [ ] WebRTC with built-in signaling
- [ ] File compression for faster transfers
- [ ] Transfer history
- [ ] iOS support
- [ ] Multi-language support (Arabic, Spanish, etc.)

---

## [0.1.0] - 2026-04-20

### Added
- Initial project setup
- Basic project structure
- CI/CD configuration
