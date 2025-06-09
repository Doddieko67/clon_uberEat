// screens/admin/store_management_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class StoreManagementScreen extends StatefulWidget {
  @override
  _StoreManagementScreenState createState() => _StoreManagementScreenState();
}

class _StoreManagementScreenState extends State<StoreManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _selectedFilter =
      'all'; // all, high_performance, low_performance, issues
  String _selectedSortBy = 'recent'; // recent, name, rating, revenue, orders

  // Datos simulados de tiendas
  final List<Map<String, dynamic>> _allStores = [
    {
      'id': 'store001',
      'name': 'Cafetería Central',
      'ownerName': 'María González',
      'email': 'cafeteria.central@escuela.edu',
      'phone': '+52 555 111 2222',
      'status': 'active',
      'category': 'Comida Mexicana',
      'location': 'Edificio Principal - Planta Baja',
      'registeredAt': DateTime.now().subtract(Duration(days: 120)),
      'approvedAt': DateTime.now().subtract(Duration(days: 118)),
      'lastActive': DateTime.now().subtract(Duration(minutes: 15)),
      'verified': true,
      'featured': true,

      // Métricas de desempeño
      'totalOrders': 1456,
      'totalRevenue': 45600.75,
      'monthlyRevenue': 8200.50,
      'averageRating': 4.7,
      'ratingCount': 892,
      'averageOrderValue': 31.3,
      'fulfillmentRate': 98.5,
      'averagePreparationTime': 12,
      'customerRetentionRate': 85.2,

      // Configuración operativa
      'operatingHours': {
        'monday': {'open': '07:00', 'close': '18:00', 'isOpen': true},
        'tuesday': {'open': '07:00', 'close': '18:00', 'isOpen': true},
        'wednesday': {'open': '07:00', 'close': '18:00', 'isOpen': true},
        'thursday': {'open': '07:00', 'close': '18:00', 'isOpen': true},
        'friday': {'open': '07:00', 'close': '18:00', 'isOpen': true},
        'saturday': {'open': '08:00', 'close': '16:00', 'isOpen': true},
        'sunday': {'open': '08:00', 'close': '16:00', 'isOpen': false},
      },
      'deliveryZones': [
        'Edificio A',
        'Edificio B',
        'Biblioteca',
        'Dormitorios',
      ],
      'minimumOrder': 50.0,
      'deliveryFee': 0.0,
      'commissionRate': 8.5,

      // Información adicional
      'description':
          'Comida tradicional mexicana preparada fresca todos los días',
      'specialties': ['Tacos', 'Quesadillas', 'Aguas frescas'],
      'paymentMethods': ['Efectivo', 'Tarjeta', 'Transferencia'],
      'avatar': Icons.restaurant,
      'hasActivePromotion': true,
      'issuesCount': 0,
      'notes': 'Tienda principal del campus, muy popular entre estudiantes',
    },

    {
      'id': 'store002',
      'name': 'Pizza Campus',
      'ownerName': 'Roberto Silva',
      'email': 'pizza.campus@escuela.edu',
      'phone': '+52 555 333 4444',
      'status': 'active',
      'category': 'Pizza & Italiana',
      'location': 'Edificio B - Planta 1',
      'registeredAt': DateTime.now().subtract(Duration(days: 85)),
      'approvedAt': DateTime.now().subtract(Duration(days: 83)),
      'lastActive': DateTime.now().subtract(Duration(hours: 1)),
      'verified': true,
      'featured': false,

      'totalOrders': 892,
      'totalRevenue': 28450.25,
      'monthlyRevenue': 5200.75,
      'averageRating': 4.4,
      'ratingCount': 456,
      'averageOrderValue': 31.9,
      'fulfillmentRate': 94.2,
      'averagePreparationTime': 18,
      'customerRetentionRate': 78.5,

      'operatingHours': {
        'monday': {'open': '11:00', 'close': '22:00', 'isOpen': true},
        'tuesday': {'open': '11:00', 'close': '22:00', 'isOpen': true},
        'wednesday': {'open': '11:00', 'close': '22:00', 'isOpen': true},
        'thursday': {'open': '11:00', 'close': '22:00', 'isOpen': true},
        'friday': {'open': '11:00', 'close': '23:00', 'isOpen': true},
        'saturday': {'open': '11:00', 'close': '23:00', 'isOpen': true},
        'sunday': {'open': '11:00', 'close': '22:00', 'isOpen': true},
      },
      'deliveryZones': ['Edificio B', 'Edificio C', 'Cafetería'],
      'minimumOrder': 80.0,
      'deliveryFee': 15.0,
      'commissionRate': 10.0,

      'description': 'Las mejores pizzas del campus con ingredientes frescos',
      'specialties': ['Pizza Margarita', 'Pizza Pepperoni', 'Lasaña'],
      'paymentMethods': ['Efectivo', 'Tarjeta'],
      'avatar': Icons.local_pizza,
      'hasActivePromotion': false,
      'issuesCount': 2,
      'notes': 'Ha tenido algunas quejas por tiempos de entrega largos',
    },

    {
      'id': 'store003',
      'name': 'Sushi Express',
      'ownerName': 'Akira Tanaka',
      'email': 'sushi.express@escuela.edu',
      'phone': '+52 555 555 6666',
      'status': 'pending',
      'category': 'Sushi & Asiática',
      'location': 'Edificio C - Planta 2',
      'registeredAt': DateTime.now().subtract(Duration(days: 3)),
      'approvedAt': null,
      'lastActive': DateTime.now().subtract(Duration(hours: 4)),
      'verified': false,
      'featured': false,

      'totalOrders': 0,
      'totalRevenue': 0.0,
      'monthlyRevenue': 0.0,
      'averageRating': 0.0,
      'ratingCount': 0,
      'averageOrderValue': 0.0,
      'fulfillmentRate': 0.0,
      'averagePreparationTime': 0,
      'customerRetentionRate': 0.0,

      'operatingHours': {
        'monday': {'open': '12:00', 'close': '20:00', 'isOpen': true},
        'tuesday': {'open': '12:00', 'close': '20:00', 'isOpen': true},
        'wednesday': {'open': '12:00', 'close': '20:00', 'isOpen': true},
        'thursday': {'open': '12:00', 'close': '20:00', 'isOpen': true},
        'friday': {'open': '12:00', 'close': '20:00', 'isOpen': true},
        'saturday': {'open': '12:00', 'close': '18:00', 'isOpen': true},
        'sunday': {'open': '12:00', 'close': '18:00', 'isOpen': false},
      },
      'deliveryZones': ['Edificio C', 'Laboratorios'],
      'minimumOrder': 100.0,
      'deliveryFee': 20.0,
      'commissionRate': 12.0,

      'description': 'Auténtico sushi japonés y comida asiática',
      'specialties': ['Sushi Rolls', 'Ramen', 'Tempura'],
      'paymentMethods': ['Efectivo', 'Tarjeta', 'Transferencia'],
      'avatar': Icons.restaurant,
      'hasActivePromotion': false,
      'issuesCount': 0,
      'notes': 'Solicitud pendiente de aprobación. Documentos completos.',
      'pendingDocuments': ['Permiso sanitario', 'Certificado de calidad'],
    },

    {
      'id': 'store004',
      'name': 'Healthy Corner',
      'ownerName': 'Carmen López',
      'email': 'healthy.corner@escuela.edu',
      'phone': '+52 555 777 8888',
      'status': 'suspended',
      'category': 'Comida Saludable',
      'location': 'Edificio A - Planta 3',
      'registeredAt': DateTime.now().subtract(Duration(days: 60)),
      'approvedAt': DateTime.now().subtract(Duration(days: 58)),
      'lastActive': DateTime.now().subtract(Duration(days: 7)),
      'verified': true,
      'featured': false,

      'totalOrders': 234,
      'totalRevenue': 8450.75,
      'monthlyRevenue': 0.0,
      'averageRating': 3.8,
      'ratingCount': 156,
      'averageOrderValue': 36.1,
      'fulfillmentRate': 87.3,
      'averagePreparationTime': 25,
      'customerRetentionRate': 65.4,

      'operatingHours': {
        'monday': {'open': '08:00', 'close': '17:00', 'isOpen': true},
        'tuesday': {'open': '08:00', 'close': '17:00', 'isOpen': true},
        'wednesday': {'open': '08:00', 'close': '17:00', 'isOpen': true},
        'thursday': {'open': '08:00', 'close': '17:00', 'isOpen': true},
        'friday': {'open': '08:00', 'close': '17:00', 'isOpen': true},
        'saturday': {'open': '09:00', 'close': '15:00', 'isOpen': true},
        'sunday': {'open': '09:00', 'close': '15:00', 'isOpen': false},
      },
      'deliveryZones': ['Edificio A', 'Gimnasio'],
      'minimumOrder': 60.0,
      'deliveryFee': 10.0,
      'commissionRate': 9.0,

      'description': 'Comida saludable y orgánica para una vida mejor',
      'specialties': ['Ensaladas', 'Smoothies', 'Bowls'],
      'paymentMethods': ['Efectivo', 'Tarjeta'],
      'avatar': Icons.eco,
      'hasActivePromotion': false,
      'issuesCount': 5,
      'notes': 'Suspendida por múltiples quejas de calidad de comida',
      'suspensionReason':
          'Múltiples reportes de problemas de calidad alimentaria',
      'suspendedAt': DateTime.now().subtract(Duration(days: 7)),
    },

    {
      'id': 'store005',
      'name': 'Sweet Dreams',
      'ownerName': 'Ana Martínez',
      'email': 'sweet.dreams@escuela.edu',
      'phone': '+52 555 999 0000',
      'status': 'active',
      'category': 'Postres & Bebidas',
      'location': 'Cafetería - Kiosco 2',
      'registeredAt': DateTime.now().subtract(Duration(days: 40)),
      'approvedAt': DateTime.now().subtract(Duration(days: 38)),
      'lastActive': DateTime.now().subtract(Duration(minutes: 30)),
      'verified': true,
      'featured': true,

      'totalOrders': 567,
      'totalRevenue': 15650.25,
      'monthlyRevenue': 4200.75,
      'averageRating': 4.9,
      'ratingCount': 423,
      'averageOrderValue': 27.6,
      'fulfillmentRate': 99.1,
      'averagePreparationTime': 8,
      'customerRetentionRate': 92.3,

      'operatingHours': {
        'monday': {'open': '09:00', 'close': '19:00', 'isOpen': true},
        'tuesday': {'open': '09:00', 'close': '19:00', 'isOpen': true},
        'wednesday': {'open': '09:00', 'close': '19:00', 'isOpen': true},
        'thursday': {'open': '09:00', 'close': '19:00', 'isOpen': true},
        'friday': {'open': '09:00', 'close': '20:00', 'isOpen': true},
        'saturday': {'open': '10:00', 'close': '20:00', 'isOpen': true},
        'sunday': {'open': '10:00', 'close': '18:00', 'isOpen': true},
      },
      'deliveryZones': ['Cafetería', 'Biblioteca', 'Patio Central'],
      'minimumOrder': 30.0,
      'deliveryFee': 0.0,
      'commissionRate': 7.0,

      'description': 'Los mejores postres y bebidas del campus',
      'specialties': ['Frappés', 'Pasteles', 'Helados'],
      'paymentMethods': ['Efectivo', 'Tarjeta', 'Transferencia'],
      'avatar': Icons.cake,
      'hasActivePromotion': true,
      'issuesCount': 0,
      'notes': 'Excelente desempeño, muy popular entre estudiantes',
    },
  ];

  // Categorías disponibles
  final List<String> _categories = [
    'Comida Mexicana',
    'Pizza & Italiana',
    'Sushi & Asiática',
    'Comida Saludable',
    'Postres & Bebidas',
    'Hamburguesas',
    'Mariscos',
    'Vegetariana',
    'Cafetería',
    'Snacks',
  ];

  List<Map<String, dynamic>> get _filteredStores {
    List<Map<String, dynamic>> filtered = _allStores;

    // Filtrar por tab seleccionado
    switch (_tabController.index) {
      case 1: // Activas
        filtered = filtered
            .where((store) => store['status'] == 'active')
            .toList();
        break;
      case 2: // Pendientes
        filtered = filtered
            .where((store) => store['status'] == 'pending')
            .toList();
        break;
      case 3: // Suspendidas
        filtered = filtered
            .where((store) => store['status'] == 'suspended')
            .toList();
        break;
    }

    // Filtrar por rendimiento
    if (_selectedFilter != 'all') {
      switch (_selectedFilter) {
        case 'high_performance':
          filtered = filtered
              .where(
                (store) =>
                    store['averageRating'] >= 4.5 &&
                    store['fulfillmentRate'] >= 95.0,
              )
              .toList();
          break;
        case 'low_performance':
          filtered = filtered
              .where(
                (store) =>
                    store['averageRating'] < 4.0 ||
                    store['fulfillmentRate'] < 90.0,
              )
              .toList();
          break;
        case 'issues':
          filtered = filtered
              .where((store) => store['issuesCount'] > 0)
              .toList();
          break;
      }
    }

    // Filtrar por búsqueda
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered
          .where(
            (store) =>
                store['name'].toLowerCase().contains(searchTerm) ||
                store['ownerName'].toLowerCase().contains(searchTerm) ||
                store['category'].toLowerCase().contains(searchTerm),
          )
          .toList();
    }

    // Ordenar
    switch (_selectedSortBy) {
      case 'recent':
        filtered.sort(
          (a, b) => (b['lastActive'] as DateTime).compareTo(
            a['lastActive'] as DateTime,
          ),
        );
        break;
      case 'name':
        filtered.sort((a, b) => a['name'].compareTo(b['name']));
        break;
      case 'rating':
        filtered.sort(
          (a, b) => (b['averageRating'] as double).compareTo(
            a['averageRating'] as double,
          ),
        );
        break;
      case 'revenue':
        filtered.sort(
          (a, b) => (b['monthlyRevenue'] as double).compareTo(
            a['monthlyRevenue'] as double,
          ),
        );
        break;
      case 'orders':
        filtered.sort(
          (a, b) =>
              (b['totalOrders'] as int).compareTo(a['totalOrders'] as int),
        );
        break;
    }

    return filtered;
  }

  Map<String, int> get _storeCounts {
    return {
      'all': _allStores.length,
      'active': _allStores.where((s) => s['status'] == 'active').length,
      'pending': _allStores.where((s) => s['status'] == 'pending').length,
      'suspended': _allStores.where((s) => s['status'] == 'suspended').length,
    };
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

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'active':
        return 'Activa';
      case 'pending':
        return 'Pendiente';
      case 'suspended':
        return 'Suspendida';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'suspended':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  void _approveStore(String storeId) {
    setState(() {
      final storeIndex = _allStores.indexWhere((s) => s['id'] == storeId);
      if (storeIndex != -1) {
        _allStores[storeIndex]['status'] = 'active';
        _allStores[storeIndex]['approvedAt'] = DateTime.now();
        _allStores[storeIndex]['verified'] = true;
      }
    });

    final store = _allStores.firstWhere((s) => s['id'] == storeId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${store['name']} ha sido aprobada'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _rejectStore(String storeId, String reason) {
    setState(() {
      _allStores.removeWhere((s) => s['id'] == storeId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Solicitud de tienda rechazada'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _suspendStore(String storeId, String reason) {
    setState(() {
      final storeIndex = _allStores.indexWhere((s) => s['id'] == storeId);
      if (storeIndex != -1) {
        _allStores[storeIndex]['status'] = 'suspended';
        _allStores[storeIndex]['suspensionReason'] = reason;
        _allStores[storeIndex]['suspendedAt'] = DateTime.now();
      }
    });

    final store = _allStores.firstWhere((s) => s['id'] == storeId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${store['name']} ha sido suspendida'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _reactivateStore(String storeId) {
    setState(() {
      final storeIndex = _allStores.indexWhere((s) => s['id'] == storeId);
      if (storeIndex != -1) {
        _allStores[storeIndex]['status'] = 'active';
        _allStores[storeIndex]['suspensionReason'] = null;
        _allStores[storeIndex]['suspendedAt'] = null;
      }
    });

    final store = _allStores.firstWhere((s) => s['id'] == storeId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${store['name']} ha sido reactivada'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleFeatured(String storeId) {
    setState(() {
      final storeIndex = _allStores.indexWhere((s) => s['id'] == storeId);
      if (storeIndex != -1) {
        _allStores[storeIndex]['featured'] =
            !_allStores[storeIndex]['featured'];
      }
    });

    final store = _allStores.firstWhere((s) => s['id'] == storeId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${store['name']} ${store['featured'] ? 'agregada a' : 'removida de'} destacadas',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'hace ${difference.inHours}h';
    } else if (difference.inDays < 30) {
      return 'hace ${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
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
          _buildSearchAndFilters(),
          _buildTabBar(),
          Expanded(child: _buildStoresList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStoreForm(),
        backgroundColor: AppColors.secondary,
        child: Icon(
          Icons.store_mall_directory,
          color: AppColors.textOnSecondary,
        ),
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
        'Gestión de Tiendas',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showCategoriesManagement(),
          icon: Icon(Icons.category, color: AppColors.textSecondary),
          tooltip: 'Gestionar categorías',
        ),
        IconButton(
          onPressed: () {
            setState(() {
              // Refresh data
            });
          },
          icon: Icon(Icons.refresh, color: AppColors.textSecondary),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
          onSelected: (value) {
            switch (value) {
              case 'analytics':
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Analytics próximamente'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                break;
              case 'bulk_actions':
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Acciones masivas próximamente'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'analytics',
              child: Row(
                children: [
                  Icon(Icons.analytics, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Text('Ver analytics'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'bulk_actions',
              child: Row(
                children: [
                  Icon(Icons.checklist, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Text('Acciones masivas'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    final counts = _storeCounts;
    final totalRevenue = _allStores
        .where((s) => s['status'] == 'active')
        .fold(0.0, (sum, store) => sum + store['monthlyRevenue']);
    final averageRating =
        _allStores
            .where((s) => s['status'] == 'active' && s['averageRating'] > 0)
            .fold(0.0, (sum, store) => sum + store['averageRating']) /
        _allStores
            .where((s) => s['status'] == 'active' && s['averageRating'] > 0)
            .length;

    return Container(
      margin: EdgeInsets.all(20),
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
          Text(
            'Resumen de Tiendas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  '${counts['all']}',
                  AppColors.primary,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Activas',
                  '${counts['active']}',
                  AppColors.success,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pendientes',
                  '${counts['pending']}',
                  AppColors.warning,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Ingresos/mes',
                  '\$${(totalRevenue / 1000).toStringAsFixed(1)}k',
                  AppColors.secondary,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Rating prom.',
                  '${averageRating.toStringAsFixed(1)}⭐',
                  AppColors.warning,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Categorías',
                  '${_categories.length}',
                  AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            controller: _searchController,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, propietario o categoría...',
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

          // Filtros
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedFilter,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Filtrar por rendimiento',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text('Todas')),
                    DropdownMenuItem(
                      value: 'high_performance',
                      child: Text('Alto rendimiento'),
                    ),
                    DropdownMenuItem(
                      value: 'low_performance',
                      child: Text('Bajo rendimiento'),
                    ),
                    DropdownMenuItem(
                      value: 'issues',
                      child: Text('Con problemas'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSortBy,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Ordenar por',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'recent',
                      child: Text('Más reciente'),
                    ),
                    DropdownMenuItem(value: 'name', child: Text('Nombre')),
                    DropdownMenuItem(value: 'rating', child: Text('Rating')),
                    DropdownMenuItem(value: 'revenue', child: Text('Ingresos')),
                    DropdownMenuItem(value: 'orders', child: Text('Pedidos')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSortBy = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final counts = _storeCounts;

    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.secondary,
        unselectedLabelColor: AppColors.textSecondary,
        indicator: BoxDecoration(
          color: AppColors.secondaryWithOpacity(0.1),
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
          Tab(text: 'Todas (${counts['all']})'),
          Tab(text: 'Activas (${counts['active']})'),
          Tab(text: 'Pendientes (${counts['pending']})'),
          Tab(text: 'Suspendidas (${counts['suspended']})'),
        ],
      ),
    );
  }

  Widget _buildStoresList() {
    final stores = _filteredStores;

    if (stores.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return _buildStoreCard(store);
      },
    );
  }

  Widget _buildEmptyState() {
    String message = 'No se encontraron tiendas';
    if (_searchController.text.isNotEmpty) {
      message = 'No hay tiendas que coincidan con "${_searchController.text}"';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined, size: 64, color: AppColors.textTertiary),
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
            'Intenta ajustar los filtros o agregar una nueva tienda',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(Map<String, dynamic> store) {
    final statusColor = _getStatusColor(store['status']);
    final performanceScore = _calculatePerformanceScore(store);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: store['featured'] == true
            ? Border.all(color: AppColors.warning, width: 2)
            : store['status'] == 'suspended'
            ? Border.all(color: AppColors.error.withOpacity(0.5))
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
        onTap: () => _showStoreDetails(store),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Header de la tienda
              Row(
                children: [
                  // Avatar de la tienda
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppGradients.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      store['avatar'],
                      color: AppColors.textOnSecondary,
                      size: 30,
                    ),
                  ),

                  SizedBox(width: 16),

                  // Info de la tienda
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                store['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (store['featured'] == true)
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
                                  '⭐ DESTACADA',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textOnPrimary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          store['ownerName'],
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                store['category'],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getStatusDisplayName(store['status']),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            if (store['issuesCount'] > 0) ...[
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
                                  '⚠ ${store['issuesCount']}',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textOnPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Métricas principales
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (store['averageRating'] > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: AppColors.warning,
                              size: 16,
                            ),
                            SizedBox(width: 2),
                            Text(
                              '${store['averageRating'].toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 4),
                      Text(
                        '${store['totalOrders']} pedidos',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '\$${(store['monthlyRevenue'] / 1000).toStringAsFixed(1)}k/mes',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Métricas de rendimiento
              if (store['status'] == 'active') ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildPerformanceMetric(
                          'Cumplimiento',
                          '${store['fulfillmentRate'].toStringAsFixed(1)}%',
                          store['fulfillmentRate'] >= 95.0
                              ? AppColors.success
                              : store['fulfillmentRate'] >= 85.0
                              ? AppColors.warning
                              : AppColors.error,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildPerformanceMetric(
                          'Prep. Prom.',
                          '${store['averagePreparationTime']}min',
                          store['averagePreparationTime'] <= 15
                              ? AppColors.success
                              : store['averagePreparationTime'] <= 25
                              ? AppColors.warning
                              : AppColors.error,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildPerformanceMetric(
                          'Retención',
                          '${store['customerRetentionRate'].toStringAsFixed(1)}%',
                          store['customerRetentionRate'] >= 80.0
                              ? AppColors.success
                              : store['customerRetentionRate'] >= 60.0
                              ? AppColors.warning
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
              ],

              // Información adicional
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        store['location'],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      'Último acceso: ${_formatDateTime(store['lastActive'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              if (store['status'] == 'suspended' &&
                  store['suspensionReason'] != null) ...[
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Suspendida: ${store['suspensionReason']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.error,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],

              SizedBox(height: 12),

              // Botones de acción
              _buildStoreActionButtons(store),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  double _calculatePerformanceScore(Map<String, dynamic> store) {
    if (store['status'] != 'active') return 0.0;

    final rating = store['averageRating'] / 5.0;
    final fulfillment = store['fulfillmentRate'] / 100.0;
    final retention = store['customerRetentionRate'] / 100.0;

    return (rating + fulfillment + retention) / 3.0;
  }

  Widget _buildStoreActionButtons(Map<String, dynamic> store) {
    if (store['status'] == 'pending') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showRejectStoreDialog(store),
              icon: Icon(Icons.close, size: 16),
              label: Text('Rechazar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _approveStore(store['id']),
              icon: Icon(Icons.check, size: 16),
              label: Text('Aprobar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.textOnPrimary,
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        // Ver detalles
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showStoreDetails(store),
            icon: Icon(Icons.visibility, size: 16),
            label: Text('Detalles'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: BorderSide(color: AppColors.border),
            ),
          ),
        ),

        SizedBox(width: 8),

        // Suspender/Reactivar
        if (store['status'] == 'active')
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showSuspendStoreDialog(store),
              icon: Icon(Icons.pause, size: 16),
              label: Text('Suspender'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
              ),
            ),
          )
        else if (store['status'] == 'suspended')
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _reactivateStore(store['id']),
              icon: Icon(Icons.play_arrow, size: 16),
              label: Text('Reactivar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.textOnPrimary,
              ),
            ),
          ),

        SizedBox(width: 8),

        // Menú de opciones adicionales
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showStoreForm(store: store);
                break;
              case 'featured':
                _toggleFeatured(store['id']);
                break;
              case 'config':
                _showStoreConfiguration(store);
                break;
              case 'analytics':
                _showStoreAnalytics(store);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'featured',
              child: Row(
                children: [
                  Icon(
                    store['featured'] ? Icons.star : Icons.star_border,
                    color: AppColors.warning,
                  ),
                  SizedBox(width: 8),
                  Text(
                    store['featured'] ? 'Quitar destacada' : 'Marcar destacada',
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'config',
              child: Row(
                children: [
                  Icon(Icons.settings, color: AppColors.secondary),
                  SizedBox(width: 8),
                  Text('Configuración'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'analytics',
              child: Row(
                children: [
                  Icon(Icons.analytics, color: AppColors.success),
                  SizedBox(width: 8),
                  Text('Analytics'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showStoreDetails(Map<String, dynamic> store) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      store['avatar'],
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
                          store['name'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          store['category'],
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
                      color: _getStatusColor(store['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusDisplayName(store['status']),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(store['status']),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Detalles de la tienda
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('Información General', [
                        _buildDetailRow('Propietario', store['ownerName']),
                        _buildDetailRow('Email', store['email']),
                        _buildDetailRow('Teléfono', store['phone']),
                        _buildDetailRow('Ubicación', store['location']),
                        _buildDetailRow('Descripción', store['description']),
                        _buildDetailRow(
                          'Especialidades',
                          (store['specialties'] as List).join(', '),
                        ),
                      ]),

                      SizedBox(height: 16),

                      if (store['status'] == 'active') ...[
                        _buildDetailSection('Métricas de Rendimiento', [
                          _buildDetailRow(
                            'Pedidos totales',
                            '${store['totalOrders']}',
                          ),
                          _buildDetailRow(
                            'Ingresos totales',
                            '\$${store['totalRevenue'].toStringAsFixed(2)}',
                          ),
                          _buildDetailRow(
                            'Ingresos mensuales',
                            '\$${store['monthlyRevenue'].toStringAsFixed(2)}',
                          ),
                          _buildDetailRow(
                            'Rating promedio',
                            '${store['averageRating']} ⭐ (${store['ratingCount']} reseñas)',
                          ),
                          _buildDetailRow(
                            'Valor promedio pedido',
                            '\$${store['averageOrderValue'].toStringAsFixed(2)}',
                          ),
                          _buildDetailRow(
                            'Tasa de cumplimiento',
                            '${store['fulfillmentRate'].toStringAsFixed(1)}%',
                          ),
                          _buildDetailRow(
                            'Tiempo prep. promedio',
                            '${store['averagePreparationTime']} min',
                          ),
                          _buildDetailRow(
                            'Retención de clientes',
                            '${store['customerRetentionRate'].toStringAsFixed(1)}%',
                          ),
                        ]),

                        SizedBox(height: 16),
                      ],

                      _buildDetailSection('Configuración Operativa', [
                        _buildDetailRow(
                          'Pedido mínimo',
                          '\$${store['minimumOrder'].toStringAsFixed(0)}',
                        ),
                        _buildDetailRow(
                          'Costo de envío',
                          '\$${store['deliveryFee'].toStringAsFixed(0)}',
                        ),
                        _buildDetailRow(
                          'Comisión',
                          '${store['commissionRate']}%',
                        ),
                        _buildDetailRow(
                          'Zonas de entrega',
                          (store['deliveryZones'] as List).join(', '),
                        ),
                        _buildDetailRow(
                          'Métodos de pago',
                          (store['paymentMethods'] as List).join(', '),
                        ),
                      ]),

                      if (store['notes'] != null &&
                          store['notes'].isNotEmpty) ...[
                        SizedBox(height: 16),
                        _buildDetailSection('Notas Administrativas', [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              store['notes'],
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ]),
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
            width: 140,
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

  void _showStoreForm({Map<String, dynamic>? store}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          store == null
              ? 'Formulario de crear tienda próximamente'
              : 'Formulario de editar tienda próximamente',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showRejectStoreDialog(Map<String, dynamic> store) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Rechazar Solicitud',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Estás seguro de que quieres rechazar la solicitud de "${store['name']}"?',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              SizedBox(height: 16),
              TextField(
                controller: reasonController,
                style: TextStyle(color: AppColors.textPrimary),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Motivo del rechazo',
                  hintText: 'Explica el motivo...',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
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
                final reason = reasonController.text.trim();
                if (reason.isNotEmpty) {
                  _rejectStore(store['id'], reason);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Debes proporcionar un motivo'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
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

  void _showSuspendStoreDialog(Map<String, dynamic> store) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Suspender Tienda',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Estás seguro de que quieres suspender "${store['name']}"?',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              SizedBox(height: 16),
              TextField(
                controller: reasonController,
                style: TextStyle(color: AppColors.textPrimary),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Motivo de la suspensión',
                  hintText: 'Explica el motivo...',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
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
                final reason = reasonController.text.trim();
                if (reason.isNotEmpty) {
                  _suspendStore(store['id'], reason);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Debes proporcionar un motivo'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(
                'Suspender',
                style: TextStyle(color: AppColors.textOnPrimary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCategoriesManagement() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gestión de categorías próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showStoreConfiguration(Map<String, dynamic> store) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Configuración de tienda próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showStoreAnalytics(Map<String, dynamic> store) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Analytics de tienda próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
