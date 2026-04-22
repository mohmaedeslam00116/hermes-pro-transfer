import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
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

/// Modern Glassmorphism Onboarding Screen with enhanced UI/UX
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.wifi,
      title: 'Connect to Wi-Fi',
      description:
          'Make sure your device is on the same Wi-Fi network as the receiver.',
      color: AppTheme.primaryColor,
    ),
    OnboardingPage(
      icon: Icons.folder_open,
      title: 'File Access',
      description:
          'Grant storage permissions to browse and share your files securely.',
      color: AppTheme.secondaryColor,
    ),
    OnboardingPage(
      icon: Icons.qr_code_scanner,
      title: 'Quick Transfer',
      description:
          'Scan QR code to connect instantly. No typing IP addresses needed.',
      color: AppTheme.accentColor,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

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
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      await _requestPermissions();

      if (!mounted) return;
      final appProvider = context.read<AppProvider>();
      await appProvider.completeOnboarding();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToPage(int index) {
    _animationController.reset();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    _animationController.forward();
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
              // Header with Skip and Progress
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMD),
                child: Row(
                  children: [
                    // Progress indicator
                    Expanded(
                      child: Row(
                        children: List.generate(
                          _pages.length,
                          (index) => Expanded(
                            child: Container(
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: index <= _currentPage
                                    ? _pages[index].color
                                    : isDark
                                        ? AppTheme.darkMuted
                                        : AppTheme.lightMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Skip button
                    TextButton(
                      onPressed: _isLoading ? null : _completeOnboarding,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.darkForeground.withOpacity(0.7)
                              : AppTheme.lightForeground.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    _animationController.reset();
                    _animationController.forward();
                  },
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_pages[index], size, isDark);
                  },
                ),
              ),

              // Bottom Controls
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLG),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
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
                                  onPressed: _isLoading
                                      ? null
                                      : () => _goToPage(_currentPage - 1),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: AppTheme.spacingMD),
                                  ),
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
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        if (_currentPage < _pages.length - 1) {
                                          _goToPage(_currentPage + 1);
                                        } else {
                                          _completeOnboarding();
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _pages[_currentPage].color,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: AppTheme.spacingMD),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(_currentPage <
                                                  _pages.length - 1
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
                ),
              ),

              // Version footer
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingMD),
                child: Text(
                  'v${AppConstants.appVersion}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppTheme.darkForeground.withOpacity(0.3)
                            : AppTheme.lightForeground.withOpacity(0.3),
                      ),
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
          // Icon Container with Glassmorphism and animated glow
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            tween: Tween(begin: 0.8, end: 1.0),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Container(
                width: size.width * 0.6 * value,
                height: size.width * 0.6 * value,
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
              );
            },
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