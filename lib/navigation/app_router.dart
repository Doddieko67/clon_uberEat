import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../screens/common/splash_screen.dart';
import '../screens/common/login_screen.dart';
import '../screens/common/register_screen.dart';
import '../screens/common/profile_screen.dart';
import '../screens/common/notifications_screen.dart';
import '../screens/customer/customer_home_screen.dart';
import '../screens/customer/cart_screen.dart';
import '../screens/customer/order_history_screen.dart';
import '../screens/customer/store_detail_screen.dart';
import '../screens/customer/checkout_screen.dart';
import '../screens/customer/order_tracking_screen.dart';
import '../screens/store/store_dashboard_screen.dart';
import '../screens/store/store_onboarding_screen.dart';
import '../screens/store/create_store_screen.dart';
import '../screens/store/join_store_screen.dart';
import '../screens/store/store_wrapper_screen.dart';
import '../screens/store/order_management_screen.dart';
import '../screens/store/menu_management_screen.dart';
import '../screens/store/store_analytics_screen.dart';
import '../screens/store/store_profile_settings_screen.dart';
import '../screens/deliverer/deliverer_dashboard_screen.dart';
import '../screens/deliverer/delivery_details_screen.dart';
import '../screens/deliverer/delivery_history_screen.dart';
import '../screens/deliverer/deliverer_location_screen.dart';
import '../screens/debug/maps_test_screen.dart';
import '../screens/debug/places_test_screen.dart';
import '../screens/debug/location_demo_screen.dart';
import 'customer_shell.dart';
import 'store_shell.dart';
import 'deliverer_shell.dart';

// Global reference to the container for navigation guards
ProviderContainer? _routerContainer;

void setRouterContainer(ProviderContainer container) {
  _routerContainer = container;
}

// Auth guard helper
String? _authGuard(BuildContext context, GoRouterState state) {
  final container = _routerContainer;
  if (container == null) return null;
  
  final authState = container.read(authNotifierProvider);
  final currentPath = state.uri.path;
  
  // Allow access to auth routes and debug routes
  if (currentPath == '/' || currentPath == '/login' || currentPath == '/register' || currentPath.startsWith('/debug')) {
    return null;
  }
  
  // Redirect to login if not authenticated
  if (authState.user == null) {
    return '/login';
  }
  
  return null;
}

// Role guard helper
String? _roleGuard(BuildContext context, GoRouterState state, UserRole requiredRole) {
  final container = _routerContainer;
  if (container == null) return null;
  
  final authState = container.read(authNotifierProvider);
  final user = authState.user;
  
  if (user == null) {
    return '/login';
  }
  
  // Check if user has the required role
  if (user.role != requiredRole) {
    // Redirect to user's appropriate dashboard
    switch (user.role) {
      case UserRole.customer:
        return '/customer';
      case UserRole.store:
        return '/store';
      case UserRole.deliverer:
        return '/deliverer';
      case UserRole.admin:
        return '/admin-dashboard';
    }
  }
  
  return null;
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: _authGuard,
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

    // Debug routes (accesible sin autenticación)
    GoRoute(
      path: '/debug/maps',
      builder: (context, state) => MapsTestScreen(),
    ),
    GoRoute(
      path: '/debug/places',
      builder: (context, state) => PlacesTestScreen(),
    ),
    GoRoute(
      path: '/debug/location',
      builder: (context, state) => LocationDemoScreen(),
    ),

    // Customer routes with shell navigation
    ShellRoute(
      builder: (context, state, child) => CustomerShell(child: child),
      routes: [
        GoRoute(
          path: '/customer',
          builder: (context, state) => const CustomerHomeScreen(),
          redirect: (context, state) => _roleGuard(context, state, UserRole.customer),
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
        return StoreDetailScreen(storeId: storeId);
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

    // Notifications routes (outside shell for full screen navigation)
    GoRoute(
      path: '/customer/notifications',
      builder: (context, state) => const NotificationsScreen(userRole: 'customer'),
    ),
    GoRoute(
      path: '/store/notifications',
      builder: (context, state) => const NotificationsScreen(userRole: 'store'),
    ),
    GoRoute(
      path: '/deliverer/notifications',
      builder: (context, state) => const NotificationsScreen(userRole: 'deliverer'),
    ),

    // Store onboarding (outside shell for full screen)
    GoRoute(
      path: '/store/onboarding',
      builder: (context, state) => const StoreOnboardingScreen(),
    ),
    GoRoute(
      path: '/store/create',
      builder: (context, state) => const CreateStoreScreen(),
    ),
    GoRoute(
      path: '/store/join',
      builder: (context, state) => const JoinStoreScreen(),
    ),

    // Store routes with shell navigation
    ShellRoute(
      builder: (context, state, child) => StoreShell(child: child),
      routes: [
        GoRoute(
          path: '/store',
          builder: (context, state) => const StoreWrapperScreen(),
          redirect: (context, state) => _roleGuard(context, state, UserRole.store),
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
          redirect: (context, state) => _roleGuard(context, state, UserRole.deliverer),
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
          path: '/deliverer/profile',
          builder: (context, state) => ProfileScreen(),
        ),
      ],
    ),

    // Legacy routes for backward compatibility
    GoRoute(
      path: '/customer-home',
      redirect: (context, state) => '/customer',
    ),
    GoRoute(
      path: '/store-dashboard',
      redirect: (context, state) => '/store',
    ),
    GoRoute(
      path: '/deliverer-dashboard',
      redirect: (context, state) => '/deliverer',
    ),
    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Admin Dashboard')),
        body: const Center(
          child: Text('Admin functionality coming soon...'),
        ),
      ),
      redirect: (context, state) => _roleGuard(context, state, UserRole.admin),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFF1a1a1a),
    appBar: AppBar(
      title: const Text('Página no encontrada'),
      backgroundColor: const Color(0xFF2d2d2d),
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            const Text(
              'Página no encontrada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'La ruta "${state.uri.path}" no existe',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final container = _routerContainer;
                if (container != null) {
                  final authState = container.read(authNotifierProvider);
                  final user = authState.user;
                  
                  if (user != null) {
                    // Redirect to user's dashboard
                    switch (user.role) {
                      case UserRole.customer:
                        context.go('/customer');
                        break;
                      case UserRole.store:
                        context.go('/store');
                        break;
                      case UserRole.deliverer:
                        context.go('/deliverer');
                        break;
                      case UserRole.admin:
                        context.go('/admin-dashboard');
                        break;
                    }
                  } else {
                    context.go('/');
                  }
                } else {
                  context.go('/');
                }
              },
              icon: const Icon(Icons.home),
              label: const Text('Volver al inicio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);