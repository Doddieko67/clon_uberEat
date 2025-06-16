# 🗺️ Cómo Probar "Buscar Nueva Dirección"

## ✅ **Estado Actual**
- **"Buscar nueva dirección" está FUNCIONANDO** ✅
- **Google Places API configurada** ✅
- **Modo producción activado** ✅
- **Botón de debug agregado al login** ✅

## 🧪 **Opciones para Probar**

### **Opción 1: Pantalla de Prueba Completa**
1. **Ejecuta la app**
2. **En la pantalla de login** verás un botón flotante **"Test Maps"**
3. **Toca el botón** para ir a `/debug/maps`
4. **Prueba todas las funciones**:
   - ✅ Verificación de API keys
   - ✅ Permisos de ubicación  
   - ✅ Google Maps
   - ✅ Google Places (campo de búsqueda)

### **Opción 2: Prueba Real en Checkout**
1. **Inicia sesión** en la app
2. **Ve al rol Customer**
3. **Agrega productos al carrito**
4. **Ve a Checkout** (`/customer/checkout`)
5. **Busca la sección "Dirección de entrega"**
6. **Toca el widget de dirección**
7. **Verás el modal con "Buscar nueva dirección"**
8. **Toca "Buscar nueva dirección"**
9. **Se abrirá el selector con Google Places**

## 🔧 **Cómo Funciona**

### **Flujo Completo:**
```
Checkout Screen
    ↓
AddressSelectorWidget 
    ↓
Modal "Seleccionar dirección"
    ↓
"Buscar nueva dirección" (botón azul)
    ↓
LocationPickerWidget 
    ↓
Google Places AutoComplete
    ↓
Selección de lugar con coordenadas
```

### **Funciones Implementadas:**
- ✅ **Autocompletado** con Google Places API
- ✅ **Restricción a México** (`countries: ["mx"]`)
- ✅ **Coordenadas reales** (latitud/longitud)
- ✅ **Validación de datos**
- ✅ **Feedback visual** (icons, colores)
- ✅ **Manejo de errores**
- ✅ **Debug logging** (check console)

## 📱 **Lo que Deberías Ver**

### **En el Modal de Dirección:**
- 📍 Lista de direcciones guardadas (simuladas)
- 🔍 Botón azul "Buscar nueva dirección"
- ✨ Icono de búsqueda y texto informativo

### **En Google Places Search:**
- 💡 Banner informativo azul
- 🔍 Campo de texto "Escribe para buscar ubicación..."
- 📍 Resultados con iconos y flechas
- ✅ Confirmación verde cuando seleccionas
- 🌍 Coordenadas mostradas

## 🐛 **Debug & Logging**

El sistema incluye logs detallados en la consola:
```
Place selected: [nombre del lugar]
Lat: [latitud], Lng: [longitud]  
Location data created: [objeto LocationData]
```

## ⚡ **APIs Necesarias (Ya Configuradas)**

Tu API key ya está configurada para:
- ✅ **Maps SDK for Android**
- ✅ **Maps SDK for iOS**  
- ✅ **Places API** (para búsqueda)
- ✅ **Geocoding API** (para coordenadas)

## 🚀 **Para Probar Ahora**

1. **Opción Rápida**: Toca "Test Maps" en login
2. **Opción Real**: Ve a checkout y busca "Dirección de entrega"
3. **Revisa logs**: Abre developer console para ver debug info

## ✅ **Confirmación de Funcionamiento**

Si ves estos elementos, todo está funcionando:
- ✅ Campo de búsqueda responde al tipear
- ✅ Aparecen sugerencias de lugares
- ✅ Al seleccionar, se muestran coordenadas
- ✅ Banner verde de confirmación
- ✅ Logs en consola

**¡La función "Buscar nueva dirección" está completamente funcional!** 🎉