#!/bin/bash

echo "🚨 CONFIGURACIÓN GOOGLE MAPS DESDE CERO 🚨"
echo ""
echo "Este script te ayudará a configurar tu nueva API key"
echo ""

# Validar que tengan la API key
read -p "💡 ¿Ya tienes tu NUEVA API key de Google Cloud? (y/n): " tiene_key

if [ "$tiene_key" != "y" ]; then
    echo ""
    echo "📋 PRIMERO NECESITAS CREAR TU API KEY:"
    echo ""
    echo "1. Ve a: https://console.cloud.google.com/"
    echo "2. Crea un NUEVO proyecto"
    echo "3. 💳 HABILITA BILLING (obligatorio)"
    echo "4. Habilita APIs: Maps SDK Android/iOS, Places API, Geocoding"
    echo "5. Crea nueva API key"
    echo "6. Ejecuta este script de nuevo"
    echo ""
    echo "⚠️ SIN BILLING = 'En desarrollo' SIEMPRE"
    exit 1
fi

# Pedir la API key
echo ""
read -p "🔑 Pega tu nueva API key: " nueva_api_key

if [ -z "$nueva_api_key" ]; then
    echo "❌ API key no puede estar vacía"
    exit 1
fi

if [ ${#nueva_api_key} -lt 30 ]; then
    echo "❌ API key parece muy corta (¿está completa?)"
    exit 1
fi

echo ""
echo "🔧 Configurando nueva API key..."

# Backup archivos originales
echo "📦 Creando backups..."
cp lib/config/maps_config_new.dart lib/config/maps_config_new.dart.backup 2>/dev/null || true
cp android/app/src/main/AndroidManifest.xml android/app/src/main/AndroidManifest.xml.backup
cp ios/Runner/Info.plist ios/Runner/Info.plist.backup

# Configurar Dart
echo "🎯 Configurando archivo Dart..."
sed -i "s/REEMPLAZAR_CON_NUEVA_API_KEY/$nueva_api_key/g" lib/config/maps_config_new.dart

# Configurar Android
echo "🤖 Configurando Android..."
sed -i "s/NUEVA_API_KEY_AQUI/$nueva_api_key/g" android/app/src/main/AndroidManifest.xml

# Configurar iOS
echo "🍎 Configurando iOS..."
sed -i "s/NUEVA_API_KEY_AQUI/$nueva_api_key/g" ios/Runner/Info.plist

# Limpiar y rebuild
echo "🧹 Limpiando proyecto..."
flutter clean

echo "📦 Obteniendo dependencias..."
flutter pub get

echo ""
echo "✅ CONFIGURACIÓN COMPLETADA"
echo ""
echo "🧪 PARA PROBAR:"
echo ""
echo "Opción 1 - Usar nueva configuración completa:"
echo "flutter run lib/main_new.dart"
echo ""
echo "Opción 2 - Usar configuración normal:"
echo "flutter run"
echo ""
echo "🔍 VERIFICAR:"
echo ""
echo "1. Busca en los logs: 'Nueva configuración validada exitosamente'"
echo "2. Ve a checkout > dirección de entrega"
echo "3. Busca 'monterrey' - NO debe aparecer 'En desarrollo'"
echo ""
echo "❌ SI SIGUE APARECIENDO 'EN DESARROLLO':"
echo "   - Tu API key NO tiene billing habilitado"
echo "   - Lee CONFIGURACION_DESDE_CERO.md"
echo ""
echo "📝 API key configurada: ${nueva_api_key:0:10}..."
echo ""
echo "🎉 ¡Listo para probar!"