// screens/deliverer/deliverer_location_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../models/order_model.dart';
import '../../services/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class DelivererLocationScreen extends ConsumerStatefulWidget {
  @override
  _DelivererLocationScreenState createState() => _DelivererLocationScreenState();
}

class _DelivererLocationScreenState extends ConsumerState<DelivererLocationScreen> {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  Position? _currentLocation;
  Order? _order;
  Set<Marker> _markers = {};
  StreamSubscription<Position>? _locationSubscription;

  // Coordenadas de ejemplo para el destino
  static const LatLng _defaultDestination = LatLng(25.6866, -100.3161); // Monterrey, México

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Obtener argumentos de navegación
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _currentLocation = args['currentLocation'] as Position?;
      _order = args['order'] as Order?;
      _updateMarkers();
    }
  }

  void _initializeMap() async {
    try {
      // Obtener ubicación actual si no se proporcionó
      if (_currentLocation == null) {
        final position = await _locationService.getCurrentLocation();
        if (position != null) {
          setState(() {
            _currentLocation = position;
          });
        }
      }

      // Iniciar tracking de ubicación
      _locationSubscription = _locationService.getLocationStream().listen(
        (Position position) {
          setState(() {
            _currentLocation = position;
          });
          _updateMarkers();
          _updateCameraPosition();
        },
      );

      _updateMarkers();
    } catch (e) {
      print('Error initializing map: $e');
    }
  }

  void _updateMarkers() {
    final markers = <Marker>{};

    // Marcador de ubicación actual
    if (_currentLocation != null) {
      markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
          infoWindow: InfoWindow(
            title: 'Mi Ubicación',
            snippet: 'Repartidor',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Marcador de destino
    markers.add(
      Marker(
        markerId: MarkerId('destination'),
        position: _defaultDestination,
        infoWindow: InfoWindow(
          title: 'Destino',
          snippet: _order?.deliveryAddress ?? 'Ubicación de entrega',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    setState(() {
      _markers = markers;
    });
  }

  void _updateCameraPosition() {
    if (_mapController != null && _currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
        ),
      );
    }
  }

  String _getEstimatedTime() {
    if (_currentLocation == null) return '8-12 min';
    
    final distance = _locationService.calculateDistance(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      _defaultDestination.latitude,
      _defaultDestination.longitude,
    );
    
    final minutes = (distance / 50).ceil(); // Aprox 50m por minuto caminando
    return '${minutes}-${minutes + 2} min';
  }

  String _getDistance() {
    if (_currentLocation == null) return '320m';
    
    final distance = _locationService.calculateDistance(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      _defaultDestination.latitude,
      _defaultDestination.longitude,
    );
    
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    } else {
      return '${distance.toInt()}m';
    }
  }

  Future<void> _openExternalNavigation() async {
    final String googleMapsUrl = 
        'https://www.google.com/maps/dir/?api=1&destination=${_defaultDestination.latitude},${_defaultDestination.longitude}&travelmode=walking';
    
    try {
      final Uri uri = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se puede abrir la aplicación de mapas')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir navegación: $e')),
      );
    }
  }

  Future<void> _callCustomer() async {
    final String phoneNumber = _order?.customerPhone ?? '+52 555 987 6543';
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se puede hacer la llamada')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al hacer la llamada')),
      );
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _locationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppColors.textSecondary),
        ),
        title: Text(
          'Ubicación del Cliente',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (_currentLocation != null && _mapController != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
                  ),
                );
              }
            },
            icon: Icon(Icons.my_location, color: AppColors.primary),
            tooltip: 'Mi ubicación',
          ),
        ],
      ),
      body: Column(
        children: [
          // Google Maps
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: _currentLocation != null
                  ? GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      initialCameraPosition: CameraPosition(
                        target: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
                        zoom: 15.0,
                      ),
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      mapType: MapType.normal,
                      zoomControlsEnabled: false,
                    )
                  : Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            SizedBox(height: 16),
                            Text(
                              'Obteniendo ubicación...',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          
          // Bottom action panel
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkWithOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _order?.deliveryAddress ?? 'Biblioteca - Sala 3, Ciudad Universitaria',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, color: AppColors.textSecondary, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'ETA: ${_getEstimatedTime()} • ${_getDistance()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openExternalNavigation,
                        icon: Icon(Icons.navigation, size: 16),
                        label: Text('Navegar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _callCustomer,
                        icon: Icon(Icons.phone, size: 16),
                        label: Text('Llamar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}