// screens/deliverer/delivery_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order_model.dart';
import '../../services/location_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../widgets/delivery_map_widget.dart';

class DeliveryDetailsScreen extends ConsumerStatefulWidget {
  @override
  _DeliveryDetailsScreenState createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends ConsumerState<DeliveryDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _statusController;
  late AnimationController _pulseController;
  late Animation<double> _statusAnimation;
  late Animation<double> _pulseAnimation;

  Timer? _updateTimer;
  Order? _order;
  String? _orderId;
  
  // Location tracking
  final LocationService _locationService = LocationService();
  Position? _currentLocation;
  StreamSubscription<Position>? _locationSubscription;

  Map<OrderStatus, Map<String, dynamic>> get _statusSteps => {
    OrderStatus.pending: {
      'title': 'Pedido Aceptado',
      'subtitle': 'Dirígete a recoger el pedido',
      'icon': Icons.check_circle,
      'color': AppColors.primary,
    },
    OrderStatus.preparing: {
      'title': 'Pedido Recogido',
      'subtitle': 'En camino al cliente',
      'icon': Icons.shopping_bag,
      'color': AppColors.warning,
    },
    OrderStatus.outForDelivery: {
      'title': 'En Entrega',
      'subtitle': 'Cerca del destino',
      'icon': Icons.delivery_dining,
      'color': AppColors.secondary,
    },
    OrderStatus.delivered: {
      'title': 'Entregado',
      'subtitle': 'Entrega completada',
      'icon': Icons.done_all,
      'color': AppColors.success,
    },
  };

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupUpdateTimer();
    _initializeLocation();
    
