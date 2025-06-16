// Configuración Google Maps SIMPLE - La que funcionaba antes
class GoogleConfigSimple {
  // API Key que funcionaba antes
  static const String apiKey = "AIzaSyA2Iani8wy51jBPnXQpTG0_IK9oAEWmeiE";
  
  // Configuración mínima
  static const bool isProduction = true;
  
  // Configuración para Places API
  static Map<String, dynamic> get placesConfig => {
    'apiKey': apiKey,
    'countries': ['mx'],
    'debounceTime': 600,
    'isLatLngRequired': true,
  };
  
  static void validateConfiguration() {
    print('🔧 Usando configuración SIMPLE de Google Maps');
    print('🔑 API Key: ${apiKey.substring(0, 10)}...');
    print('🌍 Production mode: $isProduction');
  }
}