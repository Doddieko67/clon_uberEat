# 🗺️ Solución: "Función de mapa en desarrollo"

## ❌ **Problema**
Google Maps muestra "For development purposes only" o "Función de mapa en desarrollo"

## ✅ **Causa Principal**
**Tu API key no tiene BILLING habilitado** en Google Cloud Console

## 🔧 **Solución COMPLETA**

### **Paso 1: Habilitar Billing (OBLIGATORIO)**
1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona tu proyecto
3. Ve a **"Facturación"** en el menú lateral
4. **Enlaza una tarjeta de crédito/débito**
5. ✅ **Esto es OBLIGATORIO** - Google Maps no funciona sin billing

### **Paso 2: Verificar APIs Habilitadas**
En Google Cloud Console > **APIs y servicios > Biblioteca**:
```
✅ Maps SDK for Android
✅ Maps SDK for iOS  
✅ Places API
✅ Geocoding API
✅ Maps JavaScript API (opcional)
```

### **Paso 3: Configurar API Key**
En Google Cloud Console > **Credenciales**:

#### **Restricciones de Aplicación:**
- **Android**: Agregar SHA-1 fingerprint
- **iOS**: Agregar Bundle ID
- **Para testing**: Sin restricciones (temporal)

#### **Restricciones de API:**
Seleccionar SOLO estas APIs:
```
✅ Maps SDK for Android
✅ Maps SDK for iOS
✅ Places API  
✅ Geocoding API
```

### **Paso 4: Verificar Configuración**
Usamos las pantallas de debug que creamos:

1. **Ejecuta la app**
2. **Login** → Botón **"Test Places"**
3. **Verifica logs**:
   ```
   ✅ MapsService initialized successfully
   🔑 Using API Key: AIzaSyA2...
   🌍 Production mode: true
   ```

### **Paso 5: Test Real**
1. **Rebuild completo**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
2. **Ve al checkout** → "Dirección de entrega"
3. **Busca "monterrey"** en el campo
4. **Deben aparecer sugerencias** SIN marca de agua

## 💳 **Sobre el Billing**

### **¿Es gratis?**
- ✅ **$200 USD crédito gratis** cada mes
- ✅ **Suficiente para desarrollo** y apps pequeñas
- ✅ **No se cobra** hasta que superes el crédito

### **Uso típico app de delivery:**
- 📍 **Places API**: ~$5-10/mes 
- 🗺️ **Maps SDK**: Gratis (static maps)
- 📐 **Geocoding**: ~$2-5/mes
- **Total**: ~$7-15/mes (muy por debajo del crédito gratis)

## 🚨 **Si NO puedes habilitar billing**

### **Alternativa 1: API Key temporal**
Usa una API key de prueba (pero tendrá limitaciones)

### **Alternativa 2: Deshabilitar Maps temporalmente**
```dart
// En checkout_screen.dart
bool _showMaps = false; // Cambiar a false

// Esto ocultará los mapas pero mantendrá el resto funcionando
```

### **Alternativa 3: Mock Location Service**
Usar ubicaciones predefinidas sin Maps API

## 🔍 **Diagnóstico Rápido**

### **Si sigue apareciendo "desarrollo":**
1. ✅ **Billing habilitado?** → Más importante
2. ✅ **APIs habilitadas?** → Maps SDK + Places API
3. ✅ **Rebuild completo?** → `flutter clean && flutter run`
4. ✅ **API key correcta?** → Verificar en AndroidManifest + Info.plist

### **Test definitivo:**
Prueba esta URL en tu navegador:
```
https://maps.googleapis.com/maps/api/staticmap?center=25.6876,-100.3171&zoom=13&size=400x400&key=TU_API_KEY
```

**Si funciona** → Problema en Flutter  
**Si no funciona** → Problema en Google Cloud Console

## ✅ **Resultado Esperado**

Después de habilitar billing:
- ❌ NO más "For development purposes only"
- ✅ Mapas completamente funcionales
- ✅ Places API con sugerencias
- ✅ Sin marcas de agua

**¡El billing es el 90% de los casos donde aparece "en desarrollo"!** 💳