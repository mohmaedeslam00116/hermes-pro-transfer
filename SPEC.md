# Hermes - Technical Specification

## 📋 Project Overview

| Attribute | Value |
|-----------|-------|
| **Project Name** | Hermes |
| **Project Type** | Android Mobile Application |
| **Framework** | Flutter |
| **Core Functionality** | Local file transfer over LAN without internet |
| **Target Platform** | Android (SDK 26+) |
| **License** | GNU GPLv3 |
| **Repository** | [hermes-pro-transfer](https://github.com/mohmaedeslam00116/hermes-pro-transfer) |

---

## 🎯 Objectives

Hermes is a modern, fast, and secure file transfer application designed for local network sharing. It enables users to send and receive files between Android devices and computers without internet connectivity or Bluetooth pairing.

### Primary Goals
1. Zero-configuration file sharing
2. Maximum transfer speeds over local network
3. Cross-platform compatibility (future)
4. Privacy-first: no cloud, no tracking
5. Beautiful, modern UI experience

---

## 🛠️ Technical Stack

### Framework & Language
- **Framework**: Flutter 3.24.0
- **Language**: Dart 3.x
- **Min Android SDK**: 26 (Android 8.0 Oreo)
- **Target Android SDK**: 35

### Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | ^6.1.0 | State management |
| `dio` | ^5.0.0 | HTTP client for transfers |
| `file_picker` | ^6.0.0 | File selection |
| `permission_handler` | ^11.0.0 | Runtime permissions |
| `network_info_plus` | ^5.0.0 | Network/IP detection |
| `qr_flutter` | ^4.0.0 | QR code generation |
| `mobile_scanner` | ^4.0.0 | QR code scanning |
| `path_provider` | ^2.0.15 | File system paths |

### Development Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | SDK | Unit testing |
| `flutter_lints` | ^5.0.0 | Code quality |

---

## 🏗️ Architecture

### Design Pattern
- **Clean Architecture** with separation of concerns
- **Provider** for reactive state management
- **Service-oriented** backend design

### Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart    # App-wide constants
│   └── theme/
│       └── app_theme.dart       # Theme configuration
├── models/
│   └── transfer_state.dart      # Data models
├── providers/
│   └── app_provider.dart        # Global state
├── services/
│   ├── network_service.dart     # Network utilities
│   └── file_service.dart       # File operations
├── screens/
│   ├── onboarding/              # First-run screens
│   ├── dashboard/               # Main hub
│   ├── technology_picker/       # Tech selection
│   └── transfer/               # Transfer UI
└── main.dart                   # Entry point
```

---

## 📱 Screen Flow

```
┌─────────────────┐
│   Onboarding    │ (First run only)
│  Permissions    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    Dashboard    │ ◄─────────────┐
│  Send / Receive │              │
└────────┬────────┘              │
         │                       │
    ┌────┴────┐                  │
    │         │                  │
    ▼         ▼                  │
┌───────┐  ┌───────┐             │
│ Send  │  │Receive│             │
└───┬───┘  └───┬───┘             │
    │          │                 │
    ▼          ▼                 │
┌─────────────────────┐           │
│ Technology Picker   │          │
│ HTTP / WiFi Direct / WebRTC    │
└──────────┬──────────┘          │
           │                     │
           ▼                     │
┌─────────────────────┐           │
│   Transfer Screen   │───────────┘
│  Progress / QR Code│
└─────────────────────┘
```

---

## 🔧 Transfer Technologies

### 1. HTTP Server
- **Protocol**: HTTP/HTTPS
- **Port**: Dynamic (typically 8080)
- **Method**: Device starts HTTP server, other devices download
- **Pros**: Maximum compatibility, works everywhere
- **Cons**: Requires server device to stay awake

### 2. Wi-Fi Direct
- **Protocol**: Wi-Fi P2P
- **Method**: Direct device-to-device connection
- **Pros**: No router needed, fastest speeds
- **Cons**: Limited device support, setup complexity

### 3. WebRTC
- **Protocol**: WebRTC DataChannel
- **Method**: P2P data transfer
- **Pros**: Encrypted by default, low latency
- **Cons**: NAT traversal issues, complex setup

---

## 🎨 UI/UX Design

### Color Scheme
- **Primary**: Teal (#00897B)
- **Secondary**: Orange (#FF6D00)
- **Background Light**: #FAFAFA
- **Background Dark**: #121212
- **Surface Dark**: #1E1E1E

### Typography
- **Font Family**: Plus Jakarta Sans (Google Fonts)
- **Headings**: Bold, larger sizes
- **Body**: Regular weight, readable sizes

### Design Principles
- **Glassmorphism**: Frosted glass effects on cards
- **Gradient Icons**: Modern gradient iconography
- **3D Cards**: Elevated cards with shadows
- **Smooth Animations**: Fluid transitions
- **Dark Mode**: Full dark theme support

---

## 🔒 Security

### Transfer Security
- HTTPS with self-signed certificates
- Local network only (no internet exposure)
- No cloud storage or third-party servers
- User-controlled access

### Data Privacy
- No analytics or tracking
- No data collection
- All processing done locally
- Files never leave your network

---

## 📊 Performance Requirements

| Metric | Target |
|--------|--------|
| App Launch Time | < 2 seconds |
| File List Loading | < 500ms |
| QR Code Generation | < 100ms |
| Transfer Speed | Network-limited |
| Memory Usage | < 150MB |
| APK Size | < 110MB |

---

## 📦 CI/CD Pipeline

### GitHub Actions Workflow

```
Push/PR to main
      │
      ▼
┌─────────────┐
│ Flutter     │
│ Analyze     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Build Debug │
│ APK         │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Build       │
│ Release APK │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Upload to    │
│ Release      │
└─────────────┘
```

---

## 🚀 Future Roadmap

### Phase 1 (v1.0)
- [x] Basic file transfer
- [x] QR code connection
- [x] Multiple technologies
- [x] Dark mode

### Phase 2 (v1.1)
- [ ] Transfer history
- [ ] Multiple file selection
- [ ] Pause/Resume

### Phase 3 (v2.0)
- [ ] iOS support
- [ ] Desktop apps
- [ ] File preview
- [ ] Compression options

---

## 📝 API Reference

### NetworkService
```dart
class NetworkService {
  Future<String?> getLocalIP();
  Future<bool> isOnLocalNetwork();
  String generateConnectionString(String ip, int port);
}
```

### FileService
```dart
class FileService {
  Future<List<File>> pickFiles();
  Future<String> getDownloadPath();
  Future<void> saveFile(String name, bytes);
}
```

---

## 🧪 Testing Strategy

### Unit Tests
- Service layer logic
- Model serialization
- Utility functions

### Widget Tests
- Screen rendering
- User interactions
- State changes

### Integration Tests
- Full transfer flow
- Multi-screen navigation

---

## 📄 Compliance

- **GDPR**: No user data collection
- **Play Store**: Following all guidelines
- **GPLv3**: Open source compliance

---

<div align="center">
  <p>Last Updated: 2026-04-21</p>
  <p>Hermes © 2026 | <a href="https://github.com/mohmaedeslam00116/hermes-pro-transfer">GitHub</a></p>
</div>
