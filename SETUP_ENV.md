# 🔧 Configuración de Variables de Entorno

## 📁 **Estructura de Archivos de Configuración**

```
lib/config/
├── env_config.dart        # Manejo de variables .env
├── google_config.dart     # Configuración Google Maps
└── maps_config.dart       # Configuración Maps (fallback)

proyecto/
├── .env                   # ⚠️ Tu archivo secreto (NO compartir)
├── .env.example          # 📋 Plantilla pública
└── .gitignore            # 🛡️ Protege .env
```

## 🚀 **Setup Rápido**

### **1. Instalar Dependencias**
```bash
flutter pub get
```

### **2. Crear archivo .env**
```bash
# Copiar plantilla
cp .env.example .env

# Editar con tu API key
nano .env  # o usa tu editor preferido
```

### **3. Configurar tu API Key**
```bash
# En el archivo .env
GOOGLE_MAPS_API_KEY=TU_API_KEY_REAL_AQUI
ENVIRONMENT=development
```

### **4. Ejecutar la app**
```bash
flutter run
```

## 🔑 **Cómo Obtener tu Google Maps API Key**

### **Paso 1: Google Cloud Console**
1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un proyecto nuevo o selecciona uno existente

### **Paso 2: Habilitar APIs**
En **APIs y servicios > Biblioteca**, habilita:
- ✅ Maps SDK for Android
- ✅ Maps SDK for iOS  
- ✅ Places API
- ✅ Geocoding API

### **Paso 3: Crear API Key**
1. Ve a **Credenciales > Crear credencial > Clave de API**
2. Copia la API key generada
3. Pégala en tu archivo `.env`

### **Paso 4: Configurar Restricciones (Recomendado)**
Para producción, restringe tu API key:
- **Aplicaciones**: Solo tu app Android/iOS
- **APIs**: Solo las que usas (Maps, Places, Geocoding)

## 🔧 **Configuración por Ambiente**

### **Desarrollo**
```bash
# .env
GOOGLE_MAPS_API_KEY=tu_key_de_desarrollo
ENVIRONMENT=development
```

### **Producción**
```bash
# .env
GOOGLE_MAPS_API_KEY=tu_key_de_produccion
ENVIRONMENT=production
```

## 📋 **Variables Disponibles**

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `GOOGLE_MAPS_API_KEY` | ⚠️ **Obligatoria** | `AIzaSyA...` |
| `ENVIRONMENT` | Opcional | `development`, `production` |
| `FIREBASE_API_KEY` | Opcional | Para futuro uso |
| `STRIPE_PUBLIC_KEY` | Opcional | Para pagos |

## 🔍 **Verificar Configuración**

La app validará automáticamente tu configuración al iniciar:

```
✅ Variables de entorno cargadas desde .env
✅ Configuración .env cargada correctamente
🔑 Google Maps API Key: AIzaSyA2Ia...
🌍 Environment: development
🚀 Production mode: false
```

## ⚠️ **Errores Comunes**

### **Error: "GOOGLE_MAPS_API_KEY no encontrada"**
```bash
# Verificar que existe el archivo
ls -la .env

# Verificar contenido
cat .env

# Debe contener:
GOOGLE_MAPS_API_KEY=tu_api_key
```

### **Error: "Using fallback configuration"**
- El archivo `.env` no existe o está mal formateado
- La app usará la configuración por defecto en `maps_config.dart`

### **Error: "For development purposes only"**
- Tu API key no tiene **billing habilitado** en Google Cloud
- Ver `SOLUCION_DESARROLLO_MAPS.md` para detalles

## 🛡️ **Seguridad**

### **✅ QUÉ HACER:**
- ✅ Usar `.env` para API keys
- ✅ Agregar `.env` al `.gitignore`
- ✅ Compartir solo `.env.example`
- ✅ Usar diferentes keys para dev/prod

### **❌ NO HACER:**
- ❌ Commitear `.env` al repositorio
- ❌ Hardcodear API keys en el código
- ❌ Compartir API keys en mensajes/chat
- ❌ Usar la misma key para todo

## 🔄 **Migración desde Configuración Anterior**

Tu app ya tiene un sistema de fallback:
1. **Prioridad 1**: Variables `.env` 
2. **Prioridad 2**: Configuración hardcodeada (`maps_config.dart`)

Esto significa que puedes migrar gradualmente sin romper nada.

## 🚀 **Para el Equipo**

### **Al clonar el proyecto:**
```bash
git clone tu_repositorio
cd tu_repositorio
cp .env.example .env
# Editar .env con tus API keys
flutter pub get
flutter run
```

### **Compartir con nuevos desarrolladores:**
- ❌ NO envíes tu archivo `.env`
- ✅ Envía el archivo `.env.example`
- ✅ Dales instrucciones para crear su propio `.env`

¡Tu configuración ahora es segura y fácil de manejar! 🎉