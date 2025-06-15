import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import 'dart:convert';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;
  String? _fcmToken;
  Function(AppNotification)? _onNotificationTap;
  Function(AppNotification)? _onNotificationReceived;

  // Inicializar el servicio de notificaciones
  Future<void> initialize({
    Function(AppNotification)? onNotificationTap,
    Function(AppNotification)? onNotificationReceived,
  }) async {
    if (_isInitialized) return;

    _onNotificationTap = onNotificationTap;
    _onNotificationReceived = onNotificationReceived;

    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
    await _createNotificationChannels();

    _isInitialized = true;
  }

  // Inicializar notificaciones locales
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
  }

  // Inicializar Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    try {
      // Solicitar permisos
      await _requestPermissions();

      // Obtener token FCM
      _fcmToken = await _firebaseMessaging.getToken();
      print('FCM Token: $_fcmToken');

      // Configurar manejadores de mensajes
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      // Manejar notificación que abrió la app
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }
    } catch (e) {
      print('Error initializing Firebase Messaging: $e');
    }
  }

  // Crear canales de notificación para Android
  Future<void> _createNotificationChannels() async {
    if (!Platform.isAndroid) return;

    final channels = [
      AndroidNotificationChannel(
        NotificationType.orderUpdate.channelId,
        'Actualización de Pedidos',
        description: 'Notificaciones sobre el estado de tus pedidos',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
      AndroidNotificationChannel(
        NotificationType.newOrder.channelId,
        'Nuevos Pedidos',
        description: 'Notificaciones de nuevos pedidos para la tienda',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
      AndroidNotificationChannel(
        NotificationType.chat.channelId,
        'Mensajes de Chat',
        description: 'Notificaciones de nuevos mensajes',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
      AndroidNotificationChannel(
        NotificationType.inventory.channelId,
        'Alertas de Inventario',
        description: 'Notificaciones sobre estado del inventario',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
      AndroidNotificationChannel(
        NotificationType.promotion.channelId,
        'Promociones',
        description: 'Notificaciones de ofertas y promociones',
        importance: Importance.defaultImportance,
        playSound: false,
        enableVibration: false,
      ),
    ];

    for (final channel in channels) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  // Solicitar permisos de notificación
  Future<bool> _requestPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
             settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  // Manejar mensajes en primer plano
  void _handleForegroundMessage(RemoteMessage message) {
    print('Received foreground message: ${message.messageId}');
    
    final notification = _createNotificationFromRemoteMessage(message);
    _onNotificationReceived?.call(notification);
    
    // Mostrar notificación local
    _showLocalNotification(notification);
  }

  // Manejar cuando la app se abre desde una notificación
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.messageId}');
    
    final notification = _createNotificationFromRemoteMessage(message);
    _onNotificationTap?.call(notification);
  }

  // Manejar mensajes en segundo plano
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
  }

  // Crear AppNotification desde RemoteMessage
  AppNotification _createNotificationFromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    
    return AppNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Nueva notificación',
      body: message.notification?.body ?? '',
      type: _getNotificationTypeFromString(data['type'] ?? 'system'),
      priority: _getPriorityFromString(data['priority'] ?? 'normal'),
      timestamp: DateTime.now(),
      imageUrl: message.notification?.android?.imageUrl ?? 
               message.notification?.apple?.imageUrl,
      data: data,
      targetUserId: data['targetUserId'],
      orderId: data['orderId'],
      storeId: data['storeId'],
      action: data['action'],
    );
  }

  // Mostrar notificación local
  Future<void> _showLocalNotification(AppNotification notification) async {
    final androidDetails = AndroidNotificationDetails(
      notification.type.channelId,
      notification.type.displayName,
      channelDescription: 'Notificaciones de ${notification.type.displayName}',
      importance: _getAndroidImportance(notification.priority),
      priority: _getAndroidPriority(notification.priority),
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(notification.body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.id.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(notification.toMap()),
    );
  }

  // Manejar tap en notificación local
  void _onLocalNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        final notification = AppNotification.fromMap(data);
        _onNotificationTap?.call(notification);
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  // Enviar notificación push (simulado)
  Future<void> sendPushNotification({
    required String targetUserId,
    required String title,
    required String body,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.normal,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? orderId,
    String? storeId,
    String? action,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      priority: priority,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
      data: data,
      targetUserId: targetUserId,
      orderId: orderId,
      storeId: storeId,
      action: action,
    );

    await _showLocalNotification(notification);
    _onNotificationReceived?.call(notification);
  }

  // Métodos auxiliares
  NotificationType _getNotificationTypeFromString(String type) {
    return NotificationType.values.firstWhere(
      (e) => e.toString().split('.').last == type,
      orElse: () => NotificationType.system,
    );
  }

  NotificationPriority _getPriorityFromString(String priority) {
    return NotificationPriority.values.firstWhere(
      (e) => e.toString().split('.').last == priority,
      orElse: () => NotificationPriority.normal,
    );
  }

  Importance _getAndroidImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.normal:
        return Importance.defaultImportance;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.urgent:
        return Importance.max;
    }
  }

  Priority _getAndroidPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.normal:
        return Priority.defaultPriority;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.urgent:
        return Priority.max;
    }
  }

  String? get fcmToken => _fcmToken;
}