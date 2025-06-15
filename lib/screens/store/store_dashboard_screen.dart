import 'package:flutter/material.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import 'store_analytics_screen.dart';
import 'inventory_management_screen.dart';

class StoreDashboardScreen extends StatefulWidget {
  @override
  _StoreDashboardScreenState createState() => _StoreDashboardScreenState();
}

class _StoreDashboardScreenState extends State<StoreDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _notificationController;
  late Animation<double> _pulseAnimation;

  Timer? _refreshTimer;
  bool _isStoreOpen = true;
  int _currentBottomIndex = 0;

  // Datos simulados de la tienda
  final Map<String, dynamic> _storeInfo = {
    'name': 'Cafetería Central',
    'rating': 4.8,
    'totalOrders': 156,
    'todayEarnings': 2840.50,
    'averagePreparationTime': '12 min',
  };

  // Datos simulados de pedidos activos
  List<Map<String, dynamic>> _activeOrders = [
    {
      'id': '#CMP1239',
      'customerName': 'Ana García',
      'items': [
        {'name': 'Tacos de Pastor', 'quantity': 3},
        {'name': 'Agua de Horchata', 'quantity': 2},
      ],
      'total': 165.0,
      'status': 'nuevo',
      'orderTime': DateTime.now().subtract(Duration(minutes: 2)),
      'estimatedTime': 15,
      'customerNote': 'Sin cebolla en los tacos, por favor',
      'deliveryLocation': 'Edificio A - Aula 201',
      'isUrgent': true,
    },
    {
      'id': '#CMP1240',
      'customerName': 'Carlos Mendoza',
      'items': [
        {'name': 'Quesadilla Especial', 'quantity': 2},
        {'name': 'Agua de Jamaica', 'quantity': 1},
      ],
      'total': 155.0,
      'status': 'preparando',
      'orderTime': DateTime.now().subtract(Duration(minutes: 8)),
      'estimatedTime': 7,
      'customerNote': '',
      'deliveryLocation': 'Biblioteca - Sala de estudio 3',
      'isUrgent': false,
    },
    {
      'id': '#CMP1241',
      'customerName': 'María López',
      'items': [
        {'name': 'Tacos Vegetarianos', 'quantity': 4},
        {'name': 'Smoothie Verde', 'quantity': 1},
      ],
      'total': 185.0,
      'status': 'listo',
      'orderTime': DateTime.now().subtract(Duration(minutes: 15)),
      'estimatedTime': 0,
      'customerNote': 'Extra guacamole',
      'deliveryLocation': 'Dormitorio - Cuarto 305',
      'isUrgent': false,
    },
  ];

  // Estadísticas del día
  Map<String, int> get _todayStats {
    return {
      'nuevos': _activeOrders.where((o) => o['status'] == 'nuevo').length,
      'preparando': _activeOrders
          .where((o) => o['status'] == 'preparando')
          .length,
      'listos': _activeOrders.where((o) => o['status'] == 'listo').length,
      'completados': 23, // Simulado
    };
  }

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupRefreshTimer();
  }

  void _setupAnimations() {
    _notificationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _notificationController, curve: Curves.easeInOut),
    );

    if (_todayStats['nuevos']! > 0) {
      _notificationController.repeat(reverse: true);
    }
  }

  void _setupRefreshTimer() {
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          // Simular actualizaciones automáticas
        });
      }
    });
  }

  void _toggleStoreStatus() {
    setState(() {
      _isStoreOpen = !_isStoreOpen;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isStoreOpen ? Icons.store : Icons.store_mall_directory_outlined,
              color: AppColors.textPrimary,
            ),
            SizedBox(width: 8),
            Text(_isStoreOpen ? 'Tienda abierta' : 'Tienda cerrada'),
          ],
        ),
        backgroundColor: _isStoreOpen ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'nuevo':
        return 'Nuevo';
      case 'preparando':
        return 'Preparando';
      case 'listo':
        return 'Listo';
      case 'completado':
        return 'Completado';
      default:
        return 'Desconocido';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'nuevo':
        return AppColors.warning;
      case 'preparando':
        return AppColors.primary;
      case 'listo':
        return AppColors.success;
      case 'completado':
        return AppColors.textSecondary;
      default:
        return AppColors.textTertiary;
    }
  }

  void _updateOrderStatus(String orderId, String newStatus) {
    setState(() {
      final orderIndex = _activeOrders.indexWhere((o) => o['id'] == orderId);
      if (orderIndex != -1) {
        _activeOrders[orderIndex]['status'] = newStatus;

        // Si el pedido está completado, removerlo de la lista activa después de un delay
        if (newStatus == 'completado') {
          Future.delayed(Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _activeOrders.removeAt(orderIndex);
              });
            }
          });
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pedido $orderId actualizado a: ${_getStatusText(newStatus)}',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _notificationController.dispose();
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
                    _buildQuickActions(),
                    SizedBox(height: 24),
                    _buildActiveOrdersSection(),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _storeInfo['name'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.warning, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '${_storeInfo['rating']} • ${_storeInfo['totalOrders']} pedidos',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  // Notificaciones con animación
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/store-order-management');
                    },
                    icon: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _todayStats['nuevos']! > 0
                              ? _pulseAnimation.value
                              : 1.0,
                          child: Stack(
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                color: AppColors.textSecondary,
                                size: 24,
                              ),
                              if (_todayStats['nuevos']! > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${_todayStats['nuevos']}',
                                        style: TextStyle(
                                          color: AppColors.textOnPrimary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Toggle estado de tienda
                  GestureDetector(
                    onTap: _toggleStoreStatus,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _isStoreOpen
                            ? AppColors.success
                            : AppColors.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isStoreOpen
                                ? Icons.store
                                : Icons.store_mall_directory_outlined,
                            color: AppColors.textOnPrimary,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            _isStoreOpen ? 'Abierto' : 'Cerrado',
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
                ],
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
            'Pedidos Hoy',
            '${_todayStats.values.reduce((a, b) => a + b)}',
            Icons.receipt_long,
            AppColors.primary,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Ganancias',
            '\$${_storeInfo['todayEarnings'].toStringAsFixed(0)}',
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
                'Gestionar Menú',
                Icons.restaurant_menu,
                AppColors.secondary,
                () => Navigator.pushNamed(context, '/store-menu-management'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Ver Pedidos',
                Icons.list_alt,
                AppColors.primary,
                () => Navigator.pushNamed(context, '/store-order-management'),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Analytics',
                Icons.analytics,
                AppColors.success,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StoreAnalyticsScreen(storeId: 'store_001'),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Inventario',
                Icons.inventory,
                AppColors.warning,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InventoryManagementScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Configuración',
                Icons.settings,
                AppColors.secondary,
                () => Navigator.pushNamed(context, '/store-profile-settings'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(child: SizedBox()), // Espacio vacío
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

  Widget _buildActiveOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pedidos Activos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/store-order-management');
              },
              child: Text(
                'Ver todos',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        if (_activeOrders.isEmpty)
          _buildEmptyOrders()
        else
          Column(
            children: _activeOrders
                .take(3) // Mostrar solo los primeros 3
                .map((order) => _buildOrderCard(order))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyOrders() {
    return Container(
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox, size: 48, color: AppColors.textTertiary),
          SizedBox(height: 16),
          Text(
            'No hay pedidos activos',
            style: TextStyle(
              fontSize: 16,
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

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final statusColor = _getStatusColor(order['status']);
    final statusText = _getStatusText(order['status']);
    final minutesAgo = DateTime.now()
        .difference(order['orderTime'] as DateTime)
        .inMinutes;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: order['isUrgent'] == true
            ? Border.all(color: AppColors.error, width: 2)
            : null,
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
          // Header del pedido
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                        if (order['isUrgent'] == true) ...[
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
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
                    SizedBox(height: 4),
                    Text(
                      '${order['customerName']} • hace ${minutesAgo}min',
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
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Items del pedido
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                ...order['items']
                    .take(2)
                    .map<Widget>(
                      (item) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item['quantity']}x ${item['name']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                if (order['items'].length > 2)
                  Text(
                    '+${order['items'].length - 2} más',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: 12),

          // Acciones rápidas
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total: \$${order['total'].toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (order['customerNote'].isNotEmpty)
                      Text(
                        'Nota: ${order['customerNote']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              if (order['status'] == 'nuevo')
                ElevatedButton(
                  onPressed: () =>
                      _updateOrderStatus(order['id'], 'preparando'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Aceptar',
                    style: TextStyle(color: AppColors.textOnPrimary),
                  ),
                )
              else if (order['status'] == 'preparando')
                ElevatedButton(
                  onPressed: () => _updateOrderStatus(order['id'], 'listo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Marcar Listo',
                    style: TextStyle(color: AppColors.textOnPrimary),
                  ),
                )
              else if (order['status'] == 'listo')
                ElevatedButton(
                  onPressed: () =>
                      _updateOrderStatus(order['id'], 'completado'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Completar',
                    style: TextStyle(color: AppColors.textOnSecondary),
                  ),
                ),
            ],
          ),
        ],
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
              Navigator.pushNamed(context, '/store-order-management');
              break;
            case 2:
              Navigator.pushNamed(context, '/store-menu-management');
              break;
            case 3:
              Navigator.pushNamed(context, '/store-profile-settings');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.receipt_long_outlined),
                if (_todayStats['nuevos']! > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'Menú',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }
}
