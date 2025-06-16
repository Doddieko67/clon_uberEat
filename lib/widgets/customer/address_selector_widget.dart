// widgets/customer/address_selector_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../models/location_model.dart';
import '../common/location_picker_widget.dart';
import '../../screens/common/map_location_picker_screen.dart';
import '../../providers/customer_location_provider.dart';

class AddressSelectorWidget extends ConsumerStatefulWidget {
  final LocationData? selectedLocation;
  final Function(LocationData) onLocationSelected;
  final String title;
  final String subtitle;

  const AddressSelectorWidget({
    Key? key,
    required this.selectedLocation,
    required this.onLocationSelected,
    this.title = 'Dirección de entrega',
    this.subtitle = 'Selecciona una ubicación',
  }) : super(key: key);

  @override
  _AddressSelectorWidgetState createState() => _AddressSelectorWidgetState();
}

class _AddressSelectorWidgetState extends ConsumerState<AddressSelectorWidget> {
  @override
  void initState() {
    super.initState();
    // Set initial selected location if provided
    if (widget.selectedLocation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(customerLocationProvider.notifier).setSelectedLocation(widget.selectedLocation!);
      });
    }
  }

  void _showAddressSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
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
            
            // Header
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'Seleccionar dirección',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Buscar nueva dirección
                    _buildSearchNewAddressCard(),
                    
                    SizedBox(height: 24),
                    
                    // Direcciones guardadas
                    Consumer(
                      builder: (context, ref, child) {
                        final locationState = ref.watch(customerLocationProvider);
                        final savedAddresses = locationState.savedLocations;
                        
                        if (savedAddresses.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.location_off,
                                    size: 48,
                                    color: AppColors.textTertiary,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No tienes ubicaciones guardadas',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Usa el mapa para marcar tus puntos favoritos',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Direcciones guardadas',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 16),
                            ...savedAddresses.map((address) => 
                              _buildSavedAddressCard(address)),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchNewAddressCard() {
    return Column(
      children: [
        // Map picker option
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: InkWell(
            onTap: () => _showMapPicker(),
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.map,
                    color: AppColors.textOnPrimary,
                    size: 20,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seleccionar en el mapa',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Marca el punto exacto de entrega en el campus',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'RECOMENDADO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 12),
        
        // Text search option
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
          ),
          child: InkWell(
            onTap: () => _showLocationPicker(),
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.search,
                    color: AppColors.textOnSecondary,
                    size: 20,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buscar por texto',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Busca direcciones usando Google Places',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavedAddressCard(LocationData address) {
    final isSelected = widget.selectedLocation?.placeId == address.placeId;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: isSelected 
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: InkWell(
        onTap: () {
          widget.onLocationSelected(address);
          ref.read(customerLocationProvider.notifier).setSelectedLocation(address);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getAddressIcon(address.address),
                  color: isSelected ? AppColors.textOnPrimary : AppColors.textOnSecondary,
                  size: 18,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getAddressTitle(address.address),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      address.shortAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (address.formattedAddress != null)
                      Text(
                        address.formattedAddress!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getAddressIcon(String address) {
    if (address.toLowerCase().contains('dormitorio') || 
        address.toLowerCase().contains('cuarto')) {
      return Icons.school;
    } else if (address.toLowerCase().contains('biblioteca')) {
      return Icons.local_library;
    } else if (address.toLowerCase().contains('oficina') || 
               address.toLowerCase().contains('coordinación')) {
      return Icons.work;
    }
    return Icons.location_on;
  }

  String _getAddressTitle(String address) {
    if (address.toLowerCase().contains('dormitorio')) {
      return 'Dormitorio Estudiantil';
    } else if (address.toLowerCase().contains('biblioteca')) {
      return 'Biblioteca Central';
    } else if (address.toLowerCase().contains('oficina')) {
      return 'Oficina - Coordinación';
    }
    return address.split(',').first.trim();
  }

  void _showMapPicker() async {
    Navigator.pop(context); // Close address modal first
    
    final result = await Navigator.push<LocationData>(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPickerScreen(
          initialLocation: widget.selectedLocation,
          title: 'Marcar punto de entrega',
          confirmButtonText: 'Confirmar ubicación',
        ),
      ),
    );
    
    if (result != null) {
      widget.onLocationSelected(result);
      
      // Save to user's saved locations
      await ref.read(customerLocationProvider.notifier).saveLocation(result);
    }
  }

  void _showLocationPicker() {
    Navigator.pop(context); // Close address modal first
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
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
            
            // Header
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'Buscar dirección',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: LocationPickerWidget(
                  onLocationSelected: (locationData) {
                    widget.onLocationSelected(locationData);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: _showAddressSelectionModal,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.selectedLocation != null 
                      ? AppColors.primary 
                      : AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.selectedLocation != null 
                      ? Icons.location_on 
                      : Icons.add_location,
                  color: widget.selectedLocation != null 
                      ? AppColors.textOnPrimary 
                      : AppColors.textOnSecondary,
                  size: 20,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      widget.selectedLocation?.shortAddress ?? widget.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.selectedLocation != null 
                            ? AppColors.textSecondary 
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}