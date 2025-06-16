# 🔍 Diagnóstico: "No aparece nada en Buscar Dirección"

## 🧪 **Cómo Diagnosticar**

### **Paso 1: Pantalla de Diagnóstico**
1. **Ejecuta la app**
2. **En login** verás 2 botones flotantes:
   - 🔍 **"Test Places"** ← ¡USA ESTE!
   - 🗺️ "Test Maps"
3. **Toca "Test Places"** para diagnóstico completo

### **Paso 2: Qué Revisar**
La pantalla mostrará logs en tiempo real:

#### ✅ **Si funciona verás:**
```
📋 API Key: ✅ Configurada
📋 Producción: ✅ Activado  
🌐 Probando Places API directamente...
📡 Response status: 200
✅ API Response: OK
✅ Sugerencias encontradas: 5
  📍 Monterrey, Nuevo León, México
  📍 Monterrey Centro, Nuevo León, México
```

#### ❌ **Si hay problemas verás:**
```
❌ API Response: REQUEST_DENIED
❌ Error message: This API key is not authorized to use this service
```

## 🔧 **Problemas Comunes y Soluciones**

### **1. API Key No Autorizada**
**Error:** `REQUEST_DENIED` o `This API key is not authorized`

**Solución:** En Google Cloud Console:
1. Ve a **APIs y servicios > Biblioteca**
2. Busca y **habilita**:
   - ✅ Places API
   - ✅ Places API (New)  
   - ✅ Geocoding API
3. Ve a **Credenciales** > Tu API Key
4. En **Restricciones de API** selecciona solo:
   - Places API
   - Geocoding API
   - Maps SDK for Android
   - Maps SDK for iOS

### **2. Sin Respuesta (Timeout)**
**Error:** No aparecen logs de respuesta

**Solución:**
- Revisa conexión a internet
- Verifica que la API key no tenga restricciones de IP muy estrictas
- Asegúrate de que el país México esté disponible

### **3. Widget No Responde**
**Error:** El campo de texto no muestra sugerencias

**En la pantalla de diagnóstico:**
1. **Escribe "monterrey"** en el campo
2. **Revisa logs** por mensajes como:
   - `🏗️ Building item: [lugar]`
   - `👆 Click en: [lugar]`

Si NO ves esos logs → Problema en el widget
Si SÍ los ves → Problema de renderizado/UI

### **4. Restricciones Geográficas**
**Error:** API funciona pero no muestra lugares en México

**Verificar en logs:**
- `countries: ["mx"]` está configurado
- Los resultados incluyen lugares mexicanos

## 🚨 **Configuración Obligatoria en Google Cloud**

### **APIs que DEBEN estar habilitadas:**
```
✅ Places API
✅ Places API (New) 
✅ Geocoding API
✅ Maps SDK for Android
✅ Maps SDK for iOS
```

### **En Credenciales > API Key:**
```
✅ Restricciones de aplicación: Ninguna (para testing)
✅ Restricciones de API: Solo las 5 APIs de arriba
✅ Sin restricciones de referidor HTTP
✅ Sin restricciones de IP
```

## 📱 **Test Paso a Paso**

1. **Toca "Test Places"** en login
2. **Lee los logs iniciales** - deben mostrar configuración ✅
3. **Toca "Test API Directo"** - debe mostrar `status: OK`
4. **Escribe "monterrey"** en el campo - deben aparecer sugerencias
5. **Toca una sugerencia** - debe mostrar coordenadas

## 🔍 **Si NADA Funciona**

**Verifica tu API Key en:**
- https://console.cloud.google.com/apis/credentials

**Prueba manualmente:**
```
https://maps.googleapis.com/maps/api/place/autocomplete/json?input=monterrey&key=TU_API_KEY&components=country:mx
```

**Si la URL manual funciona pero la app no → Problema en Flutter**
**Si la URL manual no funciona → Problema en Google Cloud Console**

## ⚡ **Solución Rápida**

Si tienes prisa:
1. **Verifica que Places API esté habilitada** en Google Cloud Console
2. **Quita TODAS las restricciones** de tu API Key temporalmente
3. **Usa "Test Places"** para confirmar que funciona
4. **Luego reaplica restricciones** una por una

**¡La pantalla de diagnóstico te dirá exactamente qué está mal!** 🎯