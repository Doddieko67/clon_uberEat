import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import 'auth_provider.dart';

class NotificationsNotifier extends StateNotifier<AsyncValue<List<AppNotification>>> {
  NotificationsNotifier(this._firestore, this._userId) : super(const AsyncValue.loading()) {
    _loadNotifications();
  }

  final FirebaseFirestore _firestore;
  final String? _userId;

  Future<void> _loadNotifications() async {
    if (_userId == null) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      final query = _firestore
          .collection('notifications')
          .where('targetUserId', isEqualTo: _userId)
          .orderBy('timestamp', descending: true)
          .limit(100);

      final snapshot = await query.get();
      final notifications = snapshot.docs
          .map((doc) => AppNotification.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      state = AsyncValue.data(notifications);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Stream<List<AppNotification>> watchNotifications() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('notifications')
        .where('targetUserId', isEqualTo: _userId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});

      // Update local state
      state.whenData((notifications) {
        final updatedNotifications = notifications
            .map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n)
            .toList();
        state = AsyncValue.data(updatedNotifications);
      });
    } catch (error) {
      // Handle error silently or show error message
    }
  }

  Future<void> markAllAsRead() async {
    if (_userId == null) return;

    try {
      final batch = _firestore.batch();
      
      final query = _firestore
          .collection('notifications')
          .where('targetUserId', isEqualTo: _userId)
          .where('isRead', isEqualTo: false);

      final snapshot = await query.get();
      
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      // Update local state
      state.whenData((notifications) {
        final updatedNotifications = notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
        state = AsyncValue.data(updatedNotifications);
      });
    } catch (error) {
      // Handle error
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();

      // Update local state
      state.whenData((notifications) {
        final updatedNotifications = notifications
            .where((n) => n.id != notificationId)
            .toList();
        state = AsyncValue.data(updatedNotifications);
      });
    } catch (error) {
      // Handle error
    }
  }

  Future<void> clearAllNotifications() async {
    if (_userId == null) return;

    try {
      final batch = _firestore.batch();
      
      final query = _firestore
          .collection('notifications')
          .where('targetUserId', isEqualTo: _userId);

      final snapshot = await query.get();
      
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // Update local state
      state = const AsyncValue.data([]);
    } catch (error) {
      // Handle error
    }
  }

  Future<void> addNotification(AppNotification notification) async {
    try {
      await _firestore
          .collection('notifications')
          .add(notification.toMap());

      // The real-time listener will update the state automatically
    } catch (error) {
      // Handle error
    }
  }

  void refresh() {
    _loadNotifications();
  }
}

// Provider for notifications list
final notificationsProvider = StateNotifierProvider<NotificationsNotifier, AsyncValue<List<AppNotification>>>((ref) {
  final auth = ref.watch(authNotifierProvider);
  final userId = auth.user?.id;

  return NotificationsNotifier(FirebaseFirestore.instance, userId);
});

// Provider for real-time notifications stream
final notificationsStreamProvider = StreamProvider<List<AppNotification>>((ref) {
  final notifier = ref.watch(notificationsProvider.notifier);
  return notifier.watchNotifications();
});

