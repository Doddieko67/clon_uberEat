// widgets/layouts/store_layout.dart - LAYOUT DE TIENDA
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../base_layout.dart';
import '../store_bottom_navigation.dart';
import '../../providers/store_provider.dart';

class StoreLayout extends BaseLayout {
  const StoreLayout({Key? key, required Widget child, String? currentRoute})
    : super(key: key, child: child, currentRoute: currentRoute);

  // Rutas que usan bottom navigation para TIENDAS
  static const List<String> _navigationRoutes = [
    '/store-dashboard', // Dashboard principal
    '/store-orders', // Pedidos entrantes
    '/store-menu', // Gestión de menú/productos
    '/store-analytics', // Estadísticas y reportes
    '/store-profile', // Perfil de la tienda
  ];

  @override
  bool shouldShowNavigation(String? route) {
    return _navigationRoutes.contains(route);
  }

  @override
  Widget buildBottomNavigation(BuildContext context, String? route) {
    return Consumer<StoreProvider>(
      builder: (context, storeProvider, _) {
        return StoreBottomNavigation(
          currentIndex: getIndexFromRoute(route),
          pendingOrdersCount: storeProvider.pendingOrdersCount,
          isStoreOpen: storeProvider.isStoreOpen,
        );
      },
    );
  }

  @override
  int getIndexFromRoute(String? route) {
    switch (route) {
      case '/store-dashboard':
        return 0;
      case '/store-orders':
        return 1;
      case '/store-menu':
        return 2;
      case '/store-analytics':
        return 3;
      case '/store-profile':
        return 4;
      default:
        return 0;
    }
  }
}
