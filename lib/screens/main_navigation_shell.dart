import 'package:flutter/material.dart';
import '../state/match_controller.dart';
import '../theme/app_colors.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({
    super.key,
    required this.controller,
  });

  final MatchController controller;

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void _navigateToIndex(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        controller: widget.controller,
        onNavigateToHistory: () => _navigateToIndex(1),
        onNavigateToSettings: () => _navigateToIndex(2),
      ),
      HistoryScreen(controller: widget.controller),
      const SettingsScreen(),
    ];

    // Determine nav bar theme based on current screen
    final isDarkScreen = _currentIndex == 2;
    final navBg =
        isDarkScreen ? AppColors.darkBackground : AppColors.lightBackground;
    final unselectedColor =
        isDarkScreen ? AppColors.textMutedDark : AppColors.textSecondaryDark;
    final selectedColor =
        isDarkScreen ? AppColors.servingGreen : AppColors.primaryBrown;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(
            top: BorderSide(
              color: isDarkScreen
                  ? AppColors.cardDarkBorder
                  : AppColors.cardLightBorder,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  label: 'Home',
                  icon: const Icon(Icons.home_filled, size: 22),
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                ),
                _buildNavItem(
                  index: 1,
                  label: 'History',
                  icon: const Icon(Icons.history_rounded, size: 22),
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                ),
                _buildNavItem(
                  index: 2,
                  label: 'Settings',
                  icon: const Icon(Icons.settings_outlined, size: 22),
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
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
    required String label,
    required Widget icon,
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? selectedColor : unselectedColor;

    return InkWell(
      onTap: () => _navigateToIndex(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(
              data: IconThemeData(color: color, size: 22),
              child: icon,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
