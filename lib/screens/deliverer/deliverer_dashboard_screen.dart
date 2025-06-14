// screens/deliverer/deliverer_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/order_model.dart';

class DelivererDashboardScreen extends ConsumerStatefulWidget {
  @override
  _DelivererDashboardScreenState createState() =>
      _DelivererDashboardScreenState();
}

class _DelivererDashboardScreenState extends ConsumerState<DelivererDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  Timer? _refreshTimer;
  bool _isAvailable = true;
  int _currentBottomIndex = 0;

  // Datos simulados del repartidor
  final Map<String, dynamic> _delivererStats = {
    'todayDeliveries': 12,
    'todayEarnings': 240.0,
    'averageRating': 4.8,
    'completionRate': 98.5,
  };

  // Pedidos disponibles para recoger
  List<Map<String, dynamic>> _availableOrders = [
    {
      'id': '#CMP1245',
      'storeName': 'Cafetería Central',
      'storeLocation': 'Edificio Principal - PB',
      'customerName': 'Ana García',
      'deliveryLocation': 'Biblioteca - Sala 3',
      'items': 3,
      'total': 165.0,
      'distance': '300m',
      'estimatedTime': '8 min',
      'orderTime': DateTime.now().subtract(Duration(minutes: 5)),
      'isPriority': true,
      'paymentMethod': 'Tarjeta',
    },
    {
      'id': '#CMP1246',
      'storeName': 'Healthy Corner',
      'storeLocation': 'Edificio B - Planta 1',
      'customerName': 'Carlos Mendoza',
      'deliveryLocation': 'Aula 301 - Edificio A',
      'items': 2,
      'total': 95.0,
      'distance': '450m',
      'estimatedTime': '12 min',
      'orderTime': DateTime.now().subtract(Duration(minutes: 12)),
      'isPriority': false,
      'paymentMethod': 'Efectivo',
    },
  ];

  // Entregas en progreso
  List<Map<String, dynamic>> _activeDeliveries = [
    {
      'id': '#CMP1244',
      'storeName': 'Pizza Campus',
      'customerName': 'María López',
      'deliveryLocation': 'Dormitorio - Cuarto 205',
      'status': 'picked_up', // picked_up, delivering
      'items': 4,
      'total': 280.0,
      'customerPhone': '+52 555 123 4567',
      'estimatedTime': '6 min',
      'acceptedTime': DateTime.now().subtract(Duration(minutes: 18)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupRefreshTimer();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    if (_availableOrders.isNotEmpty) {
      _pulseController.repeat(reverse: true);
    }

    _slideController.forward();
  }

  void _setupRefreshTimer() {
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted && _isAvailable) {
        setState(() {
          // Simular nuevos pedidos ocasionalmente
        });
      }
    });
  }

  void _toggleAvailability() {
    setState(() {
      _isAvailable = !_isAvailable;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isAvailable ? Icons.check_circle : Icons.pause_circle,
              color: AppColors.textPrimary,
            ),
            SizedBox(width: 8),
            Text(_isAvailable ? 'Disponible para entregas' : 'No disponible'),
          ],
        ),
        backgroundColor: _isAvailable ? AppColors.success : AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (!_isAvailable) {
      _pulseController.stop();
    } else if (_availableOrders.isNotEmpty) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _acceptOrder(String orderId) {
    final orderIndex = _availableOrders.indexWhere((o) => o['id'] == orderId);
    if (orderIndex != -1) {
      final order = _availableOrders[orderIndex];
      setState(() {
        _availableOrders.removeAt(orderIndex);
        _activeDeliveries.add({
          ...order,
          'status': 'accepted',
          'acceptedTime': DateTime.now(),
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pedido $orderId aceptado'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navegar a detalles del pedido
      Navigator.pushNamed(
        context,
        '/deliverer-delivery-details',
        arguments: order,
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsCards(),
                    SizedBox(height: 24),
                    _buildActiveDeliveries(),
                    SizedBox(height: 24),
                    _buildAvailableOrders(),
                    SizedBox(height: 24),
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    
    return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: AppGradients.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delivery_dining,
                      color: AppColors.textOnSecondary,
                      size: 25,
                    ),
                  ),

                  SizedBox(width: 16),

                  // Info del repartidor
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Repartidor',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: AppColors.warning,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${_delivererStats['averageRating']} • ${_delivererStats['todayDeliveries']} entregas hoy',
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

                  // Toggle de disponibilidad
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isAvailable && _availableOrders.isNotEmpty
                            ? _pulseAnimation.value
                            : 1.0,
                        child: GestureDetector(
                          onTap: _toggleAvailability,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _isAvailable
                                  ? AppColors.success
                                  : AppColors.warning,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow:
                                  _isAvailable && _availableOrders.isNotEmpty
                                  ? [
                                      BoxShadow(
                                        color: AppColors.success.withOpacity(
                                          0.4,
                                        ),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isAvailable
                                      ? Icons.check_circle
                                      : Icons.pause_circle,
                                  color: AppColors.textOnPrimary,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  _isAvailable ? 'Disponible' : 'Pausado',
                                  style: TextStyle(
                                    color: AppColors.textOnPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Entregas Hoy',
            '${_delivererStats['todayDeliveries']}',
            Icons.local_shipping,
            AppColors.primary,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Ganancias',
            '\$${_delivererStats['todayEarnings'].toStringAsFixed(0)}',
            Icons.attach_money,
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveDeliveries() {
    if (_activeDeliveries.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.delivery_dining, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text(
              'Entregas en Progreso',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_activeDeliveries.length}',
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        ..._activeDeliveries.map(
          (delivery) => _buildActiveDeliveryCard(delivery),
        ),
      ],
    );
  }

  Widget _buildActiveDeliveryCard(Map<String, dynamic> delivery) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryWithOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_shipping,
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
                      delivery['id'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${delivery['storeName']} → ${delivery['customerName']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  delivery['status'] == 'picked_up' ? 'En Camino' : 'Recogido',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  delivery['deliveryLocation'],
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                'ETA: ${delivery['estimatedTime']}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Llamar al cliente
                  },
                  icon: Icon(Icons.phone, size: 16),
                  label: Text('Llamar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/deliverer-delivery-details',
                      arguments: delivery,
                    );
                  },
                  icon: Icon(Icons.navigation, size: 16),
                  label: Text('Ver Detalles'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.assignment, color: AppColors.secondary, size: 20),
            SizedBox(width: 8),
            Text(
              'Pedidos Disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (_availableOrders.isNotEmpty) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_availableOrders.length}',
                  style: TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 16),
        if (!_isAvailable)
          _buildUnavailableMessage()
        else if (_availableOrders.isEmpty)
          _buildNoOrdersMessage()
        else
          SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: _availableOrders
                  .map((order) => _buildAvailableOrderCard(order))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildUnavailableMessage() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.pause_circle, size: 48, color: AppColors.warning),
          SizedBox(height: 16),
          Text(
            'No Disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Activa tu disponibilidad para ver pedidos',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNoOrdersMessage() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox, size: 48, color: AppColors.textTertiary),
          SizedBox(height: 16),
          Text(
            'No hay pedidos disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Los nuevos pedidos aparecerán aquí',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableOrderCard(Map<String, dynamic> order) {
    final minutesAgo = DateTime.now()
        .difference(order['orderTime'] as DateTime)
        .inMinutes;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: order['isPriority']
            ? Border.all(color: AppColors.warning, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.darkWithOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _acceptOrder(order['id']),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: order['isPriority']
                          ? AppColors.warning.withOpacity(0.2)
                          : AppColors.secondaryWithOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      order['isPriority']
                          ? Icons.priority_high
                          : Icons.shopping_bag,
                      color: order['isPriority']
                          ? AppColors.warning
                          : AppColors.secondary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              order['id'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (order['isPriority']) ...[
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning,
                                  borderRadius: BorderRadius.circular(4),
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
                          ],
                        ),
                        Text(
                          '${order['storeName']} • hace ${minutesAgo}min',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${order['total'].toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        '${order['items']} productos',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.store, size: 16, color: AppColors.textSecondary),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order['storeLocation'],
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order['deliveryLocation'],
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.directions_walk,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          order['distance'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          order['estimatedTime'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order['paymentMethod'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () => _acceptOrder(order['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      'Aceptar',
                      style: TextStyle(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Mi Historial',
                Icons.history,
                AppColors.secondary,
                () => Navigator.pushNamed(context, '/deliverer-history'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Ayuda',
                Icons.help_outline,
                AppColors.primary,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Centro de ayuda próximamente')),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
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
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: _currentBottomIndex,
        onTap: (index) {
          setState(() {
            _currentBottomIndex = index;
          });

          switch (index) {
            case 0:
              // Ya estamos en Dashboard
              break;
            case 1:
              Navigator.pushNamed(context, '/deliverer-history');
              break;
            case 2:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        items: [
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.dashboard_outlined),
                if (_availableOrders.isNotEmpty && _isAvailable)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
