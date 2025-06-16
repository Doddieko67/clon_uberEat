import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'navigation/app_router.dart';
import 'theme/app_theme.dart';
import 'config/google_config_simple.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Iniciando app con configuración SIMPLE...');
  
  // Validar configuración simple
  GoogleConfigSimple.validateConfiguration();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  final container = ProviderContainer();
  setRouterContainer(container);
  
  runApp(UncontrolledProviderScope(
    container: container,
    child: CampusEatsApp(),
  ));
}

class CampusEatsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'UBERecus Eat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}