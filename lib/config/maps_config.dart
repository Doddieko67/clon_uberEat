// config/maps_config.dart
import 'dart:io';

class MapsConfig {
  // API Keys for different platforms
  static const String _androidApiKey = "AIzaSyA2Iani8wy51jBPnXQpTG0_IK9oAEWmeiE";
  static const String _iosApiKey = "AIzaSyA2Iani8wy51jBPnXQpTG0_IK9oAEWmeiE";
  static const String _webApiKey = "AIzaSyA2Iani8wy51jBPnXQpTG0_IK9oAEWmeiE";
  
  // Environment configuration
  static const bool forceProductionMode = true;
  
  // Get platform-specific API key
  static String get apiKey {
    if (Platform.isAndroid) {
      return _androidApiKey;
    } else if (Platform.isIOS) {
      return _iosApiKey;
    } else {
      return _webApiKey;
    }
  }
  
  // Check if we're in production mode
  static bool get isProduction {
    if (forceProductionMode) return true;
    
    // Check for debug mode
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return !inDebugMode;
  }
  
  // Maps configuration
  static Map<String, dynamic> get mapsConfig {
    return {
      'apiKey': apiKey,
      'isProduction': isProduction,
      'enableBilling': true,
      'enableTraffic': false,
      'enableMyLocation': true,
      'compassEnabled': true,
      'mapToolbarEnabled': true,
      'zoomControlsEnabled': false,
      'liteModeEnabled': false,
    };
  }
  
  // Places API configuration
  static Map<String, dynamic> get placesConfig {
    return {
      'apiKey': apiKey,
      'countries': ['mx'],
      'language': 'es',
      'region': 'mx',
      'enableBilling': true,
      'sessionToken': null,
    };
  }
}