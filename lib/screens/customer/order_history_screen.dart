import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class OrderHistoryScreen extends StatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  // Datos simulados de pedidos
  final List<Map<String, dynamic>> _allOrders = [
    {
      'id': '#CMP1234',
      'storeName': 'Cafetería Central',
      'storeImage': Icons.restaurant,
      'items': [
        {'name': 'Tacos de Pastor', 'quantity': 2},
        {'name': 'Quesadilla Especial', 'quantity': 1},
      ],
      'total': 155.0,
      'status': 'entregado',
      'statusColor': Colors.green,
      'date': DateTime.now().subtract(Duration(days: 2)),
      'deliveryTime': '18 min',
      'rating': 5,
      'canReorder': true,
      'paymentMethod': 'Tarjeta',
    },
    {
      'id': '#CMP1235',
      'storeName': 'Pizza Campus',
      'storeImage': Icons.local_pizza,
      'items': [
        {'name': 'Pizza Margarita', 'quantity': 1},
        {'name': 'Refresco', 'quantity': 2},
      ],
      'total': 220.0,
      'status': 'entregado',
      'statusColor': Colors.green,
      'date': DateTime.now().subtract(Duration(days: 5)),
      'deliveryTime': '25 min',
      'rating': 4,
      'canReorder': true,
      'paymentMethod': 'Efectivo',
    },
    {
      'id': '#CMP1236',
      'storeName': 'Sushi Express',
      'storeImage': Icons.set_meal,
      'items': [
        {'name': 'California Roll', 'quantity': 2},
        {'name': 'Salmon Roll', 'quantity': 1},
      ],
      'total': 380.0,
      'status': 'cancelado',
      'statusColor': Colors.red,
      'date': DateTime.now().subtract(Duration(days: 8)),
      'deliveryTime': '-',
      'rating': 0,
      'canReorder': true,
      'paymentMethod': 'Tarjeta',
      'cancelReason': 'Tienda cerrada',
    },
    {
      'id': '#CMP1237',
      'storeName': 'Healthy Corner',
      'storeImage': Icons.eco,
      'items': [
        {'name': 'Ensalada César', 'quantity': 1},
        {'name': 'Smoothie Verde', 'quantity': 1},
      ],
      'total': 145.0,
      'status': 'entregado',
      'statusColor': Colors.green,
      'date': DateTime.now().subtract(Duration(days: 12)),
      'deliveryTime': '15 min',
      'rating': 5,
      'canReorder': true,
      'paymentMethod': 'Tarjeta',
    },
    {
      'id': '#CMP1238',
      'storeName': 'Sweet Dreams',
      'storeImage': Icons.cake,
      'items': [
        {'name': 'Cheesecake', 'quantity': 2},
        {'name': 'Café Americano', 'quantity': 1},
      ],
      'total': 185.0,
      'status': 'en_preparacion',
      'statusColor': Colors.orange,
      'date': DateTime.now().subtract(Duration(minutes: 30)),
      'deliveryTime': '20 min estimado',
      'rating': 0,
      'canReorder': false,
      'paymentMethod': 'Tarjeta',
    },
  ];

  List<Map<String, dynamic>> get _filteredOrders {
    List<Map<String, dynamic>> filtered = _allOrders;

    // Filtrar por tab seleccionado
    switch (_tabController.index) {
      case 1: // Entregados
        filtered = filtered
            .where((order) => order['status'] == 'entregado')
            .toList();
        break;
      case 2: // En proceso
        filtered = filtered
            .where(
              (order) =>
                  order['status'] == 'en_preparacion' ||
                  order['status'] == 'en_camino',
            )
            .toList();
        break;
      case 3: // Cancelados
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
                order['storeName'].toLowerCase().contains(searchTerm) ||
                order['id'].toLowerCase().contains(searchTerm) ||
                order['items'].any(
                  (item) => item['name'].toLowerCase().contains(searchTerm),
                ),
          )
          .toList();
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'entregado':
        return 'Entregado';
      case 'en_preparacion':
        return 'En preparación';
      case 'en_camino':
        return 'En camino';
      case 'cancelado':
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} días atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _reorderItems(Map<String, dynamic> order) {
    showDialog(
      context: context,
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
                Icon(Icons.shopping_cart, color: AppColors.primary, size: 48),

                SizedBox(height: 16),

                Text(
                  '¿Reordenar este pedido?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'Se agregarán los productos al carrito',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/customer-cart');

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Productos agregados al carrito'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Text(
                          'Reordenar',
                          style: TextStyle(color: AppColors.textOnPrimary),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _rateOrder(Map<String, dynamic> order) {
    int rating = order['rating'] ?? 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: AppGradients.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        order['storeImage'],
                        color: AppColors.textOnPrimary,
                        size: 30,
                      ),
                    ),

                    SizedBox(height: 16),

                    Text(
                      'Califica tu experiencia',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      order['storeName'],
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () {
                            setDialogState(() {
                              rating = index + 1;
                            });
                          },
                          icon: Icon(
                            Icons.star,
                            size: 32,
                            color: index < rating
                                ? AppColors.warning
                                : AppColors.textTertiary,
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: rating > 0
                            ? () {
                                Navigator.pop(context);

                                setState(() {
                                  final index = _allOrders.indexWhere(
                                    (o) => o['id'] == order['id'],
                                  );
                                  if (index != -1) {
                                    _allOrders[index]['rating'] = rating;
                                  }
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '¡Gracias por tu calificación!',
                                    ),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            : null,
                        child: Text(
                          'Enviar calificación',
                          style: TextStyle(color: AppColors.textOnPrimary),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
      },
    );
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
        'Mis Pedidos',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Filtros avanzados
          },
          icon: Icon(Icons.filter_list, color: AppColors.textSecondary),
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
          hintText: 'Buscar pedidos, tiendas o productos...',
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        onTap: (index) {
          setState(() {});
        },
        tabs: [
          Tab(text: 'Todos'),
          Tab(text: 'Entregados'),
          Tab(text: 'En proceso'),
          Tab(text: 'Cancelados'),
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
        message = 'No tienes pedidos entregados';
        icon = Icons.receipt_long_outlined;
        break;
      case 2:
        message = 'No tienes pedidos en proceso';
        icon = Icons.hourglass_empty;
        break;
      case 3:
        message = 'No tienes pedidos cancelados';
        icon = Icons.cancel_outlined;
        break;
      default:
        message = _searchController.text.isNotEmpty
            ? 'No se encontraron pedidos'
            : 'No tienes pedidos aún';
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
          if (_tabController.index == 0 && _searchController.text.isEmpty) ...[
            SizedBox(height: 8),
            Text(
              'Haz tu primer pedido para verlo aquí',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/customer-home');
              },
              child: Text(
                'Explorar tiendas',
                style: TextStyle(color: AppColors.textOnPrimary),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () {
          _showOrderDetails(order);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Header del pedido
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: AppGradients.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      order['storeImage'],
                      color: AppColors.textOnSecondary,
                      size: 25,
                    ),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['storeName'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          order['id'],
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
                      color: order['statusColor'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(order['status']),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: order['statusColor'],
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
                        )
                        .toList(),

                    if (order['items'].length > 2)
                      Text(
                        '+${order['items'].length - 2} producto(s) más',
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

              // Footer del pedido
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                      Text(
                        _formatDate(order['date']),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      // Botón de calificar (solo para entregados sin calificación)
                      if (order['status'] == 'entregado' &&
                          order['rating'] == 0)
                        IconButton(
                          onPressed: () => _rateOrder(order),
                          icon: Icon(
                            Icons.star_border,
                            color: AppColors.warning,
                          ),
                          tooltip: 'Calificar',
                        ),

                      // Mostrar estrellas si ya está calificado
                      if (order['rating'] > 0)
                        Row(
                          children: List.generate(
                            order['rating'],
                            (index) => Icon(
                              Icons.star,
                              size: 16,
                              color: AppColors.warning,
                            ),
                          ),
                        ),

                      SizedBox(width: 8),

                      // Botón de reordenar
                      if (order['canReorder'])
                        OutlinedButton(
                          onPressed: () => _reorderItems(order),
                          child: Text(
                            'Reordenar',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppGradients.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      order['storeImage'],
                      color: AppColors.textOnSecondary,
                      size: 30,
                    ),
                  ),

                  SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['storeName'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          order['id'],
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
                      color: order['statusColor'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(order['status']),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: order['statusColor'],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Detalles
              Text(
                'Detalles del pedido',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: 16),

              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Fecha', _formatDate(order['date'])),
                    _buildDetailRow('Tiempo de entrega', order['deliveryTime']),
                    _buildDetailRow('Método de pago', order['paymentMethod']),
                    if (order['cancelReason'] != null)
                      _buildDetailRow(
                        'Motivo de cancelación',
                        order['cancelReason'],
                      ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Items
              Text(
                'Productos ordenados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  itemCount: order['items'].length,
                  itemBuilder: (context, index) {
                    final item = order['items'][index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
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
                            child: Text(
                              item['name'],
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
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
                      'Total pagado',
                      style: TextStyle(
                        fontSize: 16,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
