# Hermes - Local File Transfer App Specification

## 1. Project Overview

**Project Name**: Hermes (hermes_pro)  
**Type**: Android Flutter Application  
**Core Functionality**: Professional local file transfer application over LAN (Local Area Network) without internet or Bluetooth. Enables P2P file transfer between Android devices and computers.

## 2. Technology Stack & Choices

### Framework & Language
- **Framework**: Flutter 3.24.0+
- **Language**: Dart 3.5.0+
- **Platform**: Android (minSdkVersion 26 - Android 8.0 Oreo)
- **Organization**: com.hermes.pro

### Key Libraries/Dependencies
```yaml
dependencies:
  dio: ^5.4.0              # HTTP/HTTPS file transfer
  file_picker: ^8.0.0      # File selection
  permission_handler: ^11.3.0  # Storage/Wi-Fi permissions
  network_info_plus: ^6.0.0  # Local IP detection
  qr_flutter: ^4.1.0       # QR Code generation
  mobile_scanner: ^5.1.0   # QR Code scanning
  path_provider: ^2.1.3   # Download folder
  flutter_webrtc: ^0.11.0  # WebRTC P2P
  wifi_direct: ^0.2.0     # Wi-Fi Direct
  shared_preferences: ^2.2.3  # Settings storage
  provider: ^6.1.2        # State management
```

### State Management
- **Provider** for reactive state management
- Dedicated providers for: Transfer State, App State, Settings

### Architecture Pattern
- **Clean Architecture** with 3 layers:
  - Presentation (UI/Screens/Widgets)
  - Domain (Business Logic/Services)
  - Data (Repositories/Models)

## 3. Feature List

### Core Features
1. **Onboarding Screen**: First-run permissions request (Storage, Wi-Fi)
2. **Dashboard Screen**: Two main options - Send / Receive
3. **Technology Picker**: Choose between 3 transfer technologies
4. **Transfer Screen**: Execute send/receive operations

### Transfer Technologies
1. **HTTP Server**: Simple, reliable, works everywhere
2. **Wi-Fi Direct**: Fast, peer-to-peer without router
3. **WebRTC**: Modern, secure, low-latency P2P

### Advanced Features
- QR Code generation for easy sharing
- QR Code scanning for receiving
- Real-time progress tracking
- Automatic fallback on connection failure
- Resume interrupted transfers
- Dark mode support

## 4. UI/UX Design Direction

### Overall Visual Style
- Modern, clean Material Design 3
- Professional, minimalist interface
- Following 2026 best practices

### Color Scheme
- Primary: Deep Blue (#1565C0)
- Secondary: Teal Accent (#00BFA5)
- Background: Dark/Light based on theme
- Surface: Elevated cards with subtle shadows

### Layout Approach
- Single-page flow with navigation
- Bottom navigation for main sections
- Modal sheets for options
- Full-screen transfer progress views

### Key UI Components
- Large touch-friendly buttons
- Animated transitions
- Progress indicators
- Status badges
- QR code displays with copy actions