// widgets/customer_bottom_navigation.dart
import 'package:clonubereat/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CustomerBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  final bool showCartBadge;
  final int cartItemCount;

  const CustomerBottomNavigation({
    Key? key,
    required this.currentIndex,
    this.onTap,
    this.showCartBadge = false,
    this.cartItemCount = 0,
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
            _handleDefaultNavigation(context, index);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
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
          // Home
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),

          // Cart
          BottomNavigationBarItem(
            icon: _buildCartIcon(),
            activeIcon: _buildCartIcon(isActive: true),
            label: 'Carrito',
          ),

          // Orders
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Pedidos',
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

  Widget _buildCartIcon({bool isActive = false}) {
    return Stack(
      children: [
        Icon(isActive ? Icons.shopping_cart : Icons.shopping_cart_outlined),
        if (showCartBadge && cartItemCount > 0)
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
              child: cartItemCount <= 99
                  ? Text(
                      '$cartItemCount',
                      style: TextStyle(
                        color: AppColors.textOnPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      '99+',
                      style: TextStyle(
                        color: AppColors.textOnPrimary,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
      ],
    );
  }

  void _handleDefaultNavigation(BuildContext context, int index) {
    switch (index) {
      case 0: // Home
        if (ModalRoute.of(context)?.settings.name != '/customer-home') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/customer-home',
            (route) => false,
          );
        }
        break;

      case 1: // Cart
        Navigator.pushNamed(context, '/customer-cart');
        break;

      case 2: // Orders
        Navigator.pushNamed(context, '/customer-order-history');
        break;

      case 3: // Profile
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }
}

// Clase auxiliar para manejar el estado de navegación
class CustomerNavigation {
  static const int home = 0;
  static const int cart = 1;
  static const int orders = 2;
  static const int profile = 3;

  // Método para obtener el índice basado en la ruta actual
  static int getIndexFromRoute(String? routeName) {
    switch (routeName) {
      case '/customer-home':
        return home;
      case '/customer-cart':
        return cart;
      case '/customer-order-history':
        return orders;
      case '/profile':
        return profile;
      default:
        return home;
    }
  }

  // Método para verificar si una ruta debe mostrar el bottom navigation
  static bool shouldShowBottomNav(String? routeName) {
    const mainRoutes = [
      '/customer-home',
      '/customer-cart',
      '/customer-order-history',
      '/profile',
    ];
    return mainRoutes.contains(routeName);
  }
}
