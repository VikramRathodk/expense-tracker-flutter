import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../routes/app_routes.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    _TabItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      route: AppRoutes.dashboard,
    ),
    _TabItem(
      label: 'Expenses',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      route: AppRoutes.expenses,
    ),
    _TabItem(
      label: 'Budgets',
      icon: Icons.pie_chart_outline,
      activeIcon: Icons.pie_chart,
      route: AppRoutes.budgets,
    ),
    _TabItem(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: AppRoutes.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: _tabs
            .map(
              (tab) => NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.activeIcon, color: AppColors.primary),
                label: tab.label,
              ),
            )
            .toList(),
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 64,
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
}
