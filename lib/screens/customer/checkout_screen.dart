import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/cart_item_model.dart';
import '../../models/order_model.dart';
import '../../models/order_item_model.dart';
import '../../models/location_model.dart';
import '../../widgets/customer/address_selector_widget.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  LocationData? _selectedLocation;
  int _selectedPaymentIndex = 0;
  final _instructionsController = TextEditingController();
  bool _isProcessing = false;
  bool _shareLocationEnabled = false;

  @override
  void initState() {
    super.initState();
    // Set default location
    _selectedLocation = LocationData(
      address: 'Dormitorio Estudiantil, Edificio A, Cuarto 205',
      latitude: 25.6866,
      longitude: -100.3161,
      formattedAddress: 'Edificio A, Cuarto 205, Ciudad Universitaria',
    );
  }

  String _getEstimatedDeliveryTime() {
    if (_selectedLocation == null) return '15-20 min';
    
    // Calculate estimated delivery time based on distance
    // Using default store location for calculation
    final storeLocation = LocationData(
      address: 'Tienda',
      latitude: 25.6876,
      longitude: -100.3171,
    );
    
    final distance = storeLocation.distanceTo(_selectedLocation!);
    final minutes = ((distance / 100).ceil() + 10).clamp(8, 45);
    
    return '${minutes}-${minutes + 5} min';
  }

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'card1',
      'type': 'card',
      'title': 'Tarjeta de Débito',
      'subtitle': '**** **** **** 1234',
      'icon': Icons.credit_card,
      'isDefault': true,
    },
    {
      'id': 'cash',
      'type': 'cash',
      'title': 'Efectivo',
      'subtitle': 'Pago contra entrega',
      'icon': Icons.payments,
      'isDefault': false,
    },
    {
      'id': 'digital',
      'type': 'digital',
      'title': 'Pago Digital',
      'subtitle': 'SPEI, transferencia bancaria',
      'icon': Icons.account_balance,
      'isDefault': false,
    },
  ];

  // Los cálculos ahora usan el carrito real
  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Populares':
        return Icons.local_fire_department;
      case 'Tacos':
        return Icons.lunch_dining;
      case 'Quesadillas':
        return Icons.local_dining;
      case 'Bebidas':
        return Icons.local_drink;
      default:
        return Icons.restaurant_menu;
    }
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  // Nuevos métodos para manejar GPS
  void _enableLocationSharing() async {
    // Simular solicitud de permisos de ubicación
    await Future.delayed(Duration(milliseconds: 500));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.gps_fixed, color: AppColors.textOnPrimary),
            SizedBox(width: 8),
            Expanded(
              child: Text('GPS activado - El repartidor podrá ubicarte'),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _disableLocationSharing() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.gps_off, color: AppColors.textOnPrimary),
            SizedBox(width: 8),
            Expanded(child: Text('GPS desactivado')),
          ],
        ),
        backgroundColor: AppColors.textSecondary,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _processOrder() async {
    final cart = ref.read(cartProvider);
    final authState = ref.read(authNotifierProvider);
    final ordersNotifier = ref.read(ordersProvider.notifier);
    
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El carrito está vacío'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Validate selected location
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor selecciona una dirección de entrega'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Crear la orden
      final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';
      
      // Convertir CartItems a OrderItems
      final orderItems = cart.items.map((cartItem) => cartItem.toOrderItem()).toList();
      
      // Create store location data (for now using a default - in real app would come from store data)
      final storeLocation = LocationData(
        address: cart.store?.address ?? 'Ubicación de tienda',
        latitude: 25.6876, // Default store coordinates
        longitude: -100.3171,
        formattedAddress: cart.store?.address ?? 'Ubicación de tienda',
      );
      
      final order = Order(
        id: orderId,
        customerId: authState.user?.id ?? 'guest_user',
        customerName: authState.user?.name ?? 'Cliente',
        storeId: cart.storeId ?? '',
        storeName: cart.store?.name ?? 'Tienda',
        storeLocation: storeLocation,
        items: orderItems,
        totalAmount: cart.total,
        status: OrderStatus.pending,
        deliveryLocation: _selectedLocation,
        deliveryAddress: _selectedLocation!.displayAddress, // Legacy field for backward compatibility
        orderTime: DateTime.now(),
        specialInstructions: _instructionsController.text.isNotEmpty ? _instructionsController.text : null,
        isPriority: false, // TODO: Add priority logic based on delivery time or customer tier
        paymentMethod: _paymentMethods[_selectedPaymentIndex]['name'] as String?,
        customerPhone: authState.user?.phone,
      );

      // Guardar la orden en Firestore
      await ordersNotifier.addOrder(order);
      
      // Limpiar el carrito
      final cartNotifier = ref.read(cartProvider.notifier);
      cartNotifier.clearCart();

      setState(() {
        _isProcessing = false;
      });

      // Mostrar éxito y navegar
      _showOrderConfirmation(orderId);
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar el pedido: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showOrderConfirmation(String orderId) {
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
                  '¡Pedido confirmado!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 12),

                Text(
                  'Tu pedido #${orderId.substring(orderId.length - 8)} ha sido enviado a la cocina.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8),

                Text(
                  'Tiempo estimado: 15-25 min',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/customer/tracking/$orderId');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Rastrear pedido',
                      style: TextStyle(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 8),

                TextButton(
                  onPressed: () {
                    context.go('/customer');
                  },
                  child: Text(
                    'Volver al inicio',
                    style: TextStyle(color: AppColors.textSecondary),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeliveryAddressSection(),
            SizedBox(height: 24),
            _buildLocationSharingSection(), // Nueva sección de GPS
            SizedBox(height: 24),
            _buildPaymentMethodSection(),
            SizedBox(height: 24),
            _buildOrderSummarySection(),
            SizedBox(height: 24),
            _buildSpecialInstructionsSection(),
            SizedBox(height: 24),
            _buildPricingSummary(),
            SizedBox(height: 100), // Espacio para el botón fijo
          ],
        ),
      ),
      bottomNavigationBar: _buildConfirmButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back, color: AppColors.textSecondary),
      ),
      title: Text(
        'Confirmar Pedido',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDeliveryAddressSection() {
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
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Dirección de entrega',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          AddressSelectorWidget(
            selectedLocation: _selectedLocation,
            onLocationSelected: (LocationData location) {
              setState(() {
                _selectedLocation = location;
              });
            },
            title: 'Dirección de entrega',
            subtitle: 'Selecciona dónde quieres recibir tu pedido',
          ),

          if (_selectedLocation != null) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: AppColors.success,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Tiempo estimado: ${_getEstimatedDeliveryTime()}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Nueva sección de GPS
  Widget _buildLocationSharingSection() {
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
          Row(
            children: [
              Icon(Icons.gps_fixed, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Ubicación en tiempo real',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _shareLocationEnabled
                  ? AppColors.primaryWithOpacity(0.1)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _shareLocationEnabled
                    ? AppColors.primary
                    : AppColors.border,
                width: _shareLocationEnabled ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _shareLocationEnabled
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _shareLocationEnabled ? Icons.gps_fixed : Icons.gps_off,
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
                            'Compartir mi ubicación GPS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _shareLocationEnabled
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Ayuda al repartidor a encontrarte más fácil',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Switch(
                      value: _shareLocationEnabled,
                      onChanged: (value) {
                        setState(() {
                          _shareLocationEnabled = value;
                        });

                        if (value) {
                          _enableLocationSharing();
                        } else {
                          _disableLocationSharing();
                        }
                      },
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),

                if (_shareLocationEnabled) ...[
                  SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.success, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ubicación GPS activada - El repartidor podrá verte en tiempo real',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
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

          SizedBox(height: 12),

          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.textSecondary,
                size: 16,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tu ubicación solo se compartirá durante la entrega y se desactivará automáticamente al completar el pedido',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
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
          Row(
            children: [
              Icon(Icons.payment, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Método de pago',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          ...(_paymentMethods.asMap().entries.map((entry) {
            final index = entry.key;
            final method = entry.value;
            final isSelected = index == _selectedPaymentIndex;

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedPaymentIndex = index;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryWithOpacity(0.1)
                        : AppColors.surfaceVariant,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          method['icon'],
                          color: AppColors.textOnPrimary,
                          size: 20,
                        ),
                      ),

                      SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              method['subtitle'],
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
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
          }).toList()),

          SizedBox(height: 8),

          TextButton.icon(
            onPressed: () {
              // TODO: Agregar método de pago
            },
            icon: Icon(Icons.add, color: AppColors.primary),
            label: Text(
              'Agregar método de pago',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection() {
    return Consumer(
      builder: (context, ref, _) {
        final cart = ref.watch(cartProvider);
        
        if (cart.isEmpty) {
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'No hay productos en el carrito',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        
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
              Row(
                children: [
                  Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Resumen del pedido',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Información de la tienda
              if (cart.store != null) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryWithOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: AppGradients.secondary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.store,
                          color: AppColors.textOnSecondary,
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cart.store!.storeName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Tiempo estimado: ${cart.store!.deliveryTime}-${cart.store!.deliveryTime + 10} min',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],

              // Items del carrito
              ...cart.items.map(
                (CartItem item) => Container(
                  margin: EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AppGradients.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getIconForCategory(item.menuItem.category),
                          color: AppColors.textOnPrimary,
                          size: 20,
                        ),
                      ),

                      SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.menuItem.name,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (item.specialInstructions?.isNotEmpty == true)
                              Text(
                                'Nota: ${item.specialInstructions}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),

                      Text(
                        '${item.quantity}x',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      SizedBox(width: 8),

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
              ).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpecialInstructionsSection() {
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
          Row(
            children: [
              Icon(Icons.note_add, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Instrucciones especiales',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          TextField(
            controller: _instructionsController,
            style: TextStyle(color: AppColors.textPrimary),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ej: Sin cebolla, extra salsa, tocar timbre...',
              hintStyle: TextStyle(color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Opcional - Ayúdanos a hacer tu pedido perfecto',
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSummary() {
    return Consumer(
      builder: (context, ref, _) {
        final cart = ref.watch(cartProvider);
        
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryWithOpacity(0.3), width: 2),
          ),
          child: Column(
            children: [
              _buildPriceRow(
                'Subtotal (${cart.items.length} productos)',
                '\$${cart.subtotal.toStringAsFixed(0)}',
              ),
              
              if (cart.totalSavings > 0)
                _buildPriceRow(
                  'Ahorros',
                  '-\$${cart.totalSavings.toStringAsFixed(0)}',
                  valueColor: AppColors.success,
                ),
              
              if (cart.promoDiscount > 0)
                _buildPriceRow(
                  'Descuento promocional',
                  '-\$${cart.promoDiscount.toStringAsFixed(0)}',
                  valueColor: AppColors.success,
                ),
              
              _buildPriceRow(
                'Envío',
                cart.deliveryFee == 0
                    ? 'Gratis'
                    : '\$${cart.deliveryFee.toStringAsFixed(0)}',
                valueColor: cart.deliveryFee == 0 ? AppColors.success : null,
              ),
              
              _buildPriceRow(
                'Tarifa de servicio',
                '\$${cart.serviceFee.toStringAsFixed(0)}',
              ),

              Divider(color: AppColors.border, height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '\$${cart.total.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Consumer(
      builder: (context, ref, _) {
        final cart = ref.watch(cartProvider);
        
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isProcessing || cart.isEmpty) ? null : _processOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.textOnPrimary,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Procesando pedido...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              cart.isEmpty 
                                  ? 'Carrito vacío'
                                  : 'Confirmar pedido • \$${cart.total.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                            if (cart.isNotEmpty) ...[
                              SizedBox(width: 8),
                              Icon(
                                Icons.check,
                                color: AppColors.textOnPrimary,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                ),
              ),

              SizedBox(height: 8),

              Text(
                'Al confirmar aceptas los términos y condiciones',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
