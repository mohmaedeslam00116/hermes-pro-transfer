import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../dashboard/dashboard_screen.dart';

/// Onboarding Page Data
class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

/// Modern Glassmorphism Onboarding Screen
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.wifi,
      title: 'Connect to Wi-Fi',
      description: 'Make sure your device is on the same Wi-Fi network as the receiver.',
      color: AppTheme.primaryColor,
    ),
    OnboardingPage(
      icon: Icons.folder_open,
      title: 'File Access',
      description: 'Grant storage permissions to browse and share your files securely.',
      color: AppTheme.secondaryColor,
    ),
    OnboardingPage(
      icon: Icons.qr_code_scanner,
      title: 'Quick Transfer',
      description: 'Scan QR code to connect instantly. No typing IP addresses needed.',
      color: AppTheme.accentColor,
    ),
  ];

  Future<void> _requestPermissions() async {
    final permissions = [
      Permission.storage,
      Permission.camera,
      Permission.location,
      Permission.nearbyWifiDevices,
    ];

    for (final permission in permissions) {
      await permission.request();
    }
  }

  Future<void> _completeOnboarding() async {
    await _requestPermissions();

    if (mounted) {
      final appProvider = context.read<AppProvider>();
      await appProvider.completeOnboarding();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppTheme.darkBackground,
                    AppTheme.darkSurface,
                    AppTheme.darkBackground,
                  ]
                : [
                    AppTheme.lightBackground,
                    AppTheme.lightSurface,
                    AppTheme.lightBackground,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMD),
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text('Skip'),
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_pages[index], size, isDark);
                  },
                ),
              ),

              // Bottom Controls
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLG),
                child: Column(
                  children: [
                    // Page Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => _buildDot(index, isDark),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXL),

                    // Buttons
                    Row(
                      children: [
                        if (_currentPage > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_back, size: 20),
                                  SizedBox(width: 8),
                                  Text('Back'),
                                ],
                              ),
                            ),
                          ),
                        if (_currentPage > 0)
                          const SizedBox(width: AppTheme.spacingMD),
                        Expanded(
                          flex: _currentPage > 0 ? 1 : 2,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_currentPage < _pages.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                _completeOnboarding();
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_currentPage < _pages.length - 1
                                    ? 'Next'
                                    : 'Get Started'),
                                const SizedBox(width: 8),
                                Icon(
                                  _currentPage < _pages.length - 1
                                      ? Icons.arrow_forward
                                      : Icons.check,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page, Size size, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLG),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container with Glassmorphism
          Container(
            width: size.width * 0.6,
            height: size.width * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  page.color.withOpacity(0.3),
                  page.color.withOpacity(0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: page.color.withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: page.color.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    page.icon,
                    size: size.width * 0.25,
                    color: page.color,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingXXL),

          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingMD),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLG),
            child: Text(
              page.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDark
                        ? AppTheme.darkForeground.withOpacity(0.7)
                        : AppTheme.lightForeground.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, bool isDark) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isActive
            ? AppTheme.primaryColor
            : isDark
                ? AppTheme.darkMuted
                : AppTheme.lightMuted,
      ),
    );
  }
}