import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_item_model.dart';
import '../../models/cart_model.dart';

class CartScreen extends ConsumerStatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> with TickerProviderStateMixin {
  final _promoController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;


  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -100.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _promoController.dispose();
    _animationController.dispose();
    super.dispose();
  }


  void _updateQuantity(String cartItemId, int newQuantity) {
    final cartNotifier = ref.read(cartProvider.notifier);
    
    // Validar límites
    if (newQuantity < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('La cantidad mínima es 1'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    
    if (newQuantity > 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('La cantidad máxima es 15'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    cartNotifier.updateItemQuantity(cartItemId, newQuantity);
  }

  void _removeItem(String cartItemId) {
    final cartNotifier = ref.read(cartProvider.notifier);
    cartNotifier.removeItem(cartItemId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Producto eliminado del carrito'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Deshacer',
          textColor: AppColors.textPrimary,
          onPressed: () {
            // TODO: Implementar deshacer
          },
        ),
      ),
    );
  }

  void _applyPromoCode() {
    final code = _promoController.text.trim().toUpperCase();
    final cartNotifier = ref.read(cartProvider.notifier);
    
    final success = cartNotifier.applyPromoCode(code);
    
    if (success) {
      _promoController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.textPrimary),
              SizedBox(width: 8),
              Text('¡Código aplicado exitosamente!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.textPrimary),
              SizedBox(width: 8),
              Text('Código promocional inválido'),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removePromoCode() {
    final cartNotifier = ref.read(cartProvider.notifier);
    cartNotifier.removePromoCode();
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer(
        builder: (context, ref, _) {
          final cart = ref.watch(cartProvider);
          return cart.items.isEmpty ? _buildEmptyCart() : _buildCartContent();
        },
      ),
      bottomNavigationBar: Consumer(
        builder: (context, ref, _) {
          final cart = ref.watch(cartProvider);
          return cart.items.isNotEmpty ? _buildCheckoutButton() : SizedBox.shrink();
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        'Mi Carrito',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Consumer(
          builder: (context, ref, _) {
            final cart = ref.watch(cartProvider);
            if (cart.items.isEmpty) return SizedBox.shrink();
            
            return TextButton(
              onPressed: () {
                _showClearCartDialog();
              },
              child: Text(
                'Limpiar',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: AppColors.textTertiary,
            ),
          ),

          SizedBox(height: 24),

          Text(
            'Tu carrito está vacío',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Agrega productos de tus tiendas favoritas',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 32),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/customer-home',
                (route) => false,
              );
            },
            icon: Icon(Icons.store, color: AppColors.textOnPrimary),
            label: Text(
              'Explorar tiendas',
              style: TextStyle(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStoreHeader(),
          SizedBox(height: 16),
          _buildCartItems(),
          SizedBox(height: 24),
          _buildPromoSection(),
          SizedBox(height: 24),
          _buildOrderSummary(),
          SizedBox(height: 100), // Espacio para el botón fijo
        ],
      ),
    );
  }

  Widget _buildStoreHeader() {
    return Consumer(
      builder: (context, ref, _) {
        final cart = ref.watch(cartProvider);
        if (cart.store == null) return SizedBox.shrink();
        
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryWithOpacity(0.3), width: 1),
          ),
          child: Row(
            children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppGradients.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.store,
              color: AppColors.textOnSecondary,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pedido de: ${cart.store!.storeName}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Tiempo estimado: ${cart.store!.deliveryTime}-${cart.store!.deliveryTime + 10} min',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
              Icon(Icons.info_outline, color: AppColors.textSecondary, size: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartItems() {
    return Consumer(
      builder: (context, ref, _) {
        final cart = ref.watch(cartProvider);
        return Column(
          children: cart.items.map((item) => _buildCartItem(item)).toList(),
        );
      },
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkWithOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Product Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForCategory(item.menuItem.category),
                  color: AppColors.textOnPrimary,
                  size: 30,
                ),
              ),

              SizedBox(width: 16),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.menuItem.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      item.menuItem.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (item.specialInstructions?.isNotEmpty == true) ...[
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Nota: ${item.specialInstructions}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Remove button
              IconButton(
                onPressed: () => _removeItem(item.id),
                icon: Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Price and Quantity Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '\$${item.menuItem.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),

                      if (item.menuItem.hasDiscount) ...[
                        SizedBox(width: 8),
                        Text(
                          '\$${item.menuItem.originalPrice!.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),

                  Text(
                    'Subtotal: \$${(item.menuItem.price * item.quantity).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              // Quantity Controls
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: item.quantity > 1 ? () {
                        final cartNotifier = ref.read(cartProvider.notifier);
                        cartNotifier.decrementItem(item.id);
                      } : null,
                      icon: Icon(
                        Icons.remove,
                        color: item.quantity > 1 ? AppColors.primary : AppColors.textTertiary,
                        size: 18,
                      ),
                      constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                    ),

                    Container(
                      width: 40,
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        if (item.quantity < 15) {
                          final cartNotifier = ref.read(cartProvider.notifier);
                          cartNotifier.incrementItem(item.id);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('La cantidad máxima es 15'),
                              backgroundColor: AppColors.warning,
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      icon: Icon(Icons.add, color: AppColors.primary, size: 18),
                      constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Código promocional',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Consumer(
            builder: (context, ref, _) {
              final cart = ref.watch(cartProvider);
              
              if (cart.promoCode == null) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promoController,
                            style: TextStyle(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Ingresa tu código',
                              hintStyle: TextStyle(color: AppColors.textTertiary),
                              filled: true,
                              fillColor: AppColors.surfaceVariant,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _promoController.text.isNotEmpty
                              ? _applyPromoCode
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Aplicar',
                            style: TextStyle(
                              color: AppColors.textOnPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Códigos disponibles: ESTUDIANTE10, PRIMERAVEZ, CAMPUS20',
                      style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                    ),
                  ],
                );
              } else {
                return Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.success, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Código aplicado: ${cart.promoCode}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                            Text(
                              'Descuento: -\$${cart.promoDiscount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _removePromoCode,
                        icon: Icon(Icons.close, color: AppColors.success, size: 18),
                      ),
                    ],
                  ),
                );
              }
            },
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
        border: Border.all(color: AppColors.border, width: 1),
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

          Consumer(
            builder: (context, ref, _) {
              final cart = ref.watch(cartProvider);
              final deliveryFee = cart.store?.deliveryFee ?? 0.0;
              final total = cart.total;
              
              return Column(
                children: [
                  _buildSummaryRow(
                    'Subtotal (${cart.items.length} productos)',
                    '\$${cart.subtotal.toStringAsFixed(0)}',
                  ),

                  if (cart.totalSavings > 0)
                    _buildSummaryRow(
                      'Ahorros',
                      '-\$${cart.totalSavings.toStringAsFixed(0)}',
                      color: AppColors.success,
                    ),

                  if (cart.promoDiscount > 0)
                    _buildSummaryRow(
                      'Descuento promocional',
                      '-\$${cart.promoDiscount.toStringAsFixed(0)}',
                      color: AppColors.success,
                    ),

                  _buildSummaryRow(
                    'Costo de envío',
                    deliveryFee == 0
                        ? 'Gratis'
                        : '\$${deliveryFee.toStringAsFixed(0)}',
                    color: deliveryFee == 0 ? AppColors.success : null,
                  ),

                  _buildSummaryRow(
                    'Tarifa de servicio',
                    '\$${cart.serviceFee.toStringAsFixed(0)}',
                  ),

                  Divider(color: AppColors.border, thickness: 1, height: 24),

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
                        '\$${total.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
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
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton() {
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
              onPressed: () {
                Navigator.pushNamed(context, '/customer-checkout');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Consumer(
                    builder: (context, ref, _) {
                      final cart = ref.watch(cartProvider);
                      final deliveryFee = cart.store?.deliveryFee ?? 0.0;
                      final total = cart.total;
                      return Text(
                        'Proceder al pago • \$${total.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textOnPrimary,
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: AppColors.textOnPrimary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 8),

          Consumer(
            builder: (context, ref, _) {
              final cart = ref.watch(cartProvider);
              final deliveryTime = cart.store?.deliveryTime ?? 20;
              return Text(
                'Tiempo estimado de entrega: $deliveryTime-${deliveryTime + 10} min',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Limpiar carrito',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar todos los productos del carrito?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                final cartNotifier = ref.read(cartProvider.notifier);
                cartNotifier.clearCart();
                Navigator.pop(context);
              },
              child: Text('Limpiar', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }
}
