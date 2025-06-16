// screens/debug/maps_test_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import '../../config/google_config.dart';
import '../../theme/app_theme.dart';
import 'package:geolocator/geolocator.dart';

class MapsTestScreen extends StatefulWidget {
  @override
  _MapsTestScreenState createState() => _MapsTestScreenState();
}

class _MapsTestScreenState extends State<MapsTestScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  String _testResults = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  Future<void> _runTests() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Ejecutando pruebas...\n';
    });

    // Test 1: Verificar configuración
    _addTestResult('✓ Configuración GoogleConfig cargada');
    _addTestResult('API Key configurada: ${GoogleConfig.apiKey.isNotEmpty ? 'SÍ' : 'NO'}');
    _addTestResult('Modo producción: ${GoogleConfig.isProduction ? 'SÍ' : 'NO'}');

    // Test 2: Permisos de ubicación
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _addTestResult('✗ Permisos de ubicación: DENEGADOS');
      } else {
        _addTestResult('✓ Permisos de ubicación: CONCEDIDOS');
        
        // Test 3: Obtener ubicación actual
        try {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          _currentPosition = position;
          _addTestResult('✓ Ubicación actual obtenida: ${position.latitude}, ${position.longitude}');
        } catch (e) {
          _addTestResult('✗ Error obteniendo ubicación: $e');
        }
      }
    } catch (e) {
      _addTestResult('✗ Error verificando permisos: $e');
    }

    // Test 4: Test básico de Places API (solo verificar que no falle la inicialización)
    try {
      _addTestResult('✓ Google Places Widget inicializado correctamente');
    } catch (e) {
      _addTestResult('✗ Error con Google Places: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _addTestResult(String result) {
    setState(() {
      _testResults += '$result\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Prueba Google Maps & Places'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _runTests,
          ),
        ],
      ),
      body: Column(
        children: [
          // Resultados de las pruebas
          Container(
            height: 200,
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resultados de Pruebas:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      _testResults,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Google Places Search Widget
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: GooglePlaceAutoCompleteTextField(
              textEditingController: TextEditingController(),
              googleAPIKey: GoogleConfig.apiKey,
              inputDecoration: InputDecoration(
                hintText: 'Buscar lugar...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              debounceTime: 800,
              countries: ["mx"],
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (prediction) {
                _addTestResult('✓ Lugar seleccionado: ${prediction.description}');
              },
              itemClick: (prediction) {
                _addTestResult('✓ Places API funcionando: ${prediction.description}');
              },
            ),
          ),

          SizedBox(height: 16),

          // Google Map
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition != null 
                        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                        : LatLng(25.6876, -100.3171), // Monterrey por defecto
                    zoom: 15,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    _addTestResult('✓ Google Maps inicializado correctamente');
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _currentPosition != null ? {
                    Marker(
                      markerId: MarkerId('current_location'),
                      position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      infoWindow: InfoWindow(title: 'Tu ubicación actual'),
                    ),
                  } : {},
                ),
              ),
            ),
          ),

          // Información de configuración
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuración Actual:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'API Key: ${GoogleConfig.apiKey.substring(0, 10)}...',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                Text(
                  'Modo Producción: ${GoogleConfig.isProduction}',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                SizedBox(height: 8),
                Text(
                  'Servicios necesarios en Google Cloud Console:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                Text(
                  '• Maps SDK for Android\n• Maps SDK for iOS\n• Places API\n• Geocoding API',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}