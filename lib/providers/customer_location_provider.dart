import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/location_model.dart';
import '../models/customer_model.dart';
import 'auth_provider.dart';

// Provider for managing customer locations
final customerLocationProvider = StateNotifierProvider<CustomerLocationNotifier, CustomerLocationState>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return CustomerLocationNotifier(ref, authState.user?.id);
});

// State class for customer locations
class CustomerLocationState {
  final LocationData? selectedLocation;
  final List<LocationData> savedLocations;
  final bool isLoading;
  final String? error;

  CustomerLocationState({
    this.selectedLocation,
    this.savedLocations = const [],
    this.isLoading = false,
    this.error,
  });

  CustomerLocationState copyWith({
    LocationData? selectedLocation,
    List<LocationData>? savedLocations,
    bool? isLoading,
    String? error,
  }) {
    return CustomerLocationState(
      selectedLocation: selectedLocation ?? this.selectedLocation,
      savedLocations: savedLocations ?? this.savedLocations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CustomerLocationNotifier extends StateNotifier<CustomerLocationState> {
  final Ref ref;
  final String? userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CustomerLocationNotifier(this.ref, this.userId) : super(CustomerLocationState()) {
    if (userId != null) {
      _loadSavedLocations();
    }
  }

  // Load saved locations from Firestore
  Future<void> _loadSavedLocations() async {
    if (userId == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final doc = await _firestore.collection('customers').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final savedLocations = data['savedLocations'] as List<dynamic>?;
        final preferredLocationData = data['preferredLocationData'] as Map<String, dynamic>?;

        state = state.copyWith(
          savedLocations: savedLocations
              ?.map((loc) => LocationData.fromMap(loc as Map<String, dynamic>))
              .toList() ?? [],
          selectedLocation: preferredLocationData != null
              ? LocationData.fromMap(preferredLocationData)
              : null,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading locations: $e',
      );
    }
  }

  // Set selected location
  void setSelectedLocation(LocationData location) {
    state = state.copyWith(selectedLocation: location);
  }

  // Add or update a saved location
  Future<void> saveLocation(LocationData location) async {
    if (userId == null) return;

    try {
      // Check if location already exists (by coordinates)
      final existingIndex = state.savedLocations.indexWhere(
        (loc) => loc.latitude == location.latitude && loc.longitude == location.longitude,
      );

      List<LocationData> updatedLocations;
      if (existingIndex != -1) {
        // Update existing location
        updatedLocations = List.from(state.savedLocations);
        updatedLocations[existingIndex] = location;
      } else {
        // Add new location (keep max 10 locations)
        updatedLocations = [location, ...state.savedLocations];
        if (updatedLocations.length > 10) {
          updatedLocations = updatedLocations.sublist(0, 10);
        }
      }

      // Update Firestore
      await _firestore.collection('customers').doc(userId).update({
        'savedLocations': updatedLocations.map((loc) => loc.toMap()).toList(),
        'preferredLocationData': location.toMap(),
        'preferredLocation': location.displayAddress, // For backward compatibility
      });

      state = state.copyWith(
        savedLocations: updatedLocations,
        selectedLocation: location,
      );
    } catch (e) {
      state = state.copyWith(error: 'Error saving location: $e');
    }
  }

  // Remove a saved location
  Future<void> removeLocation(LocationData location) async {
    if (userId == null) return;

    try {
      final updatedLocations = state.savedLocations
          .where((loc) => !(loc.latitude == location.latitude && loc.longitude == location.longitude))
          .toList();

      // Update Firestore
      await _firestore.collection('customers').doc(userId).update({
        'savedLocations': updatedLocations.map((loc) => loc.toMap()).toList(),
      });

      state = state.copyWith(savedLocations: updatedLocations);
    } catch (e) {
      state = state.copyWith(error: 'Error removing location: $e');
    }
  }

  // Update location nickname/label
  Future<void> updateLocationLabel(LocationData location, String newLabel) async {
    if (userId == null) return;

    try {
      final updatedLocation = location.copyWith(address: newLabel);
      await saveLocation(updatedLocation);
    } catch (e) {
      state = state.copyWith(error: 'Error updating location label: $e');
    }
  }

  // Clear selected location
  void clearSelectedLocation() {
    state = state.copyWith(selectedLocation: null);
  }
}

// Provider for commonly used campus locations
final campusLocationsProvider = Provider<List<LocationData>>((ref) {
  return [
    LocationData(
      address: 'Biblioteca Central',
      latitude: 25.6856,
      longitude: -100.3151,
      formattedAddress: 'Biblioteca Central - Entrada Principal',
    ),
    LocationData(
      address: 'Edificio A - Dormitorios',
      latitude: 25.6866,
      longitude: -100.3161,
      formattedAddress: 'Edificio A - Área de dormitorios estudiantiles',
    ),
    LocationData(
      address: 'Cafetería Principal',
      latitude: 25.6876,
      longitude: -100.3141,
      formattedAddress: 'Cafetería Principal - Edificio de servicios',
    ),
    LocationData(
      address: 'Área Deportiva',
      latitude: 25.6846,
      longitude: -100.3171,
      formattedAddress: 'Área Deportiva - Canchas y gimnasio',
    ),
    LocationData(
      address: 'Edificio Administrativo',
      latitude: 25.6876,
      longitude: -100.3171,
      formattedAddress: 'Edificio Administrativo - Oficinas',
    ),
    LocationData(
      address: 'Estacionamiento Principal',
      latitude: 25.6886,
      longitude: -100.3181,
      formattedAddress: 'Estacionamiento Principal - Entrada vehicular',
    ),
  ];
});