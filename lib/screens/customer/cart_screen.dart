import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  final _promoController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  // Simulación de datos del carrito (en una app real vendría de un provider/state management)
  List<Map<String, dynamic>> _cartItems = [
    {
      'id': 'pop1',
      'name': 'Tacos de Pastor',
      'description':
          'Deliciosos tacos con carne de pastor, piña, cebolla y cilantro',
      'price': 45.0,
      'originalPrice': 55.0,
      'image': Icons.lunch_dining,
      'quantity': 2,
      'store': 'Cafetería Central',
      'specialInstructions': '',
    },
    {
      'id': 'ques1',
      'name': 'Quesadilla Especial',
      'description': 'Quesadilla gigante con queso oaxaca, champiñones y pollo',
      'price': 65.0,
      'originalPrice': null,
      'image': Icons.local_dining,
      'quantity': 1,
      'store': 'Cafetería Central',
      'specialInstructions': 'Sin cebolla, por favor',
    },
    {
      'id': 'beb1',
      'name': 'Agua de Horchata',
      'description': 'Refrescante agua de horchata con canela',
      'price': 25.0,
      'originalPrice': null,
      'image': Icons.local_drink,
      'quantity': 2,
      'store': 'Cafetería Central',
      'specialInstructions': '',
    },
  ];

  String? _appliedPromoCode;
  double _promoDiscount = 0.0;
  final double _deliveryFee = 0.0; // Gratis para Cafetería Central
  final double _serviceFee = 5.0;

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

  double get _subtotal {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );
  }

  double get _totalSavings {
    return _cartItems.fold(0.0, (sum, item) {
      if (item['originalPrice'] != null) {
        return sum +
            ((item['originalPrice'] - item['price']) * item['quantity']);
      }
      return sum;
    });
  }

  double get _total {
    return _subtotal - _promoDiscount + _deliveryFee + _serviceFee;
  }

  // MODIFICACIÓN AQUÍ
  void _updateQuantity(String itemId, int newQuantity) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item['id'] == itemId);
      if (index != -1) {
        // Asegurarse de que la cantidad no baje de 1
        if (newQuantity < 1) {
          newQuantity = 1;
          // Opcional: mostrar un SnackBar si se intenta bajar a 0
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('La cantidad mínima es 1'),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 1),
            ),
          );
        }
        // Asegurarse de que la cantidad no exceda de 15
        if (newQuantity > 15) {
          newQuantity = 15;
          // Opcional: mostrar un SnackBar si se intenta superar 15
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('La cantidad máxima es 15'),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 1),
            ),
          );
        }

        _cartItems[index]['quantity'] = newQuantity;
      }
      // Si el item ya no existe (quizás eliminado por otro lado), no hacemos nada
    });
  }

  void _removeItem(String itemId) {
    setState(() {
      _cartItems.removeWhere((item) => item['id'] == itemId);
    });

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

    // Códigos promocionales simulados
    final promoCodes = {
      'ESTUDIANTE10': 0.10,
      'PRIMERAVEZ': 0.15,
      'CAMPUS20': 0.20,
    };

    if (promoCodes.containsKey(code)) {
      setState(() {
        _appliedPromoCode = code;
        _promoDiscount = _subtotal * promoCodes[code]!;
        _promoController.clear();
      });

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
    setState(() {
      _appliedPromoCode = null;
      _promoDiscount = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _cartItems.isEmpty ? _buildEmptyCart() : _buildCartContent(),
      bottomNavigationBar: _cartItems.isNotEmpty
          ? _buildCheckoutButton()
          : null,
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
        'Mi Carrito',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (_cartItems.isNotEmpty)
          TextButton(
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
    final storeName = _cartItems.first['store'];
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
                  'Pedido de: $storeName',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Tiempo estimado: 15-25 min',
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
  }

  Widget _buildCartItems() {
    return Column(
      children: _cartItems.map((item) => _buildCartItem(item)).toList(),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
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
                  item['image'],
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
                      item['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      item['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (item['specialInstructions'].isNotEmpty) ...[
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
                          'Nota: ${item['specialInstructions']}',
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
                onPressed: () => _removeItem(item['id']),
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
                        '\$${item['price'].toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),

                      if (item['originalPrice'] != null) ...[
                        SizedBox(width: 8),
                        Text(
                          '\$${item['originalPrice'].toStringAsFixed(0)}',
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
                    'Subtotal: \$${(item['price'] * item['quantity']).toStringAsFixed(0)}',
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
                      // Al presionar "menos", envía la cantidad actual - 1
                      onPressed: () =>
                          _updateQuantity(item['id'], item['quantity'] - 1),
                      icon: Icon(
                        Icons.remove,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                    ),

                    Container(
                      width: 40,
                      child: Text(
                        '${item['quantity']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    IconButton(
                      // Al presionar "más", envía la cantidad actual + 1
                      onPressed: () =>
                          _updateQuantity(item['id'], item['quantity'] + 1),
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

          if (_appliedPromoCode == null) ...[
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
          ] else ...[
            Container(
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
                          'Código aplicado: $_appliedPromoCode',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          'Descuento: -\$${_promoDiscount.toStringAsFixed(0)}',
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
            ),
          ],
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

          _buildSummaryRow(
            'Subtotal (${_cartItems.length} productos)',
            '\$${_subtotal.toStringAsFixed(0)}',
          ),

          if (_totalSavings > 0)
            _buildSummaryRow(
              'Ahorros',
              '-\$${_totalSavings.toStringAsFixed(0)}',
              color: AppColors.success,
            ),

          if (_promoDiscount > 0)
            _buildSummaryRow(
              'Descuento promocional',
              '-\$${_promoDiscount.toStringAsFixed(0)}',
              color: AppColors.success,
            ),

          _buildSummaryRow(
            'Costo de envío',
            _deliveryFee == 0
                ? 'Gratis'
                : '\$${_deliveryFee.toStringAsFixed(0)}',
            color: _deliveryFee == 0 ? AppColors.success : null,
          ),

          _buildSummaryRow(
            'Tarifa de servicio',
            '\$${_serviceFee.toStringAsFixed(0)}',
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
                '\$${_total.toStringAsFixed(0)}',
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
                  Text(
                    'Proceder al pago • \$${_total.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textOnPrimary,
                    ),
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

          Text(
            'Tiempo estimado de entrega: 15-25 min',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                setState(() {
                  _cartItems.clear();
                });
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
