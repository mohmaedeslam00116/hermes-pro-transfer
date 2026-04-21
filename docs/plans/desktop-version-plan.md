# Hermes Desktop Implementation Plan

> **For Hermes:** Use subagent-driven-development skill to implement this plan.

**Goal:** Build Hermes Desktop app for Windows/Linux/macOS with same LAN file transfer functionality as mobile version.

**Architecture:** Modular design with platform abstraction - shared business logic in `lib_core/`, platform-specific implementations in `lib/desktop/` and `lib/mobile/`.

**Tech Stack:** Flutter 3.41+, Provider, Dio, Shelf (desktop HTTP server)

---

## Phase 1: Project Setup

### Task 1: Create Desktop Project Structure

**Objective:** Create new directory structure for desktop-specific code

**Files:**
- Create: `lib/desktop/` (desktop-specific screens and services)
- Create: `lib/mobile/` (move mobile-specific code here)
- Create: `lib_core/` (shared business logic between platforms)

**Step 1: Create directory structure**
```bash
mkdir -p lib/desktop/{screens,services,widgets}
mkdir -p lib/mobile/{screens,services,widgets}
mkdir -p lib_core/{models,providers,services,utils}
```

**Step 2: Move mobile-specific code**
```bash
# Move Android-specific code
mv lib/screens/transfer/receive_screen.dart lib/mobile/screens/
mv lib/services/wifi_direct_service.dart lib/mobile/services/
```

**Step 3: Commit**
```bash
git add .
git commit -m "chore: create desktop/mobile directory structure"
```

---

### Task 2: Update pubspec.yaml for Desktop

**Objective:** Add desktop-compatible dependencies and enable platforms

**Files:**
- Modify: `pubspec.yaml`

**Step 1: Update pubspec.yaml**
```yaml
# Add desktop HTTP server instead of mobile-specific
shelf: ^1.4.1
shelf_router: ^1.1.4
shelf_plus: ^1.0.1

# Cross-platform file picker (already supports desktop)
file_picker: ^8.0.0  # Desktop compatible

# Desktop window management
window_manager: ^0.3.8

# Remove mobile-only dependencies:
# - mobile_scanner (mobile only)
# - wifi_direct (mobile only)
# - permission_handler (mobile only, use different approach on desktop)
```

**Step 2: Run flutter pub get**
```bash
flutter pub get
```

**Step 3: Commit**
```bash
git add pubspec.yaml
git commit -m "feat: add desktop dependencies (shelf, window_manager)"
```

---

### Task 3: Create Desktop HTTP Server Service

**Objective:** Desktop-compatible HTTP server using Shelf

**Files:**
- Create: `lib_core/services/desktop_http_server.dart`

**Step 1: Write the service**
```dart
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

class DesktopHttpServer {
  HttpServer? _server;
  
  Future<String> startServer({
    required String filePath,
    required String fileName,
    int port = 8080,
  }) async {
    final router = Router();
    
    router.get('/download', (Request request) async {
      final file = File(filePath);
      if (!await file.exists()) {
        return Response.notFound('File not found');
      }
      
      final bytes = await file.readAsBytes();
      return Response.ok(
        bytes,
        headers: {
          'Content-Type': 'application/octet-stream',
          'Content-Disposition': 'attachment; filename="$fileName"',
          'Content-Length': bytes.length.toString(),
        },
      );
    });
    
    _server = await shelf_io.serve(
      const Pipeline().addMiddleware(logRequests()).addHandler(router.call),
      InternetAddress.anyIPv4,
      port,
    );
    
    return 'http://${_getLocalIp()}:$port/download';
  }
  
  String _getLocalIp() {
    // Get local IP address
    final interfaces = NetworkInterface.list(type: InternetAddressType.IPv4);
    for (final interface in interfaces) {
      for (final addr in interface.addresses) {
        if (!addr.isLoopback) return addr.address;
      }
    }
    return 'localhost';
  }
  
  Future<void> stopServer() async {
    await _server?.close(force: true);
    _server = null;
  }
}
```

**Step 2: Test the service**
```bash
flutter analyze lib_core/services/desktop_http_server.dart
```

**Step 3: Commit**
```bash
git add lib_core/services/desktop_http_server.dart
git commit -m "feat: add DesktopHttpServer using Shelf"
```

---

## Phase 2: Desktop UI Implementation

### Task 4: Create Desktop Main Screen

**Objective:** Professional desktop UI with sidebar navigation

**Files:**
- Create: `lib/desktop/screens/desktop_dashboard.dart`

