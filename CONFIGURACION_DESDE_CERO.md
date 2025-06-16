# 🚨 CONFIGURACIÓN GOOGLE MAPS DESDE CERO

## ❌ **PROBLEMA: "Función de mapa en desarrollo"**

Si sigues viendo esta marca, es porque tu API key **NO TIENE BILLING HABILITADO**.

## 🔄 **SOLUCIÓN: EMPEZAR DESDE CERO**

### **📋 PASO 1: CREAR NUEVO PROYECTO EN GOOGLE CLOUD**

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. **Crear nuevo proyecto** (no usar uno existente)
3. Nombre: `ubereat-clone-prod` (o similar)
4. Espera a que se cree el proyecto

### **💳 PASO 2: HABILITAR BILLING (OBLIGATORIO)**

⚠️ **SIN ESTO, SIEMPRE APARECERÁ "EN DESARROLLO"**

1. En Google Cloud Console → **Facturación**
2. **Vincular cuenta de facturación**
3. Agregar tarjeta de crédito/débito
4. ✅ **Esto es 100% NECESARIO**

**💰 ¿Cuánto cuesta?**
- 🎁 **$200 USD gratis** cada mes
- 📱 Apps pequeñas: ~$5-15/mes
- 🚀 **Muy por debajo del crédito gratis**

### **📡 PASO 3: HABILITAR APIs**

En **APIs y servicios → Biblioteca**, busca y habilita:

```
✅ Maps SDK for Android
✅ Maps SDK for iOS
✅ Places API
✅ Geocoding API
```

### **🔑 PASO 4: CREAR NUEVA API KEY**

1. **Credenciales → Crear credencial → Clave de API**
2. **Copiar la API key** generada
3. **IMPORTANTE**: Guárdala, la necesitarás

### **🔒 PASO 5: CONFIGURAR RESTRICCIONES (OPCIONAL)**

Por seguridad (después de testing):

**Restricciones de aplicación:**
- Android: SHA-1 fingerprint de tu app
- iOS: Bundle ID de tu app

**Restricciones de API:**
- Solo seleccionar las APIs que habilitaste

---

## 🛠️ **CONFIGURACIÓN EN TU APP**

### **ARCHIVO 1: `lib/config/maps_config_new.dart`**

```dart
// Reemplazar "_apiKey" con tu nueva key
static const String _apiKey = "AIzaSyC_TU_NUEVA_API_KEY_AQUI";
```

### **ARCHIVO 2: `android/app/src/main/AndroidManifest.xml`**

```xml
<!-- Buscar estas líneas y reemplazar -->
<meta-data android:name="com.google.android.geo.API_KEY"
           android:value="TU_NUEVA_API_KEY_AQUI"/>

<meta-data android:name="com.google.android.maps.v2.API_KEY"
           android:value="TU_NUEVA_API_KEY_AQUI"/>
```

### **ARCHIVO 3: `ios/Runner/Info.plist`**

```xml
<!-- Buscar esta línea y reemplazar -->
<key>GMSAPIKey</key>
<string>TU_NUEVA_API_KEY_AQUI</string>
```

---

## 🧪 **TESTING RÁPIDO**

### **Verificar si tu API key funciona:**

Abre esta URL en tu navegador (reemplaza TU_API_KEY):

```
https://maps.googleapis.com/maps/api/staticmap?center=25.6866,-100.3161&zoom=13&size=400x400&key=TU_API_KEY
```

**✅ Si funciona**: Verás un mapa de Monterrey  
**❌ Si no funciona**: Error de billing o key inválida

---

## 🔄 **APLICAR CAMBIOS EN LA APP**

### **OPCIÓN A: Usar nueva configuración**

```bash
# 1. Editar los 3 archivos mencionados arriba
# 2. Limpiar y rebuild
flutter clean
flutter pub get
flutter run
```

### **OPCIÓN B: Usar archivos nuevos creados**

```bash
# Usar main_new.dart en lugar de main.dart
flutter run lib/main_new.dart
```

---

## 🎯 **RESULTADO ESPERADO**

### **✅ CON BILLING HABILITADO:**
- ❌ NO más "For development purposes only"
- ✅ Mapas completamente funcionales
- ✅ Places API con sugerencias perfectas
- ✅ Sin marcas de agua

### **❌ SIN BILLING:**
- ⚠️ Siempre aparecerá "En desarrollo"
- 🚫 No importa qué hagas en la app
- 💳 Es una limitación de Google

---

## 🔍 **DIAGNÓSTICO RÁPIDO**

### **1. Verificar billing:**
- Google Cloud Console → Facturación
- Debe tener tarjeta vinculada y activa

### **2. Verificar APIs:**
- APIs y servicios → APIs habilitadas
- Deben estar las 4 mencionadas

### **3. Verificar restricciones:**
- Credenciales → Tu API key
- No muy restrictivas al principio

### **4. Test de conectividad:**
- Usar la URL del mapa estático
- Debe mostrar mapa sin marcas

---

## 📞 **SI NADA FUNCIONA**

### **Posibles causas:**

1. **Billing no habilitado** (90% de los casos)
2. **API key incorrecta** (5% de los casos)
3. **APIs no habilitadas** (3% de los casos)
4. **Restricciones muy estrictas** (2% de los casos)

### **Solución drástica:**

1. **Eliminar proyecto actual** en Google Cloud
2. **Crear proyecto completamente nuevo**
3. **Seguir esta guía paso a paso**
4. **No saltarse el billing**

---

## 🎉 **CONFIGURACIÓN EXITOSA**

Cuando esté bien configurado, verás en los logs:

```
✅ Nueva configuración validada exitosamente
🔑 API Key (nueva): AIzaSyC_TU...
🌍 Production mode (nueva): true
🎯 [NUEVA CONFIG] Place selected: Monterrey, N.L.
```

**¡Sin más "En desarrollo"!** 🚀