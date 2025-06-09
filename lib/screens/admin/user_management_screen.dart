// screens/admin/user_management_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _selectedFilter = 'all'; // all, active, inactive, banned
  String _selectedSortBy = 'recent'; // recent, name, email, role

  // Datos simulados de usuarios
  final List<Map<String, dynamic>> _allUsers = [
    // Clientes
    {
      'id': 'user001',
      'name': 'Ana García López',
      'email': 'ana.garcia@estudiante.edu',
      'phone': '+52 555 123 4567',
      'role': 'customer',
      'status': 'active',
      'registeredAt': DateTime.now().subtract(Duration(days: 15)),
      'lastActive': DateTime.now().subtract(Duration(hours: 2)),
      'avatar': Icons.person,
      'totalOrders': 23,
      'totalSpent': 1245.50,
      'averageRating': 4.8,
      'preferredLocation': 'Biblioteca - Sala 3',
      'verified': true,
      'notes': 'Cliente frecuente, siempre puntual',
    },
    {
      'id': 'user002',
      'name': 'Carlos Mendoza Silva',
      'email': 'carlos.mendoza@estudiante.edu',
      'phone': '+52 555 987 6543',
      'role': 'customer',
      'status': 'active',
      'registeredAt': DateTime.now().subtract(Duration(days: 8)),
      'lastActive': DateTime.now().subtract(Duration(minutes: 30)),
      'avatar': Icons.person,
      'totalOrders': 12,
      'totalSpent': 680.25,
      'averageRating': 4.5,
      'preferredLocation': 'Dormitorio - Cuarto 205',
      'verified': true,
      'notes': '',
    },
    {
      'id': 'user003',
      'name': 'María López Hernández',
      'email': 'maria.lopez@estudiante.edu',
      'phone': '+52 555 456 7890',
      'role': 'customer',
      'status': 'inactive',
      'registeredAt': DateTime.now().subtract(Duration(days: 45)),
      'lastActive': DateTime.now().subtract(Duration(days: 7)),
      'avatar': Icons.person,
      'totalOrders': 5,
      'totalSpent': 234.75,
      'averageRating': 4.2,
      'preferredLocation': 'Aula 301 - Edificio A',
      'verified': false,
      'notes': 'Cuenta inactiva por más de una semana',
    },

    // Tiendas
    {
      'id': 'store001',
      'name': 'Cafetería Central',
      'email': 'cafeteria.central@escuela.edu',
      'phone': '+52 555 111 2222',
      'role': 'store',
      'status': 'active',
      'registeredAt': DateTime.now().subtract(Duration(days: 120)),
      'lastActive': DateTime.now().subtract(Duration(minutes: 15)),
      'avatar': Icons.store,
      'totalOrders': 1456,
      'totalEarnings': 45600.75,
      'averageRating': 4.7,
      'location': 'Edificio Principal - Planta Baja',
      'verified': true,
      'notes': 'Tienda principal, muy popular',
      'category': 'Comida Mexicana',
      'operatingHours': 'L-V: 7:00-18:00, S: 8:00-16:00',
    },
    {
      'id': 'store002',
      'name': 'Pizza Campus',
      'email': 'pizza.campus@escuela.edu',
      'phone': '+52 555 333 4444',
      'role': 'store',
      'status': 'active',
      'registeredAt': DateTime.now().subtract(Duration(days: 85)),
      'lastActive': DateTime.now().subtract(Duration(hours: 1)),
      'avatar': Icons.local_pizza,
      'totalOrders': 892,
      'totalEarnings': 28450.25,
      'averageRating': 4.4,
      'location': 'Edificio B - Planta 1',
      'verified': true,
      'notes': '',
      'category': 'Pizza & Italiana',
      'operatingHours': 'L-D: 11:00-22:00',
    },
    {
      'id': 'store003',
      'name': 'Sushi Express',
      'email': 'sushi.express@escuela.edu',
      'phone': '+52 555 555 6666',
      'role': 'store',
      'status': 'pending',
      'registeredAt': DateTime.now().subtract(Duration(days: 3)),
      'lastActive': DateTime.now().subtract(Duration(hours: 4)),
      'avatar': Icons.restaurant,
      'totalOrders': 0,
      'totalEarnings': 0.0,
      'averageRating': 0.0,
      'location': 'Edificio C - Planta 2',
      'verified': false,
      'notes': 'Pendiente de aprobación por administración',
      'category': 'Sushi & Asiática',
      'operatingHours': 'L-V: 12:00-20:00',
    },

    // Repartidores
    {
      'id': 'delivery001',
      'name': 'Roberto Silva Martínez',
      'email': 'roberto.silva@estudiante.edu',
      'phone': '+52 555 777 8888',
      'role': 'deliverer',
      'status': 'active',
      'registeredAt': DateTime.now().subtract(Duration(days: 35)),
      'lastActive': DateTime.now().subtract(Duration(minutes: 45)),
      'avatar': Icons.delivery_dining,
      'totalDeliveries': 156,
      'totalEarnings': 3120.50,
      'averageRating': 4.9,
      'preferredZones': ['Edificios A-B', 'Dormitorios'],
      'verified': true,
      'notes': 'Repartidor estrella, muy confiable',
      'isAvailable': true,
      'vehicleType': 'A pie',
    },
    {
      'id': 'delivery002',
      'name': 'Laura Hernández Cruz',
      'email': 'laura.hernandez@estudiante.edu',
      'phone': '+52 555 999 0000',
      'role': 'deliverer',
      'status': 'active',
      'registeredAt': DateTime.now().subtract(Duration(days: 22)),
      'lastActive': DateTime.now().subtract(Duration(hours: 3)),
      'avatar': Icons.delivery_dining,
      'totalDeliveries': 89,
      'totalEarnings': 1780.25,
      'averageRating': 4.6,
      'preferredZones': ['Biblioteca', 'Cafetería'],
      'verified': true,
      'notes': '',
      'isAvailable': false,
      'vehicleType': 'A pie',
    },
    {
      'id': 'delivery003',
      'name': 'José Martínez Ruiz',
      'email': 'jose.martinez@estudiante.edu',
      'phone': '+52 555 111 0000',
      'role': 'deliverer',
      'status': 'banned',
      'registeredAt': DateTime.now().subtract(Duration(days: 60)),
      'lastActive': DateTime.now().subtract(Duration(days: 14)),
      'avatar': Icons.delivery_dining,
      'totalDeliveries': 45,
      'totalEarnings': 900.0,
      'averageRating': 3.2,
      'preferredZones': ['Campus General'],
      'verified': false,
      'notes': 'Suspendido por múltiples quejas de clientes',
      'isAvailable': false,
      'vehicleType': 'A pie',
      'banReason': 'Incumplimiento de horarios y quejas de servicio',
    },
  ];

  List<Map<String, dynamic>> get _filteredUsers {
    List<Map<String, dynamic>> filtered = _allUsers;

    // Filtrar por tab seleccionado
    switch (_tabController.index) {
      case 1: // Clientes
        filtered = filtered
            .where((user) => user['role'] == 'customer')
            .toList();
        break;
      case 2: // Tiendas
        filtered = filtered.where((user) => user['role'] == 'store').toList();
        break;
      case 3: // Repartidores
        filtered = filtered
            .where((user) => user['role'] == 'deliverer')
            .toList();
        break;
    }

    // Filtrar por estado
    if (_selectedFilter != 'all') {
      filtered = filtered
          .where((user) => user['status'] == _selectedFilter)
          .toList();
    }

    // Filtrar por búsqueda
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered
          .where(
            (user) =>
                user['name'].toLowerCase().contains(searchTerm) ||
                user['email'].toLowerCase().contains(searchTerm) ||
                user['role'].toLowerCase().contains(searchTerm),
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
      case 'email':
        filtered.sort((a, b) => a['email'].compareTo(b['email']));
        break;
      case 'role':
        filtered.sort((a, b) => a['role'].compareTo(b['role']));
        break;
    }

    return filtered;
  }

  Map<String, int> get _userCounts {
    return {
      'all': _allUsers.length,
      'customers': _allUsers.where((u) => u['role'] == 'customer').length,
      'stores': _allUsers.where((u) => u['role'] == 'store').length,
      'deliverers': _allUsers.where((u) => u['role'] == 'deliverer').length,
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

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'customer':
        return 'Cliente';
      case 'store':
        return 'Tienda';
      case 'deliverer':
        return 'Repartidor';
      case 'admin':
        return 'Administrador';
      default:
        return role;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'active':
        return 'Activo';
      case 'inactive':
        return 'Inactivo';
      case 'pending':
        return 'Pendiente';
      case 'banned':
        return 'Suspendido';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.success;
      case 'inactive':
        return AppColors.warning;
      case 'pending':
        return AppColors.primary;
      case 'banned':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'customer':
        return AppColors.primary;
      case 'store':
        return AppColors.secondary;
      case 'deliverer':
        return AppColors.warning;
      case 'admin':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  void _toggleUserStatus(String userId) {
    setState(() {
      final userIndex = _allUsers.indexWhere((u) => u['id'] == userId);
      if (userIndex != -1) {
        final currentStatus = _allUsers[userIndex]['status'];
        if (currentStatus == 'active') {
          _allUsers[userIndex]['status'] = 'inactive';
        } else if (currentStatus == 'inactive') {
          _allUsers[userIndex]['status'] = 'active';
        }
      }
    });

    final user = _allUsers.firstWhere((u) => u['id'] == userId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${user['name']} ${user['status'] == 'active' ? 'activado' : 'desactivado'}',
        ),
        backgroundColor: user['status'] == 'active'
            ? AppColors.success
            : AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _changeUserRole(String userId, String newRole) {
    setState(() {
      final userIndex = _allUsers.indexWhere((u) => u['id'] == userId);
      if (userIndex != -1) {
        _allUsers[userIndex]['role'] = newRole;
      }
    });

    final user = _allUsers.firstWhere((u) => u['id'] == userId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Rol de ${user['name']} cambiado a ${_getRoleDisplayName(newRole)}',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _banUser(String userId, String reason) {
    setState(() {
      final userIndex = _allUsers.indexWhere((u) => u['id'] == userId);
      if (userIndex != -1) {
        _allUsers[userIndex]['status'] = 'banned';
        _allUsers[userIndex]['banReason'] = reason;
      }
    });

    final user = _allUsers.firstWhere((u) => u['id'] == userId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${user['name']} ha sido suspendido'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteUser(String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final user = _allUsers.firstWhere((u) => u['id'] == userId);
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Eliminar Usuario',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar a "${user['name']}"? Esta acción no se puede deshacer.',
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
                setState(() {
                  _allUsers.removeWhere((u) => u['id'] == userId);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Usuario eliminado'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(
                'Eliminar',
                style: TextStyle(color: AppColors.textOnPrimary),
              ),
            ),
          ],
        );
      },
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
          Expanded(child: _buildUsersList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserForm(),
        backgroundColor: AppColors.primary,
        child: Icon(Icons.person_add, color: AppColors.textOnPrimary),
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
        'Gestión de Usuarios',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
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
              case 'export':
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Función de exportar próximamente'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                break;
              case 'import':
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Función de importar próximamente'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Text('Exportar usuarios'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'import',
              child: Row(
                children: [
                  Icon(Icons.upload, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Text('Importar usuarios'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    final counts = _userCounts;
    final activeUsers = _allUsers.where((u) => u['status'] == 'active').length;
    final pendingUsers = _allUsers
        .where((u) => u['status'] == 'pending')
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
            'Resumen de Usuarios',
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
                  'Activos',
                  '$activeUsers',
                  AppColors.success,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pendientes',
                  '$pendingUsers',
                  AppColors.warning,
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
              hintText: 'Buscar por nombre, email o rol...',
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
                    labelText: 'Filtrar por estado',
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
                    DropdownMenuItem(value: 'all', child: Text('Todos')),
                    DropdownMenuItem(value: 'active', child: Text('Activos')),
                    DropdownMenuItem(
                      value: 'inactive',
                      child: Text('Inactivos'),
                    ),
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text('Pendientes'),
                    ),
                    DropdownMenuItem(
                      value: 'banned',
                      child: Text('Suspendidos'),
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
                    DropdownMenuItem(value: 'email', child: Text('Email')),
                    DropdownMenuItem(value: 'role', child: Text('Rol')),
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
    final counts = _userCounts;

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
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        onTap: (index) {
          setState(() {});
        },
        tabs: [
          Tab(text: 'Todos (${counts['all']})'),
          Tab(text: 'Clientes (${counts['customers']})'),
          Tab(text: 'Tiendas (${counts['stores']})'),
          Tab(text: 'Repartidores (${counts['deliverers']})'),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    final users = _filteredUsers;

    if (users.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildEmptyState() {
    String message = 'No se encontraron usuarios';
    if (_searchController.text.isNotEmpty) {
      message = 'No hay usuarios que coincidan con "${_searchController.text}"';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppColors.textTertiary),
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
            'Intenta ajustar los filtros o agregar un nuevo usuario',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final statusColor = _getStatusColor(user['status']);
    final roleColor = _getRoleColor(user['role']);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: user['status'] == 'banned'
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
        onTap: () => _showUserDetails(user),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Header del usuario
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: roleColor.withOpacity(0.3)),
                    ),
                    child: Icon(user['avatar'], color: roleColor, size: 25),
                  ),

                  SizedBox(width: 16),

                  // Info del usuario
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (user['verified'] == true)
                              Icon(
                                Icons.verified,
                                color: AppColors.primary,
                                size: 16,
                              ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          user['email'],
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
                                color: roleColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getRoleDisplayName(user['role']),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: roleColor,
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
                                _getStatusDisplayName(user['status']),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Información específica por rol
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (user['role'] == 'customer') ...[
                        Text(
                          '${user['totalOrders']} pedidos',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '\$${user['totalSpent'].toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ] else if (user['role'] == 'store') ...[
                        Text(
                          '${user['totalOrders']} órdenes',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '\$${(user['totalEarnings'] / 1000).toStringAsFixed(1)}k',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ] else if (user['role'] == 'deliverer') ...[
                        Text(
                          '${user['totalDeliveries']} entregas',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '\$${user['totalEarnings'].toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                      if (user['averageRating'] > 0) ...[
                        SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: AppColors.warning,
                              size: 12,
                            ),
                            SizedBox(width: 2),
                            Text(
                              '${user['averageRating'].toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12),

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
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Último acceso: ${_formatDateTime(user['lastActive'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Registro: ${_formatDateTime(user['registeredAt'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              if (user['status'] == 'banned' && user['banReason'] != null) ...[
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Suspendido: ${user['banReason']}',
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
              _buildUserActionButtons(user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserActionButtons(Map<String, dynamic> user) {
    return Row(
      children: [
        // Ver detalles
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showUserDetails(user),
            icon: Icon(Icons.visibility, size: 16),
            label: Text('Detalles'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: BorderSide(color: AppColors.border),
            ),
          ),
        ),

        SizedBox(width: 8),

        // Activar/Desactivar
        if (user['status'] != 'banned' && user['status'] != 'pending')
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _toggleUserStatus(user['id']),
              icon: Icon(
                user['status'] == 'active' ? Icons.pause : Icons.play_arrow,
                size: 16,
              ),
              label: Text(user['status'] == 'active' ? 'Pausar' : 'Activar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: user['status'] == 'active'
                    ? AppColors.warning
                    : AppColors.success,
                side: BorderSide(
                  color: user['status'] == 'active'
                      ? AppColors.warning
                      : AppColors.success,
                ),
              ),
            ),
          ),

        if (user['status'] == 'pending')
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _toggleUserStatus(user['id']),
              icon: Icon(Icons.check, size: 16),
              label: Text('Aprobar'),
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
                _showUserForm(user: user);
                break;
              case 'change_role':
                _showChangeRoleDialog(user);
                break;
              case 'ban':
                _showBanUserDialog(user);
                break;
              case 'delete':
                _deleteUser(user['id']);
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
              value: 'change_role',
              child: Row(
                children: [
                  Icon(Icons.swap_horiz, color: AppColors.secondary),
                  SizedBox(width: 8),
                  Text('Cambiar rol'),
                ],
              ),
            ),
            if (user['status'] != 'banned')
              PopupMenuItem(
                value: 'ban',
                child: Row(
                  children: [
                    Icon(Icons.block, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Suspender'),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Eliminar'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
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
                      color: _getRoleColor(user['role']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getRoleColor(user['role']).withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      user['avatar'],
                      color: _getRoleColor(user['role']),
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          _getRoleDisplayName(user['role']),
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
                      color: _getStatusColor(user['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusDisplayName(user['status']),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(user['status']),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Detalles específicos por rol
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('Información Personal', [
                        _buildDetailRow('Email', user['email']),
                        _buildDetailRow('Teléfono', user['phone']),
                        _buildDetailRow('ID de Usuario', user['id']),
                        _buildDetailRow(
                          'Registro',
                          _formatDateTime(user['registeredAt']),
                        ),
                        _buildDetailRow(
                          'Último acceso',
                          _formatDateTime(user['lastActive']),
                        ),
                        _buildDetailRow(
                          'Verificado',
                          user['verified'] ? 'Sí' : 'No',
                        ),
                      ]),

                      SizedBox(height: 16),

                      if (user['role'] == 'customer') ...[
                        _buildDetailSection('Estadísticas de Cliente', [
                          _buildDetailRow(
                            'Total de pedidos',
                            '${user['totalOrders']}',
                          ),
                          _buildDetailRow(
                            'Total gastado',
                            '\$${user['totalSpent'].toStringAsFixed(2)}',
                          ),
                          _buildDetailRow(
                            'Calificación promedio',
                            '${user['averageRating']} ⭐',
                          ),
                          _buildDetailRow(
                            'Ubicación preferida',
                            user['preferredLocation'],
                          ),
                        ]),
                      ] else if (user['role'] == 'store') ...[
                        _buildDetailSection('Información de Tienda', [
                          _buildDetailRow('Categoría', user['category']),
                          _buildDetailRow('Ubicación', user['location']),
                          _buildDetailRow('Horarios', user['operatingHours']),
                          _buildDetailRow(
                            'Órdenes totales',
                            '${user['totalOrders']}',
                          ),
                          _buildDetailRow(
                            'Ganancias totales',
                            '\$${user['totalEarnings'].toStringAsFixed(2)}',
                          ),
                          _buildDetailRow(
                            'Calificación promedio',
                            '${user['averageRating']} ⭐',
                          ),
                        ]),
                      ] else if (user['role'] == 'deliverer') ...[
                        _buildDetailSection('Información de Repartidor', [
                          _buildDetailRow(
                            'Entregas totales',
                            '${user['totalDeliveries']}',
                          ),
                          _buildDetailRow(
                            'Ganancias totales',
                            '\$${user['totalEarnings'].toStringAsFixed(2)}',
                          ),
                          _buildDetailRow(
                            'Calificación promedio',
                            '${user['averageRating']} ⭐',
                          ),
                          _buildDetailRow(
                            'Tipo de vehículo',
                            user['vehicleType'],
                          ),
                          _buildDetailRow(
                            'Disponible',
                            user['isAvailable'] ? 'Sí' : 'No',
                          ),
                          _buildDetailRow(
                            'Zonas preferidas',
                            (user['preferredZones'] as List).join(', '),
                          ),
                        ]),
                      ],

                      if (user['notes'] != null &&
                          user['notes'].isNotEmpty) ...[
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
                              user['notes'],
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
            width: 120,
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

  void _showUserForm({Map<String, dynamic>? user}) {
    // Implementar formulario para crear/editar usuario
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          user == null
              ? 'Formulario de crear usuario próximamente'
              : 'Formulario de editar usuario próximamente',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showChangeRoleDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedRole = user['role'];
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text(
                'Cambiar Rol de Usuario',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '¿Qué rol quieres asignar a ${user['name']}?',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 16),
                  DropdownButton<String>(
                    value: selectedRole,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(
                        value: 'customer',
                        child: Text('Cliente'),
                      ),
                      DropdownMenuItem(value: 'store', child: Text('Tienda')),
                      DropdownMenuItem(
                        value: 'deliverer',
                        child: Text('Repartidor'),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('Administrador'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
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
                    _changeUserRole(user['id'], selectedRole);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(
                    'Cambiar',
                    style: TextStyle(color: AppColors.textOnPrimary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBanUserDialog(Map<String, dynamic> user) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Suspender Usuario',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Estás seguro de que quieres suspender a ${user['name']}?',
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
                  _banUser(user['id'], reason);
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
}
