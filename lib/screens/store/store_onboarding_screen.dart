import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/store_provider.dart';
import '../../models/store_model.dart';
import '../../models/user_model.dart';
import '../../models/operating_hours.dart';

class StoreOnboardingScreen extends ConsumerStatefulWidget {
  const StoreOnboardingScreen({super.key});

  @override
  ConsumerState<StoreOnboardingScreen> createState() => _StoreOnboardingScreenState();
}

class _StoreOnboardingScreenState extends ConsumerState<StoreOnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildHeader(),
            ),
            
            // Main content with scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            const SizedBox(height: 32),
                            _buildWelcomeMessage(user?.name ?? 'Usuario'),
                            const SizedBox(height: 40),
                            _buildOptionCards(),
                            const SizedBox(height: 40), // Bottom padding
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.go('/customer'),
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          'Configuración de Tienda',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeMessage(String userName) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Icon(
            Icons.store,
            size: 50,
            color: AppColors.textOnPrimary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '¡Bienvenido,\n$userName!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Para comenzar como tienda,\nnecesitas configurar tu negocio',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOptionCards() {
    return Column(
      children: [
        _buildOptionCard(
          icon: Icons.add_business,
          title: 'Crear Nueva Tienda',
          description: 'Configura tu propia tienda desde cero',
          color: AppColors.primary,
          onTap: () => _showCreateStoreDialog(),
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          icon: Icons.group_add,
          title: 'Unirse a Tienda Existente',
          description: 'Únete a una tienda ya registrada con un código',
          color: AppColors.secondary,
          onTap: () => _showJoinStoreDialog(),
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateStoreDialog() {
    final _storeNameController = TextEditingController();
    final _addressController = TextEditingController();
    final _categoryController = TextEditingController();
    final _descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.add_business, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              'Crear Nueva Tienda',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  controller: _storeNameController,
                  label: 'Nombre de la tienda',
                  icon: Icons.store,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _categoryController,
                  label: 'Categoría (ej: Mexicana, Italiana)',
                  icon: Icons.category,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La categoría es requerida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: 'Dirección',
                  icon: Icons.location_on,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La dirección es requerida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Descripción (opcional)',
                  icon: Icons.description,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                await _createStore(
                  storeName: _storeNameController.text,
                  category: _categoryController.text,
                  address: _addressController.text,
                  description: _descriptionController.text.isEmpty 
                      ? null 
                      : _descriptionController.text,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: const Text('Crear Tienda'),
          ),
        ],
      ),
    );
  }

  void _showJoinStoreDialog() {
    final _codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.group_add, color: AppColors.secondary),
            const SizedBox(width: 12),
            Text(
              'Unirse a Tienda',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ingresa el código de invitación que te proporcionó el dueño de la tienda',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _codeController,
              label: 'Código de invitación',
              icon: Icons.key,
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_codeController.text.isNotEmpty) {
                Navigator.pop(context);
                await _joinStore(_codeController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.textOnSecondary,
            ),
            child: const Text('Unirse'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.words,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
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
    );
  }

  Future<void> _createStore({
    required String storeName,
    required String category,
    required String address,
    String? description,
  }) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          content: Row(
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(width: 20),
              Text(
                'Creando tienda...',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      );

      final user = ref.read(authNotifierProvider).user;
      if (user == null) return;

      // Create store object
      final store = Store(
        id: user.id,
        name: user.name,
        phone: user.phone,
        status: UserStatus.active,
        lastActive: DateTime.now(),
        photoUrl: user.photoUrl,
        storeName: storeName,
        address: address,
        category: category,
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
        description: description,
        deliveryFee: 15.0,
        deliveryTime: 30,
        hasSpecialOffer: false,
      );

      // Save to Firestore through provider
      await ref.read(storeProvider.notifier).createStore(store);

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
        
        // Show success and navigate
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
        Navigator.pop(context); // Close loading
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
    }
  }

  Future<void> _joinStore(String invitationCode) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          content: Row(
            children: [
              CircularProgressIndicator(color: AppColors.secondary),
              const SizedBox(width: 20),
              Text(
                'Verificando código...',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      );

      // TODO: Implement join store logic with Firestore
      // For now, simulate the process
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        Navigator.pop(context); // Close loading
        
        // Show result (for now, show that feature is coming soon)
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Row(
              children: [
                Icon(Icons.construction, color: AppColors.warning),
                const SizedBox(width: 12),
                Text(
                  'Función en desarrollo',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
            content: Text(
              'La función de unirse a tiendas existentes estará disponible pronto. Por ahora, puedes crear tu propia tienda.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Entendido',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al verificar el código: $e',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}