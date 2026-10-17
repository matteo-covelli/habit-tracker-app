import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'analytics_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
    _SettingsPlaceholderScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF121622),
          border: Border(
            top: BorderSide(color: Color(0xFF1E2638), width: 0.8),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.auto_graph_outlined,
                  activeIcon: Icons.auto_graph,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person_outline,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF323954) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppColors.primaryButton : AppColors.textSecondary,
          size: 24,
        ),
      ),
    );
  }
}

class _SettingsPlaceholderScreen extends StatelessWidget {
  const _SettingsPlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Text(
            'Settings',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
