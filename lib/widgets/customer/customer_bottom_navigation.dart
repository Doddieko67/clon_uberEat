// widgets/customer_bottom_navigation.dart - WIDGET FINAL COMPLETO
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/cart_provider.dart';

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
          // 🏠 HOME
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),

          // 🛒 CART with Badge
          BottomNavigationBarItem(
            icon: _buildCartIcon(),
            activeIcon: _buildCartIcon(isActive: true),
            label: 'Carrito',
          ),

          // 📋 ORDERS
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),

          // 👤 PROFILE
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  // 🛒 WIDGET DEL CARRITO CON BADGE INTELIGENTE
  Widget _buildCartIcon({bool isActive = false}) {
    return Stack(
      children: [
        Icon(isActive ? Icons.shopping_cart : Icons.shopping_cart_outlined),

        // Badge solo si hay items en el carrito
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

  // 🚀 NAVEGACIÓN POR DEFECTO
  void _handleDefaultNavigation(BuildContext context, int index) {
    final routes = [
      '/customer-home',
      '/customer-cart',
      '/customer-order-history',
      '/customer-profile', // o '/profile'
    ];

    final targetRoute = routes[index];
    final currentRoute = ModalRoute.of(context)?.settings.name;

    // No navegar si ya estamos en la misma ruta
    if (currentRoute == targetRoute) return;

    // 🏠 HOME: Limpiar stack (volver al inicio)
    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(context, targetRoute, (route) => false);
    }
    // 🛒 CART: Verificar si tiene items (opcional)
    else if (index == 1) {
      // Opcional: Mostrar mensaje si carrito vacío
      if (cartItemCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  color: AppColors.textOnPrimary,
                ),
                SizedBox(width: 8),
                Text('Tu carrito está vacío'),
              ],
            ),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
      Navigator.pushNamed(context, targetRoute);
    }
    // 📋📱 OTROS: Navegación normal
    else {
      Navigator.pushNamed(context, targetRoute);
    }
  }
}

// 🎯 CONSTANTES PARA FACILITAR EL USO
class CustomerNavIndex {
  static const int home = 0;
  static const int cart = 1;
  static const int orders = 2;
  static const int profile = 3;

  // Método para obtener el índice basado en la ruta actual
  static int fromRoute(String? routeName) {
    switch (routeName) {
      case '/customer-home':
        return home;
      case '/customer-cart':
        return cart;
      case '/customer-order-history':
        return orders;
      case '/customer-profile':
      case '/profile':
        return profile;
      default:
        return home;
    }
  }

  // Método para verificar si una ruta debe mostrar el bottom navigation
  static bool shouldShow(String? routeName) {
    const mainRoutes = [
      '/customer-home',
      '/customer-cart',
      '/customer-order-history',
      '/customer-profile',
      '/profile',
    ];
    return mainRoutes.contains(routeName);
  }
}

// 🔥 WIDGET CON PROVIDER AUTOMÁTICO (VERSIÓN AVANZADA)
class CustomerBottomNavigationWithProvider extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomerBottomNavigationWithProvider({
    Key? key,
    required this.currentIndex,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return CustomerBottomNavigation(
          currentIndex: currentIndex,
          onTap: onTap,
          showCartBadge: cartProvider.hasItems,
          cartItemCount: cartProvider.totalItems,
        );
      },
    );
  }
}

// 🎨 WIDGET CON PERSONALIZACIÓN AVANZADA
class CustomCustomerBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  final bool showCartBadge;
  final int cartItemCount;
  final Color? selectedColor;
  final Color? unselectedColor;
  final bool showLabels;
  final List<String>? customLabels;

  const CustomCustomerBottomNavigation({
    Key? key,
    required this.currentIndex,
    this.onTap,
    this.showCartBadge = false,
    this.cartItemCount = 0,
    this.selectedColor,
    this.unselectedColor,
    this.showLabels = true,
    this.customLabels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final labels = customLabels ?? ['Inicio', 'Carrito', 'Pedidos', 'Perfil'];

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
        onTap: onTap ?? (index) => _handleDefaultNavigation(context, index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: selectedColor ?? AppColors.primary,
        unselectedItemColor: unselectedColor ?? AppColors.textTertiary,
        showSelectedLabels: showLabels,
        showUnselectedLabels: showLabels,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: labels[0],
          ),
          BottomNavigationBarItem(
            icon: _buildCartIcon(),
            activeIcon: _buildCartIcon(isActive: true),
            label: labels[1],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: labels[2],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: labels[3],
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
                color: selectedColor ?? AppColors.primary,
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
    // Misma lógica que el widget principal
    final routes = [
      '/customer-home',
      '/customer-cart',
      '/customer-order-history',
      '/customer-profile',
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
