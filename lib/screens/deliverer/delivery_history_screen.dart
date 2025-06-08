// screens/deliverer/delivery_history_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DeliveryHistoryScreen extends StatefulWidget {
  @override
  _DeliveryHistoryScreenState createState() => _DeliveryHistoryScreenState();
}

class _DeliveryHistoryScreenState extends State<DeliveryHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _selectedTimeFilter = 'all'; // all, today, week, month

  // Datos simulados de entregas
  final List<Map<String, dynamic>> _allDeliveries = [
    {
      'id': '#CMP1243',
      'storeName': 'Cafetería Central',
      'customerName': 'Ana García',
      'deliveryLocation': 'Biblioteca - Sala 3',
      'items': 3,
      'total': 165.0,
      'earnings': 25.0,
      'distance': '320m',
      'deliveryTime': '12 min',
      'status': 'delivered',
      'rating': 5,
      'tip': 15.0,
      'completedAt': DateTime.now().subtract(Duration(hours: 2)),
      'paymentMethod': 'Tarjeta',
      'customerNotes': 'Excelente servicio, muy rápido',
    },
    {
      'id': '#CMP1242',
      'storeName': 'Pizza Campus',
      'customerName': 'Carlos Mendoza',
      'deliveryLocation': 'Dormitorio - Cuarto 205',
      'items': 2,
      'total': 280.0,
      'earnings': 35.0,
      'distance': '450m',
      'deliveryTime': '18 min',
      'status': 'delivered',
      'rating': 4,
      'tip': 20.0,
      'completedAt': DateTime.now().subtract(Duration(hours: 5)),
      'paymentMethod': 'Efectivo',
      'customerNotes': '',
    },
    {
      'id': '#CMP1241',
      'storeName': 'Healthy Corner',
      'customerName': 'María López',
      'deliveryLocation': 'Aula 301 - Edificio A',
      'items': 1,
      'total': 95.0,
      'earnings': 18.0,
      'distance': '200m',
      'deliveryTime': '8 min',
      'status': 'delivered',
      'rating': 5,
      'tip': 10.0,
      'completedAt': DateTime.now().subtract(Duration(days: 1, hours: 3)),
      'paymentMethod': 'Tarjeta',
      'customerNotes': 'Pedido perfecto, gracias!',
    },
    {
      'id': '#CMP1240',
      'storeName': 'Sweet Dreams',
      'customerName': 'Roberto Silva',
      'deliveryLocation': 'Oficina Administrativa - Piso 2',
      'items': 4,
      'total': 220.0,
      'earnings': 30.0,
      'distance': '600m',
      'deliveryTime': '25 min',
      'status': 'delivered',
      'rating': 3,
      'tip': 0.0,
      'completedAt': DateTime.now().subtract(Duration(days: 2)),
      'paymentMethod': 'Efectivo',
      'customerNotes': 'Entrega tardía',
    },
    {
      'id': '#CMP1239',
      'storeName': 'Sushi Express',
      'customerName': 'Laura Hernández',
      'deliveryLocation': 'Biblioteca - Entrada Principal',
      'items': 6,
      'total': 480.0,
      'earnings': 60.0,
      'distance': '380m',
      'deliveryTime': '15 min',
      'status': 'delivered',
      'rating': 5,
      'tip': 40.0,
      'completedAt': DateTime.now().subtract(Duration(days: 3)),
      'paymentMethod': 'Tarjeta',
      'customerNotes': 'Increíble velocidad de entrega!',
    },
    {
      'id': '#CMP1238',
      'storeName': 'Cafetería Central',
      'customerName': 'José Martínez',
      'deliveryLocation': 'Laboratorio de Química',
      'items': 2,
      'total': 125.0,
      'earnings': 20.0,
      'distance': '290m',
      'deliveryTime': '10 min',
      'status': 'cancelled',
      'rating': 0,
      'tip': 0.0,
      'completedAt': DateTime.now().subtract(Duration(days: 5)),
      'paymentMethod': 'Tarjeta',
      'customerNotes': '',
      'cancelReason': 'Cliente no encontrado en la ubicación',
    },
  ];

  List<Map<String, dynamic>> get _filteredDeliveries {
    List<Map<String, dynamic>> filtered = _allDeliveries;

    // Filtrar por tab
    switch (_tabController.index) {
      case 1: // Completadas
        filtered = filtered.where((d) => d['status'] == 'delivered').toList();
        break;
      case 2: // Canceladas
        filtered = filtered.where((d) => d['status'] == 'cancelled').toList();
        break;
    }

    // Filtrar por tiempo
    if (_selectedTimeFilter != 'all') {
      final now = DateTime.now();
      filtered = filtered.where((delivery) {
        final completedAt = delivery['completedAt'] as DateTime;
        switch (_selectedTimeFilter) {
          case 'today':
            return completedAt.day == now.day &&
                completedAt.month == now.month &&
                completedAt.year == now.year;
          case 'week':
            final weekAgo = now.subtract(Duration(days: 7));
            return completedAt.isAfter(weekAgo);
          case 'month':
            final monthAgo = now.subtract(Duration(days: 30));
            return completedAt.isAfter(monthAgo);
          default:
            return true;
        }
      }).toList();
    }

    // Filtrar por búsqueda
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered
          .where(
            (delivery) =>
                delivery['id'].toLowerCase().contains(searchTerm) ||
                delivery['storeName'].toLowerCase().contains(searchTerm) ||
                delivery['customerName'].toLowerCase().contains(searchTerm) ||
                delivery['deliveryLocation'].toLowerCase().contains(searchTerm),
          )
          .toList();
    }

    // Ordenar por fecha más reciente
    filtered.sort(
      (a, b) => (b['completedAt'] as DateTime).compareTo(
        a['completedAt'] as DateTime,
      ),
    );

    return filtered;
  }

  // Estadísticas calculadas
  Map<String, dynamic> get _stats {
    final completedDeliveries = _allDeliveries
        .where((d) => d['status'] == 'delivered')
        .toList();

    final totalEarnings = completedDeliveries.fold(
      0.0,
      (sum, d) => sum + d['earnings'] + d['tip'],
    );
    final totalDeliveries = completedDeliveries.length;
    final totalDistance = completedDeliveries.fold(0.0, (sum, d) {
      final distanceStr = d['distance'] as String;
      final distance =
          double.tryParse(
            distanceStr.replaceAll('m', '').replaceAll('km', ''),
          ) ??
          0.0;
      return sum + (distanceStr.contains('km') ? distance * 1000 : distance);
    });

    final averageRating = completedDeliveries.isNotEmpty
        ? completedDeliveries
                  .where((d) => d['rating'] > 0)
                  .fold(0.0, (sum, d) => sum + d['rating']) /
              completedDeliveries.where((d) => d['rating'] > 0).length
        : 0.0;

    return {
      'totalEarnings': totalEarnings,
      'totalDeliveries': totalDeliveries,
      'totalDistance': totalDistance,
      'averageRating': averageRating,
    };
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} días atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStatsSection(),
          _buildFiltersSection(),
          _buildTabBar(),
          Expanded(child: _buildHistoryList()),
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
        'Historial de Entregas',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              // Refrescar datos
            });
          },
          icon: Icon(Icons.refresh, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    final stats = _stats;
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
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
            children: [
              Icon(Icons.analytics, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Estadísticas Generales',
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
              Expanded(
                child: _buildStatCard(
                  'Entregas',
                  '${stats['totalDeliveries']}',
                  Icons.local_shipping,
                  AppColors.primary,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Ganancias',
                  '\$${stats['totalEarnings'].toStringAsFixed(0)}',
                  Icons.attach_money,
                  AppColors.success,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Distancia',
                  '${(stats['totalDistance'] / 1000).toStringAsFixed(1)}km',
                  Icons.directions_walk,
                  AppColors.secondary,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Rating',
                  '${stats['averageRating'].toStringAsFixed(1)}⭐',
                  Icons.star,
                  AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            controller: _searchController,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Buscar por ID, tienda, cliente...',
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
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          SizedBox(height: 16),
          // Filtros de tiempo
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTimeFilter('all', 'Todos'),
                SizedBox(width: 8),
                _buildTimeFilter('today', 'Hoy'),
                SizedBox(width: 8),
                _buildTimeFilter('week', 'Esta Semana'),
                SizedBox(width: 8),
                _buildTimeFilter('month', 'Este Mes'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilter(String value, String label) {
    final isSelected = _selectedTimeFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTimeFilter = value;
        });
      },
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.primaryWithOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final deliveryCounts = {
      'all': _allDeliveries.length,
      'delivered': _allDeliveries
          .where((d) => d['status'] == 'delivered')
          .length,
      'cancelled': _allDeliveries
          .where((d) => d['status'] == 'cancelled')
          .length,
    };

    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicator: BoxDecoration(
          color: AppColors.primaryWithOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        onTap: (index) {
          setState(() {});
        },
        tabs: [
          Tab(text: 'Todas (${deliveryCounts['all']})'),
          Tab(text: 'Completadas (${deliveryCounts['delivered']})'),
          Tab(text: 'Canceladas (${deliveryCounts['cancelled']})'),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    final deliveries = _filteredDeliveries;

    if (deliveries.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: deliveries.length,
      itemBuilder: (context, index) {
        final delivery = deliveries[index];
        return _buildDeliveryCard(delivery);
      },
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_tabController.index) {
      case 1:
        message = 'No hay entregas completadas';
        icon = Icons.inbox_outlined;
        break;
      case 2:
        message = 'No hay entregas canceladas';
        icon = Icons.cancel_outlined;
        break;
      default:
        message = _searchController.text.isNotEmpty
            ? 'No se encontraron entregas'
            : 'No hay entregas en este período';
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
            'Las entregas aparecerán aquí cuando las completes',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(Map<String, dynamic> delivery) {
    final isDelivered = delivery['status'] == 'delivered';
    final statusColor = isDelivered ? AppColors.success : AppColors.error;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: delivery['rating'] >= 5
              ? AppColors.warning.withOpacity(0.5)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkWithOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showDeliveryDetails(delivery),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isDelivered ? Icons.check_circle : Icons.cancel,
                      color: statusColor,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+\$${delivery['earnings'].toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      if (delivery['tip'] > 0)
                        Text(
                          '+\$${delivery['tip'].toStringAsFixed(0)} propina',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.warning,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Info de la entrega
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
                      delivery['deliveryLocation'],
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              // Métricas
              Row(
                children: [
                  _buildMetricChip(Icons.schedule, delivery['deliveryTime']),
                  SizedBox(width: 8),
                  _buildMetricChip(Icons.directions_walk, delivery['distance']),
                  SizedBox(width: 8),
                  _buildMetricChip(
                    Icons.shopping_bag,
                    '${delivery['items']} items',
                  ),
                  if (isDelivered && delivery['rating'] > 0) ...[
                    SizedBox(width: 8),
                    _buildRatingChip(delivery['rating']),
                  ],
                ],
              ),

              SizedBox(height: 12),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(delivery['completedAt']),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isDelivered ? 'Entregado' : 'Cancelado',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ],
              ),

              if (!isDelivered && delivery['cancelReason'] != null) ...[
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Motivo: ${delivery['cancelReason']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.error,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingChip(int rating) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 12, color: AppColors.warning),
          SizedBox(width: 4),
          Text(
            '$rating',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeliveryDetails(Map<String, dynamic> delivery) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
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
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppGradients.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.delivery_dining,
                      color: AppColors.textOnSecondary,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delivery['id'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          _formatDate(delivery['completedAt']),
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
                      color: delivery['status'] == 'delivered'
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      delivery['status'] == 'delivered'
                          ? 'Entregado'
                          : 'Cancelado',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: delivery['status'] == 'delivered'
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Detalles de la entrega
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('Tienda', [
                        _buildDetailRow('Nombre', delivery['storeName']),
                      ]),

                      SizedBox(height: 16),

                      _buildDetailSection('Cliente', [
                        _buildDetailRow('Nombre', delivery['customerName']),
                        _buildDetailRow(
                          'Ubicación',
                          delivery['deliveryLocation'],
                        ),
                      ]),

                      SizedBox(height: 16),

                      _buildDetailSection('Entrega', [
                        _buildDetailRow(
                          'Productos',
                          '${delivery['items']} items',
                        ),
                        _buildDetailRow(
                          'Total',
                          '\$${delivery['total'].toStringAsFixed(0)}',
                        ),
                        _buildDetailRow('Pago', delivery['paymentMethod']),
                        _buildDetailRow('Distancia', delivery['distance']),
                        _buildDetailRow('Tiempo', delivery['deliveryTime']),
                      ]),

                      SizedBox(height: 16),

                      _buildDetailSection('Ganancias', [
                        _buildDetailRow(
                          'Pago base',
                          '\$${delivery['earnings'].toStringAsFixed(0)}',
                        ),
                        if (delivery['tip'] > 0)
                          _buildDetailRow(
                            'Propina',
                            '\$${delivery['tip'].toStringAsFixed(0)}',
                          ),
                        _buildDetailRow(
                          'Total ganado',
                          '\$${(delivery['earnings'] + delivery['tip']).toStringAsFixed(0)}',
                        ),
                      ]),

                      if (delivery['status'] == 'delivered' &&
                          delivery['rating'] > 0) ...[
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.warning),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: AppColors.warning,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Calificación del Cliente',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    Icons.star,
                                    color: index < delivery['rating']
                                        ? AppColors.warning
                                        : AppColors.textTertiary,
                                    size: 24,
                                  );
                                }),
                              ),
                              if (delivery['customerNotes'].isNotEmpty) ...[
                                SizedBox(height: 8),
                                Text(
                                  '"${delivery['customerNotes']}"',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      if (delivery['status'] == 'cancelled') ...[
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.error),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.cancel,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Entrega Cancelada',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              if (delivery['cancelReason'] != null) ...[
                                SizedBox(height: 8),
                                Text(
                                  'Motivo: ${delivery['cancelReason']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ],
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
