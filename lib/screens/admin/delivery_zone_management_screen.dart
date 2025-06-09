// screens/admin/delivery_zone_management_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DeliveryZoneManagementScreen extends StatefulWidget {
  @override
  _DeliveryZoneManagementScreenState createState() =>
      _DeliveryZoneManagementScreenState();
}

class _DeliveryZoneManagementScreenState
    extends State<DeliveryZoneManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _selectedFilter = 'all'; // all, high_traffic, low_traffic, restricted
  String _selectedZoneType = 'all'; // all, building, outdoor, special

  // Configuración del geofence principal del campus
  final Map<String, dynamic> _campusGeofence = {
    'name': 'Campus Principal',
    'isActive': true,
    'center': {
      'lat': 19.4326,
      'lng': -99.1332,
    }, // Coordenadas del centro del campus
    'radius': 500.0, // metros
    'points': [
      {'lat': 19.4340, 'lng': -99.1345, 'name': 'Esquina Norte'},
      {'lat': 19.4340, 'lng': -99.1319, 'name': 'Esquina Noreste'},
      {'lat': 19.4312, 'lng': -99.1319, 'name': 'Esquina Sureste'},
      {'lat': 19.4312, 'lng': -99.1345, 'name': 'Esquina Suroeste'},
    ],
    'lastUpdated': DateTime.now().subtract(Duration(days: 30)),
    'totalArea': 125000, // metros cuadrados
  };

  // Puntos de entrega predefinidos
  List<Map<String, dynamic>> _deliveryPoints = [
    // Edificios académicos
    {
      'id': 'point001',
      'name': 'Edificio A - Aula 101',
      'type': 'building',
      'zone': 'Zona Académica Norte',
      'building': 'Edificio A',
      'floor': 1,
      'coordinates': {'lat': 19.4335, 'lng': -99.1340},
      'isActive': true,
      'accessLevel': 'public', // public, restricted, private
      'estimatedDeliveryTime': 8,
      'popularityScore': 95,
      'weeklyDeliveries': 45,
      'averageWaitTime': 3.2,
      'accessInstructions': 'Entrada principal, primer piso',
      'restrictions': [],
      'operatingHours': {
        'monday': {'start': '07:00', 'end': '20:00'},
        'tuesday': {'start': '07:00', 'end': '20:00'},
        'wednesday': {'start': '07:00', 'end': '20:00'},
        'thursday': {'start': '07:00', 'end': '20:00'},
        'friday': {'start': '07:00', 'end': '18:00'},
        'saturday': {'start': '08:00', 'end': '14:00'},
        'sunday': {'start': 'closed', 'end': 'closed'},
      },
      'lastDelivery': DateTime.now().subtract(Duration(minutes: 15)),
      'totalDeliveries': 1245,
      'issues': [],
    },

    {
      'id': 'point002',
      'name': 'Biblioteca Central - Sala de Estudio 3',
      'type': 'building',
      'zone': 'Zona Académica Central',
      'building': 'Biblioteca',
      'floor': 2,
      'coordinates': {'lat': 19.4330, 'lng': -99.1335},
      'isActive': true,
      'accessLevel': 'public',
      'estimatedDeliveryTime': 6,
      'popularityScore': 88,
      'weeklyDeliveries': 38,
      'averageWaitTime': 2.8,
      'accessInstructions': 'Segundo piso, área de estudio silencioso',
      'restrictions': ['no_food_allowed', 'quiet_zone'],
      'operatingHours': {
        'monday': {'start': '08:00', 'end': '22:00'},
        'tuesday': {'start': '08:00', 'end': '22:00'},
        'wednesday': {'start': '08:00', 'end': '22:00'},
        'thursday': {'start': '08:00', 'end': '22:00'},
        'friday': {'start': '08:00', 'end': '20:00'},
        'saturday': {'start': '09:00', 'end': '18:00'},
        'sunday': {'start': '10:00', 'end': '18:00'},
      },
      'lastDelivery': DateTime.now().subtract(Duration(hours: 2)),
      'totalDeliveries': 892,
      'issues': ['noise_complaints'],
    },

    {
      'id': 'point003',
      'name': 'Dormitorio - Cuarto 205',
      'type': 'building',
      'zone': 'Zona Residencial',
      'building': 'Dormitorio Principal',
      'floor': 2,
      'coordinates': {'lat': 19.4325, 'lng': -99.1325},
      'isActive': true,
      'accessLevel': 'restricted',
      'estimatedDeliveryTime': 12,
      'popularityScore': 76,
      'weeklyDeliveries': 28,
      'averageWaitTime': 5.1,
      'accessInstructions': 'Entrada por recepción, segundo piso',
      'restrictions': ['id_required', 'visitor_registration'],
      'operatingHours': {
        'monday': {'start': '06:00', 'end': '23:00'},
        'tuesday': {'start': '06:00', 'end': '23:00'},
        'wednesday': {'start': '06:00', 'end': '23:00'},
        'thursday': {'start': '06:00', 'end': '23:00'},
        'friday': {'start': '06:00', 'end': '24:00'},
        'saturday': {'start': '06:00', 'end': '24:00'},
        'sunday': {'start': '06:00', 'end': '23:00'},
      },
      'lastDelivery': DateTime.now().subtract(Duration(minutes: 45)),
      'totalDeliveries': 567,
      'issues': [],
    },

    // Áreas al aire libre
    {
      'id': 'point004',
      'name': 'Patio Central - Fuente Principal',
      'type': 'outdoor',
      'zone': 'Zona Central',
      'building': null,
      'floor': 0,
      'coordinates': {'lat': 19.4328, 'lng': -99.1332},
      'isActive': true,
      'accessLevel': 'public',
      'estimatedDeliveryTime': 5,
      'popularityScore': 92,
      'weeklyDeliveries': 52,
      'averageWaitTime': 1.5,
      'accessInstructions': 'Área abierta cerca de la fuente',
      'restrictions': ['weather_dependent'],
      'operatingHours': {
        'monday': {'start': '06:00', 'end': '22:00'},
        'tuesday': {'start': '06:00', 'end': '22:00'},
        'wednesday': {'start': '06:00', 'end': '22:00'},
        'thursday': {'start': '06:00', 'end': '22:00'},
        'friday': {'start': '06:00', 'end': '22:00'},
        'saturday': {'start': '06:00', 'end': '22:00'},
        'sunday': {'start': '06:00', 'end': '22:00'},
      },
      'lastDelivery': DateTime.now().subtract(Duration(minutes: 8)),
      'totalDeliveries': 1678,
      'issues': [],
    },

    {
      'id': 'point005',
      'name': 'Cafetería - Mesa 15',
      'type': 'special',
      'zone': 'Zona de Servicios',
      'building': 'Cafetería Principal',
      'floor': 1,
      'coordinates': {'lat': 19.4332, 'lng': -99.1338},
      'isActive': true,
      'accessLevel': 'public',
      'estimatedDeliveryTime': 4,
      'popularityScore': 99,
      'weeklyDeliveries': 78,
      'averageWaitTime': 2.0,
      'accessInstructions': 'Mesa cerca de la entrada principal',
      'restrictions': ['high_traffic_area'],
      'operatingHours': {
        'monday': {'start': '07:00', 'end': '19:00'},
        'tuesday': {'start': '07:00', 'end': '19:00'},
        'wednesday': {'start': '07:00', 'end': '19:00'},
        'thursday': {'start': '07:00', 'end': '19:00'},
        'friday': {'start': '07:00', 'end': '19:00'},
        'saturday': {'start': '08:00', 'end': '17:00'},
        'sunday': {'start': '08:00', 'end': '17:00'},
      },
      'lastDelivery': DateTime.now().subtract(Duration(minutes: 3)),
      'totalDeliveries': 2134,
      'issues': [],
    },

    {
      'id': 'point006',
      'name': 'Laboratorio de Química - Entrada',
      'type': 'building',
      'zone': 'Zona de Laboratorios',
      'building': 'Edificio C',
      'floor': 1,
      'coordinates': {'lat': 19.4315, 'lng': -99.1330},
      'isActive': false,
      'accessLevel': 'restricted',
      'estimatedDeliveryTime': 15,
      'popularityScore': 23,
      'weeklyDeliveries': 5,
      'averageWaitTime': 8.2,
      'accessInstructions': 'Entrada por el costado este del edificio',
      'restrictions': ['safety_protocols', 'no_food_in_lab', 'id_required'],
      'operatingHours': {
        'monday': {'start': '08:00', 'end': '17:00'},
        'tuesday': {'start': '08:00', 'end': '17:00'},
        'wednesday': {'start': '08:00', 'end': '17:00'},
        'thursday': {'start': '08:00', 'end': '17:00'},
        'friday': {'start': '08:00', 'end': '17:00'},
        'saturday': {'start': 'closed', 'end': 'closed'},
        'sunday': {'start': 'closed', 'end': 'closed'},
      },
      'lastDelivery': DateTime.now().subtract(Duration(days: 3)),
      'totalDeliveries': 89,
      'issues': ['access_restrictions', 'safety_concerns'],
    },

    {
      'id': 'point007',
      'name': 'Gimnasio - Área de Descanso',
      'type': 'special',
      'zone': 'Zona Deportiva',
      'building': 'Complejo Deportivo',
      'floor': 1,
      'coordinates': {'lat': 19.4320, 'lng': -99.1345},
      'isActive': true,
      'accessLevel': 'public',
      'estimatedDeliveryTime': 10,
      'popularityScore': 67,
      'weeklyDeliveries': 22,
      'averageWaitTime': 4.5,
      'accessInstructions': 'Área de descanso junto a las canchas',
      'restrictions': ['sports_equipment_area', 'locker_access_only'],
      'operatingHours': {
        'monday': {'start': '06:00', 'end': '21:00'},
        'tuesday': {'start': '06:00', 'end': '21:00'},
        'wednesday': {'start': '06:00', 'end': '21:00'},
        'thursday': {'start': '06:00', 'end': '21:00'},
        'friday': {'start': '06:00', 'end': '21:00'},
        'saturday': {'start': '08:00', 'end': '20:00'},
        'sunday': {'start': '08:00', 'end': '20:00'},
      },
      'lastDelivery': DateTime.now().subtract(Duration(hours: 6)),
      'totalDeliveries': 445,
      'issues': [],
    },
  ];

  // Zonas del campus
  final List<Map<String, dynamic>> _campusZones = [
    {
      'id': 'zone001',
      'name': 'Zona Académica Norte',
      'type': 'academic',
      'color': AppColors.primary,
      'isActive': true,
      'deliveryPoints': 8,
      'averageDeliveryTime': 7.2,
      'weeklyDeliveries': 145,
      'restrictions': ['quiet_hours_after_10pm'],
      'priorityLevel': 'high',
    },
    {
      'id': 'zone002',
      'name': 'Zona Académica Central',
      'type': 'academic',
      'color': AppColors.secondary,
      'isActive': true,
      'deliveryPoints': 12,
      'averageDeliveryTime': 6.8,
      'weeklyDeliveries': 198,
      'restrictions': [],
      'priorityLevel': 'high',
    },
    {
      'id': 'zone003',
      'name': 'Zona Residencial',
      'type': 'residential',
      'color': AppColors.warning,
      'isActive': true,
      'deliveryPoints': 15,
      'averageDeliveryTime': 9.5,
      'weeklyDeliveries': 267,
      'restrictions': ['id_required', 'visitor_registration'],
      'priorityLevel': 'medium',
    },
    {
      'id': 'zone004',
      'name': 'Zona de Servicios',
      'type': 'services',
      'color': AppColors.success,
      'isActive': true,
      'deliveryPoints': 6,
      'averageDeliveryTime': 4.2,
      'weeklyDeliveries': 89,
      'restrictions': ['high_traffic_area'],
      'priorityLevel': 'high',
    },
    {
      'id': 'zone005',
      'name': 'Zona de Laboratorios',
      'type': 'labs',
      'color': AppColors.error,
      'isActive': true,
      'deliveryPoints': 4,
      'averageDeliveryTime': 12.8,
      'weeklyDeliveries': 23,
      'restrictions': ['safety_protocols', 'no_food_in_labs'],
      'priorityLevel': 'low',
    },
    {
      'id': 'zone006',
      'name': 'Zona Deportiva',
      'type': 'sports',
      'color': AppColors.textSecondary,
      'isActive': true,
      'deliveryPoints': 3,
      'averageDeliveryTime': 8.9,
      'weeklyDeliveries': 45,
      'restrictions': ['equipment_area'],
      'priorityLevel': 'medium',
    },
  ];

  // Rutas populares
  final List<Map<String, dynamic>> _popularRoutes = [
    {
      'id': 'route001',
      'name': 'Cafetería → Biblioteca',
      'startPoint': 'Cafetería - Mesa 15',
      'endPoint': 'Biblioteca Central - Sala de Estudio 3',
      'distance': 120.0, // metros
      'averageTime': 3.2, // minutos
      'weeklyUsage': 89,
      'difficulty': 'easy',
      'popularTimes': ['12:00-14:00', '18:00-20:00'],
    },
    {
      'id': 'route002',
      'name': 'Cafetería → Dormitorios',
      'startPoint': 'Cafetería - Mesa 15',
      'endPoint': 'Dormitorio - Cuarto 205',
      'distance': 280.0,
      'averageTime': 6.8,
      'weeklyUsage': 156,
      'difficulty': 'medium',
      'popularTimes': ['19:00-22:00'],
    },
    {
      'id': 'route003',
      'name': 'Patio Central → Edificio A',
      'startPoint': 'Patio Central - Fuente Principal',
      'endPoint': 'Edificio A - Aula 101',
      'distance': 95.0,
      'averageTime': 2.5,
      'weeklyUsage': 67,
      'difficulty': 'easy',
      'popularTimes': ['07:00-09:00', '13:00-15:00'],
    },
  ];

  List<Map<String, dynamic>> get _filteredDeliveryPoints {
    List<Map<String, dynamic>> filtered = _deliveryPoints;

    // Filtrar por tab seleccionado
    switch (_tabController.index) {
      case 1: // Puntos de entrega
        // Ya está filtrado
        break;
      case 2: // Zonas
        return []; // No aplica para esta vista
      case 3: // Rutas
        return []; // No aplica para esta vista
    }

    // Filtrar por tipo de zona
    if (_selectedZoneType != 'all') {
      filtered = filtered
          .where((point) => point['type'] == _selectedZoneType)
          .toList();
    }

    // Filtrar por tráfico
    if (_selectedFilter != 'all') {
      switch (_selectedFilter) {
        case 'high_traffic':
          filtered = filtered
              .where((point) => point['weeklyDeliveries'] >= 40)
              .toList();
          break;
        case 'low_traffic':
          filtered = filtered
              .where((point) => point['weeklyDeliveries'] < 20)
              .toList();
          break;
        case 'restricted':
          filtered = filtered
              .where((point) => point['restrictions'].isNotEmpty)
              .toList();
          break;
      }
    }

    // Filtrar por búsqueda
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered
          .where(
            (point) =>
                point['name'].toLowerCase().contains(searchTerm) ||
                point['zone'].toLowerCase().contains(searchTerm) ||
                (point['building']?.toLowerCase().contains(searchTerm) ??
                    false),
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

  String _getPointTypeDisplayName(String type) {
    switch (type) {
      case 'building':
        return 'Edificio';
      case 'outdoor':
        return 'Exterior';
      case 'special':
        return 'Especial';
      default:
        return type;
    }
  }

  String _getAccessLevelDisplayName(String level) {
    switch (level) {
      case 'public':
        return 'Público';
      case 'restricted':
        return 'Restringido';
      case 'private':
        return 'Privado';
      default:
        return level;
    }
  }

  Color _getAccessLevelColor(String level) {
    switch (level) {
      case 'public':
        return AppColors.success;
      case 'restricted':
        return AppColors.warning;
      case 'private':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getRouteDifficultyDisplayName(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 'Fácil';
      case 'medium':
        return 'Media';
      case 'hard':
        return 'Difícil';
      default:
        return difficulty;
    }
  }

  Color _getRouteDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  void _togglePointStatus(String pointId) {
    setState(() {
      final pointIndex = _deliveryPoints.indexWhere((p) => p['id'] == pointId);
      if (pointIndex != -1) {
        _deliveryPoints[pointIndex]['isActive'] =
            !_deliveryPoints[pointIndex]['isActive'];
      }
    });

    final point = _deliveryPoints.firstWhere((p) => p['id'] == pointId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${point['name']} ${point['isActive'] ? 'activado' : 'desactivado'}',
        ),
        backgroundColor: point['isActive']
            ? AppColors.success
            : AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteDeliveryPoint(String pointId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final point = _deliveryPoints.firstWhere((p) => p['id'] == pointId);
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Eliminar Punto de Entrega',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar "${point['name']}"?',
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
                  _deliveryPoints.removeWhere((p) => p['id'] == pointId);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Punto de entrega eliminado'),
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

  List<Map<String, dynamic>> _getTopDeliveryPoints() {
    final activePoints = _deliveryPoints.where((p) => p['isActive']).toList();
    activePoints.sort(
      (a, b) => (b['weeklyDeliveries'] as int).compareTo(
        a['weeklyDeliveries'] as int,
      ),
    );
    return activePoints.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildGeofenceStatus(),
          _buildTabBar(),
          if (_tabController.index == 1) _buildSearchAndFilters(),
          Expanded(child: _buildTabContent()),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
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
        'Gestión de Zonas de Entrega',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showGeofenceConfig(),
          icon: Icon(Icons.radar, color: AppColors.textSecondary),
          tooltip: 'Configurar geofence',
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
              case 'export_map':
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Exportar mapa próximamente'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                break;
              case 'analytics':
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Analytics de zonas próximamente'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'export_map',
              child: Row(
                children: [
                  Icon(Icons.map, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Text('Exportar mapa'),
                ],
              ),
            ),
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
          ],
        ),
      ],
    );
  }

  Widget _buildGeofenceStatus() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: _campusGeofence['isActive']
            ? AppGradients.primary
            : LinearGradient(
                colors: [AppColors.error, AppColors.error.withOpacity(0.7)],
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkWithOpacity(0.2),
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
                  color: AppColors.textOnPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _campusGeofence['isActive']
                      ? Icons.location_on
                      : Icons.location_off,
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
                      'Geofence del Campus',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    Text(
                      _campusGeofence['isActive']
                          ? 'Sistema activo y funcionando'
                          : 'Sistema desactivado',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textOnPrimary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _campusGeofence['isActive'],
                onChanged: (value) {
                  setState(() {
                    _campusGeofence['isActive'] = value;
                  });
                },
                activeColor: AppColors.textOnPrimary,
                activeTrackColor: AppColors.textOnPrimary.withOpacity(0.3),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildGeofenceStatCard(
                  'Radio',
                  '${_campusGeofence['radius'].toStringAsFixed(0)}m',
                  Icons.radar,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildGeofenceStatCard(
                  'Área',
                  '${(_campusGeofence['totalArea'] / 1000).toStringAsFixed(1)}k m²',
                  Icons.area_chart,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildGeofenceStatCard(
                  'Puntos',
                  '${_deliveryPoints.length}',
                  Icons.place,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeofenceStatCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textOnPrimary, size: 16),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnPrimary,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textOnPrimary.withOpacity(0.8),
            ),
          ),
        ],
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
        labelColor: AppColors.warning,
        unselectedLabelColor: AppColors.textSecondary,
        indicator: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
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
          Tab(text: 'Resumen'),
          Tab(text: 'Puntos (${_deliveryPoints.length})'),
          Tab(text: 'Zonas (${_campusZones.length})'),
          Tab(text: 'Rutas (${_popularRoutes.length})'),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            controller: _searchController,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Buscar puntos de entrega...',
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

          SizedBox(height: 12),

          // Filtros
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedFilter,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Filtrar por tráfico',
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
                    DropdownMenuItem(
                      value: 'high_traffic',
                      child: Text('Alto tráfico'),
                    ),
                    DropdownMenuItem(
                      value: 'low_traffic',
                      child: Text('Bajo tráfico'),
                    ),
                    DropdownMenuItem(
                      value: 'restricted',
                      child: Text('Restringidos'),
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
                  value: _selectedZoneType,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Tipo de punto',
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
                    DropdownMenuItem(
                      value: 'building',
                      child: Text('Edificios'),
                    ),
                    DropdownMenuItem(
                      value: 'outdoor',
                      child: Text('Exteriores'),
                    ),
                    DropdownMenuItem(
                      value: 'special',
                      child: Text('Especiales'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedZoneType = value!;
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

  Widget _buildTabContent() {
    switch (_tabController.index) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildDeliveryPointsTab();
      case 2:
        return _buildZonesTab();
      case 3:
        return _buildRoutesTab();
      default:
        return Container();
    }
  }

  Widget _buildOverviewTab() {
    final totalDeliveries = _deliveryPoints.fold(
      0,
      (sum, point) => sum + point['totalDeliveries'] as int,
    );
    final averageDeliveryTime =
        _deliveryPoints
            .where((p) => p['isActive'])
            .fold(0.0, (sum, point) => sum + point['estimatedDeliveryTime']) /
        _deliveryPoints.where((p) => p['isActive']).length;
    final activePoints = _deliveryPoints.where((p) => p['isActive']).length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estadísticas generales
          Text(
            'Estadísticas Generales',
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
                child: _buildOverviewStatCard(
                  'Entregas Totales',
                  '$totalDeliveries',
                  Icons.local_shipping,
                  AppColors.primary,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildOverviewStatCard(
                  'Tiempo Prom.',
                  '${averageDeliveryTime.toStringAsFixed(1)}min',
                  Icons.access_time,
                  AppColors.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildOverviewStatCard(
                  'Puntos Activos',
                  '$activePoints/${_deliveryPoints.length}',
                  Icons.place,
                  AppColors.success,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildOverviewStatCard(
                  'Zonas',
                  '${_campusZones.length}',
                  Icons.map,
                  AppColors.warning,
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Top puntos de entrega
          Text(
            'Puntos Más Populares',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          // Top puntos de entrega
          ..._getTopDeliveryPoints()
              .map((point) => _buildTopPointCard(point))
              .toList(),

          SizedBox(height: 24),

          // Zonas por rendimiento
          Text(
            'Zonas por Rendimiento',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          ..._campusZones
              .map((zone) => _buildZonePerformanceCard(zone))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildOverviewStatCard(
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
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopPointCard(Map<String, dynamic> point) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: AppColors.warning, width: 4)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.star, color: AppColors.warning, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point['name'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  point['zone'],
                  style: TextStyle(
                    fontSize: 12,
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
                '${point['weeklyDeliveries']} entregas/sem',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
              Text(
                '${point['estimatedDeliveryTime']}min',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZonePerformanceCard(Map<String, dynamic> zone) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: zone['color'].withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: zone['color'],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone['name'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${zone['deliveryPoints']} puntos • ${zone['averageDeliveryTime'].toStringAsFixed(1)}min prom.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${zone['weeklyDeliveries']} entregas/sem',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: zone['color'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryPointsTab() {
    final points = _filteredDeliveryPoints;

    if (points.isEmpty) {
      return _buildEmptyState('No se encontraron puntos de entrega');
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: points.length,
      itemBuilder: (context, index) {
        final point = points[index];
        return _buildDeliveryPointCard(point);
      },
    );
  }

  Widget _buildDeliveryPointCard(Map<String, dynamic> point) {
    final accessColor = _getAccessLevelColor(point['accessLevel']);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: !point['isActive']
            ? Border.all(color: AppColors.error.withOpacity(0.5))
            : point['issues'].isNotEmpty
            ? Border.all(color: AppColors.warning.withOpacity(0.5))
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
        onTap: () => _showDeliveryPointDetails(point),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Header del punto
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: point['isActive']
                          ? AppColors.warning.withOpacity(0.1)
                          : AppColors.textTertiary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: point['isActive']
                            ? AppColors.warning.withOpacity(0.3)
                            : AppColors.textTertiary.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      point['type'] == 'building'
                          ? Icons.business
                          : point['type'] == 'outdoor'
                          ? Icons.park
                          : Icons.star,
                      color: point['isActive']
                          ? AppColors.warning
                          : AppColors.textTertiary,
                      size: 25,
                    ),
                  ),

                  SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                point['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: point['isActive']
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ),
                            if (point['issues'].isNotEmpty)
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
                                  '⚠ ${point['issues'].length}',
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
                          point['zone'],
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
                                color: AppColors.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getPointTypeDisplayName(point['type']),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warning,
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
                                color: accessColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getAccessLevelDisplayName(
                                  point['accessLevel'],
                                ),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: accessColor,
                                ),
                              ),
                            ),
                            if (!point['isActive']) ...[
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'INACTIVO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Métricas del punto
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${point['estimatedDeliveryTime']}min',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        '${point['weeklyDeliveries']}/sem',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Score: ${point['popularityScore']}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: point['popularityScore'] >= 80
                              ? AppColors.success
                              : point['popularityScore'] >= 60
                              ? AppColors.warning
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Información adicional
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Column(
                      children: [
                        Text(
                          'Última entrega: ${_formatDateTime(point['lastDelivery'])}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Espera prom: ${point['averageWaitTime'].toStringAsFixed(1)}min',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _togglePointStatus(point['id']),
                      icon: Icon(
                        point['isActive'] ? Icons.pause : Icons.play_arrow,
                        size: 16,
                      ),
                      label: Text(point['isActive'] ? 'Pausar' : 'Activar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: point['isActive']
                            ? AppColors.warning
                            : AppColors.success,
                        side: BorderSide(
                          color: point['isActive']
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showDeliveryPointForm(point: point);
                          break;
                        case 'delete':
                          _deleteDeliveryPoint(point['id']);
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZonesTab() {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: _campusZones.length,
      itemBuilder: (context, index) {
        final zone = _campusZones[index];
        return _buildZoneCard(zone);
      },
    );
  }

  Widget _buildZoneCard(Map<String, dynamic> zone) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: zone['color'].withOpacity(0.3)),
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
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: zone['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: zone['color'].withOpacity(0.3)),
                ),
                child: Icon(Icons.map, color: zone['color'], size: 25),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${zone['deliveryPoints']} puntos de entrega',
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
                  color: zone['priorityLevel'] == 'high'
                      ? AppColors.success.withOpacity(0.1)
                      : zone['priorityLevel'] == 'medium'
                      ? AppColors.warning.withOpacity(0.1)
                      : AppColors.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  zone['priorityLevel'].toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: zone['priorityLevel'] == 'high'
                        ? AppColors.success
                        : zone['priorityLevel'] == 'medium'
                        ? AppColors.warning
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildZoneMetric(
                  'Entregas/sem',
                  '${zone['weeklyDeliveries']}',
                  zone['color'],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildZoneMetric(
                  'Tiempo prom.',
                  '${zone['averageDeliveryTime'].toStringAsFixed(1)}min',
                  zone['color'],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildZoneMetric(
                  'Estado',
                  zone['isActive'] ? 'Activa' : 'Inactiva',
                  zone['isActive'] ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
          if (zone['restrictions'].isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Restricciones: ${(zone['restrictions'] as List).join(', ')}',
                style: TextStyle(fontSize: 12, color: AppColors.warning),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildZoneMetric(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutesTab() {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: _popularRoutes.length,
      itemBuilder: (context, index) {
        final route = _popularRoutes[index];
        return _buildRouteCard(route);
      },
    );
  }

  Widget _buildRouteCard(Map<String, dynamic> route) {
    final difficultyColor = _getRouteDifficultyColor(route['difficulty']);

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
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.route, color: AppColors.primary, size: 20),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${route['startPoint']} → ${route['endPoint']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: difficultyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getRouteDifficultyDisplayName(route['difficulty']),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: difficultyColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRouteMetric(
                  'Distancia',
                  '${route['distance'].toStringAsFixed(0)}m',
                  Icons.straighten,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildRouteMetric(
                  'Tiempo prom.',
                  '${route['averageTime'].toStringAsFixed(1)}min',
                  Icons.access_time,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildRouteMetric(
                  'Uso semanal',
                  '${route['weeklyUsage']}',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Horas populares: ${(route['popularTimes'] as List).join(', ')}',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteMetric(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 16),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 64, color: AppColors.textTertiary),
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
            'Intenta ajustar los filtros o agregar nuevos puntos',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_tabController.index == 1) {
      return FloatingActionButton(
        onPressed: () => _showDeliveryPointForm(),
        backgroundColor: AppColors.warning,
        child: Icon(Icons.add_location, color: AppColors.textOnPrimary),
      );
    }
    return null;
  }

  void _showDeliveryPointDetails(Map<String, dynamic> point) {
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
              // Contenido del punto
              Text(
                'Detalles del Punto de Entrega',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16),
              Text(
                point['name'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                point['zone'],
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              SizedBox(height: 16),
              Text(
                'Información próximamente disponible...',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeliveryPointForm({Map<String, dynamic>? point}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          point == null
              ? 'Formulario de crear punto próximamente'
              : 'Formulario de editar punto próximamente',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showGeofenceConfig() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Configuración de geofence próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
