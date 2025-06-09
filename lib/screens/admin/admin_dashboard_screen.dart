// screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _statsController;
  late AnimationController _alertController;
  late Animation<double> _statsAnimation;
  late Animation<double> _alertPulse;

  Timer? _refreshTimer;
  int _currentBottomIndex = 0;
  bool _showAlerts = true;

  // Datos simulados del sistema
  final Map<String, dynamic> _systemStats = {
    'totalUsers': 1247,
    'activeUsers': 856,
    'totalStores': 23,
    'activeStores': 19,
    'totalDeliverers': 45,
    'activeDeliverers': 28,
    'todayOrders': 234,
    'todayRevenue': 12450.75,
    'avgOrderValue': 53.2,
    'systemUptime': '99.8%',
  };

  // Estadísticas por categoría
  final Map<String, Map<String, dynamic>> _userStats = {
    'customers': {
      'total': 1156,
      'active': 798,
      'new_today': 12,
      'growth': 8.5,
      'color': AppColors.primary,
      'icon': Icons.people,
    },
    'stores': {
      'total': 23,
      'active': 19,
      'new_today': 1,
      'growth': 15.2,
      'color': AppColors.secondary,
      'icon': Icons.store,
    },
    'deliverers': {
      'total': 45,
      'active': 28,
      'new_today': 3,
      'growth': 22.1,
      'color': AppColors.warning,
      'icon': Icons.delivery_dining,
    },
    'orders': {
      'total': 234,
      'active': 47,
      'new_today': 234,
      'growth': 12.8,
      'color': AppColors.success,
      'icon': Icons.receipt_long,
    },
  };

  // Alertas del sistema
  final List<Map<String, dynamic>> _systemAlerts = [
    {
      'id': 'alert1',
      'type': 'warning',
      'title': 'Tienda pendiente de aprobación',
      'message': 'Sushi Express solicita activación',
      'time': DateTime.now().subtract(Duration(minutes: 15)),
      'priority': 'medium',
      'action': 'review_store',
    },
    {
      'id': 'alert2',
      'type': 'error',
      'title': 'Problema reportado',
      'message': 'Cliente reporta entrega no recibida (#CMP1234)',
      'time': DateTime.now().subtract(Duration(hours: 2)),
      'priority': 'high',
      'action': 'review_complaint',
    },
    {
      'id': 'alert3',
      'type': 'info',
      'title': 'Mantenimiento programado',
      'message': 'Actualización del sistema el 15/06 a las 02:00',
      'time': DateTime.now().subtract(Duration(hours: 6)),
      'priority': 'low',
      'action': 'schedule_maintenance',
    },
  ];

  // Actividad reciente
  final List<Map<String, dynamic>> _recentActivity = [
    {
      'type': 'user_registered',
      'description': 'Nuevo cliente registrado: Ana García',
      'time': DateTime.now().subtract(Duration(minutes: 5)),
      'icon': Icons.person_add,
      'color': AppColors.primary,
    },
    {
      'type': 'store_activated',
      'description': 'Pizza Campus reactivó su tienda',
      'time': DateTime.now().subtract(Duration(minutes: 18)),
      'icon': Icons.store,
      'color': AppColors.success,
    },
    {
      'type': 'order_completed',
      'description': 'Pedido #CMP1245 completado exitosamente',
      'time': DateTime.now().subtract(Duration(minutes: 32)),
      'icon': Icons.check_circle,
      'color': AppColors.success,
    },
    {
      'type': 'deliverer_joined',
      'description': 'Nuevo repartidor: Carlos Mendoza',
      'time': DateTime.now().subtract(Duration(hours: 1)),
      'icon': Icons.delivery_dining,
      'color': AppColors.warning,
    },
    {
      'type': 'complaint_resolved',
      'description': 'Queja #RPT789 marcada como resuelta',
      'time': DateTime.now().subtract(Duration(hours: 3)),
      'icon': Icons.support_agent,
      'color': AppColors.secondary,
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupRefreshTimer();
  }

  void _setupAnimations() {
    _statsController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _alertController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _statsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _statsController, curve: Curves.easeOutBack),
    );

    _alertPulse = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _alertController, curve: Curves.easeInOut),
    );

    _statsController.forward();

    if (_systemAlerts.any((alert) => alert['priority'] == 'high')) {
      _alertController.repeat(reverse: true);
    }
  }

  void _setupRefreshTimer() {
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          // Simular cambios en datos en tiempo real
          _systemStats['activeUsers'] = 850 + math.Random().nextInt(20);
          _systemStats['todayOrders'] = 230 + math.Random().nextInt(10);
        });
      }
    });
  }

  void _dismissAlert(String alertId) {
    setState(() {
      _systemAlerts.removeWhere((alert) => alert['id'] == alertId);
    });

    if (_systemAlerts.isEmpty ||
        !_systemAlerts.any((alert) => alert['priority'] == 'high')) {
      _alertController.stop();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alerta descartada'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleAlertAction(Map<String, dynamic> alert) {
    String route;
    switch (alert['action']) {
      case 'review_store':
        route = '/admin-store-management';
        break;
      case 'review_complaint':
        route = '/admin-user-management';
        break;
      case 'schedule_maintenance':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Función de mantenimiento próximamente'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      default:
        return;
    }

    Navigator.pushNamed(context, route);
  }

  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'hace ${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  Color _getAlertColor(String type) {
    switch (type) {
      case 'error':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      case 'info':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  @override
  void dispose() {
    _statsController.dispose();
    _alertController.dispose();
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
                    if (_systemAlerts.isNotEmpty) ...[
                      _buildSystemAlerts(),
                      SizedBox(height: 24),
                    ],
                    _buildMainStats(),
                    SizedBox(height: 24),
                    _buildUserTypeStats(),
                    SizedBox(height: 24),
                    _buildQuickActions(),
                    SizedBox(height: 24),
                    _buildRecentActivity(),
                    SizedBox(height: 100), // Espacio para BottomNav
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
        gradient: AppGradients.splash,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: AppColors.textOnPrimary,
                  size: 25,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Panel de Administración',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    Text(
                      'UBERecus Eats Control Center',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textOnPrimary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: AppColors.textOnPrimary, size: 8),
                    SizedBox(width: 4),
                    Text(
                      'Online',
                      style: TextStyle(
                        color: AppColors.textOnPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildSystemAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _alertPulse,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _alertPulse.value,
                      child: Icon(
                        Icons.warning,
                        color: AppColors.error,
                        size: 20,
                      ),
                    );
                  },
                ),
                SizedBox(width: 8),
                Text(
                  'Alertas del Sistema',
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
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_systemAlerts.length}',
                    style: TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _showAlerts = !_showAlerts;
                });
              },
              child: Text(
                _showAlerts ? 'Ocultar' : 'Ver',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        if (_showAlerts) ...[
          SizedBox(height: 16),
          ...(_systemAlerts.take(3).map((alert) => _buildAlertCard(alert))),
          if (_systemAlerts.length > 3)
            TextButton(
              onPressed: () {
                // Navegar a vista completa de alertas
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Vista completa de alertas próximamente'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text('Ver todas las alertas (${_systemAlerts.length})'),
            ),
        ],
      ],
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final alertColor = _getAlertColor(alert['type']);
    final alertIcon = _getAlertIcon(alert['type']);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: alertColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkWithOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: alertColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(alertIcon, color: alertColor, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['title'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  alert['message'],
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _formatTimeAgo(alert['time']),
                  style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () => _handleAlertAction(alert),
                icon: Icon(Icons.arrow_forward_ios, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: alertColor.withOpacity(0.1),
                  foregroundColor: alertColor,
                ),
              ),
              IconButton(
                onPressed: () => _dismissAlert(alert['id']),
                icon: Icon(Icons.close, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceVariant,
                  foregroundColor: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainStats() {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _statsAnimation.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    child: _buildMainStatCard(
                      'Usuarios Activos',
                      '${_systemStats['activeUsers']}',
                      '/${_systemStats['totalUsers']}',
                      Icons.people,
                      AppColors.primary,
                      (_systemStats['activeUsers'] /
                          _systemStats['totalUsers']),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildMainStatCard(
                      'Tiendas Operando',
                      '${_systemStats['activeStores']}',
                      '/${_systemStats['totalStores']}',
                      Icons.store,
                      AppColors.secondary,
                      (_systemStats['activeStores'] /
                          _systemStats['totalStores']),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMainStatCard(
                      'Pedidos Hoy',
                      '${_systemStats['todayOrders']}',
                      '',
                      Icons.receipt_long,
                      AppColors.success,
                      1.0,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildMainStatCard(
                      'Ingresos Hoy',
                      '\$${(_systemStats['todayRevenue'] / 1000).toStringAsFixed(1)}k',
                      '',
                      Icons.attach_money,
                      AppColors.warning,
                      1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainStatCard(
    String title,
    String value,
    String suffix,
    IconData icon,
    Color color,
    double progress,
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
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Spacer(),
              if (progress < 1.0)
                Container(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeWidth: 3,
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (suffix.isNotEmpty)
                Text(
                  suffix,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
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

  Widget _buildUserTypeStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Desglose por Categoría',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _userStats.length,
          itemBuilder: (context, index) {
            final key = _userStats.keys.elementAt(index);
            final stats = _userStats[key]!;
            return Expanded(child: _buildUserStatCard(key, stats));
          },
        ),
      ],
    );
  }

  Widget _buildUserStatCard(String type, Map<String, dynamic> stats) {
    final isPositiveGrowth = stats['growth'] > 0;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (stats['color'] as Color).withOpacity(0.3)),
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
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (stats['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(stats['icon'], color: stats['color'], size: 20),
              ),
              Spacer(),
              Icon(
                isPositiveGrowth ? Icons.trending_up : Icons.trending_down,
                color: isPositiveGrowth ? AppColors.success : AppColors.error,
                size: 16,
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '${stats['total']}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            type.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Activos: ${stats['active']}',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              Spacer(),
              Text(
                '${isPositiveGrowth ? '+' : ''}${stats['growth'].toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPositiveGrowth ? AppColors.success : AppColors.error,
                ),
              ),
            ],
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
                'Gestionar Usuarios',
                Icons.people,
                AppColors.primary,
                () => Navigator.pushNamed(context, '/admin-user-management'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Gestionar Tiendas',
                Icons.store,
                AppColors.secondary,
                () => Navigator.pushNamed(context, '/admin-store-management'),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Zonas de Entrega',
                Icons.location_on,
                AppColors.warning,
                () => Navigator.pushNamed(
                  context,
                  '/admin-delivery-zone-management',
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Reportes',
                Icons.analytics,
                AppColors.success,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Módulo de reportes próximamente'),
                      behavior: SnackBarBehavior.floating,
                    ),
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

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Actividad Reciente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Registro completo próximamente'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(
                'Ver todo',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
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
            children: _recentActivity.take(5).map((activity) {
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (activity['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        activity['icon'],
                        color: activity['color'],
                        size: 16,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity['description'],
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            _formatTimeAgo(activity['time']),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
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
              Navigator.pushNamed(context, '/admin-user-management');
              break;
            case 2:
              Navigator.pushNamed(context, '/admin-store-management');
              break;
            case 3:
              Navigator.pushNamed(context, '/admin-delivery-zone-management');
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
                Icon(Icons.people_outlined),
                if (_systemAlerts.any(
                  (alert) => alert['action'] == 'review_complaint',
                ))
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
            activeIcon: Icon(Icons.people),
            label: 'Usuarios',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.store_outlined),
                if (_systemAlerts.any(
                  (alert) => alert['action'] == 'review_store',
                ))
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
            activeIcon: Icon(Icons.store),
            label: 'Tiendas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on),
            label: 'Zonas',
          ),
        ],
      ),
    );
  }
}
