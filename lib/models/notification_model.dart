import 'package:flutter/material.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final String? targetUserId;
  final String? orderId;
  final String? storeId;
  final String? action; // Acción al tocar la notificación

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.priority = NotificationPriority.normal,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.data,
    this.targetUserId,
    this.orderId,
    this.storeId,
    this.action,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? timestamp,
    bool? isRead,
    String? imageUrl,
    Map<String, dynamic>? data,
    String? targetUserId,
    String? orderId,
    String? storeId,
    String? action,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      targetUserId: targetUserId ?? this.targetUserId,
      orderId: orderId ?? this.orderId,
      storeId: storeId ?? this.storeId,
      action: action ?? this.action,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'imageUrl': imageUrl,
      'data': data,
      'targetUserId': targetUserId,
      'orderId': orderId,
      'storeId': storeId,
      'action': action,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString().split('.').last == (map['priority'] ?? 'normal'),
        orElse: () => NotificationPriority.normal,
      ),
      timestamp: DateTime.parse(map['timestamp'] as String),
      isRead: map['isRead'] as bool? ?? false,
      imageUrl: map['imageUrl'] as String?,
      data: map['data'] as Map<String, dynamic>?,
      targetUserId: map['targetUserId'] as String?,
      orderId: map['orderId'] as String?,
      storeId: map['storeId'] as String?,
      action: map['action'] as String?,
    );
  }
}

enum NotificationType {
  orderUpdate,    // Actualización de estado de pedido
  newOrder,       // Nueva orden para tienda
  promotion,      // Promociones y ofertas
  inventory,      // Alertas de inventario
  chat,           // Nuevo mensaje de chat
  payment,        // Confirmación de pago
  delivery,       // Actualización de entrega
  system,         // Notificaciones del sistema
  marketing,      // Notificaciones de marketing
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.orderUpdate:
        return 'Actualización de Pedido';
      case NotificationType.newOrder:
        return 'Nuevo Pedido';
      case NotificationType.promotion:
        return 'Promoción';
      case NotificationType.inventory:
        return 'Inventario';
      case NotificationType.chat:
        return 'Mensaje';
      case NotificationType.payment:
        return 'Pago';
      case NotificationType.delivery:
        return 'Entrega';
      case NotificationType.system:
        return 'Sistema';
      case NotificationType.marketing:
        return 'Marketing';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.orderUpdate:
        return Icons.shopping_bag;
      case NotificationType.newOrder:
        return Icons.add_shopping_cart;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.inventory:
        return Icons.inventory;
      case NotificationType.chat:
        return Icons.chat;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.delivery:
        return Icons.delivery_dining;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.marketing:
        return Icons.campaign;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.orderUpdate:
        return Colors.blue;
      case NotificationType.newOrder:
        return Colors.green;
      case NotificationType.promotion:
        return Colors.orange;
      case NotificationType.inventory:
        return Colors.red;
      case NotificationType.chat:
        return Colors.purple;
      case NotificationType.payment:
        return Colors.teal;
      case NotificationType.delivery:
        return Colors.amber;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.marketing:
        return Colors.pink;
    }
  }

  String get channelId {
    switch (this) {
      case NotificationType.orderUpdate:
        return 'order_updates';
      case NotificationType.newOrder:
        return 'new_orders';
      case NotificationType.promotion:
        return 'promotions';
      case NotificationType.inventory:
        return 'inventory_alerts';
      case NotificationType.chat:
        return 'chat_messages';
      case NotificationType.payment:
        return 'payment_updates';
      case NotificationType.delivery:
        return 'delivery_updates';
      case NotificationType.system:
        return 'system_notifications';
      case NotificationType.marketing:
        return 'marketing_messages';
    }
  }
}

extension NotificationPriorityExtension on NotificationPriority {
  String get displayName {
    switch (this) {
      case NotificationPriority.low:
        return 'Baja';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.high:
        return 'Alta';
      case NotificationPriority.urgent:
        return 'Urgente';
    }
  }

  int get androidImportance {
    switch (this) {
      case NotificationPriority.low:
        return 2; // IMPORTANCE_LOW
      case NotificationPriority.normal:
        return 3; // IMPORTANCE_DEFAULT
      case NotificationPriority.high:
        return 4; // IMPORTANCE_HIGH
      case NotificationPriority.urgent:
        return 5; // IMPORTANCE_MAX
    }
  }
}

