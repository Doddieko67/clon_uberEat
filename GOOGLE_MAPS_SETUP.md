# Google Maps & Places API - Configuración para Producción

## ✅ Estado Actual
- **API Key configurada**: `AIzaSyA2Iani8wy51jBPnXQpTG0_IK9oAEWmeiE`
- **Modo producción activado**: `isProduction = true`
- **Configuración Android**: ✅ Completada en AndroidManifest.xml
- **Configuración iOS**: ✅ Completada en Info.plist

## 🔧 Servicios que DEBEN estar habilitados en Google Cloud Console

Para que la aplicación funcione correctamente, debes habilitar estos servicios en tu proyecto de Google Cloud Console:

### Servicios Required:
1. **Maps SDK for Android** - Para mapas en Android
2. **Maps SDK for iOS** - Para mapas en iOS  
3. **Places API** - Para búsqueda de lugares y autocompletado
4. **Geocoding API** - Para convertir coordenadas a direcciones

### Pasos para habilitar:
1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona tu proyecto o crea uno nuevo
3. Ve a "APIs y servicios" > "Biblioteca"
4. Busca y habilita cada uno de los servicios listados arriba
5. Ve a "Credenciales" y verifica que tu API key tenga acceso a estos servicios

## 🧪 Pantalla de Prueba

Hemos creado una pantalla de prueba que puedes usar para verificar que todo funciona:

**URL de acceso**: `/debug/maps`

### Qué prueba:
- ✅ Configuración de API keys
- ✅ Permisos de ubicación
- ✅ Google Maps SDK
- ✅ Google Places API
- ✅ Obtención de ubicación actual

### Cómo usar:
1. Ejecuta la app
2. Ve a la URL: `http://localhost:PORT/#/debug/maps`
3. O agrega un botón temporal en login para acceder
4. Verifica que todos los tests pasen

## 🔒 Configuración de Restricciones (Recomendado)

Para mayor seguridad, configura restricciones en tu API key:

### Restricciones de Aplicación:
- **Android**: Agrega el SHA-1 fingerprint de tu app
- **iOS**: Agrega el Bundle ID de tu app

### Restricciones de API:
- Limita solo a las APIs que necesitas:
  - Maps SDK for Android
  - Maps SDK for iOS
  - Places API
  - Geocoding API

## 🚨 Limitaciones de Desarrollo vs Producción

### Modo Desarrollo (`isProduction = false`):
- Mapas pueden mostrar marca de agua "For development purposes only"
- Límites más bajos de requests
- Algunas funciones pueden estar limitadas

### Modo Producción (`isProduction = true`):
- Mapas sin marca de agua
- Límites normales de producción
- Todas las funciones disponibles
- **REQUIERE** configuración correcta en Google Cloud Console

## 📱 Configuración Actual de la App

### Android (AndroidManifest.xml):
```xml
<meta-data android:name="com.google.android.geo.API_KEY"
           android:value="AIzaSyA2Iani8wy51jBPnXQpTG0_IK9oAEWmeiE"/>
```

### iOS (Info.plist):
```xml
<key>GMSAPIKey</key>
<string>AIzaSyA2Iani8wy51jBPnXQpTG0_IK9oAEWmeiE</string>
```

### Flutter (google_config.dart):
```dart
static const bool isProduction = true; // ✅ Activado para producción
static const String googlePlacesApiKey = "AIzaSyA2Iani8wy51jBPnXQpTG0_IK9oAEWmeiE";
```

## ✅ Verificación Final

Para confirmar que todo funciona:

1. **Ejecuta la pantalla de prueba** en `/debug/maps`
2. **Verifica que todos los tests pasen**
3. **Prueba las funciones reales** en la app:
   - Selección de ubicación en checkout
   - Mapas de tracking en pedidos
   - Búsqueda de lugares

Si algún test falla, revisa la configuración en Google Cloud Console y asegúrate de que todos los servicios estén habilitados.