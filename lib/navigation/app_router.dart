import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/common/splash_screen.dart';
import '../screens/common/login_screen.dart';
import '../screens/common/register_screen.dart';
import '../screens/common/profile_screen.dart';
import '../screens/customer/customer_home_screen.dart';
import '../screens/customer/cart_screen.dart';
import '../screens/customer/order_history_screen.dart';
import '../screens/customer/store_detail_screen.dart';
import '../screens/customer/checkout_screen.dart';
import '../screens/customer/order_tracking_screen.dart';
import '../screens/store/store_dashboard_screen.dart';
import '../screens/store/order_management_screen.dart';
import '../screens/store/menu_management_screen.dart';
import '../screens/store/store_analytics_screen.dart';
import '../screens/store/store_profile_settings_screen.dart';
import '../screens/deliverer/deliverer_dashboard_screen.dart';
import '../screens/deliverer/delivery_details_screen.dart';
import '../screens/deliverer/delivery_history_screen.dart';
import '../screens/deliverer/deliverer_location_screen.dart';
import 'customer_shell.dart';
import 'store_shell.dart';
import 'deliverer_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Auth routes
    GoRoute(
      path: '/',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => RegisterScreen(),
    ),

    // Customer routes with shell navigation
    ShellRoute(
      builder: (context, state, child) => CustomerShell(child: child),
      routes: [
        GoRoute(
          path: '/customer',
          builder: (context, state) => const CustomerHomeScreen(),
        ),
        GoRoute(
          path: '/customer/cart',
          builder: (context, state) => CartScreen(),
        ),
        GoRoute(
          path: '/customer/orders',
          builder: (context, state) => OrderHistoryScreen(),
        ),
        GoRoute(
          path: '/customer/profile',
          builder: (context, state) => ProfileScreen(),
        ),
      ],
    ),

    // Customer detail routes (outside shell for full screen)
    GoRoute(
      path: '/customer/store/:storeId',
      builder: (context, state) {
        final storeId = state.pathParameters['storeId']!;
        return StoreDetailScreen();
      },
    ),
    GoRoute(
      path: '/customer/checkout',
      builder: (context, state) => CheckoutScreen(),
    ),
    GoRoute(
      path: '/customer/tracking/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return OrderTrackingScreen();
      },
    ),

    // Store routes with shell navigation
    ShellRoute(
      builder: (context, state, child) => StoreShell(child: child),
      routes: [
        GoRoute(
          path: '/store',
          builder: (context, state) => StoreDashboardScreen(),
        ),
        GoRoute(
          path: '/store/orders',
          builder: (context, state) => OrderManagementScreen(),
        ),
        GoRoute(
          path: '/store/menu',
          builder: (context, state) => MenuManagementScreen(),
        ),
        GoRoute(
          path: '/store/analytics',
          builder: (context, state) => StoreAnalyticsScreen(storeId: 'default-store'),
        ),
        GoRoute(
          path: '/store/settings',
          builder: (context, state) => StoreProfileSettingsScreen(),
        ),
        GoRoute(
          path: '/store/profile',
          builder: (context, state) => ProfileScreen(),
        ),
      ],
    ),

    // Deliverer routes with shell navigation
    ShellRoute(
      builder: (context, state, child) => DelivererShell(child: child),
      routes: [
        GoRoute(
          path: '/deliverer',
          builder: (context, state) => DelivererDashboardScreen(),
        ),
        GoRoute(
          path: '/deliverer/active',
          builder: (context, state) => DeliveryDetailsScreen(),
        ),
        GoRoute(
          path: '/deliverer/history',
          builder: (context, state) => DeliveryHistoryScreen(),
        ),
        GoRoute(
          path: '/deliverer/location',
          builder: (context, state) => DelivererLocationScreen(),
        ),
      ],
    ),

    // Legacy routes for backward compatibility
    GoRoute(
      path: '/store-dashboard',
      redirect: (context, state) => '/store',
    ),
    GoRoute(
      path: '/deliverer-dashboard',
      redirect: (context, state) => '/deliverer',
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Página no encontrada')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Página no encontrada',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('La ruta "${state.uri}" no existe'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Volver al inicio'),
          ),
        ],
      ),
    ),
  ),
);