# Changelog

All notable changes to the Hermes project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- **CI/CD Pipeline**: Automated builds via GitHub Actions

### Technical Details
- **Min SDK**: 26 (Android 8.0 Oreo)
- **Compile SDK**: 35
- **Flutter Version**: 3.24.0
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

### Known Issues
- Wi-Fi Direct requires device support
- WebRTC may have NAT traversal issues on some networks

---

## [Unreleased]

### Planned Features
- File transfer history
- Multiple file selection
- Pause/Resume transfers
- Transfer queue management
- Background transfer support
- iOS support

---

## Release Types

- **Alpha**: Early development releases
- **Beta**: Feature-complete, testing needed
- **RC (Release Candidate)**: Final testing before release
- **Stable**: Production-ready releases

---

## How to Update

1. Download the latest APK from [Releases](https://github.com/mohmaedeslam00116/hermes-pro-transfer/releases)
2. Enable "Install from unknown sources" in Android settings
3. Install the new APK (previous version will be replaced)
4. Your settings and history will be preserved

---

## Version History

| Version | Date | Type | Status |
|---------|------|------|--------|
| v1.0.0-beta.1 | 2026-04-21 | Beta | ✅ Released |

---

<div align="center">
  <p>Hermes © 2026 | <a href="https://github.com/mohmaedeslam00116/hermes-pro-transfer">GitHub Repository</a></p>
</div>
