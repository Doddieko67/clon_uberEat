import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class OrderManagementScreen extends StatefulWidget {
  @override
  _OrderManagementScreenState createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  // Datos simulados de todos los pedidos
  final List<Map<String, dynamic>> _allOrders = [
    {
      'id': '#CMP1239',
      'customerName': 'Ana García',
      'customerPhone': '+52 555 123 4567',
      'items': [
        {'name': 'Tacos de Pastor', 'quantity': 3, 'price': 45.0},
        {'name': 'Agua de Horchata', 'quantity': 2, 'price': 25.0},
      ],
      'total': 185.0,
      'status': 'nuevo',
      'orderTime': DateTime.now().subtract(Duration(minutes: 2)),
      'estimatedTime': 15,
      'customerNote': 'Sin cebolla en los tacos, por favor',
      'deliveryLocation': 'Edificio A - Aula 201',
      'paymentMethod': 'Tarjeta',
      'isUrgent': true,
    },
    {
      'id': '#CMP1240',
      'customerName': 'Carlos Mendoza',
      'customerPhone': '+52 555 987 6543',
      'items': [
        {'name': 'Quesadilla Especial', 'quantity': 2, 'price': 65.0},
        {'name': 'Agua de Jamaica', 'quantity': 1, 'price': 20.0},
      ],
      'total': 150.0,
      'status': 'preparando',
      'orderTime': DateTime.now().subtract(Duration(minutes: 8)),
      'estimatedTime': 7,
      'customerNote': '',
      'deliveryLocation': 'Biblioteca - Sala de estudio 3',
      'paymentMethod': 'Efectivo',
      'isUrgent': false,
    },
    {
      'id': '#CMP1241',
      'customerName': 'María López',
      'customerPhone': '+52 555 456 7890',
      'items': [
        {'name': 'Tacos Vegetarianos', 'quantity': 4, 'price': 35.0},
        {'name': 'Smoothie Verde', 'quantity': 1, 'price': 45.0},
      ],
      'total': 185.0,
      'status': 'listo',
      'orderTime': DateTime.now().subtract(Duration(minutes: 15)),
      'estimatedTime': 0,
      'customerNote': 'Extra guacamole',
      'deliveryLocation': 'Dormitorio - Cuarto 305',
      'paymentMethod': 'Tarjeta',
      'isUrgent': false,
    },
    {
      'id': '#CMP1242',
      'customerName': 'Roberto Silva',
      'customerPhone': '+52 555 321 0987',
      'items': [
        {'name': 'Pizza Margarita', 'quantity': 1, 'price': 120.0},
        {'name': 'Refresco', 'quantity': 2, 'price': 30.0},
      ],
      'total': 180.0,
      'status': 'completado',
      'orderTime': DateTime.now().subtract(Duration(hours: 1, minutes: 30)),
      'estimatedTime': 0,
      'customerNote': '',
      'deliveryLocation': 'Cafetería - Mesa 5',
      'paymentMethod': 'Efectivo',
      'isUrgent': false,
    },
    {
      'id': '#CMP1243',
      'customerName': 'Laura Hernández',
      'customerPhone': '+52 555 654 3210',
      'items': [
        {'name': 'Ensalada César', 'quantity': 1, 'price': 85.0},
        {'name': 'Agua Natural', 'quantity': 1, 'price': 15.0},
      ],
      'total': 100.0,
      'status': 'cancelado',
      'orderTime': DateTime.now().subtract(Duration(minutes: 45)),
      'estimatedTime': 0,
      'customerNote': 'Sin aderezo',
      'deliveryLocation': 'Patio Central',
      'paymentMethod': 'Tarjeta',
      'isUrgent': false,
      'cancelReason': 'Cliente canceló - cambio de planes',
    },
  ];

  List<Map<String, dynamic>> get _filteredOrders {
    List<Map<String, dynamic>> filtered = _allOrders;

    // Filtrar por tab seleccionado
    switch (_tabController.index) {
      case 1: // Nuevos
        filtered = filtered
            .where((order) => order['status'] == 'nuevo')
            .toList();
        break;
      case 2: // En proceso
        filtered = filtered
            .where(
              (order) =>
                  order['status'] == 'preparando' || order['status'] == 'listo',
            )
            .toList();
        break;
      case 3: // Completados
        filtered = filtered
            .where((order) => order['status'] == 'completado')
            .toList();
        break;
      case 4: // Cancelados
        filtered = filtered
            .where((order) => order['status'] == 'cancelado')
            .toList();
        break;
    }

    // Filtrar por búsqueda
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered
          .where(
            (order) =>
                order['id'].toLowerCase().contains(searchTerm) ||
                order['customerName'].toLowerCase().contains(searchTerm) ||
                order['items'].any(
                  (item) => item['name'].toLowerCase().contains(searchTerm),
                ),
          )
          .toList();
    }

    // Ordenar por tiempo (más recientes primero)
    filtered.sort(
      (a, b) =>
          (b['orderTime'] as DateTime).compareTo(a['orderTime'] as DateTime),
    );

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
      case 'cancelado':
        return 'Cancelado';
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
      case 'cancelado':
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  void _updateOrderStatus(String orderId, String newStatus) {
    setState(() {
      final orderIndex = _allOrders.indexWhere((o) => o['id'] == orderId);
      if (orderIndex != -1) {
        _allOrders[orderIndex]['status'] = newStatus;
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

  void _rejectOrder(String orderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Rechazar pedido',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            '¿Estás seguro de que quieres rechazar el pedido $orderId?',
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
            ElevatedButton(
              onPressed: () {
                _updateOrderStatus(orderId, 'cancelado');
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(
                'Rechazar',
                style: TextStyle(color: AppColors.textOnPrimary),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatOrderTime(DateTime orderTime) {
    final now = DateTime.now();
    final difference = now.difference(orderTime);

    if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'hace ${difference.inHours}h';
    } else {
      return '${orderTime.day}/${orderTime.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(child: _buildOrdersList()),
        ],
      ),
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
        'Gestión de Pedidos',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              // Simular refresh
            });
          },
          icon: Icon(Icons.refresh, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Buscar por ID, cliente o producto...',
          hintStyle: TextStyle(color: AppColors.textTertiary),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                    });
                  },
                  icon: Icon(Icons.clear, color: AppColors.textSecondary),
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildTabBar() {
    final orderCounts = {
      'todos': _allOrders.length,
      'nuevos': _allOrders.where((o) => o['status'] == 'nuevo').length,
      'proceso': _allOrders
          .where((o) => o['status'] == 'preparando' || o['status'] == 'listo')
          .length,
      'completados': _allOrders
          .where((o) => o['status'] == 'completado')
          .length,
      'cancelados': _allOrders.where((o) => o['status'] == 'cancelado').length,
    };

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicator: BoxDecoration(
          color: AppColors.primaryWithOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        onTap: (index) {
          setState(() {});
        },
        tabs: [
          Tab(text: 'Todos (${orderCounts['todos']})'),
          Tab(text: 'Nuevos (${orderCounts['nuevos']})'),
          Tab(text: 'En Proceso (${orderCounts['proceso']})'),
          Tab(text: 'Completados (${orderCounts['completados']})'),
          Tab(text: 'Cancelados (${orderCounts['cancelados']})'),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    final orders = _filteredOrders;

    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_tabController.index) {
      case 1:
        message = 'No hay pedidos nuevos';
        icon = Icons.inbox_outlined;
        break;
      case 2:
        message = 'No hay pedidos en proceso';
        icon = Icons.hourglass_empty;
        break;
      case 3:
        message = 'No hay pedidos completados';
        icon = Icons.check_circle_outline;
        break;
      case 4:
        message = 'No hay pedidos cancelados';
        icon = Icons.cancel_outlined;
        break;
      default:
        message = _searchController.text.isNotEmpty
            ? 'No se encontraron pedidos'
            : 'No hay pedidos';
        icon = Icons.search_off;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textTertiary),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Los pedidos aparecerán aquí cuando lleguen',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final statusColor = _getStatusColor(order['status']);
    final statusText = _getStatusText(order['status']);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Header del pedido
              Row(
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
                                fontSize: 18,
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
                          '${order['customerName']} • ${_formatOrderTime(order['orderTime'])}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
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

              SizedBox(height: 16),

              // Información del pedido
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
                  Text(
                    'Total: \$${order['total'].toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              if (order['customerNote'].isNotEmpty) ...[
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Nota: ${order['customerNote']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],

              if (order['status'] == 'cancelado' &&
                  order['cancelReason'] != null) ...[
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Cancelado: ${order['cancelReason']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.error,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],

              SizedBox(height: 16),

              // Botones de acción
              _buildActionButtons(order),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order) {
    if (order['status'] == 'completado' || order['status'] == 'cancelado') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showOrderDetails(order),
              icon: Icon(Icons.visibility, size: 16),
              label: Text('Ver Detalles'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ],
      );
    }

    switch (order['status']) {
      case 'nuevo':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _rejectOrder(order['id']),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error),
                ),
                child: Text('Rechazar'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _updateOrderStatus(order['id'], 'preparando'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: Text(
                  'Aceptar',
                  style: TextStyle(color: AppColors.textOnPrimary),
                ),
              ),
            ),
          ],
        );

      case 'preparando':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showOrderDetails(order),
                icon: Icon(Icons.visibility, size: 16),
                label: Text('Ver Detalles'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(color: AppColors.border),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _updateOrderStatus(order['id'], 'listo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
                child: Text(
                  'Marcar Listo',
                  style: TextStyle(color: AppColors.textOnPrimary),
                ),
              ),
            ),
          ],
        );

      case 'listo':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showOrderDetails(order),
                icon: Icon(Icons.visibility, size: 16),
                label: Text('Ver Detalles'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(color: AppColors.border),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _updateOrderStatus(order['id'], 'completado'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
                child: Text(
                  'Completar',
                  style: TextStyle(color: AppColors.textOnSecondary),
                ),
              ),
            ),
          ],
        );

      default:
        return SizedBox.shrink();
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Detalles del Pedido',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(order['status']),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(order['status']),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Información del pedido
              _buildDetailSection('Información del Pedido', [
                _buildDetailRow('ID', order['id']),
                _buildDetailRow('Cliente', order['customerName']),
                _buildDetailRow('Teléfono', order['customerPhone']),
                _buildDetailRow('Ubicación', order['deliveryLocation']),
                _buildDetailRow('Pago', order['paymentMethod']),
                _buildDetailRow('Hora', _formatOrderTime(order['orderTime'])),
              ]),

              SizedBox(height: 20),

              // Productos
              Text(
                'Productos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: 12),

              Expanded(
                child: ListView.builder(
                  itemCount: order['items'].length,
                  itemBuilder: (context, index) {
                    final item = order['items'][index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                              Icons.fastfood,
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
                                  item['name'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '\$${item['price'].toStringAsFixed(0)} c/u',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${item['quantity']}x',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            '\$${(item['price'] * item['quantity']).toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Total
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryWithOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Row(
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
                      '\$${order['total'].toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Acciones
              if (order['status'] != 'completado' &&
                  order['status'] != 'cancelado')
                _buildActionButtons(order),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          Text(': ', style: TextStyle(color: AppColors.textSecondary)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
