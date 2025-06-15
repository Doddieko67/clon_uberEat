import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class DelivererShell extends StatelessWidget {
  final Widget child;

  const DelivererShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: DelivererBottomNavBar(),
    );
  }
}

class DelivererBottomNavBar extends ConsumerWidget {
  const DelivererBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String location = GoRouterState.of(context).uri.path;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          elevation: 0,
          currentIndex: _getSelectedIndex(location),
          onTap: (index) => _onTap(context, index),
          items: [
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.dashboard_outlined, Icons.dashboard, location == '/deliverer'),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.delivery_dining_outlined, Icons.delivery_dining, location == '/deliverer/active'),
              label: 'Activas',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.history_outlined, Icons.history, location == '/deliverer/history'),
              label: 'Historial',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.location_on_outlined, Icons.location_on, location == '/deliverer/location'),
              label: 'Ubicación',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(IconData outlinedIcon, IconData filledIcon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Icon(
        isSelected ? filledIcon : outlinedIcon,
        size: 24,
      ),
    );
  }

  int _getSelectedIndex(String location) {
    switch (location) {
      case '/deliverer':
        return 0;
      case '/deliverer/active':
        return 1;
      case '/deliverer/history':
        return 2;
      case '/deliverer/location':
        return 3;
      default:
        return 0;
    }
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/deliverer');
        break;
      case 1:
        context.go('/deliverer/active');
        break;
      case 2:
        context.go('/deliverer/history');
        break;
      case 3:
        context.go('/deliverer/location');
        break;
    }
  }
}