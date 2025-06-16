import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:google_places_flutter/model/place_details.dart';
import '../../theme/app_theme.dart';
import '../../config/google_config.dart';

class LocationData {
  final String address;
  final double latitude;
  final double longitude;
  final String? placeId;

  LocationData({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.placeId,
  });
}

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
    if (widget.initialAddress != null) {
      _controller.text = widget.initialAddress!;
    }
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
        GooglePlaceAutoCompleteTextField(
          textEditingController: _controller,
          googleAPIKey: GoogleConfig.apiKey,
          inputDecoration: InputDecoration(
            labelText: widget.labelText ?? 'Dirección',
            hintText: widget.hintText ?? 'Buscar ubicación...',
            prefixIcon: Icon(
              widget.prefixIcon ?? Icons.location_on,
              color: AppColors.textSecondary,
            ),
            suffixIcon: _selectedLocation != null
                ? Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                  )
                : Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
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
          debounceTime: 800,
          countries: const ["mx"], // Restrict to Mexico
          isLatLngRequired: true,
          getPlaceDetailWithLatLng: (Prediction prediction) async {
            // Handle place selection
            if (prediction.lat != null && prediction.lng != null) {
              final locationData = LocationData(
                address: prediction.description ?? '',
                latitude: double.parse(prediction.lat!),
                longitude: double.parse(prediction.lng!),
                placeId: prediction.placeId,
              );

              setState(() {
                _selectedLocation = locationData;
                _controller.text = prediction.description ?? '';
              });

              widget.onLocationSelected(locationData);
            }
          },
          itemClick: (Prediction prediction) {
            _controller.text = prediction.description ?? '';
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description?.length ?? 0),
            );
          },
          seperatedBuilder: const Divider(),
          containerHorizontalPadding: 10,
          itemBuilder: (context, index, Prediction prediction) {
            return Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      prediction.description ?? "",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
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