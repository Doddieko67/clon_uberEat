// services/maps_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../config/google_config.dart';

class MapsService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Forzar modo producción en Google Maps
      if (!kIsWeb) {
        const platform = MethodChannel('flutter/google_maps');
        
        // Configurar modo producción
        await platform.invokeMethod('setProductionMode', {
          'enabled': true,
          'apiKey': GoogleConfig.apiKey,
        }).catchError((error) {
          // Ignorar errores si el método no existe
          print('⚠️ Platform method setProductionMode not available: $error');
        });
      }

      _initialized = true;
      print('✅ MapsService initialized successfully');
      print('🔑 Using API Key: ${GoogleConfig.apiKey.substring(0, 10)}...');
      print('🌍 Production mode: ${GoogleConfig.isProduction}');
      
    } catch (e) {
      print('❌ Error initializing MapsService: $e');
    }
  }

  static bool get isInitialized => _initialized;
}