// Provider for unread notifications count
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.when(
    data: (notifs) => notifs.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Provider for notifications by type
final notificationsByTypeProvider = Provider.family<List<AppNotification>, NotificationType>((ref, type) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.when(
    data: (notifs) => notifs.where((n) => n.type == type).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider for notification settings
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, AsyncValue<NotificationSettings?>>((ref) {
  final auth = ref.watch(authNotifierProvider);
  final userId = auth.user?.id;

  return NotificationSettingsNotifier(FirebaseFirestore.instance, userId);
});

class NotificationSettingsNotifier extends StateNotifier<AsyncValue<NotificationSettings?>> {
  NotificationSettingsNotifier(this._firestore, this._userId) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  final FirebaseFirestore _firestore;
  final String? _userId;

  Future<void> _loadSettings() async {
    if (_userId == null) {
      state = const AsyncValue.data(null);
      return;
    }

    try {
      final doc = await _firestore
          .collection('notification_settings')
          .doc(_userId)
          .get();

      if (doc.exists) {
        final settings = NotificationSettings.fromMap(doc.data()!);
        state = AsyncValue.data(settings);
      } else {
        // Create default settings
        final defaultSettings = NotificationSettings(userId: _userId!);
        await _saveSettings(defaultSettings);
        state = AsyncValue.data(defaultSettings);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateSettings(NotificationSettings settings) async {
    try {
      await _saveSettings(settings);
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> _saveSettings(NotificationSettings settings) async {
    await _firestore
        .collection('notification_settings')
        .doc(_userId)
        .set(settings.toMap(), SetOptions(merge: true));
  }

  Future<void> toggleNotificationType(NotificationType type, bool enabled) async {
    final currentSettings = state.asData?.value;
    if (currentSettings == null) return;

    NotificationSettings updatedSettings;
    
    switch (type) {
      case NotificationType.orderUpdate:
      case NotificationType.newOrder:
      case NotificationType.delivery:
        updatedSettings = currentSettings.copyWith(enableOrderUpdates: enabled);
        break;
      case NotificationType.promotion:
        updatedSettings = currentSettings.copyWith(enablePromotions: enabled);
        break;
      case NotificationType.chat:
        updatedSettings = currentSettings.copyWith(enableChatMessages: enabled);
        break;
      case NotificationType.inventory:
        updatedSettings = currentSettings.copyWith(enableInventoryAlerts: enabled);
        break;
      case NotificationType.marketing:
        updatedSettings = currentSettings.copyWith(enableMarketingMessages: enabled);
        break;
      default:
        return; // Don't allow toggling system notifications
    }

    await updateSettings(updatedSettings);
  }
}

// Mock data for testing
class MockNotificationService {
  static List<AppNotification> generateMockNotifications(String userId) {
    final now = DateTime.now();
    
    return [
      AppNotification(
        id: '1',
        title: 'Pedido confirmado',
        body: 'Tu pedido #12345 ha sido confirmado y está siendo preparado.',
        type: NotificationType.orderUpdate,
        timestamp: now.subtract(const Duration(minutes: 5)),
        targetUserId: userId,
        orderId: '12345',
        isRead: false,
      ),
      AppNotification(
        id: '2',
        title: 'Nuevo pedido',
        body: 'Tienes un nuevo pedido de Juan Pérez por \$450.00',
        type: NotificationType.newOrder,
        timestamp: now.subtract(const Duration(minutes: 15)),
        targetUserId: userId,
        orderId: '12346',
        isRead: false,
      ),
      AppNotification(
        id: '3',
        title: '¡Oferta especial!',
        body: '50% de descuento en hamburguesas. ¡Solo por hoy!',
        type: NotificationType.promotion,
        timestamp: now.subtract(const Duration(hours: 2)),
        targetUserId: userId,
        isRead: true,
      ),
      AppNotification(
        id: '4',
        title: 'Stock bajo',
        body: 'Quedan solo 5 unidades de "Hamburguesa Clásica"',
        type: NotificationType.inventory,
        priority: NotificationPriority.high,
        timestamp: now.subtract(const Duration(hours: 4)),
        targetUserId: userId,
        isRead: false,
      ),
      AppNotification(
        id: '5',
        title: 'Nuevo mensaje',
        body: 'Cliente: "¿Cuánto tiempo tardará mi pedido?"',
        type: NotificationType.chat,
        timestamp: now.subtract(const Duration(minutes: 30)),
        targetUserId: userId,
        orderId: '12345',
        isRead: false,
      ),
      AppNotification(
        id: '6',
        title: 'Pago procesado',
        body: 'El pago de \$450.00 ha sido procesado exitosamente.',
        type: NotificationType.payment,
        timestamp: now.subtract(const Duration(hours: 1)),
        targetUserId: userId,
        orderId: '12346',
        isRead: true,
      ),
      AppNotification(
        id: '7',
        title: 'Entrega en progreso',
        body: 'Tu repartidor está en camino. Tiempo estimado: 15 min.',
        type: NotificationType.delivery,
        timestamp: now.subtract(const Duration(minutes: 10)),
        targetUserId: userId,
        orderId: '12345',
        isRead: false,
      ),
      AppNotification(
        id: '8',
        title: 'Actualización del sistema',
        body: 'La aplicación se actualizará en mantenimiento programado mañana a las 3:00 AM.',
        type: NotificationType.system,
        priority: NotificationPriority.normal,
        timestamp: now.subtract(const Duration(days: 1)),
        targetUserId: userId,
        isRead: true,
      ),
    ];
  }

  static Future<void> addMockNotifications(String userId) async {
    final firestore = FirebaseFirestore.instance;
    final notifications = generateMockNotifications(userId);

    for (final notification in notifications) {
      await firestore.collection('notifications').add(notification.toMap());
    }
  }
}