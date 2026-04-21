import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/desktop_shell.dart';
import 'widgets/desktop_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager
  await windowManager.ensureInitialized();
  
  const windowOptions = WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(900, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Hermes',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const HermesDesktopApp());
}

class HermesDesktopApp extends StatelessWidget {
  const HermesDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hermes',
      debugShowCheckedModeBanner: false,
      theme: DesktopTheme.darkTheme,
      home: const DesktopShell(),
    );
  }
}
