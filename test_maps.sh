#!/bin/bash
echo "🔧 Limpiando proyecto..."
flutter clean

echo "📦 Obteniendo dependencias..."
flutter pub get

echo "🏗️ Construyendo app..."
flutter build apk --debug

echo "🚀 Ejecutando app..."
flutter run

echo "✅ Para probar:"
echo "1. Toca 'Test Places' en login"
echo "2. Ve a checkout > dirección de entrega"
echo "3. Busca 'monterrey' en el campo"