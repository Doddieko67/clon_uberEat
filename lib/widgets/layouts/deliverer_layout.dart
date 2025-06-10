// widgets/layouts/deliverer_layout.dart - LAYOUT DE REPARTIDOR
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './base_layout.dart';
import '../deliverer_bottom_navigation.dart';
import '../../providers/delivery_provider.dart';

class DelivererLayout extends BaseLayout {
  const DelivererLayout({Key? key, required Widget child, String? currentRoute})
    : super(key: key, child: child, currentRoute: currentRoute);

  // Rutas que usan bottom navigation para REPARTIDORES
  static const List<String> _navigationRoutes = [
    '/deliverer-home', // Ver pedidos disponibles
    '/deliverer-active', // Pedido activo/en curso
    '/deliverer-history', // Historial de entregas
    '/deliverer-earnings', // Ganancias/estadísticas
    '/deliverer-profile', // Perfil del repartidor
  ];

  @override
  bool shouldShowNavigation(String? route) {
    return _navigationRoutes.contains(route);
  }

  @override
  Widget buildBottomNavigation(BuildContext context, String? route) {
    return Consumer<DeliveryProvider>(
      builder: (context, deliveryProvider, _) {
        return DelivererBottomNavigation(
          currentIndex: getIndexFromRoute(route),
          hasActiveDelivery: deliveryProvider.hasActiveDelivery,
          availableOrdersCount: deliveryProvider.availableOrdersCount,
        );
      },
    );
  }

  @override
  int getIndexFromRoute(String? route) {
    switch (route) {
      case '/deliverer-home':
        return 0;
      case '/deliverer-active':
        return 1;
      case '/deliverer-history':
        return 2;
      case '/deliverer-earnings':
        return 3;
      case '/deliverer-profile':
        return 4;
      default:
        return 0;
    }
  }
}
