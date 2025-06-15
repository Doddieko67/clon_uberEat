import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class StoreShell extends StatelessWidget {
  final Widget child;

  const StoreShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: StoreBottomNavBar(),
    );
  }
}

class StoreBottomNavBar extends ConsumerWidget {
  const StoreBottomNavBar({super.key});

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
              icon: _buildIcon(Icons.dashboard_outlined, Icons.dashboard, location == '/store'),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.receipt_long_outlined, Icons.receipt_long, location == '/store/orders'),
              label: 'Pedidos',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.restaurant_menu_outlined, Icons.restaurant_menu, location == '/store/menu'),
              label: 'Menú',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.analytics_outlined, Icons.analytics, location == '/store/analytics'),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.settings_outlined, Icons.settings, location == '/store/settings'),
              label: 'Tienda',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.person_outline, Icons.person, location == '/store/profile'),
              label: 'Perfil',
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
        size: 22, // Back to 5 tabs
      ),
    );
  }

  int _getSelectedIndex(String location) {
    switch (location) {
      case '/store':
        return 0;
      case '/store/orders':
        return 1;
      case '/store/menu':
        return 2;
      case '/store/analytics':
        return 3;
      case '/store/settings':
        return 4;
      case '/store/profile':
        return 5;
      default:
        return 0;
    }
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/store');
        break;
      case 1:
        context.go('/store/orders');
        break;
      case 2:
        context.go('/store/menu');
        break;
      case 3:
        context.go('/store/analytics');
        break;
      case 4:
        context.go('/store/settings');
        break;
      case 5:
        context.go('/store/profile');
        break;
    }
  }
}