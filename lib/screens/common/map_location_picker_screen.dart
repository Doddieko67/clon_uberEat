import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../theme/app_theme.dart';
import '../../models/location_model.dart';

class MapLocationPickerScreen extends StatefulWidget {
  final LocationData? initialLocation;
  final String title;
  final String confirmButtonText;

  const MapLocationPickerScreen({
    Key? key,
    this.initialLocation,
    this.title = 'Seleccionar ubicación',
    this.confirmButtonText = 'Confirmar ubicación',
  }) : super(key: key);

  @override
  State<MapLocationPickerScreen> createState() => _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = 'Buscando dirección...';
  bool _isLoadingAddress = false;
  bool _isLoadingLocation = true;
  
  // Campus locations for quick selection
  final List<CampusLocation> _campusLocations = [
    CampusLocation(
      name: 'Biblioteca Central',
      icon: Icons.local_library,
      position: LatLng(25.6856, -100.3151),
      description: 'Planta Baja, Entrada Principal',
    ),
    CampusLocation(
      name: 'Edificio A - Dormitorios',
      icon: Icons.school,
      position: LatLng(25.6866, -100.3161),
      description: 'Área de dormitorios estudiantiles',
    ),
    CampusLocation(
      name: 'Cafetería Principal',
      icon: Icons.restaurant,
      position: LatLng(25.6876, -100.3141),
      description: 'Edificio de servicios',
    ),
    CampusLocation(
      name: 'Área Deportiva',
      icon: Icons.sports_soccer,
      position: LatLng(25.6846, -100.3171),
      description: 'Canchas y gimnasio',
    ),
    CampusLocation(
      name: 'Edificio Administrativo',
      icon: Icons.business,
      position: LatLng(25.6876, -100.3171),
      description: 'Oficinas y coordinación',
    ),
    CampusLocation(
      name: 'Estacionamiento Principal',
      icon: Icons.local_parking,
      position: LatLng(25.6886, -100.3181),
      description: 'Entrada vehicular',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (widget.initialLocation != null) {
      setState(() {
        _selectedLocation = LatLng(
          widget.initialLocation!.latitude,
          widget.initialLocation!.longitude,
        );
        _selectedAddress = widget.initialLocation!.displayAddress;
        _isLoadingLocation = false;
      });
    } else {
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        // Use default campus location
        setState(() {
          _selectedLocation = LatLng(25.6876, -100.3171);
          _isLoadingLocation = false;
        });
        _getAddressFromLatLng(_selectedLocation!);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
      
      _getAddressFromLatLng(_selectedLocation!);
    } catch (e) {
      print('Error getting location: $e');
      // Use default campus location
      setState(() {
        _selectedLocation = LatLng(25.6876, -100.3171);
        _isLoadingLocation = false;
      });
      _getAddressFromLatLng(_selectedLocation!);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';
        
        // Build address from components
        if (place.street != null && place.street!.isNotEmpty) {
          address = place.street!;
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          address += address.isEmpty ? place.subLocality! : ', ${place.subLocality}';
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          address += address.isEmpty ? place.locality! : ', ${place.locality}';
        }
        
        setState(() {
          _selectedAddress = address.isEmpty ? 'Ubicación seleccionada' : address;
          _isLoadingAddress = false;
        });
      } else {
        setState(() {
          _selectedAddress = 'Ubicación en el campus';
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      print('Error getting address: $e');
      setState(() {
        _selectedAddress = 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
        _isLoadingAddress = false;
      });
    }
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
    _getAddressFromLatLng(position);
    
    // Animate camera to new position
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(position),
    );
  }

  void _selectCampusLocation(CampusLocation location) {
    setState(() {
      _selectedLocation = location.position;
      _selectedAddress = '${location.name} - ${location.description}';
    });
    
    // Animate camera to campus location
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location.position,
          zoom: 18,
        ),
      ),
    );
  }

  void _confirmLocation() {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor selecciona una ubicación'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final locationData = LocationData(
      address: _selectedAddress,
      latitude: _selectedLocation!.latitude,
      longitude: _selectedLocation!.longitude,
      formattedAddress: _selectedAddress,
    );

    Navigator.pop(context, locationData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _selectedLocation != null ? _confirmLocation : null,
            child: Text(
              widget.confirmButtonText,
              style: TextStyle(
                color: _selectedLocation != null 
                    ? AppColors.primary 
                    : AppColors.textTertiary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          _isLoadingLocation
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation ?? LatLng(25.6876, -100.3171),
                    zoom: 16,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onTap: _onMapTapped,
                  markers: _selectedLocation != null
                      ? {
                          Marker(
                            markerId: MarkerId('selected_location'),
                            position: _selectedLocation!,
                            infoWindow: InfoWindow(
                              title: 'Ubicación de entrega',
                              snippet: _selectedAddress,
                            ),
                          ),
                        }
                      : {},
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),

          // Center pin overlay
          if (!_isLoadingLocation)
            Center(
              child: Transform.translate(
                offset: Offset(0, -25),
                child: Icon(
                  Icons.location_pin,
                  size: 50,
                  color: AppColors.primary,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.3),
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom sheet with address and campus locations
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Selected address
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ubicación de entrega',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  _isLoadingAddress
                                      ? SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          _selectedAddress,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                  if (_selectedLocation != null)
                                    Text(
                                      'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textTertiary,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 20),
                        
                        // Instruction text
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Toca el mapa para seleccionar el punto exacto de entrega',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 20),
                        
                        // Campus locations
                        Text(
                          'Ubicaciones del campus',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 12),
                        
                        // Campus location chips
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _campusLocations.length,
                            itemBuilder: (context, index) {
                              final location = _campusLocations[index];
                              return GestureDetector(
                                onTap: () => _selectCampusLocation(location),
                                child: Container(
                                  width: 120,
                                  margin: EdgeInsets.only(right: 12),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.border.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        location.icon,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        location.name,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Confirm button
                  Container(
                    padding: EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedLocation != null ? _confirmLocation : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.confirmButtonText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // My location button
          Positioned(
            right: 16,
            bottom: 380,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.surface,
              onPressed: _getCurrentLocation,
              child: Icon(
                Icons.my_location,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CampusLocation {
  final String name;
  final IconData icon;
  final LatLng position;
  final String description;

  CampusLocation({
    required this.name,
    required this.icon,
    required this.position,
    required this.description,
  });
}