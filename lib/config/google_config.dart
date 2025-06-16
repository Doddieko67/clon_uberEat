// Google API Configuration using Environment Variables
import 'env_config.dart';
import 'maps_config.dart';

class GoogleConfig {
  // IMPORTANTE: Ahora usa variables de entorno del archivo .env
  // Cómo configurar:
  // 1. Crea archivo .env en la raíz del proyecto
  // 2. Agrega: GOOGLE_MAPS_API_KEY=tu_api_key_real
  // 3. Opcional: ENVIRONMENT=development o production
  
  // Preferir configuración desde .env
  static String get apiKey {
    try {
      return EnvConfig.googleMapsApiKey;
    } catch (e) {
      print('⚠️ No se pudo cargar API key desde .env, usando fallback');
      return MapsConfig.apiKey; // Fallback al método anterior
    }
  }
  
  static bool get isProduction {
    try {
      return EnvConfig.isProduction;
    } catch (e) {
      return MapsConfig.isProduction; // Fallback
    }
  }
  
  static bool get isDevelopment {
    try {
      return EnvConfig.isDevelopment;
    } catch (e) {
      return !MapsConfig.isProduction; // Fallback
    }
  }
  
  // Configuración adicional para Places
  static Map<String, dynamic> get placesConfig => MapsConfig.placesConfig;
  static Map<String, dynamic> get mapsConfig => MapsConfig.mapsConfig;
  
  // Validar configuración al inicio
  static void validateConfiguration() {
    try {
      print('🔧 Validando configuración de Google Maps...');
      final key = apiKey;
      print('✅ API Key cargada: ${key.substring(0, 10)}...');
      print('🌍 Environment: ${isProduction ? "Production" : "Development"}');
    } catch (e) {
      print('❌ Error en configuración: $e');
      rethrow;
    }
  }
}
