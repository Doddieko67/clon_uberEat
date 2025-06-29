import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:google_places_flutter/model/place_details.dart';
import '../../theme/app_theme.dart';
import '../../config/google_config_simple.dart';
import '../../models/location_model.dart';

class LocationPickerWidget extends StatefulWidget {
  final String? initialAddress;
  final Function(LocationData) onLocationSelected;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  const LocationPickerWidget({
    super.key,
    this.initialAddress,
    required this.onLocationSelected,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.validator,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  final TextEditingController _controller = TextEditingController();
  LocationData? _selectedLocation;

  @override
  void initState() {
    super.initState();
    print('🔧 LocationPickerWidget initialized (CONFIGURACIÓN SIMPLE)');
    print('🔑 API Key: ${GoogleConfigSimple.apiKey.substring(0, 10)}...');
    print('🌍 Production mode: ${GoogleConfigSimple.isProduction}');
    
    if (widget.initialAddress != null) {
      _controller.text = widget.initialAddress!;
    }
    
    // Listener para actualizar el estado cuando cambie el texto
    _controller.addListener(() {
      setState(() {
        // Resetear ubicación seleccionada si el usuario modifica el texto
        if (_selectedLocation != null && _controller.text != _selectedLocation!.address) {
          _selectedLocation = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Información de estado
        Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 16,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Busca y selecciona tu ubicación usando Google Places',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        GooglePlaceAutoCompleteTextField(
          textEditingController: _controller,
          googleAPIKey: GoogleConfigSimple.apiKey,
          inputDecoration: InputDecoration(
            labelText: widget.labelText ?? 'Dirección',
            hintText: widget.hintText ?? 'Escribe para buscar ubicación...',
            prefixIcon: Icon(
              widget.prefixIcon ?? Icons.location_on,
              color: AppColors.textSecondary,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _controller.clear();
                        _selectedLocation = null;
                      });
                    },
                  )
                : (_selectedLocation != null
                    ? Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                      )
                    : Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      )),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            labelStyle: TextStyle(color: AppColors.textSecondary),
            hintStyle: TextStyle(color: AppColors.textSecondary),
          ),
          textStyle: TextStyle(color: AppColors.textPrimary),
          debounceTime: 600,
          countries: const ["mx"],
          isLatLngRequired: true,
          getPlaceDetailWithLatLng: (Prediction prediction) async {
            print('🎯 Place selected: ${prediction.description}');
            print('📍 Coordinates: ${prediction.lat}, ${prediction.lng}');
            
            if (prediction.lat != null && prediction.lng != null) {
              try {
                final locationData = LocationData(
                  address: prediction.description ?? '',
                  latitude: double.parse(prediction.lat!),
                  longitude: double.parse(prediction.lng!),
                  placeId: prediction.placeId,
                  formattedAddress: prediction.description,
                );

                setState(() {
                  _selectedLocation = locationData;
                  _controller.text = prediction.description ?? '';
                });

                print('✅ Location created successfully: ${locationData.address}');
                widget.onLocationSelected(locationData);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Ubicación seleccionada: ${locationData.shortAddress}'),
                    backgroundColor: AppColors.success,
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                print('❌ Error creating location: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error al procesar la ubicación'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            } else {
              print('❌ Missing coordinates in prediction');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ No se encontraron coordenadas'),
                  backgroundColor: AppColors.warning,
                ),
              );
            }
          },
          itemClick: (Prediction prediction) {
            print('👆 Item tapped: ${prediction.description}');
            _controller.text = prediction.description ?? '';
          },
          seperatedBuilder: Divider(
            height: 1,
            color: AppColors.border.withOpacity(0.3),
          ),
          containerHorizontalPadding: 10,
          itemBuilder: (context, index, Prediction prediction) {
            print('🏗️ Building suggestion: ${prediction.description}');
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prediction.description ?? "",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (prediction.structuredFormatting?.secondaryText != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              prediction.structuredFormatting!.secondaryText!,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textTertiary,
                    size: 12,
                  ),
                ],
              ),
            );
          },
          isCrossBtnShown: true,
        ),
        if (widget.validator != null && _controller.text.isNotEmpty)
          Builder(
            builder: (context) {
              final error = widget.validator!(_controller.text);
              if (error != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    error,
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        if (_selectedLocation != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ubicación seleccionada correctamente',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String? validate() {
    if (widget.validator != null) {
      return widget.validator!(_controller.text);
    }
    return null;
  }

  LocationData? get selectedLocation => _selectedLocation;
  String get address => _controller.text;
}