// Configuración de notificaciones por usuario
class NotificationSettings {
  final String userId;
  final bool enablePushNotifications;
  final bool enableOrderUpdates;
  final bool enablePromotions;
  final bool enableChatMessages;
  final bool enableInventoryAlerts;
  final bool enableMarketingMessages;
  final bool enableSounds;
  final bool enableVibration;
  final String quietHoursStart; // "22:00"
  final String quietHoursEnd;   // "07:00"
  final bool enableQuietHours;

  NotificationSettings({
    required this.userId,
    this.enablePushNotifications = true,
    this.enableOrderUpdates = true,
    this.enablePromotions = true,
    this.enableChatMessages = true,
    this.enableInventoryAlerts = true,
    this.enableMarketingMessages = false,
    this.enableSounds = true,
    this.enableVibration = true,
    this.quietHoursStart = "22:00",
    this.quietHoursEnd = "07:00",
    this.enableQuietHours = false,
  });

  NotificationSettings copyWith({
    String? userId,
    bool? enablePushNotifications,
    bool? enableOrderUpdates,
    bool? enablePromotions,
    bool? enableChatMessages,
    bool? enableInventoryAlerts,
    bool? enableMarketingMessages,
    bool? enableSounds,
    bool? enableVibration,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? enableQuietHours,
  }) {
    return NotificationSettings(
      userId: userId ?? this.userId,
      enablePushNotifications: enablePushNotifications ?? this.enablePushNotifications,
      enableOrderUpdates: enableOrderUpdates ?? this.enableOrderUpdates,
      enablePromotions: enablePromotions ?? this.enablePromotions,
      enableChatMessages: enableChatMessages ?? this.enableChatMessages,
      enableInventoryAlerts: enableInventoryAlerts ?? this.enableInventoryAlerts,
      enableMarketingMessages: enableMarketingMessages ?? this.enableMarketingMessages,
      enableSounds: enableSounds ?? this.enableSounds,
      enableVibration: enableVibration ?? this.enableVibration,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      enableQuietHours: enableQuietHours ?? this.enableQuietHours,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'enablePushNotifications': enablePushNotifications,
      'enableOrderUpdates': enableOrderUpdates,
      'enablePromotions': enablePromotions,
      'enableChatMessages': enableChatMessages,
      'enableInventoryAlerts': enableInventoryAlerts,
      'enableMarketingMessages': enableMarketingMessages,
      'enableSounds': enableSounds,
      'enableVibration': enableVibration,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'enableQuietHours': enableQuietHours,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      userId: map['userId'] as String,
      enablePushNotifications: map['enablePushNotifications'] as bool? ?? true,
      enableOrderUpdates: map['enableOrderUpdates'] as bool? ?? true,
      enablePromotions: map['enablePromotions'] as bool? ?? true,
      enableChatMessages: map['enableChatMessages'] as bool? ?? true,
      enableInventoryAlerts: map['enableInventoryAlerts'] as bool? ?? true,
      enableMarketingMessages: map['enableMarketingMessages'] as bool? ?? false,
      enableSounds: map['enableSounds'] as bool? ?? true,
      enableVibration: map['enableVibration'] as bool? ?? true,
      quietHoursStart: map['quietHoursStart'] as String? ?? "22:00",
      quietHoursEnd: map['quietHoursEnd'] as String? ?? "07:00",
      enableQuietHours: map['enableQuietHours'] as bool? ?? false,
    );
  }

  bool shouldShowNotification(NotificationType type) {
    if (!enablePushNotifications) return false;

    switch (type) {
      case NotificationType.orderUpdate:
      case NotificationType.newOrder:
      case NotificationType.delivery:
        return enableOrderUpdates;
      case NotificationType.promotion:
        return enablePromotions;
      case NotificationType.chat:
        return enableChatMessages;
      case NotificationType.inventory:
        return enableInventoryAlerts;
      case NotificationType.marketing:
        return enableMarketingMessages;
      case NotificationType.payment:
      case NotificationType.system:
        return true; // Siempre mostrar notificaciones críticas
    }
  }

  bool isInQuietHours() {
    if (!enableQuietHours) return false;

    final now = DateTime.now();
    final currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    
    // Verificar si estamos en horario silencioso
    if (quietHoursStart.compareTo(quietHoursEnd) <= 0) {
      // Horario normal (ej: 22:00 - 07:00 del día siguiente)
      return currentTime.compareTo(quietHoursStart) >= 0 || currentTime.compareTo(quietHoursEnd) <= 0;
    } else {
      // Horario que cruza medianoche (ej: 22:00 - 07:00)
      return currentTime.compareTo(quietHoursStart) >= 0 && currentTime.compareTo(quietHoursEnd) <= 0;
    }
  }
}