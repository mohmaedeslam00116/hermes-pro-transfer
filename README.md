# Hermes 📡

<p align="center">
  <a href="https://github.com/mohmaedeslam00116/hermes-pro-transfer/releases">
    <img src="https://img.shields.io/github/v/release/mohmaedeslam00116/hermes-pro-transfer?include_prereleases&style=flat&color=0D9488" alt="Release">
  </a>
  <a href="https://github.com/mohmaedeslam00116/hermes-pro-transfer/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/mohmaedeslam00116/hermes-pro-transfer?color=0D9488" alt="License">
  </a>
  <a href="https://github.com/mohmaedeslam00116/hermes-pro-transfer/actions">
    <img src="https://img.shields.io/github/actions/workflow/status/mohmaedeslam00116/hermes-pro-transfer/build.yml?color=0D9488" alt="Build">
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android-0D9488?style=for-the-badge&logo=android" alt="Android">
  <img src="https://img.shields.io/badge/Framework-Flutter-02569B?style=for-the-badge&logo=flutter" alt="Flutter">
</p>

<p align="center">
  <strong>Hermes</strong> — A fast, secure, and easy-to-use local file transfer application. Share files between devices over your home network without internet or Bluetooth.
</p>

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🚀 **High Speed Transfer** | Transfer files over Wi-Fi at maximum speed |
| 📱 **Android Only** | Native Android application |
| 🔒 **Secure** | End-to-end encryption via HTTPS |
| 🌙 **Dark Mode** | Comfortable dark theme for night use |
| 📲 **QR Code** | Quick connection via QR code scanning |
| 🔌 **No Internet Required** | Works locally without internet connection |
| 🎯 **Multiple Technologies** | Supports HTTP, Wi-Fi Direct, and WebRTC |
| 🌐 **LAN Only** | No cloud, no servers — your data stays on your network |

---

## 📥 Downloads

### Latest Release

| Platform | File | Status |
|----------|------|--------|
| Android | Release APK | ✅ [Download](https://github.com/mohmaedeslam00116/hermes-pro-transfer/releases/latest) |

### Quick Download
Download from the [Actions](https://github.com/mohmaedeslam00116/hermes-pro-transfer/actions) tab:
1. Go to latest workflow run
2. Find your platform under "Artifacts"
3. Download the artifact

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.27.0 or higher
- Android SDK 26+ (Android 8.0 Oreo)
- Android device with Wi-Fi capability

### Installation

```bash
# Clone the repository
git clone https://github.com/mohmaedeslam00116/hermes-pro-transfer.git
cd hermes-pro-transfer

# Install dependencies
flutter pub get

# Build Android APK
flutter build apk --release

# Build Linux Desktop
flutter config --enable-linux-desktop
flutter build linux --release

# Build Windows Desktop
flutter config --enable-windows-desktop
flutter build windows --release
```

### Running the App

```bash
# Debug build
flutter run

# Release build
flutter build apk --release
```

---

## 📁 Project Structure

```
hermes-pro-transfer/
├── lib/
│   ├── core/
│   │   ├── constants/     # App constants
│   │   └── theme/         # Theme definitions
│   ├── desktop/           # Desktop application
│   │   ├── screens/       # Desktop UI screens
│   │   ├── services/      # Desktop services
│   │   └── widgets/       # Desktop widgets
│   ├── models/            # Data models
│   ├── providers/         # State management
│   ├── services/          # Network services
│   └── screens/           # Mobile UI screens
├── android/               # Android configuration
├── ios/                   # iOS configuration
├── linux/                 # Linux configuration
├── windows/               # Windows configuration
├── assets/                # App assets
├── test/                  # Unit and widget tests
├── .github/
│   └── workflows/         # CI/CD pipelines
├── LICENSE               # GPLv3 License
├── README.md             # This file
└── CHANGELOG.md          # Version history
```

---

## 🛠️ Supported Technologies

### 1. HTTP Server
- ✅ Most reliable method
- ✅ Works on any Wi-Fi network
- ✅ Zero configuration required
- ✅ Best compatibility across devices

### 2. Wi-Fi Direct
- ✅ Direct device-to-device connection
- ✅ No router needed
- ✅ Ultra-fast transfer speeds
- ✅ Works in offline scenarios

### 3. WebRTC
- ✅ Modern P2P technology
- ✅ Automatic encryption
- ✅ Ultra-low latency
- ✅ NAT traversal built-in

---

## 🏗️ Architecture

### State Management
- **Provider** for reactive state management
- Clean separation between UI and business logic
- Centralized app state for transfer progress, errors, and settings

### Services
- `NetworkService` - Device IP detection, network scanning
- `HttpServerService` - Local HTTP server for file hosting
- `FileTransferService` - File sending and receiving logic
- `DesktopHttpServer` - Shelf-based HTTP server for desktop

### Models
- `TransferState` - Transfer progress, status, errors
- `TransferFile` - File metadata (name, size, path)
- `TransferTechnology` - Technology enum (HTTP, WiFiDirect, WebRTC)

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run unit tests
flutter test test/unit/

# Run widget tests
flutter test test/widget/
```

### Test Coverage
- ✅ 36 tests (unit + widget)
- ✅ Transfer state tests
- ✅ Provider tests
- ✅ Widget tests

---

## 🤝 Contributing

Contributions are welcome! Please read our [CONTRIBUTING.md](CONTRIBUTING.md) guide before submitting pull requests.

### Development Workflow
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
6. CI/CD will automatically build and test your changes

---

## 📄 License

This project is licensed under the **GNU General Public License v3.0 (GPLv3)** — see the [LICENSE](LICENSE) file for details.

### Key Points of GPLv3:
- ✅ Free to use, modify, and distribute
- ✅ Source code must be provided
- ✅ Modifications must be released under GPLv3
- ✅ No patent litigation allowed

---

## 🔐 Security

Please read our [SECURITY.md](SECURITY.md) for responsible disclosure guidelines and security practices.

---

## 📈 Roadmap

- [x] Android APK support
- [x] Linux Desktop support
- [x] Windows Desktop support
- [ ] macOS Desktop support
- [ ] File transfer history
- [ ] Multiple file selection
- [ ] Pause/Resume transfers
- [ ] Background transfer support
- [ ] iOS support

---

## 🐛 Reporting Issues

Found a bug? Please report it via [GitHub Issues](https://github.com/mohmaedeslam00116/hermes-pro-transfer/issues).

For security vulnerabilities, please see [SECURITY.md](SECURITY.md).

---

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - UI framework
- [Provider](https://pub.dev/packages/provider) - State management
- [Dio](https://pub.dev/packages/dio) - HTTP client
- [LocalSend](https://localsend.org/) - Inspiration for local file sharing
- [Shelf](https://pub.dev/packages/shelf) - Desktop HTTP server

---

<div align="center">
  <p>Made with ❤️ by <a href="https://github.com/mohmaedeslam00116">Mohamed Eslam</a></p>
  <p>Hermes © 2026</p>
</div>