// routes/app_routes.dart - ROUTER ESCALABLE
import 'package:flutter/material.dart';
import '../widgets/layouts/customer_layout.dart';
import '../widgets/layouts/deliverer_layout.dart';
import '../widgets/layouts/store_layout.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? '/';
    final dynamic arguments = settings.arguments;

    // 🎯 DETECTAR TIPO DE USUARIO BASADO EN LA RUTA
    UserType userType = _getUserTypeFromRoute(routeName);

    // 📱 OBTENER EL SCREEN CORRESPONDIENTE
    Widget screen = _getScreenForRoute(routeName, arguments);

    // 🏗️ ENVOLVER CON EL LAYOUT APROPIADO
    Widget wrappedScreen = _wrapWithLayout(screen, routeName, userType);

    return MaterialPageRoute(builder: (_) => wrappedScreen, settings: settings);
  }

  // Detectar tipo de usuario por la ruta
  static UserType _getUserTypeFromRoute(String route) {
    if (route.startsWith('/customer-')) return UserType.customer;
    if (route.startsWith('/deliverer-')) return UserType.deliverer;
    if (route.startsWith('/store-')) return UserType.store;
    if (route == '/profile') return UserType.customer; // Default para profile
    return UserType.customer; // Default
  }

  // Obtener el screen correcto
  static Widget _getScreenForRoute(String route, dynamic arguments) {
    switch (route) {
      // ===== CUSTOMER ROUTES =====
      case '/customer-home':
        return CustomerHomeScreen();
      case '/customer-cart':
        return CartScreen();
      case '/customer-order-history':
        return OrderHistoryScreen();
      case '/customer-store-detail':
        return StoreDetailScreen();
      case '/customer-checkout':
        return CheckoutScreen();
      case '/customer-order-tracking':
        return OrderTrackingScreen();
      case '/customer-profile':
      case '/profile':
        return ProfileScreen();

      // ===== DELIVERER ROUTES =====
      case '/deliverer-home':
        return DelivererHomeScreen();
      case '/deliverer-active':
        return ActiveDeliveryScreen();
      case '/deliverer-history':
        return DelivererHistoryScreen();
      case '/deliverer-earnings':
        return EarningsScreen();
      case '/deliverer-profile':
        return DelivererProfileScreen();
      case '/deliverer-order-detail':
        return DeliveryOrderDetailScreen();

      // ===== STORE ROUTES =====
      case '/store-dashboard':
        return StoreDashboardScreen();
      case '/store-orders':
        return StoreOrdersScreen();
      case '/store-menu':
        return StoreMenuScreen();
      case '/store-analytics':
        return StoreAnalyticsScreen();
      case '/store-profile':
        return StoreProfileScreen();
      case '/store-order-detail':
        return StoreOrderDetailScreen();

      // ===== AUTH & COMMON ROUTES =====
      case '/login':
        return LoginScreen();
      case '/register':
        return RegisterScreen();
      case '/splash':
        return SplashScreen();

      default:
        return CustomerHomeScreen();
    }
  }

  // Envolver con el layout apropiado
  static Widget _wrapWithLayout(
    Widget screen,
    String route,
    UserType userType,
  ) {
    switch (userType) {
      case UserType.customer:
        return CustomerLayout(child: screen, currentRoute: route);

      case UserType.deliverer:
        return DelivererLayout(child: screen, currentRoute: route);

      case UserType.store:
        return StoreLayout(child: screen, currentRoute: route);

      default:
        return screen; // Sin layout para rutas como login, splash, etc.
    }
  }
}

enum UserType { customer, deliverer, store }
