import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/store_provider.dart';
import '../../models/store_model.dart';
import '../../models/user_model.dart';
import '../../models/operating_hours.dart';
import '../../models/location_model.dart';
import '../../widgets/common/location_picker_widget.dart';

class CreateStoreScreen extends ConsumerStatefulWidget {
  const CreateStoreScreen({super.key});

  @override
  ConsumerState<CreateStoreScreen> createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends ConsumerState<CreateStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  LocationData? _selectedLocation;
  bool _isLoading = false;

  @override
  void dispose() {
    _storeNameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createStore() async {
    if (!_formKey.currentState!.validate() || _selectedLocation == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(authNotifierProvider).user;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Create store object
      final store = Store(
        id: user.id,
        name: user.name,
        phone: user.phone,
        status: UserStatus.active,
        lastActive: DateTime.now(),
        photoUrl: user.photoUrl,
        storeName: _storeNameController.text.trim(),
        address: _selectedLocation!.address,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        category: _categoryController.text.trim(),
        rating: 0.0,
        reviewCount: 0,
        openingHours: OperatingHours.fromDayHours(
          monday: DayHours(isOpen: true, openTime: '09:00', closeTime: '21:00'),
          tuesday: DayHours(isOpen: true, openTime: '09:00', closeTime: '21:00'),
          wednesday: DayHours(isOpen: true, openTime: '09:00', closeTime: '21:00'),
          thursday: DayHours(isOpen: true, openTime: '09:00', closeTime: '21:00'),
          friday: DayHours(isOpen: true, openTime: '09:00', closeTime: '21:00'),
          saturday: DayHours(isOpen: true, openTime: '10:00', closeTime: '22:00'),
          sunday: DayHours(isOpen: false),
        ),
        isOpen: true,
        description: _descriptionController.text.isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        deliveryFee: 15.0,
        deliveryTime: 30,
        hasSpecialOffer: false,
      );

      // Save to Firestore through provider
      await ref.read(storeProvider.notifier).createStore(store);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Tienda creada exitosamente!',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Navigate to store dashboard
        context.go('/store');
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al crear la tienda: $e',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Crear Nueva Tienda',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header illustration
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.store,
                      size: 60,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Form title
                Text(
                  'Información de la Tienda',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Completa los datos para registrar tu negocio',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Store Name
                TextFormField(
                  controller: _storeNameController,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Nombre de la tienda',
                    hintText: 'Ej: Pizzería Don Mario',
                    prefixIcon: Icon(Icons.store, color: AppColors.textSecondary),
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
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.error),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es requerido';
                    }
                    if (value.length < 3) {
                      return 'El nombre debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category
                TextFormField(
                  controller: _categoryController,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    hintText: 'Ej: Mexicana, Italiana, Asiática',
                    prefixIcon: Icon(Icons.category, color: AppColors.textSecondary),
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
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.error),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La categoría es requerida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Location
                LocationPickerWidget(
                  labelText: 'Ubicación de la tienda',
                  hintText: 'Buscar dirección en Google Maps...',
                  prefixIcon: Icons.location_on,
                  onLocationSelected: (location) {
                    _selectedLocation = location;
                  },
                  validator: (value) {
                    if (_selectedLocation == null) {
                      return 'Debes seleccionar una ubicación';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Descripción (opcional)',
                    hintText: 'Describe tu tienda y lo que ofreces',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: Icon(Icons.description, color: AppColors.textSecondary),
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
                  ),
                ),
                const SizedBox(height: 32),

                // Info cards
                _buildInfoCard(
                  icon: Icons.access_time,
                  title: 'Horarios',
                  description: 'Podrás configurar los horarios de atención después',
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.restaurant_menu,
                  title: 'Menú',
                  description: 'Agrega productos y precios desde el panel de administración',
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.delivery_dining,
                  title: 'Entregas',
                  description: 'Configura zonas y costos de entrega más tarde',
                ),
                const SizedBox(height: 32),

                // Create button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createStore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.textOnPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Crear Tienda',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Cancel button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}