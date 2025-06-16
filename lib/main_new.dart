import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'navigation/app_router.dart';
import 'theme/app_theme.dart';
import 'config/google_config_new.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Iniciando app con NUEVA configuración Google Maps...');
  
  try {
    // Validar nueva configuración
    await GoogleConfigNew.testApiConnection();
    print('✅ Nueva configuración validada exitosamente');
    
  } catch (e) {
    print('🚨 CONFIGURACIÓN PENDIENTE 🚨');
    print(e.toString());
    print('');
    print('📋 PASOS PARA CONFIGURAR:');
    print('');
    print('1. Ve a: https://console.cloud.google.com/');
    print('2. Crea un NUEVO proyecto');
    print('3. 💳 HABILITA BILLING (tarjeta de crédito)');
    print('4. Habilita estas APIs:');
    print('   - Maps SDK for Android');
    print('   - Maps SDK for iOS');
    print('   - Places API');
    print('   - Geocoding API');
    print('5. Crea nueva API key');
    print('6. Edita lib/config/maps_config_new.dart');
    print('7. Edita android/app/src/main/AndroidManifest.xml');
    print('8. Edita ios/Runner/Info.plist');
    print('');
    print('⚠️ SIN BILLING = "En desarrollo" SIEMPRE');
    
    // No lanzar error para permitir desarrollo
  }
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  final container = ProviderContainer();
  setRouterContainer(container);
  
  runApp(UncontrolledProviderScope(
    container: container,
    child: CampusEatsAppNew(),
  ));
}

class CampusEatsAppNew extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'UBERecus Eat - Nueva Config',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}