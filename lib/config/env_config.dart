import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get googleMapsApiKey {
    final key = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception(
        'GOOGLE_MAPS_API_KEY no encontrada en .env\n'
        'Asegúrate de:\n'
        '1. Crear archivo .env en la raíz del proyecto\n'
        '2. Agregar: GOOGLE_MAPS_API_KEY=tu_api_key\n'
        '3. Ejecutar: flutter pub get'
      );
    }
    return key;
  }

  static String get environment {
    return dotenv.env['ENVIRONMENT'] ?? 'development';
  }

  static bool get isProduction {
    return environment.toLowerCase() == 'production';
  }

  static bool get isDevelopment {
    return environment.toLowerCase() == 'development';
  }

  // Firebase (opcional)
  static String? get firebaseApiKey {
    return dotenv.env['FIREBASE_API_KEY'];
  }

  static String? get firebaseProjectId {
    return dotenv.env['FIREBASE_PROJECT_ID'];
  }

  // Payment APIs (ejemplos para futuro)
  static String? get stripePublicKey {
    return dotenv.env['STRIPE_PUBLIC_KEY'];
  }

  static String? get stripeSecretKey {
    return dotenv.env['STRIPE_SECRET_KEY'];
  }

  // Validación de configuración
  static void validateConfig() {
    try {
      // Validar APIs críticas
      googleMapsApiKey;
      
      print('✅ Configuración .env cargada correctamente');
      print('🔑 Google Maps API Key: ${googleMapsApiKey.substring(0, 10)}...');
      print('🌍 Environment: $environment');
      print('🚀 Production mode: $isProduction');
      
    } catch (e) {
      print('❌ Error en configuración .env: $e');
      rethrow;
    }
  }
}