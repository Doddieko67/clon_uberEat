// screens/debug/places_test_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import '../../theme/app_theme.dart';
import '../../config/google_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlacesTestScreen extends StatefulWidget {
  @override
  _PlacesTestScreenState createState() => _PlacesTestScreenState();
}

class _PlacesTestScreenState extends State<PlacesTestScreen> {
  final TextEditingController _controller = TextEditingController();
  String _testResults = '';
  List<String> _logs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  void _addLog(String log) {
    setState(() {
      _logs.add('[${DateTime.now().toString().substring(11, 19)}] $log');
      _testResults = _logs.join('\n');
    });
    print(log);
  }

  Future<void> _runDiagnostics() async {
    _addLog('🔧 Iniciando diagnósticos...');
    
    // Test 1: Verificar configuración
    _addLog('📋 API Key: ${GoogleConfig.apiKey.isNotEmpty ? "✅ Configurada" : "❌ Faltante"}');
    _addLog('📋 Producción: ${GoogleConfig.isProduction ? "✅ Activado" : "❌ Desactivado"}');
    _addLog('📋 Key (primeros 10): ${GoogleConfig.apiKey.substring(0, 10)}...');
    
    // Test 2: Test directo de Places API
    await _testPlacesAPIDirect();
  }

  Future<void> _testPlacesAPIDirect() async {
    _addLog('🌐 Probando Places API directamente...');
    
    try {
      final String query = 'monterrey';
      final String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=$query'
          '&key=${GoogleConfig.apiKey}'
          '&components=country:mx'
          '&language=es';
      
      _addLog('📡 URL: ${url.substring(0, 80)}...');
      
      final response = await http.get(Uri.parse(url));
      _addLog('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _addLog('✅ API Response: ${data['status']}');
        
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          _addLog('✅ Sugerencias encontradas: ${predictions.length}');
          
          for (int i = 0; i < predictions.length && i < 3; i++) {
            _addLog('  📍 ${predictions[i]['description']}');
          }
        } else {
          _addLog('❌ API Error: ${data['status']}');
          _addLog('❌ Error message: ${data['error_message'] ?? "No message"}');
        }
      } else {
        _addLog('❌ HTTP Error: ${response.statusCode}');
        _addLog('❌ Response: ${response.body}');
      }
    } catch (e) {
      _addLog('❌ Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Places API Diagnóstico'),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _logs.clear();
                _testResults = '';
              });
              _runDiagnostics();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información de configuración
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuración Actual',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('API Key: ${GoogleConfig.apiKey.substring(0, 15)}...', 
                       style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'monospace')),
                  Text('Producción: ${GoogleConfig.isProduction}', 
                       style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Test field
            Text(
              'Prueba Google Places Widget:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),

            GooglePlaceAutoCompleteTextField(
              textEditingController: _controller,
              googleAPIKey: GoogleConfig.apiKey,
              inputDecoration: InputDecoration(
                hintText: 'Escribe "monterrey" o "mexico"...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              debounceTime: 800,
              countries: const ["mx"],
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (Prediction prediction) async {
                _addLog('✅ Lugar seleccionado: ${prediction.description}');
                _addLog('📍 Coordenadas: ${prediction.lat}, ${prediction.lng}');
              },
              itemClick: (Prediction prediction) {
                _addLog('👆 Click en: ${prediction.description}');
              },
              itemBuilder: (context, index, Prediction prediction) {
                _addLog('🏗️ Building item: ${prediction.description}');
                return Container(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: AppColors.primary, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          prediction.description ?? '',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 16),

            // Logs
            Text(
              'Logs de Diagnóstico:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),

            Expanded(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResults.isEmpty ? 'Ejecutando pruebas...' : _testResults,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Acciones
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      setState(() {
                        _logs.clear();
                        _testResults = '';
                      });
                      await _testPlacesAPIDirect();
                    },
                    icon: Icon(Icons.api),
                    label: Text('Test API Directo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _addLog('📝 Escribe "monterrey" en el campo de arriba');
                      _addLog('👀 Observa si aparecen sugerencias');
                      _addLog('🔍 Revisa los logs de "Building item"');
                    },
                    icon: Icon(Icons.help),
                    label: Text('Ayuda'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.textOnSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}