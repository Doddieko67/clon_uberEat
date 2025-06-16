// Google API Configuration
class GoogleConfig {
  // IMPORTANTE: Reemplaza esta API key con tu propia Google Places API key
  // Cómo obtener una API key:
  // 1. Ve a Google Cloud Console (https://console.cloud.google.com/)
  // 2. Crea un nuevo proyecto o selecciona uno existente
  // 3. Habilita la API de Google Places
  // 4. Ve a Credenciales > Crear credencial > Clave de API
  // 5. Restricciones recomendadas:
  //    - Restringir por aplicación (Android/iOS)
  //    - Restringir APIs: Places API, Geocoding API, Maps SDK
  
  static const String googlePlacesApiKey = "AIzaSyA2Iani8wy51jBPnXQpTG0_IK9oAEWmeiE"; // CAMBIAR POR TU API KEY
  
  // Para desarrollo, puedes usar esta key temporal, pero para producción DEBES usar tu propia key
  static const bool isProduction = false;
  
  static String get apiKey {
    if (isProduction) {
      // En producción, asegúrate de tener tu API key real aquí
      return googlePlacesApiKey;
    } else {
      // En desarrollo, considera usar variables de entorno
      const String envApiKey = String.fromEnvironment('GOOGLE_PLACES_API_KEY', defaultValue: '');
      return envApiKey.isNotEmpty ? envApiKey : googlePlacesApiKey;
    }
  }
}
