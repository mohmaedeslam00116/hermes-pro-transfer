# Changelog

All notable changes to the Hermes project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.0.1] - 2026-04-22

### Added
- Android-only release (simpler, more stable)

### Fixed
- receive_screen variable naming typo
- transfer_screen port (using AppConstants.httpServerPort)
- technology_picker color handling
- technology_picker isSend logic
- onboarding permissions (parallel requests)
- network_service timeout and disposal
- device_discovery_service fixes
- transfer_provider variable shadowing

### Code Quality
- Android code is now error-free (flutter analyze passes)
- 2 minor warnings (unused variables)

### Removed
- Windows Desktop support (temporarily disabled)
- Linux Desktop support

---

## [v1.0.0-desktop] - 2026-04-21

### Added
- **Desktop Support** - Linux and Windows desktop builds
- **Hermes Desktop** - Full desktop application with drag-and-drop
- **CI/CD Desktop Builds** - Automated Linux and Windows builds
- **Modern Desktop UI** - Professional glassmorphism design

### Desktop Features
- Linux Desktop Bundle (23 MB)
- Windows Desktop Bundle
- Desktop HTTP Server using Shelf
- Drag-and-drop file selection
- Network IP detection

---

## [v1.0.0-beta.3] - 2026-04-21

### Added
- **CI/CD Pipeline** - Full GitHub Actions automation
- **36 Unit Tests** - Comprehensive test coverage
- **Analysis Options** - Strict code quality enforcement

### CI/CD Jobs
- Flutter Analyze ✅
- Flutter Test ✅ (28 tests)
- Build Linux Desktop ✅
- Build Windows Desktop ✅
- Build Debug APK ✅
- Build Release APK ✅

---

## [v1.0.0-beta.2] - 2026-04-21

### Added
- **Desktop Application** - lib/desktop/ module
- **DesktopTheme** - Custom desktop theming
- **DesktopHttpServer** - Shelf-based HTTP server
- **DesktopShell** - Main desktop interface
- **SendScreen** - Desktop file sending
- **ReceiveScreen** - Desktop file receiving

---

## [v1.0.0-beta.1] - 2026-04-21

### Added
- **Initial Release** - First public beta release
- **Three Transfer Technologies**: HTTP Server, Wi-Fi Direct, WebRTC
- **QR Code Integration**: Easy connection via QR scanning
- **Dark Mode Support**: Full dark theme implementation
- **Modern UI**: Glassmorphism design with Teal/Orange color scheme
- **Onboarding Flow**: First-run permission handling
- **Dashboard**: Clean main screen with Send/Receive options
- **Technology Picker**: Visual technology selection cards
- **Transfer Screen**: Progress tracking and QR code display

### Technical Details
- **Min SDK**: 26 (Android 8.0 Oreo)
- **Compile SDK**: 35
- **Flutter Version**: 3.27.0
- **State Management**: Provider
- **License**: GPLv3

### Dependencies
- `dio: ^5.0.0` - HTTP client
- `file_picker: ^6.0.0` - File selection
- `permission_handler: ^11.0.0` - Runtime permissions
- `network_info_plus: ^5.0.0` - IP detection
- `qr_flutter: ^4.0.0` - QR generation
- `mobile_scanner: ^4.0.0` - QR scanning
- `path_provider: ^2.0.15` - File storage paths
- `provider: ^6.1.0` - State management
- `shelf: ^1.4.1` - Desktop HTTP server
- `window_manager: ^0.3.9` - Desktop window control
- `desktop_drop: ^0.4.4` - Drag and drop support

### Known Issues
- Wi-Fi Direct requires device support
- WebRTC may have NAT traversal issues on some networks

---

## Version History

| Version | Date | Type | Status |
|---------|------|------|--------|
| v1.0.0-desktop | 2026-04-21 | Beta | ✅ Released |
| v1.0.0-beta.3 | 2026-04-21 | Beta | ✅ Released |
| v1.0.0-beta.2 | 2026-04-21 | Beta | ✅ Released |
| v1.0.0-beta.1 | 2026-04-21 | Beta | ✅ Released |

---

<div align="center">
  <p>Hermes © 2026 | <a href="https://github.com/mohmaedeslam00116/hermes-pro-transfer">GitHub Repository</a></p>
</div>