**Step 1: Write the dashboard**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class DesktopDashboard extends StatelessWidget {
  const DesktopDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Icon(Icons.rocket_launch, size: 48, 
                     color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                Text('Hermes', 
                     style: Theme.of(context).textTheme.headlineSmall),
                const Divider(height: 40),
                _NavItem(icon: Icons.upload, label: 'Send', selected: true),
                _NavItem(icon: Icons.download, label: 'Receive'),
                _NavItem(icon: Icons.history, label: 'History'),
                const Spacer(),
                _NavItem(icon: Icons.settings, label: 'Settings'),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.upload_file, size: 80),
                  const SizedBox(height: 24),
                  Text('Drag & Drop files here', 
                       style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Select Files'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  
  const _NavItem({
    required this.icon, 
    required this.label, 
    this.selected = false
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: selected 
          ? Theme.of(context).colorScheme.primary 
          : null),
      title: Text(label),
      selected: selected,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
      onTap: () {},
    );
  }
}
```

**Step 2: Create main.dart for desktop**
```dart
// lib/desktop/main_desktop.dart
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/desktop_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await windowManager.ensureInitialized();
  
  const windowOptions = WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(800, 600),
    center: true,
    title: 'Hermes',
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  
  runApp(const HermesApp());
}
```

**Step 3: Commit**
```bash
git add lib/desktop/
git commit -m "feat: add desktop dashboard UI"
```

---

### Task 5: Create Desktop Send Screen

**Objective:** File selection and HTTP server start for sending

**Files:**
- Create: `lib/desktop/screens/desktop_send_screen.dart`

**Step 1: Write the send screen**
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/desktop_http_server.dart';

class DesktopSendScreen extends StatefulWidget {
  const DesktopSendScreen({super.key});

  @override
  State<DesktopSendScreen> createState() => _DesktopSendScreenState();
}

class _DesktopSendScreenState extends State<DesktopSendScreen> {
  final _server = DesktopHttpServer();
  File? _selectedFile;
  String? _downloadUrl;
  bool _isServerRunning = false;
  
  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }
  
  Future<void> _startServer() async {
    if (_selectedFile == null) return;
    
    final url = await _server.startServer(
      filePath: _selectedFile!.path,
      fileName: _selectedFile!.name,
    );
    
    setState(() {
      _downloadUrl = url;
      _isServerRunning = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Send Files', 
               style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 32),
          
          // File drop zone
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _selectedFile == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_upload, size: 48),
                        const SizedBox(height: 16),
                        const Text('Select a file to send'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _selectFile,
                          child: const Text('Browse'),
                        ),
                      ],
                    ),
                  )
                : ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(_selectedFile!.name),
                    subtitle: Text('${(_selectedFile!.sizeSync() / 1024 / 1024).toStringAsFixed(2)} MB'),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _selectedFile = null),
                    ),
                  ),
          ),
          
          const SizedBox(height: 24),
          
          if (_selectedFile != null && !_isServerRunning)
            ElevatedButton.icon(
              onPressed: _startServer,
              icon: const Icon(Icons.share),
              label: const Text('Start Sharing'),
            ),
          
          if (_isServerRunning) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Share this link:'),
                    const SizedBox(height: 8),
                    SelectableText(
                      _downloadUrl ?? '',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Open on another device connected to the same network',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _server.stopServer();
    super.dispose();
  }
}
```

**Step 2: Commit**
```bash
git add lib/desktop/screens/desktop_send_screen.dart
git commit -m "feat: add desktop send screen"
```

---

### Task 6: Create Desktop Receive Screen

**Objective:** Download files from mobile devices

**Files:**
- Create: `lib/desktop/screens/desktop_receive_screen.dart`

**Step 1: Write the receive screen**
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DesktopReceiveScreen extends StatefulWidget {
  const DesktopReceiveScreen({super.key});

  @override
  State<DesktopReceiveScreen> createState() => _DesktopReceiveScreenState();
}

class _DesktopReceiveScreenState extends State<DesktopReceiveScreen> {
  final _urlController = TextEditingController();
  final _dio = Dio();
  bool _isDownloading = false;
  double _progress = 0;

  Future<void> _downloadFile() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    try {
      final dir = await getDownloadsDirectory();
      if (dir == null) return;

      setState(() {
        _isDownloading = true;
        _progress = 0;
      });

      await _dio.download(
        url,
        '${dir.path}/hermes_download',
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _progress = received / total;
            });
          }
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download complete!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Receive Files', 
               style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 32),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enter download link from sender:'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      hintText: 'http://192.168.x.x:8080/download',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isDownloading ? null : _downloadFile,
                    icon: const Icon(Icons.download),
                    label: Text(_isDownloading ? 'Downloading...' : 'Download'),
                  ),
                  if (_isDownloading) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(value: _progress),
                    Text('${(_progress * 100).toStringAsFixed(1)}%'),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: Commit**
```bash
git add lib/desktop/screens/desktop_receive_screen.dart
git commit -m "feat: add desktop receive screen"
```

---

## Phase 3: Integration & Build

### Task 7: Build Linux Desktop App

**Objective:** Build and verify desktop app works

**Step 1: Build release**
```bash
flutter build linux --release
```

**Expected:** `build/linux/x64/release/bundle/hermes`

**Step 2: Test the build**
```bash
ls -la build/linux/x64/release/bundle/
```

**Step 3: Commit**
```bash
git add build/linux/x64/release/bundle/
git commit -m "feat: build linux desktop app"
```

---

### Task 8: Update CI/CD for Desktop

**Objective:** Build desktop apps in GitHub Actions

**Files:**
- Modify: `.github/workflows/build.yml`

**Step 1: Add desktop build jobs**
```yaml
jobs:
  linux:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build linux --release
      
  windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build windows --release
```

**Step 2: Commit and push**
```bash
git add .github/workflows/build.yml
git commit -m "ci: add desktop build jobs"
git push
```

---

## Verification Checklist

- [ ] Linux desktop builds successfully
- [ ] Windows desktop builds successfully  
- [ ] File transfer works between desktop and mobile
- [ ] All existing mobile tests still pass
- [ ] CI/CD pipeline passes

---

## Execution

**"Plan complete (8 tasks). Ready to execute using subagent-driven-development."**

Shall I proceed with implementation?
