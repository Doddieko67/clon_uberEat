import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  final String userRole;
  
  const NotificationsScreen({
    super.key,
    required this.userRole,
  });

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  NotificationType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _goToDashboard() {
    switch (widget.userRole) {
      case 'customer':
        context.go('/customer');
        break;
      case 'store':
        context.go('/store');
        break;
      case 'deliverer':
        context.go('/deliverer');
        break;
      default:
        context.go('/customer');
        break;
    }
  }

  String _getDashboardName() {
    switch (widget.userRole) {
      case 'customer':
        return 'Inicio';
      case 'store':
        return 'Tienda';
      case 'deliverer':
        return 'Repartidor';
      default:
        return 'Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Notificaciones',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            Text(
              'Desde ${_getDashboardName()}',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textSecondary),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => _goToDashboard(),
          tooltip: 'Volver al ${_getDashboardName()}',
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(notificationsProvider.notifier).markAllAsRead(),
              child: Text(
                'Marcar todo como leído',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
            ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
            onSelected: (value) {
              switch (value) {
                case 'clear_all':
                  _showClearAllDialog();
                  break;
                case 'settings':
                  // TODO: Navigate to settings
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 20),
                    SizedBox(width: 8),
                    Text('Borrar todas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('Configuración'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textTertiary,
          tabs: [
            Tab(
              text: 'Todas',
              icon: notifications.when(
                data: (notifs) => notifs.isEmpty
                    ? null
                    : Badge(
                        backgroundColor: AppColors.secondary,
                        label: Text('${notifs.length}'),
                        child: const Icon(Icons.notifications),
                      ),
                loading: () => const Icon(Icons.notifications),
                error: (_, __) => const Icon(Icons.notifications),
              ),
            ),
            Tab(
              text: 'No leídas',
              icon: unreadCount > 0
                  ? Badge(
                      backgroundColor: Colors.red,
                      label: Text('$unreadCount'),
                      child: const Icon(Icons.notifications_active),
                    )
                  : const Icon(Icons.notifications_active),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationsList(showAll: true),
                _buildNotificationsList(showAll: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('Todas'),
              selected: _selectedFilter == null,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = selected ? null : _selectedFilter;
                });
              },
              backgroundColor: AppColors.surfaceVariant,
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
            ),
            const SizedBox(width: 8),
            ...NotificationType.values.map(
              (type) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(type.displayName),
                  selected: _selectedFilter == type,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? type : null;
                    });
                  },
                  backgroundColor: AppColors.surfaceVariant,
                  selectedColor: type.color.withValues(alpha: 0.2),
                  checkmarkColor: type.color,
                  avatar: Icon(
                    type.icon,
                    size: 16,
                    color: _selectedFilter == type ? type.color : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList({required bool showAll}) {
    return Consumer(
      builder: (context, ref, _) {
        final notificationsAsync = ref.watch(notificationsProvider);

        return notificationsAsync.when(
          data: (notifications) {
            var filteredNotifications = notifications;

            if (!showAll) {
              filteredNotifications = notifications.where((n) => !n.isRead).toList();
            }

            if (_selectedFilter != null) {
              filteredNotifications = filteredNotifications
                  .where((n) => n.type == _selectedFilter)
                  .toList();
            }

            if (filteredNotifications.isEmpty) {
              return _buildEmptyState(showAll);
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.read(notificationsProvider.notifier).refresh();
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredNotifications.length,
                itemBuilder: (context, index) {
                  final notification = filteredNotifications[index];
                  return _buildNotificationCard(notification);
                },
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar notificaciones',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => ref.read(notificationsProvider.notifier).refresh(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool showAll) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            showAll ? Icons.notifications_none : Icons.notifications_active_outlined,
            size: 80,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            showAll 
                ? 'No tienes notificaciones'
                : 'No tienes notificaciones sin leer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            showAll
                ? 'Las notificaciones aparecerán aquí'
                : 'Todas tus notificaciones están al día',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final timeAgo = _formatTimeAgo(notification.timestamp);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: notification.isRead ? 0 : 2,
      color: notification.isRead ? AppColors.surface : AppColors.surface,
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notification.type.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  notification.type.icon,
                  color: notification.type.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                              fontSize: 16,
                              color: notification.isRead ? AppColors.textSecondary : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: notification.type.color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 14,
                        color: notification.isRead ? AppColors.textTertiary : AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          notification.type.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: notification.type.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.textTertiary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleNotificationAction(notification, value),
                itemBuilder: (context) => [
                  if (!notification.isRead)
                    const PopupMenuItem(
                      value: 'mark_read',
                      child: Row(
                        children: [
                          Icon(Icons.done, size: 20),
                          SizedBox(width: 8),
                          Text('Marcar como leído'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20),
                        SizedBox(width: 8),
                        Text('Eliminar'),
                      ],
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('MMM dd').format(timestamp);
    }
  }

  void _handleNotificationTap(AppNotification notification) {
    // Mark as read when tapped
    if (!notification.isRead) {
      ref.read(notificationsProvider.notifier).markAsRead(notification.id);
    }

    // Handle navigation based on notification action or type
    if (notification.action != null) {
      // TODO: Handle custom actions
    } else {
      // Default actions based on type
      switch (notification.type) {
        case NotificationType.orderUpdate:
        case NotificationType.newOrder:
          if (notification.orderId != null) {
            // TODO: Navigate to order details
          }
          break;
        case NotificationType.chat:
          // TODO: Navigate to chat
          break;
        case NotificationType.inventory:
          // TODO: Navigate to inventory
          break;
        default:
          break;
      }
    }
  }

  void _handleNotificationAction(AppNotification notification, String action) {
    switch (action) {
      case 'mark_read':
        ref.read(notificationsProvider.notifier).markAsRead(notification.id);
        break;
      case 'delete':
        ref.read(notificationsProvider.notifier).deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Notificación eliminada',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            backgroundColor: AppColors.surfaceVariant,
            duration: Duration(seconds: 2),
          ),
        );
        break;
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar todas las notificaciones'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todas las notificaciones? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(notificationsProvider.notifier).clearAllNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Todas las notificaciones han sido eliminadas',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  backgroundColor: AppColors.surfaceVariant,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Borrar todas'),
          ),
        ],
      ),
    );
  }
}