// screens/deliverer/delivery_details_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../theme/app_theme.dart';

class DeliveryDetailsScreen extends StatefulWidget {
  @override
  _DeliveryDetailsScreenState createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends State<DeliveryDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _statusController;
  late AnimationController _pulseController;
  late Animation<double> _statusAnimation;
  late Animation<double> _pulseAnimation;

  Timer? _updateTimer;
  String _currentStatus =
      'accepted'; // accepted, picked_up, delivering, delivered

  // Datos del pedido (en una app real vendrían como argumentos)
  final Map<String, dynamic> _orderData = {
    'id': '#CMP1245',
    'storeName': 'Cafetería Central',
    'storeLocation': 'Edificio Principal - Planta Baja',
    'storePhone': '+52 555 123 4567',
    'customerName': 'Ana García López',
    'customerPhone': '+52 555 987 6543',
    'deliveryLocation': 'Biblioteca Central - Sala de Estudio 3',
    'deliveryInstructions':
        'Entrada por la parte trasera de la biblioteca. Buscar en el mostrador de información.',
    'items': [
      {'name': 'Tacos de Pastor', 'quantity': 3, 'price': 45.0},
      {'name': 'Agua de Horchata', 'quantity': 2, 'price': 25.0},
      {'name': 'Salsa Extra', 'quantity': 1, 'price': 10.0},
    ],
    'total': 185.0,
    'paymentMethod': 'Tarjeta (Pagado)',
    'distance': '320m',
    'estimatedTime': '8 min',
    'orderTime': DateTime.now().subtract(Duration(minutes: 15)),
    'acceptedTime': DateTime.now().subtract(Duration(minutes: 3)),
    'specialNotes': 'Cliente solicita llamar 5 minutos antes de llegar',
    'isPriority': true,
  };

  final List<Map<String, dynamic>> _statusSteps = [
    {
      'key': 'accepted',
      'title': 'Pedido Aceptado',
      'subtitle': 'Dirígete a recoger el pedido',
      'icon': Icons.check_circle,
      'color': AppColors.primary,
    },
    {
      'key': 'picked_up',
      'title': 'Pedido Recogido',
      'subtitle': 'En camino al cliente',
      'icon': Icons.shopping_bag,
      'color': AppColors.warning,
    },
    {
      'key': 'delivering',
      'title': 'En Entrega',
      'subtitle': 'Cerca del destino',
      'icon': Icons.delivery_dining,
      'color': AppColors.secondary,
    },
    {
      'key': 'delivered',
      'title': 'Entregado',
      'subtitle': 'Entrega completada',
      'icon': Icons.done_all,
      'color': AppColors.success,
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupUpdateTimer();
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
    if (_currentStatus != 'delivered') {
      _pulseController.repeat(reverse: true);
    }
  }

  void _setupUpdateTimer() {
    _updateTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted && _currentStatus != 'delivered') {
        setState(() {
          // Simular actualizaciones de tiempo estimado
        });
      }
    });
  }

  void _updateStatus(String newStatus) {
    setState(() {
      _currentStatus = newStatus;
    });

    _statusController.reset();
    _statusController.forward();

    if (newStatus == 'delivered') {
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
  }

  String _getStatusTitle(String status) {
    return _statusSteps.firstWhere((step) => step['key'] == status)['title'];
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
                  'Has completado exitosamente la entrega del pedido ${_orderData['id']}',
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
                      Navigator.pop(context); // Volver al dashboard
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
    super.dispose();
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
            _buildOrderHeader(),
            SizedBox(height: 24),
            _buildStatusTimeline(),
            SizedBox(height: 24),
            _buildLocationInfo(),
            SizedBox(height: 24),
            _buildCustomerInfo(),
            SizedBox(height: 24),
            _buildOrderSummary(),
            if (_orderData['specialNotes'].isNotEmpty) ...[
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

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
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
            // Mostrar mapa en pantalla completa
            Navigator.pushNamed(context, '/deliverer-customer-location');
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
                      _orderData['id'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    Text(
                      _orderData['customerName'],
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textOnPrimary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              if (_orderData['isPriority'])
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
              Text(
                'Tiempo estimado: ${_orderData['estimatedTime']}',
                style: TextStyle(fontSize: 14, color: AppColors.textOnPrimary),
              ),
              Spacer(),
              Icon(
                Icons.directions_walk,
                color: AppColors.textOnPrimary,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                _orderData['distance'],
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
          ..._statusSteps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isActive = step['key'] == _currentStatus;
            final isCompleted = _getStepIndex(_currentStatus) > index;
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

  int _getStepIndex(String stepKey) {
    return _statusSteps.indexWhere((step) => step['key'] == stepKey);
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
                          _orderData['storeName'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          _orderData['storeLocation'],
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Llamar a la tienda
                    },
                    icon: Icon(Icons.phone, color: AppColors.warning),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.warning.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
                          _orderData['deliveryLocation'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (_orderData['deliveryInstructions'].isNotEmpty) ...[
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
                                    _orderData['deliveryInstructions'],
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
                      Navigator.pushNamed(
                        context,
                        '/deliverer-customer-location',
                      );
                    },
                    icon: Icon(Icons.map, color: AppColors.primary),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
                      _orderData['customerName'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _orderData['customerPhone'],
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Llamar al cliente
                },
                icon: Icon(Icons.phone, size: 16),
                label: Text('Llamar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
          ...(_orderData['items'] as List).map((item) {
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
                      '${item['quantity']}x ${item['name']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '\$${(item['price'] * item['quantity']).toStringAsFixed(0)}',
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
                '\$${_orderData['total'].toStringAsFixed(0)}',
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
            _orderData['paymentMethod'],
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
            _orderData['specialNotes'],
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

    switch (_currentStatus) {
      case 'accepted':
        buttonText = 'Marcar como Recogido';
        onPressed = () => _updateStatus('picked_up');
        break;
      case 'picked_up':
        buttonText = 'Iniciar Entrega';
        onPressed = () => _updateStatus('delivering');
        break;
      case 'delivering':
        buttonText = 'Marcar como Entregado';
        onPressed = () => _updateStatus('delivered');
        break;
      case 'delivered':
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
            _currentStatus == 'delivered' ? Icons.check : Icons.arrow_forward,
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
            backgroundColor: _currentStatus == 'delivered'
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
}
