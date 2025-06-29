import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  @override
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  Timer? _statusTimer;
  String? _orderId;
  Order? _currentOrder;

  List<Map<String, dynamic>> _getTrackingSteps(Order? order) {
    if (order == null) return [];
    
    final steps = [
      {
        'title': 'Pedido confirmado',
        'subtitle': 'Tu pedido ha sido recibido',
        'icon': Icons.check_circle,
        'time': _formatTime(order.orderTime),
        'isCompleted': true,
        'status': OrderStatus.pending,
      },
      {
        'title': 'Preparando tu pedido',
        'subtitle': 'La cocina está preparando tu comida',
        'icon': Icons.restaurant,
        'time': order.status.index >= 1 ? _formatTime(order.orderTime.add(Duration(minutes: 3))) : '',
        'isCompleted': order.status.index >= 1,
        'status': OrderStatus.preparing,
      },
      {
        'title': 'En camino',
        'subtitle': 'El repartidor va hacia tu ubicación',
        'icon': Icons.delivery_dining,
        'time': order.status.index >= 2 ? _formatTime(order.orderTime.add(Duration(minutes: 15))) : '',
        'isCompleted': order.status.index >= 2,
        'status': OrderStatus.outForDelivery,
      },
      {
        'title': 'Entregado',
        'subtitle': 'Tu pedido ha sido entregado',
        'icon': Icons.home,
        'time': order.status == OrderStatus.delivered && order.deliveryTime != null 
            ? _formatTime(order.deliveryTime!) 
            : '',
        'isCompleted': order.status == OrderStatus.delivered,
        'status': OrderStatus.delivered,
      },
    ];
    
    if (order.status == OrderStatus.cancelled) {
      steps.add({
        'title': 'Pedido cancelado',
        'subtitle': 'El pedido ha sido cancelado',
        'icon': Icons.cancel,
        'time': _formatTime(DateTime.now()),
        'isCompleted': true,
        'status': OrderStatus.cancelled,
      });
    }
    
    return steps;
  }
  
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Confirmado';
      case OrderStatus.preparing:
        return 'Preparando';
      case OrderStatus.outForDelivery:
        return 'En camino';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }
  
  int _getCurrentStep(Order? order) {
    if (order == null) return 0;
    switch (order.status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.preparing:
        return 1;
      case OrderStatus.outForDelivery:
        return 2;
      case OrderStatus.delivered:
        return 3;
      case OrderStatus.cancelled:
        return 4;
    }
  }

  // Datos del repartidor
  final Map<String, dynamic> _deliveryPerson = {
    'name': 'Carlos Mendoza',
    'phone': '+52 555 123 4567',
    'vehicle': 'Bicicleta Roja',
    'rating': 4.8,
    'estimatedArrival': '5-8 min',
    'currentLocation': 'A 2 cuadras de distancia',
  };

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupStatusTimer();
    
    // Obtener orderId de los argumentos de navegación
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        setState(() {
          _orderId = args;
        });
        _loadOrder();
      }
    });
  }
  
  void _loadOrder() async {
    if (_orderId == null) return;
    
    final orders = ref.read(ordersProvider);
    orders.whenData((ordersList) {
      final order = ordersList.firstWhere(
        (o) => o.id == _orderId,
        orElse: () => Order(
          id: _orderId!,
          customerId: 'unknown',
          storeId: 'unknown',
          items: [],
          totalAmount: 0,
          status: OrderStatus.pending,
          deliveryAddress: 'Dirección no disponible',
          orderTime: DateTime.now(),
        ),
      );
      setState(() {
        _currentOrder = order;
      });
    });
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );

    _pulseController.repeat(reverse: true);
    _progressController.forward();
  }

  void _setupStatusTimer() {
    // Timer para actualizar automáticamente el estado del pedido
    // Los datos reales vienen de Firestore, pero podemos simular cambios para demo
    _statusTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      // En una app real, esto sería controlado por el backend
      // Por ahora solo refrescamos los datos
      if (mounted) {
        ref.refresh(ordersProvider);
      }
    });
  }
  
  void _showCancelOrderDialog(Order order) {
    final ordersNotifier = ref.read(ordersProvider.notifier);
    final canCancel = ordersNotifier.canCancelOrder(order);
    
    if (!canCancel) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Este pedido ya no puede ser cancelado'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedReason = 'Cambié de opinión';
        final reasons = [
          'Cambié de opinión',
          'Tiempo de entrega muy largo',
          'Problemas con el pago',
          'Ordené por error',
          'Otro motivo',
        ];

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text(
                'Cancelar pedido',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Estás seguro de que quieres cancelar este pedido?',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Razón de cancelación:',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  ...reasons.map((reason) => RadioListTile<String>(
                    title: Text(
                      reason,
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    ),
                    value: reason,
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value!;
                      });
                    },
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  )),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Mantener pedido',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _cancelOrder(order.id, selectedReason);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: Text(
                    'Cancelar pedido',
                    style: TextStyle(color: AppColors.textOnPrimary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  Future<void> _cancelOrder(String orderId, String reason) async {
    try {
      final ordersNotifier = ref.read(ordersProvider.notifier);
      await ordersNotifier.cancelOrder(orderId, cancelReason: reason);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.textOnPrimary),
              SizedBox(width: 8),
              Text('Pedido cancelado exitosamente'),
            ],
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cancelar el pedido: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _statusTimer?.cancel();
    super.dispose();
  }

  void _showDeliveryConfirmation() {
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
                  '¡Pedido entregado!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 12),

                Text(
                  '¿Cómo estuvo tu experiencia?',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      onPressed: () {
                        // TODO: Guardar calificación
                      },
                      icon: Icon(
                        Icons.star,
                        color: AppColors.warning,
                        size: 32,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/customer');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Finalizar',
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer(
        builder: (context, ref, _) {
          final ordersAsync = ref.watch(ordersProvider);
          
          return ordersAsync.when(
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: AppColors.error, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Error al cargar el pedido',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            data: (orders) {
              // Always update the current order with the latest data from Firestore
              if (_orderId != null) {
                final order = orders.firstWhere(
                  (o) => o.id == _orderId,
                  orElse: () => Order(
                    id: _orderId!,
                    customerId: 'unknown',
                    storeId: 'unknown',
                    items: [],
                    totalAmount: 0,
                    status: OrderStatus.pending,
                    deliveryAddress: 'Dirección no disponible',
                    orderTime: DateTime.now(),
                  ),
                );
                // Update current order with latest data
                if (_currentOrder?.id == order.id && _currentOrder?.status != order.status) {
                  // Order status has changed, trigger UI rebuild
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _currentOrder = order;
                      });
                    }
                  });
                } else {
                  _currentOrder = order;
                }
              }
              
              if (_currentOrder == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, color: AppColors.textTertiary, size: 64),
                      SizedBox(height: 16),
                      Text(
                        'Pedido no encontrado',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No se pudo encontrar la información del pedido',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }
              
              final currentStep = _getCurrentStep(_currentOrder);
              final trackingSteps = _getTrackingSteps(_currentOrder);
              
              return SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderHeader(_currentOrder!),
                    SizedBox(height: 24),
                    _buildMapSection(currentStep),
                    SizedBox(height: 24),
                    _buildTrackingTimeline(trackingSteps, currentStep),
                    SizedBox(height: 24),
                    if (currentStep == 2) _buildDeliveryPersonInfo(),
                    if (currentStep == 2) SizedBox(height: 24),
                    _buildOrderSummary(_currentOrder!),
                    SizedBox(height: 24),
                    _buildContactButtons(_currentOrder!),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.go('/customer'),
        icon: Icon(Icons.arrow_back, color: AppColors.textSecondary),
      ),
      title: Text(
        'Rastrear pedido',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        // Mostrar botón cancelar solo si el pedido puede ser cancelado
        if (_currentOrder != null)
          Consumer(
            builder: (context, ref, _) {
              final ordersNotifier = ref.read(ordersProvider.notifier);
              final canCancel = ordersNotifier.canCancelOrder(_currentOrder!);
              
              if (!canCancel) return SizedBox.shrink();
              
              return IconButton(
                onPressed: () => _showCancelOrderDialog(_currentOrder!),
                icon: Icon(Icons.cancel, color: AppColors.error),
                tooltip: 'Cancelar pedido',
              );
            },
          ),
        IconButton(
          onPressed: () {
            // TODO: Compartir estado del pedido
          },
          icon: Icon(Icons.share, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildOrderHeader(Order order) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pedido #${order.id.substring(order.id.length - 8)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Total: \$${order.totalAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textOnPrimary.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(order.status),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
              Text(
                'Tiempo estimado: ${_deliveryPerson['estimatedArrival']}',
                style: TextStyle(fontSize: 14, color: AppColors.textOnPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(int currentStep) {
    // Obtener ubicación del repartidor desde la orden actual
    final delivererLat = _currentOrder?.delivererLatitude;
    final delivererLng = _currentOrder?.delivererLongitude;
    final lastUpdate = _currentOrder?.lastLocationUpdate;
    
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Mapa real con ubicación del repartidor
            if (delivererLat != null && delivererLng != null && currentStep >= 2)
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(delivererLat, delivererLng),
                  zoom: 15.0,
                ),
                markers: {
                  // Marcador del repartidor
                  Marker(
                    markerId: MarkerId('deliverer'),
                    position: LatLng(delivererLat, delivererLng),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                    infoWindow: InfoWindow(
                      title: 'Tu repartidor',
                      snippet: 'Ubicación actual',
                    ),
                  ),
                  // Marcador de destino (dirección del cliente)
                  Marker(
                    markerId: MarkerId('destination'),
                    position: LatLng(25.6866, -100.3161), // Coordenadas de ejemplo
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                    infoWindow: InfoWindow(
                      title: 'Tu ubicación',
                      snippet: _currentOrder?.deliveryAddress ?? 'Dirección de entrega',
                    ),
                  ),
                },
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              )
            else
              // Mapa de placeholder cuando no hay ubicación del repartidor
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.surfaceVariant, AppColors.surface],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      currentStep < 2 ? Icons.restaurant : Icons.map,
                      size: 48,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(height: 12),
                    Text(
                      currentStep < 2 
                          ? 'Preparando tu pedido'
                          : 'Esperando ubicación del repartidor',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

            // Información superpuesta
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: AppColors.primary, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getLocationText(currentStep, delivererLat, delivererLng),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (lastUpdate != null && currentStep >= 2) ...[
                      SizedBox(height: 4),
                      Text(
                        'Última actualización: ${_formatLastUpdate(lastUpdate)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
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

  String _getLocationText(int currentStep, double? lat, double? lng) {
    if (currentStep < 2) {
      return 'Preparando en la cocina';
    } else if (lat != null && lng != null) {
      return 'Repartidor en camino - Ubicación en tiempo real';
    } else {
      return 'Esperando ubicación del repartidor...';
    }
  }

  String _formatLastUpdate(DateTime lastUpdate) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    
    if (difference.inMinutes < 1) {
      return 'Hace ${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else {
      return 'Hace ${difference.inHours}h';
    }
  }

  Widget _buildTrackingTimeline(List<Map<String, dynamic>> trackingSteps, int currentStep) {
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
            'Estado del pedido',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 20),

          ...trackingSteps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isActive = index == currentStep;
            final isCompleted = step['isCompleted'];
            final isLast = index == trackingSteps.length - 1;

            return IntrinsicHeight(
              child: Row(
                children: [
                  // Timeline indicator
                  Column(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isCompleted || isActive
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                          shape: BoxShape.circle,
                          border: isActive && !isCompleted
                              ? Border.all(color: AppColors.primary, width: 3)
                              : null,
                        ),
                        child: Icon(
                          step['icon'],
                          color: isCompleted || isActive
                              ? AppColors.textOnPrimary
                              : AppColors.textTertiary,
                          size: 20,
                        ),
                      ),

                      if (!isLast)
                        Container(
                          width: 2,
                          height: 40,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          color: isCompleted
                              ? AppColors.primary
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                step['title'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isCompleted || isActive
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              if (step['time'].isNotEmpty)
                                Text(
                                  step['time'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
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
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'En progreso...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDeliveryPersonInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryWithOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.delivery_dining, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Tu repartidor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary,
                child: Icon(
                  Icons.person,
                  color: AppColors.textOnPrimary,
                  size: 30,
                ),
              ),

              SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _deliveryPerson['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(Icons.star, color: AppColors.warning, size: 14),
                        SizedBox(width: 4),
                        Text(
                          '${_deliveryPerson['rating']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          _deliveryPerson['vehicle'],
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () {
                  // TODO: Llamar al repartidor
                },
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone,
                    color: AppColors.textOnPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(Order order) {
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
            'Resumen del pedido',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 16),

          ...order.items
              .map(
                (item) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                        '\$${item.total.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),

          Divider(color: AppColors.border, height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '\$${order.totalAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButtons(Order order) {
    return Consumer(
      builder: (context, ref, _) {
        final ordersNotifier = ref.read(ordersProvider.notifier);
        final canCancel = ordersNotifier.canCancelOrder(order);
        
        if (canCancel) {
          // Mostrar botón de cancelar si es posible
          return Column(
            children: [
              // Botón de cancelar pedido
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelOrderDialog(order),
                  icon: Icon(Icons.cancel, color: AppColors.error),
                  label: Text(
                    'Cancelar pedido',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.error, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 12),
              
              // Botones de contacto
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Contactar tienda
                      },
                      icon: Icon(Icons.store, color: AppColors.primary),
                      label: Text(
                        'Contactar tienda',
                        style: TextStyle(color: AppColors.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Ayuda/soporte
                      },
                      icon: Icon(Icons.help_outline, color: AppColors.textOnPrimary),
                      label: Text(
                        'Ayuda',
                        style: TextStyle(color: AppColors.textOnPrimary),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          // Solo mostrar botones de contacto si no se puede cancelar
          return Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Contactar tienda
                  },
                  icon: Icon(Icons.store, color: AppColors.primary),
                  label: Text(
                    'Contactar tienda',
                    style: TextStyle(color: AppColors.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 12),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Ayuda/soporte
                  },
                  icon: Icon(Icons.help_outline, color: AppColors.textOnPrimary),
                  label: Text(
                    'Ayuda',
                    style: TextStyle(color: AppColors.textOnPrimary),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

// Custom painter para simular un mapa
class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;

    // Dibujar líneas de "calles"
    for (int i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (int i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Dibujar "ruta"
    final routePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.3);
    path.lineTo(size.width * 0.5, size.height * 0.3);
    path.lineTo(size.width * 0.5, size.height * 0.6);
    path.lineTo(size.width * 0.75, size.height * 0.6);
    path.lineTo(size.width * 0.75, size.height * 0.8);

    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
