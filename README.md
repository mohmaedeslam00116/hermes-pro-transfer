# Hermes - Local File Transfer App

<div align="center">
  <img src="assets/icon.png" alt="Hermes Logo" width="120"/>
  
  **Hermes** is a professional local file transfer application for Android that enables peer-to-peer file sharing over your local network without internet or Bluetooth.

  [![Flutter](https://img.shields.io/badge/Flutter-3.24.0-blue)](https://flutter.dev)
  [![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20LAN-green)](https://developer.android.com)
  [![License](https://img.shields.io/badge/License-MIT-purple)](LICENSE)
</div>

---

## Features

### 🚀 Core Features
- **Send Files**: Share files to any device on your local network
- **Receive Files**: Download files shared by other devices
- **QR Code Transfer**: Quick connection via QR code scanning
- **Multiple Transfer Technologies**: Choose the best method for your needs

### 🔧 Transfer Technologies

| Technology | Description | Best For |
|------------|-------------|----------|
| **HTTP Server** | Simple and reliable | Most users, cross-platform |
| **Wi-Fi Direct** | Peer-to-peer connection | No router needed |
| **WebRTC** | Modern P2P with low latency | Fast, secure transfers |

### ✨ Advanced Features
- 📁 Multi-file selection and transfer
- 📊 Real-time progress tracking
- 🌙 Dark/Light theme support
- 🔄 Automatic fallback on connection failure
- 📱 Modern Material Design 3 UI

---

## Screenshots

| Dashboard | Send | Receive |
|-----------|------|---------|
| ![Dashboard](screenshots/dashboard.png) | ![Send](screenshots/send.png) | ![Receive](screenshots/receive.png) |

---

## Getting Started

### Prerequisites

- Flutter SDK 3.24.0+
- Android SDK 35+
- Android device with API 26+ (Android 8.0 Oreo)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/mohmaedeslam00116/hermes-pro-transfer.git
   cd hermes-pro-transfer
   ```

2. **Navigate to project:**
   ```bash
   cd hermes_pro
   ```

3. **Get dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

5. **Build debug APK:**
   ```bash
   flutter build apk --debug
   ```

6. **Build release APK:**
   ```bash
   flutter build apk --release
   ```

---

## Project Structure

```
hermes_pro/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── core/
│   │   ├── theme/
│   │   │   └── app_theme.dart   # Light/Dark themes
│   │   └── constants/
│   │       └── app_constants.dart
│   ├── models/
│   │   ├── transfer_file.dart    # File model
│   │   └── transfer_state.dart   # Transfer state model
│   ├── providers/
│   │   ├── app_provider.dart     # App settings
│   │   └── transfer_provider.dart # Transfer logic
│   ├── services/
│   │   ├── network_service.dart  # Network utilities
│   │   └── http_server_service.dart # HTTP server/client
│   └── screens/
│       ├── onboarding/          # First-run experience
│       ├── dashboard/           # Main screen
│       ├── technology_picker/   # Tech selection
│       └── transfer/            # Send/Receive screens
└── android/                     # Android configuration
```

---

## How It Works

### Sending Files
1. Select "Send" on the dashboard
2. Choose transfer technology (HTTP/Wi-Fi Direct/WebRTC)
3. Select files to share
4. Share the QR code or URL with the receiver
5. Wait for connections and transfer to complete

### Receiving Files
1. Select "Receive" on the dashboard
2. Scan the sender's QR code
3. Preview and download incoming files
4. Track progress in real-time

---

## Technology Stack

- **Framework**: Flutter 3.24.0
- **Language**: Dart 3.5.0
- **State Management**: Provider
- **Architecture**: Clean Architecture
- **Target Platform**: Android (API 26+)

### Key Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `dio` | HTTP client |
| `file_picker` | File selection |
| `permission_handler` | Runtime permissions |
| `network_info_plus` | Network utilities |
| `qr_flutter` | QR code generation |
| `mobile_scanner` | QR code scanning |
| `flutter_webrtc` | WebRTC support |

---

## CI/CD

This project uses GitHub Actions for continuous integration:

- ✅ **Flutter Analyze**: Code quality checks
- ✅ **Debug Build**: Automatic APK generation
- ✅ **Release Build**: Production-ready APK on main branch

---

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- Inspired by [LocalSend](https://github.com/localsend/localsend) and [SHAREit](https://shareit.one/)
- Built with ❤️ using Flutter
- Designed for speed, simplicity, and reliability

---

<div align="center">
  <p>Made with ❤️ by the Hermes Team</p>
  <p>© 2024 Hermes. All rights reserved.</p>
</div>