import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import '../../theme/app_theme.dart';
import '../../config/google_config_new.dart';
import '../../models/location_model.dart';

class LocationPickerWidgetNew extends StatefulWidget {
  final String? initialAddress;
  final Function(LocationData) onLocationSelected;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  const LocationPickerWidgetNew({
    super.key,
    this.initialAddress,
    required this.onLocationSelected,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.validator,
  });

  @override
  State<LocationPickerWidgetNew> createState() => _LocationPickerWidgetNewState();
}

class _LocationPickerWidgetNewState extends State<LocationPickerWidgetNew> {
  final TextEditingController _controller = TextEditingController();
  LocationData? _selectedLocation;

  @override
  void initState() {
    super.initState();
    print('🔧 LocationPickerWidgetNew initialized (NUEVA CONFIGURACIÓN)');
    
    try {
      final apiKey = GoogleConfigNew.apiKey;
      print('🔑 API Key (nueva): ${apiKey.substring(0, 10)}...');
      print('🌍 Production mode (nueva): ${GoogleConfigNew.isProduction}');
    } catch (e) {
      print('⚠️ Error cargando nueva configuración: $e');
    }
    
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
        // Información de configuración
        Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'NUEVA CONFIGURACIÓN GOOGLE MAPS',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                'Usando configuración desde cero para eliminar "En desarrollo"',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        
        GooglePlaceAutoCompleteTextField(
          textEditingController: _controller,
          googleAPIKey: GoogleConfigNew.apiKey,
          inputDecoration: InputDecoration(
            labelText: widget.labelText ?? 'Dirección (Nueva Config)',
            hintText: widget.hintText ?? 'Buscar ubicación con nueva API...',
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
              borderSide: BorderSide(color: Colors.blue, width: 2),
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
            print('🎯 [NUEVA CONFIG] Place selected: ${prediction.description}');
            print('📍 [NUEVA CONFIG] Coordinates: ${prediction.lat}, ${prediction.lng}');
            
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

                print('✅ [NUEVA CONFIG] Location created: ${locationData.address}');
                widget.onLocationSelected(locationData);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Nueva Config: ${locationData.shortAddress}'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                print('❌ [NUEVA CONFIG] Error: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error con nueva configuración'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          itemClick: (Prediction prediction) {
            print('👆 [NUEVA CONFIG] Item tapped: ${prediction.description}');
            _controller.text = prediction.description ?? '';
          },
          seperatedBuilder: Divider(
            height: 1,
            color: AppColors.border.withOpacity(0.3),
          ),
          containerHorizontalPadding: 10,
          itemBuilder: (context, index, Prediction prediction) {
            print('🏗️ [NUEVA CONFIG] Building suggestion: ${prediction.description}');
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.blue,
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
                        Text(
                          'Nueva configuración',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.new_releases,
                    color: Colors.blue,
                    size: 12,
                  ),
                ],
              ),
            );
          },
          isCrossBtnShown: true,
        ),
        
        if (_selectedLocation != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nueva Config - Ubicación OK',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      color: Colors.green,
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