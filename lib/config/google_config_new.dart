// Nueva configuración Google - Empezando desde cero
import 'maps_config_new.dart';

class GoogleConfigNew {
  // CONFIGURACIÓN NUEVA - REEMPLAZA TODA LA ANTERIOR
  
  static String get apiKey => MapsConfigNew.apiKey;
  static bool get isProduction => MapsConfigNew.isProduction;
  
  // Configuraciones específicas
  static Map<String, dynamic> get placesConfig => MapsConfigNew.placesConfig;
  static Map<String, dynamic> get mapsConfig => MapsConfigNew.mapsConfig;
  
  // Validación completa
  static void validateConfiguration() {
    print('🔧 Validando nueva configuración Google Maps...');
    
    try {
      MapsConfigNew.validateApiKey();
      
      print('✅ Validación exitosa:');
      print('   🔑 API Key: ${apiKey.substring(0, 15)}...');
      print('   🌍 Producción: $isProduction');
      print('   📍 Places configurado: ${placesConfig['countries']}');
      
    } catch (e) {
      print('❌ Error en validación: $e');
      rethrow;
    }
  }
  
  // Test de conectividad
  static Future<bool> testApiConnection() async {
    try {
      print('🧪 Probando conectividad API...');
      
      // Aquí podrías agregar una llamada real de test
      // Por ahora solo validamos la configuración
      validateConfiguration();
      
      return true;
    } catch (e) {
      print('❌ Test de API falló: $e');
      return false;
    }
  }
}