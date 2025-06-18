import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/location_model.dart';
import '../theme/app_theme.dart';

class DeliveryMapWidget extends StatefulWidget {
  final LocationData? storeLocation;
  final LocationData? deliveryLocation;
  final double? delivererLatitude;
  final double? delivererLongitude;
  final bool showRoute;
  final double height;

  const DeliveryMapWidget({
    Key? key,
    this.storeLocation,
    this.deliveryLocation,
    this.delivererLatitude,
    this.delivererLongitude,
    this.showRoute = true,
    this.height = 200,
  }) : super(key: key);

  @override
  State<DeliveryMapWidget> createState() => _DeliveryMapWidgetState();
}

class _DeliveryMapWidgetState extends State<DeliveryMapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _setupMarkers();
    if (widget.showRoute) {
      _setupRoute();
    }
  }

  void _setupMarkers() {
    final markers = <Marker>{};

    // Store marker
    if (widget.storeLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('store'),
          position: LatLng(
            widget.storeLocation!.latitude,
            widget.storeLocation!.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Tienda',
            snippet: widget.storeLocation!.address,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
    }

    // Delivery location marker
    if (widget.deliveryLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('delivery'),
          position: LatLng(
            widget.deliveryLocation!.latitude,
            widget.deliveryLocation!.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Entregar aquí',
            snippet: widget.deliveryLocation!.address,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    // Deliverer marker
    if (widget.delivererLatitude != null && widget.delivererLongitude != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('deliverer'),
          position: LatLng(
            widget.delivererLatitude!,
            widget.delivererLongitude!,
          ),
          infoWindow: const InfoWindow(
            title: 'Tu ubicación',
            snippet: 'Ubicación actual del repartidor',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _setupRoute() {
    if (widget.storeLocation == null || widget.deliveryLocation == null) return;

    // Simple route visualization (in production, use Directions API)
    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: [
        LatLng(widget.storeLocation!.latitude, widget.storeLocation!.longitude),
        if (widget.delivererLatitude != null && widget.delivererLongitude != null)
          LatLng(widget.delivererLatitude!, widget.delivererLongitude!),
        LatLng(widget.deliveryLocation!.latitude, widget.deliveryLocation!.longitude),
      ],
      color: AppColors.primary,
      width: 4,
      patterns: [], // Solid line
    );

    setState(() {
      _polylines = {polyline};
    });
  }

  LatLngBounds _calculateBounds() {
    final locations = <LatLng>[];
    
    if (widget.storeLocation != null) {
      locations.add(LatLng(
        widget.storeLocation!.latitude,
        widget.storeLocation!.longitude,
      ));
    }
    
    if (widget.deliveryLocation != null) {
      locations.add(LatLng(
        widget.deliveryLocation!.latitude,
        widget.deliveryLocation!.longitude,
      ));
    }
    
    if (widget.delivererLatitude != null && widget.delivererLongitude != null) {
      locations.add(LatLng(
        widget.delivererLatitude!,
        widget.delivererLongitude!,
      ));
    }

    if (locations.isEmpty) {
      // Default to campus center if no locations
      return LatLngBounds(
        southwest: const LatLng(25.65, -100.35),
        northeast: const LatLng(25.70, -100.25),
      );
    }

    double minLat = locations.first.latitude;
    double maxLat = locations.first.latitude;
    double minLng = locations.first.longitude;
    double maxLng = locations.first.longitude;

    for (final location in locations) {
      minLat = location.latitude < minLat ? location.latitude : minLat;
      maxLat = location.latitude > maxLat ? location.latitude : maxLat;
      minLng = location.longitude < minLng ? location.longitude : minLng;
      maxLng = location.longitude > maxLng ? location.longitude : maxLng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat - 0.005, minLng - 0.005),
      northeast: LatLng(maxLat + 0.005, maxLng + 0.005),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If no location data, show placeholder
    if (widget.storeLocation == null && widget.deliveryLocation == null) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 48,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 8),
              Text(
                'Sin datos de ubicación',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.deliveryLocation != null
              ? LatLng(
                  widget.deliveryLocation!.latitude,
                  widget.deliveryLocation!.longitude,
                )
              : LatLng(
                  widget.storeLocation!.latitude,
                  widget.storeLocation!.longitude,
                ),
          zoom: 15,
        ),
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        onMapCreated: (controller) {
          _mapController = controller;
          // Fit bounds to show all markers
          Future.delayed(const Duration(milliseconds: 100), () {
            _mapController?.animateCamera(
              CameraUpdate.newLatLngBounds(_calculateBounds(), 100),
            );
          });
        },
      ),
    );
  }

  @override
  void didUpdateWidget(DeliveryMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.delivererLatitude != widget.delivererLatitude ||
        oldWidget.delivererLongitude != widget.delivererLongitude) {
      _setupMarkers();
      if (widget.showRoute) {
        _setupRoute();
      }
    }
  }
}