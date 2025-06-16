// Nueva configuración Google Maps - Empezando desde cero
class MapsConfigNew {
  // PASO 1: Crear nueva API key en Google Cloud Console
  // IMPORTANTE: Esta key DEBE tener billing habilitado
  
  // API Key temporal - REEMPLAZAR con tu nueva key
  static const String _apiKey = "REEMPLAZAR_CON_NUEVA_API_KEY";
  
  // Configuración de producción estricta
  static const bool _isProduction = true;
  
  // Getters públicos
  static String get apiKey => _apiKey;
  static bool get isProduction => _isProduction;
  
  // Validación estricta
  static void validateApiKey() {
    if (_apiKey == "REEMPLAZAR_CON_NUEVA_API_KEY") {
      throw Exception(
        '🚨 CONFIGURACIÓN PENDIENTE 🚨\n'
        '\n'
        'Debes configurar una nueva API key:\n'
        '\n'
        '1. Ve a: https://console.cloud.google.com/\n'
        '2. Crea un NUEVO proyecto\n'
        '3. Habilita billing (tarjeta de crédito)\n'
        '4. Habilita estas APIs:\n'
        '   - Maps SDK for Android\n'
        '   - Maps SDK for iOS\n'
        '   - Places API\n'
        '   - Geocoding API\n'
        '5. Crea nueva API key\n'
        '6. Reemplaza "_apiKey" en este archivo\n'
        '\n'
        '⚠️ SIN BILLING = "En desarrollo" siempre'
      );
    }
    
    if (_apiKey.length < 30) {
      throw Exception('API key parece inválida (muy corta)');
    }
    
    print('✅ Nueva configuración Google Maps cargada');
    print('🔑 API Key: ${_apiKey.substring(0, 10)}...');
    print('🚀 Modo producción: $_isProduction');
  }
  
  // Configuración específica para diferentes servicios
  static Map<String, dynamic> get placesConfig => {
    'apiKey': apiKey,
    'countries': ['mx'],
    'debounceTime': 600,
    'isLatLngRequired': true,
  };
  
  static Map<String, dynamic> get mapsConfig => {
    'apiKey': apiKey,
    'isProduction': isProduction,
    'defaultZoom': 15.0,
    'defaultCountry': 'Mexico',
  };
}