// widgets/customer/address_selector_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../models/location_model.dart';
import '../common/location_picker_widget.dart';

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
  // Direcciones guardadas (simuladas - en una app real vendrían de Firestore)
  List<LocationData> _savedAddresses = [
    LocationData(
      address: 'Dormitorio Estudiantil, Edificio A, Cuarto 205',
      latitude: 25.6866,
      longitude: -100.3161,
      formattedAddress: 'Edificio A, Cuarto 205, Ciudad Universitaria',
      placeId: 'ChIJkbeSa_BrQIYRFf4EG79BhOA',
    ),
    LocationData(
      address: 'Biblioteca Central, Planta Baja',
      latitude: 25.6856,
      longitude: -100.3151,
      formattedAddress: 'Biblioteca Central, Planta Baja, Ciudad Universitaria',
      placeId: 'ChIJkbeSa_BrQIYRFf4EG79BhOB',
    ),
    LocationData(
      address: 'Oficina - Coordinación, Edificio Administrativo',
      latitude: 25.6876,
      longitude: -100.3171,
      formattedAddress: 'Edificio Administrativo, Piso 3, Oficina 301',
      placeId: 'ChIJkbeSa_BrQIYRFf4EG79BhOC',
    ),
  ];

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
                    if (_savedAddresses.isNotEmpty) ...[
                      Text(
                        'Direcciones guardadas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 16),
                      ..._savedAddresses.map((address) => 
                        _buildSavedAddressCard(address)),
                    ],
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
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: () => _showLocationPicker(),
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
                Icons.search,
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
                    'Buscar nueva dirección',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Usa Google Maps para encontrar tu ubicación',
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
              color: AppColors.primary,
              size: 16,
            ),
          ],
        ),
      ),
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