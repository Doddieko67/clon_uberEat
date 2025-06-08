import 'package:clonubereat/screens/common/forgot_password_screen.dart';
import 'package:clonubereat/screens/common/login_screen.dart';
import 'package:clonubereat/screens/common/profile_screen.dart';
import 'package:clonubereat/screens/common/register_screen.dart';
import 'package:clonubereat/screens/common/splash_screen.dart';
import 'package:clonubereat/screens/customer/cart_screen.dart';
import 'package:clonubereat/screens/customer/checkout_screen.dart';
import 'package:clonubereat/screens/customer/customer_home_screen.dart';
import 'package:clonubereat/screens/customer/order_history_screen.dart';
import 'package:clonubereat/screens/customer/order_tracking_screen.dart';
import 'package:clonubereat/screens/customer/store_detail_screen.dart';
import 'package:clonubereat/screens/deliverer/deliverer_dashboard_screen.dart';
import 'package:clonubereat/screens/deliverer/delivery_details_screen.dart';
import 'package:clonubereat/screens/deliverer/delivery_history_screen.dart';
import 'package:clonubereat/screens/store/menu_management_screen.dart';
import 'package:clonubereat/screens/store/order_management_screen.dart';
import 'package:clonubereat/screens/store/store_dashboard_screen.dart';
import 'package:clonubereat/screens/store/store_profile_settings_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importa el provider de autenticación y el theme
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';

// Importa las pantallas específicas por rol (cuando las tengas)
// import 'screens/customer/customer_home_screen.dart';
// import 'screens/store/store_dashboard_screen.dart';
// import 'screens/deliverer/deliverer_dashboard_screen.dart';
// import 'screens/admin/admin_dashboard_screen.dart';

void main() async {
  // Asegura que la inicialización de Flutter esté completa
  WidgetsFlutterBinding.ensureInitialized();

  // Aquí inicializarías Firebase cuando lo agregues:
  await Firebase.initializeApp();
  runApp(CampusEatsApp());
}

class CampusEatsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider para la autenticación
        ChangeNotifierProvider(create: (context) => AuthProvider()),

        // Aquí puedes agregar más providers según necesites:
        // ChangeNotifierProvider(create: (context) => CartProvider()),
        // ChangeNotifierProvider(create: (context) => OrderProvider()),
        // ChangeNotifierProvider(create: (context) => StoreProvider()),
      ],
      child: MaterialApp(
        title: 'Campus Eats',
        debugShowCheckedModeBanner: false,

        // Tema personalizado OSCURO de la aplicación
        theme: AppTheme.darkTheme,

        // Pantalla inicial
        initialRoute: '/deliverer-dashboard',

        // Configuración de rutas
        routes: {
          '/': (context) => SplashScreen(),
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/forgot-password': (context) => ForgotPasswordScreen(),
          '/profile': (context) => ProfileScreen(),

          // Rutas para Cliente
          '/customer-home': (context) => CustomerHomeScreen(),
          '/customer-store-detail': (context) => StoreDetailScreen(),
          '/customer-cart': (context) => CartScreen(),
          '/customer-checkout': (context) => CheckoutScreen(),
          '/customer-order-tracking': (context) => OrderTrackingScreen(),
          '/customer-order-history': (context) => OrderHistoryScreen(),

          // Rutas para Tienda
          '/store-dashboard': (context) => StoreDashboardScreen(),
          '/store-order-management': (context) => OrderManagementScreen(),
          '/store-menu-management': (context) => MenuManagementScreen(),
          '/store-profile-settings': (context) => StoreProfileSettingsScreen(),

          // Rutas para Repartidor
          '/deliverer-dashboard': (context) => DelivererDashboardScreen(),
          '/deliverer-delivery-details': (context) => DeliveryDetailsScreen(),
          '/deliverer-customer-location': (context) =>
              DelivererCustomerLocationPlaceholder(),
          '/deliverer-history': (context) => DeliveryHistoryScreen(),

          // Rutas para Admin
          '/admin-dashboard': (context) => AdminDashboardPlaceholder(),
          '/admin-user-management': (context) =>
              AdminUserManagementPlaceholder(),
          '/admin-store-management': (context) =>
              AdminStoreManagementPlaceholder(),
          '/admin-delivery-zone-management': (context) =>
              AdminDeliveryZoneManagementPlaceholder(),
        },

        // Manejo de rutas no encontradas - TEMA OSCURO
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: Text(
                  'Página no encontrada',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                backgroundColor: AppColors.surface,
                iconTheme: IconThemeData(color: AppColors.textSecondary),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Página no encontrada',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'La ruta "${settings.name}" no existe',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      ),
                      child: Text('Volver al inicio'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// PANTALLAS PLACEHOLDER TEMPORALES CON TEMA OSCURO
// Estas son pantallas temporales que puedes reemplazar con las reales

class DelivererDashboardPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Panel de Repartidor'),
        backgroundColor: AppColors.surface,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryWithOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Icon(
                Icons.delivery_dining,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Panel de Repartidor',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Gestiona tus entregas',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              icon: Icon(Icons.person),
              label: Text('Ver Perfil'),
            ),
          ],
        ),
      ),
    );
  }
}

class DelivererDeliveryDetailsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Detalles de Entrega'),
        backgroundColor: AppColors.surface,
      ),
      body: Center(
        child: Text(
          'Pantalla de Detalles de Entrega',
          style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class DelivererCustomerLocationPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Ubicación del Cliente'),
        backgroundColor: AppColors.surface,
      ),
      body: Center(
        child: Text(
          'Pantalla de Ubicación del Cliente',
          style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class DelivererHistoryPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Historial de Entregas'),
        backgroundColor: AppColors.surface,
      ),
      body: Center(
        child: Text(
          'Pantalla de Historial de Entregas',
          style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class AdminDashboardPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Panel de Administrador'),
        backgroundColor: AppColors.surface,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.secondaryWithOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.secondary, width: 2),
              ),
              child: Icon(
                Icons.admin_panel_settings,
                size: 64,
                color: AppColors.secondary,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Panel de Administrador',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Control total del sistema',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              icon: Icon(Icons.person),
              label: Text('Ver Perfil'),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminUserManagementPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Gestión de Usuarios'),
        backgroundColor: AppColors.surface,
      ),
      body: Center(
        child: Text(
          'Pantalla de Gestión de Usuarios',
          style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class AdminStoreManagementPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Gestión de Tiendas'),
        backgroundColor: AppColors.surface,
      ),
      body: Center(
        child: Text(
          'Pantalla de Gestión de Tiendas',
          style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class AdminDeliveryZoneManagementPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Gestión de Zonas de Entrega'),
        backgroundColor: AppColors.surface,
      ),
      body: Center(
        child: Text(
          'Pantalla de Gestión de Zonas de Entrega',
          style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
