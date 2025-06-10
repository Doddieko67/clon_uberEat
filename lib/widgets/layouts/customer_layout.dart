// widgets/layouts/customer_layout.dart - LAYOUT DE CLIENTE
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './base_layout.dart';
import './customer_bottom_navigation.dart';
import '../../providers/cart_provider.dart';

class CustomerLayout extends BaseLayout {
  final int? cartItemCount;

  const CustomerLayout({
    Key? key,
    required Widget child,
    String? currentRoute,
    this.cartItemCount,
  }) : super(key: key, child: child, currentRoute: currentRoute);

  // Rutas que usan bottom navigation para CLIENTES
  static const List<String> _navigationRoutes = [
    '/customer-home',
    '/customer-cart',
    '/customer-order-history',
    '/customer-profile',
  ];

  @override
  bool shouldShowNavigation(String? route) {
    return _navigationRoutes.contains(route);
  }

  @override
  Widget buildBottomNavigation(BuildContext context, String? route) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        return CustomerBottomNavigation(
          currentIndex: getIndexFromRoute(route),
          showCartBadge: cartProvider.hasItems,
          cartItemCount: cartItemCount ?? cartProvider.totalItems,
        );
      },
    );
  }

  @override
  int getIndexFromRoute(String? route) {
    switch (route) {
      case '/customer-home':
        return 0;
      case '/customer-cart':
        return 1;
      case '/customer-order-history':
        return 2;
      case '/customer-profile':
        return 3;
      default:
        return 0;
    }
  }
}
