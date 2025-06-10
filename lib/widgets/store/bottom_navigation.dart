// widgets/store_bottom_navigation.dart - NAVEGACIÓN DE TIENDA
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class StoreBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  final int pendingOrdersCount;
  final bool isStoreOpen;

  const StoreBottomNavigation({
    Key? key,
    required this.currentIndex,
    this.onTap,
    this.pendingOrdersCount = 0,
    this.isStoreOpen = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.darkWithOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: currentIndex,
        onTap: (index) {
          if (onTap != null) {
            onTap!(index);
          } else {
            _handleNavigation(context, index);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.warning, // Color diferente para stores
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        items: [
          // Dashboard
          BottomNavigationBarItem(
            icon: _buildDashboardIcon(),
            activeIcon: _buildDashboardIcon(isActive: true),
            label: 'Dashboard',
          ),

          // Orders
          BottomNavigationBarItem(
            icon: _buildOrdersIcon(),
            activeIcon: _buildOrdersIcon(isActive: true),
            label: 'Pedidos',
          ),

          // Menu Management
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'Menú',
          ),

          // Analytics
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Reportes',
          ),

          // Store Profile
          BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            activeIcon: Icon(Icons.store),
            label: 'Tienda',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardIcon({bool isActive = false}) {
    return Stack(
      children: [
        Icon(isActive ? Icons.dashboard : Icons.dashboard_outlined),
        if (!isStoreOpen)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOrdersIcon({bool isActive = false}) {
    return Stack(
      children: [
        Icon(isActive ? Icons.receipt_long : Icons.receipt_long_outlined),
        if (pendingOrdersCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 1),
              ),
              constraints: BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$pendingOrdersCount',
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    final routes = [
      '/store-dashboard',
      '/store-orders',
      '/store-menu',
      '/store-analytics',
      '/store-profile',
    ];

    final targetRoute = routes[index];
    final currentRoute = ModalRoute.of(context)?.settings.name;

    if (currentRoute == targetRoute) return;

    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(context, targetRoute, (route) => false);
    } else {
      Navigator.pushNamed(context, targetRoute);
    }
  }
}
