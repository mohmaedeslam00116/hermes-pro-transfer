import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../widgets/desktop_theme.dart';
import 'send_screen.dart';
import 'receive_screen.dart';

class DesktopShell extends StatefulWidget {
  const DesktopShell({super.key});

  @override
  State<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<DesktopShell> with WindowListener {
  int _selectedIndex = 0;
  bool _isMaximized = false;

  final List<NavigationItem> _navItems = [
    NavigationItem(
      icon: Icons.upload_file_rounded,
      label: 'Send',
      description: 'Share files to devices',
    ),
    NavigationItem(
      icon: Icons.download_rounded,
      label: 'Receive',
      description: 'Download files from devices',
    ),
    NavigationItem(
      icon: Icons.history_rounded,
      label: 'History',
      description: 'View transfer history',
    ),
  ];

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _initWindow();
  }

  Future<void> _initWindow() async {
    _isMaximized = await windowManager.isMaximized();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    setState(() => _isMaximized = true);
  }

  @override
  void onWindowUnmaximize() {
    setState(() => _isMaximized = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: DesktopTheme.gradientBackground,
        child: Column(
          children: [
            _buildTitleBar(),
            Expanded(
              child: Row(
                children: [
                  _buildSidebar(),
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBar() {
    return GestureDetector(
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: DesktopTheme.surface.withOpacity(0.5),
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.rocket_launch_rounded,
              color: DesktopTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Hermes',
              style: TextStyle(
                color: DesktopTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _buildWindowButton(
              icon: Icons.remove,
              onPressed: () => windowManager.minimize(),
            ),
            _buildWindowButton(
              icon: _isMaximized ? Icons.filter_none : Icons.crop_square,
              onPressed: () async {
                if (_isMaximized) {
                  await windowManager.unmaximize();
                } else {
                  await windowManager.maximize();
                }
              },
            ),
            _buildWindowButton(
              icon: Icons.close,
              onPressed: () => windowManager.close(),
              isClose: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWindowButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isClose = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        hoverColor: isClose
            ? DesktopTheme.error.withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 46,
          height: 32,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 16,
            color: isClose
                ? DesktopTheme.textSecondary
                : DesktopTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DesktopTheme.surface.withOpacity(0.3),
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DesktopTheme.primaryColor.withOpacity(0.2),
                  DesktopTheme.accent.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DesktopTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    color: DesktopTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hermes',
                      style: TextStyle(
                        color: DesktopTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Local Transfer',
                      style: TextStyle(
                        color: DesktopTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Navigation
          const Text(
            'NAVIGATION',
            style: TextStyle(
              color: DesktopTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView.separated(
              itemCount: _navItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = _selectedIndex == index;
                return _NavItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedIndex = index),
                );
              },
            ),
          ),

          // Settings at bottom
          const Divider(color: Colors.transparent),
          _NavItem(
            item: NavigationItem(
              icon: Icons.settings_rounded,
              label: 'Settings',
              description: 'App preferences',
            ),
            isSelected: false,
            onTap: () {},
          ),

          const SizedBox(height: 16),
          // Version
          Center(
            child: Text(
              'v1.0.0 Desktop',
              style: TextStyle(
                color: DesktopTheme.textSecondary.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _selectedIndex == 0
          ? const SendScreen()
          : _selectedIndex == 1
              ? const ReceiveScreen()
              : _buildHistoryPlaceholder(),
    );
  }

  Widget _buildHistoryPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 80,
            color: DesktopTheme.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Transfer History',
            style: TextStyle(
              color: DesktopTheme.textSecondary.withOpacity(0.5),
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No transfers yet',
            style: TextStyle(
              color: DesktopTheme.textSecondary.withOpacity(0.3),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final String description;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.description,
  });
}

class _NavItem extends StatelessWidget {
  final NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? DesktopTheme.primaryColor.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? DesktopTheme.primaryColor.withOpacity(0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: isSelected
                    ? DesktopTheme.primaryColor
                    : DesktopTheme.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected
                            ? DesktopTheme.textPrimary
                            : DesktopTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: TextStyle(
                        color: DesktopTheme.textSecondary.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: DesktopTheme.primaryColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