    // Obtener el pedido desde los argumentos de navegación
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get order from GoRouter state - for now using first available active order
      final ordersAsyncValue = ref.read(ordersProvider);
      ordersAsyncValue.whenData((orders) {
        final authState = ref.read(authNotifierProvider);
        final currentUserId = authState.user?.id;
        
        // Find first active delivery for this deliverer
        final activeOrder = orders.firstWhere(
          (order) => order.delivererId == currentUserId && 
                     (order.status == OrderStatus.preparing || 
                      order.status == OrderStatus.outForDelivery),
          orElse: () => orders.isNotEmpty ? orders.first : Order(
            id: 'demo-order',
            customerId: '',
            storeId: '',
            items: [],
            totalAmount: 0,
            status: OrderStatus.preparing,
            deliveryAddress: '',
            orderTime: DateTime.now(),
          ),
        );
        
        setState(() {
          _order = activeOrder;
          _orderId = activeOrder.id;
        });
      });
    });
  }

  void _setupAnimations() {
    _statusController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _statusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _statusController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _statusController.forward();
    if (_order?.status != OrderStatus.delivered) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _setupUpdateTimer() {
    _updateTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted && _order?.status != OrderStatus.delivered) {
        setState(() {
          // Actualizar datos del pedido
        });
      }
    });
  }

  void _initializeLocation() async {
    try {
      final hasPermission = await _locationService.requestLocationPermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permisos de ubicación requeridos para tracking'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      // Obtener ubicación inicial
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentLocation = position;
        });
      }

      // Iniciar tracking en tiempo real
      _locationSubscription = _locationService.getLocationStream().listen(
        (Position position) {
          setState(() {
            _currentLocation = position;
          });
          
          // Actualizar ubicación en Firestore si hay un pedido activo
          if (_orderId != null && _order?.status != OrderStatus.delivered) {
            _updateLocationInFirestore(position.latitude, position.longitude);
          }
        },
        onError: (error) {
          print('Error in location stream: $error');
        },
      );
    } catch (e) {
      print('Error initializing location: $e');
    }
  }

  void _updateStatus(OrderStatus newStatus) async {
    if (_order == null) return;
    
    try {
      await ref.read(ordersProvider.notifier).updateOrderStatus(_order!.id, newStatus);
      
      _statusController.reset();
      _statusController.forward();

      if (newStatus == OrderStatus.delivered) {
        _pulseController.stop();
        _showDeliveryCompleteDialog();
      } else {
        _pulseController.repeat(reverse: true);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado actualizado: ${_getStatusTitle(newStatus)}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar estado: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _updateLocationInFirestore(double latitude, double longitude) async {
    if (_orderId == null) return;
    
    try {
      await ref.read(ordersProvider.notifier).updateDelivererLocation(
        _orderId!,
        latitude,
        longitude,
      );
    } catch (e) {
      print('Error updating location in Firestore: $e');
    }
  }

  String _getStatusTitle(OrderStatus status) {
    return _statusSteps[status]?['title'] ?? 'Estado desconocido';
  }

  void _showDeliveryCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: AppColors.textOnPrimary,
                    size: 40,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  '¡Entrega Completada!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Has completado exitosamente la entrega del pedido ${_order?.id ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Cerrar dialog
                      context.go('/deliverer'); // Volver al dashboard
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Volver al Dashboard',
                      style: TextStyle(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _statusController.dispose();
    _pulseController.dispose();
    _updateTimer?.cancel();
    _locationSubscription?.cancel();
    _locationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios en las órdenes
    if (_orderId != null) {
      final ordersAsyncValue = ref.watch(ordersProvider);
      
      return ordersAsyncValue.when(
        data: (orders) {
          _order = orders.firstWhere(
            (order) => order.id == _orderId,
            orElse: () => _order ?? Order(
              id: _orderId!,
              customerId: '',
              storeId: '',
              items: [],
              totalAmount: 0,
              status: OrderStatus.pending,
              deliveryAddress: '',
              orderTime: DateTime.now(),
            ),
          );
          
          return _buildScaffold();
        },
        loading: () => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            title: Text('Cargando...'),
          ),
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
        error: (error, stack) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            title: Text('Error'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: AppColors.error),
                SizedBox(height: 16),
                Text('Error al cargar el pedido: $error'),
              ],
            ),
          ),
        ),
      );
    }
    
    return _buildScaffold();
  }
  
  Widget _buildScaffold() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(),
            SizedBox(height: 24),
            _buildStatusTimeline(),
            SizedBox(height: 24),
            _buildLocationInfo(),
            SizedBox(height: 24),
            _buildMapPreview(),
            SizedBox(height: 24),
            _buildCustomerInfo(),
            SizedBox(height: 24),
            _buildOrderSummary(),
            if (_hasSpecialNotes()) ...[
              SizedBox(height: 24),
              _buildSpecialNotes(),
            ],
            SizedBox(height: 24),
            _buildActionButtons(),
            SizedBox(height: 100), // Espacio extra para el botón fijo
          ],
        ),
      ),
      bottomNavigationBar: _buildMainActionButton(),
    );
  }
  
  bool _hasSpecialNotes() {
    return _order?.specialInstructions?.isNotEmpty == true;
  }
  
  String _getEstimatedTime() {
    if (_currentLocation == null) return '8-12 min';
    
    // Simulación de cálculo de tiempo estimado
    final distance = _getDistanceToDestination();
    if (distance != null) {
      final minutes = (distance / 50).ceil(); // Aprox 50m por minuto caminando
      return '${minutes}-${minutes + 2} min';
    }
    return '8-12 min';
  }
  
  String _getDistance() {
    final distance = _getDistanceToDestination();
    if (distance != null) {
      if (distance >= 1000) {
        return '${(distance / 1000).toStringAsFixed(1)}km';
      } else {
        return '${distance.toInt()}m';
      }
    }
    return '320m';
  }

  double? _getDistanceToDestination() {
    if (_currentLocation == null) return null;
    
    // Coordenadas de ejemplo para el destino (en una app real vendrían del pedido)
    const double destLat = 25.6866; // Ejemplo: Monterrey, México
    const double destLng = -100.3161;
    
    return _locationService.calculateDistance(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      destLat,
      destLng,
    );
  }
  
  String _getStoreLocation() {
    return _order?.displayStoreAddress ?? 'Ubicación de tienda';
  }
  
  String _getCustomerPhone() {
    return _order?.customerPhone ?? '+52 555 987 6543';
  }
  
  String _getStorePhone() {
    // En una app real, esto vendría del modelo de la tienda
    return '+52 555 123 4567';
  }
  
  String _getPaymentMethod() {
    final method = _order?.paymentMethod ?? 'Tarjeta';
    return '$method (Pagado)';
  }
  
  String _getCustomerName() {
    return _order?.customerName ?? 'Cliente';
  }
  
  String _getStoreName() {
    return _order?.storeName ?? 'Tienda';
  }
  
  bool _getIsPriority() {
    return _order?.isPriority ?? false;
  }
  
  Future<void> _makePhoneCall(String phoneNumber) async {
    // Solicitar permisos de teléfono
    final phonePermission = await Permission.phone.request();
    
    if (phonePermission.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permisos de teléfono requeridos'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se puede hacer la llamada'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al hacer la llamada: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    // Remover caracteres especiales del número
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // URL de WhatsApp con mensaje predefinido
    final whatsappUrl = Uri.parse(
      'https://wa.me/$cleanNumber?text=Hola, soy tu repartidor de UberEats. Estoy en camino con tu pedido ${_order?.id ?? ''}.'
    );
    
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se puede abrir WhatsApp'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir WhatsApp'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _openWhatsAppStore(String phoneNumber) async {
    // Remover caracteres especiales del número
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // URL de WhatsApp con mensaje predefinido para la tienda
    final whatsappUrl = Uri.parse(
      'https://wa.me/$cleanNumber?text=Hola, soy el repartidor asignado al pedido ${_order?.id ?? ''}. Estoy en camino a recoger el pedido.'
    );
    
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se puede abrir WhatsApp'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir WhatsApp'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.go('/deliverer'),
        icon: Icon(Icons.arrow_back, color: AppColors.textSecondary),
      ),
      title: Text(
        'Detalles de Entrega',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            _showFullScreenMap();
          },
          icon: Icon(Icons.map, color: AppColors.textSecondary),
          tooltip: 'Ver en mapa',
        ),
      ],
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryWithOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.delivery_dining,
                  color: AppColors.textOnPrimary,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _order?.id ?? 'N/A',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    Text(
                      _getCustomerName(),
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textOnPrimary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              if (_getIsPriority())
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'URGENTE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time, color: AppColors.textOnPrimary, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tiempo estimado: ${_getEstimatedTime()}',
                  style: TextStyle(fontSize: 14, color: AppColors.textOnPrimary),
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.directions_walk,
                color: AppColors.textOnPrimary,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                _getDistance(),
                style: TextStyle(fontSize: 14, color: AppColors.textOnPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado de la Entrega',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 20),
          ..._statusSteps.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final statusEntry = entry.value;
            final status = statusEntry.key;
            final step = statusEntry.value;
            final isActive = status == _order?.status;
            final isCompleted = _getStepIndex(_order?.status) > index;
            final isLast = index == _statusSteps.length - 1;

            return AnimatedBuilder(
              animation: _statusAnimation,
              builder: (context, child) {
                return IntrinsicHeight(
                  child: Row(
                    children: [
                      // Timeline indicator
                      Column(
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: (isCompleted || isActive)
                                  ? step['color']
                                  : AppColors.surfaceVariant,
                              shape: BoxShape.circle,
                              border: isActive && !isCompleted
                                  ? Border.all(color: step['color'], width: 3)
                                  : null,
                            ),
                            child: Transform.scale(
                              scale: isActive ? _statusAnimation.value : 1.0,
                              child: Icon(
                                step['icon'],
                                color: (isCompleted || isActive)
                                    ? AppColors.textOnPrimary
                                    : AppColors.textTertiary,
                                size: 20,
                              ),
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 40,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              color: isCompleted
                                  ? step['color']
                                  : AppColors.border,
                            ),
                        ],
                      ),
                      SizedBox(width: 16),
                      // Step content
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step['title'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: (isCompleted || isActive)
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                step['subtitle'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (isActive && !isCompleted)
                                Container(
                                  margin: EdgeInsets.only(top: 8),
                                  child: AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _pulseAnimation.value,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 12,
                                              height: 12,
                                              child: CircularProgressIndicator(
                                                color: step['color'],
                                                strokeWidth: 2,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'En progreso...',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: step['color'],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  int _getStepIndex(OrderStatus? status) {
    if (status == null) return -1;
    return _statusSteps.keys.toList().indexOf(status);
  }

  Widget _buildLocationInfo() {
    return Column(
      children: [
        // Ubicación de recogida
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.store,
                      color: AppColors.warning,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recoger en:',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _getStoreName(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          _getStoreLocation(),
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _makePhoneCall(_getStorePhone());
                        },
                        icon: Icon(Icons.phone, color: AppColors.warning),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.warning.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        tooltip: 'Llamar tienda',
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          _openWhatsAppStore(_getStorePhone());
                        },
                        icon: Icon(Icons.chat, color: AppColors.success),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.success.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        tooltip: 'WhatsApp tienda',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Ubicación de entrega
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary, width: 1),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Entregar en:',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _order?.deliveryAddress ?? 'Dirección no disponible',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (_order?.specialInstructions?.isNotEmpty == true) ...[
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _order!.specialInstructions!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _showFullScreenMap();
                    },
                    icon: Icon(Icons.map, color: AppColors.primary),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    tooltip: 'Ver en mapa',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información del Cliente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.secondary,
                child: Icon(
                  Icons.person,
                  color: AppColors.textOnSecondary,
                  size: 25,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCustomerName(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _getCustomerPhone(),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _makePhoneCall(_getCustomerPhone());
                    },
                    icon: Icon(Icons.phone, color: AppColors.primary),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    tooltip: 'Llamar',
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      _openWhatsApp(_getCustomerPhone());
                    },
                    icon: Icon(Icons.chat, color: AppColors.success),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.success.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    tooltip: 'WhatsApp',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen del Pedido',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          ...(_order?.items ?? []).map((item) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.fastfood,
                      color: AppColors.textOnPrimary,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${item.quantity}x ${item.productName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '\$${(item.priceAtPurchase * item.quantity).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          Divider(color: AppColors.border, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '\$${_order?.totalAmount.toStringAsFixed(0) ?? '0'}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            _getPaymentMethod(),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialNotes() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.priority_high, color: AppColors.warning, size: 20),
              SizedBox(width: 8),
              Text(
                'Nota Especial',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            _order?.specialInstructions ?? '',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Reportar problema
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Función de reportar problema próximamente'),
                ),
              );
            },
            icon: Icon(Icons.report_problem, size: 16),
            label: Text('Reportar Problema'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Necesitar ayuda
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Centro de ayuda próximamente')),
              );
            },
            icon: Icon(Icons.help_outline, size: 16),
            label: Text('Ayuda'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainActionButton() {
    String buttonText;
    VoidCallback? onPressed;

    switch (_order?.status) {
      case OrderStatus.pending:
        buttonText = 'Marcar como Recogido';
        onPressed = () => _updateStatus(OrderStatus.preparing);
        break;
      case OrderStatus.preparing:
        buttonText = 'Iniciar Entrega';
        onPressed = () => _updateStatus(OrderStatus.outForDelivery);
        break;
      case OrderStatus.outForDelivery:
        buttonText = 'Marcar como Entregado';
        onPressed = () => _updateStatus(OrderStatus.delivered);
        break;
      case OrderStatus.delivered:
        buttonText = 'Entrega Completada';
        onPressed = null;
        break;
      default:
        buttonText = 'Continuar';
        onPressed = null;
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.darkWithOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(
            _order?.status == OrderStatus.delivered ? Icons.check : Icons.arrow_forward,
            color: AppColors.textOnPrimary,
          ),
          label: Text(
            buttonText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textOnPrimary,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _order?.status == OrderStatus.delivered
                ? AppColors.success
                : AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.map, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Ruta de entrega',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: _showFullScreenMap,
                  child: Text(
                    'Ver completo',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          DeliveryMapWidget(
            storeLocation: _order?.storeLocation,
            deliveryLocation: _order?.deliveryLocation,
            delivererLatitude: _currentLocation?.latitude ?? _order?.delivererLatitude,
            delivererLongitude: _currentLocation?.longitude ?? _order?.delivererLongitude,
            height: 200,
          ),
        ],
      ),
    );
  }

  void _showFullScreenMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Ruta de entrega'),
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.textSecondary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: DeliveryMapWidget(
            storeLocation: _order?.storeLocation,
            deliveryLocation: _order?.deliveryLocation,
            delivererLatitude: _currentLocation?.latitude ?? _order?.delivererLatitude,
            delivererLongitude: _currentLocation?.longitude ?? _order?.delivererLongitude,
            height: MediaQuery.of(context).size.height,
          ),
        ),
      ),
    );
  }
}
