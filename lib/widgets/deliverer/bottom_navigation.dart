// widgets/deliverer_bottom_navigation.dart - NAVEGACIÓN DE REPARTIDOR
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DelivererBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  final bool hasActiveDelivery;
  final int availableOrdersCount;

  const DelivererBottomNavigation({
    Key? key,
    required this.currentIndex,
    this.onTap,
    this.hasActiveDelivery = false,
    this.availableOrdersCount = 0,
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
        selectedItemColor:
            AppColors.secondary, // Color diferente para deliverers
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
          // Available Orders
          BottomNavigationBarItem(
            icon: _buildOrdersIcon(),
            activeIcon: _buildOrdersIcon(isActive: true),
            label: 'Pedidos',
          ),

          // Active Delivery
          BottomNavigationBarItem(
            icon: _buildActiveDeliveryIcon(),
            activeIcon: _buildActiveDeliveryIcon(isActive: true),
            label: 'Activo',
          ),

          // History
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            activeIcon: Icon(Icons.history),
            label: 'Historial',
          ),

          // Earnings
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Ganancias',
          ),

          // Profile
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersIcon({bool isActive = false}) {
    return Stack(
      children: [
        Icon(isActive ? Icons.assignment : Icons.assignment_outlined),
        if (availableOrdersCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.warning,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 1),
              ),
              constraints: BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$availableOrdersCount',
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

  Widget _buildActiveDeliveryIcon({bool isActive = false}) {
    return Stack(
      children: [
        Icon(isActive ? Icons.delivery_dining : Icons.delivery_dining_outlined),
        if (hasActiveDelivery)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    final routes = [
      '/deliverer-home',
      '/deliverer-active',
      '/deliverer-history',
      '/deliverer-earnings',
      '/deliverer-profile',
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
