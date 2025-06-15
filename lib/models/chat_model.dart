import 'package:flutter/material.dart';

class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final UserRole senderRole;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final String? audioUrl;
  final MessageStatus status;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.audioUrl,
    this.status = MessageStatus.sent,
  });

  ChatMessage copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    UserRole? senderRole,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isRead,
    String? imageUrl,
    String? audioUrl,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole.toString().split('.').last,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'status': status.toString().split('.').last,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      chatId: map['chatId'] as String,
      senderId: map['senderId'] as String,
      senderName: map['senderName'] as String,
      senderRole: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == map['senderRole'],
      ),
      content: map['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      timestamp: DateTime.parse(map['timestamp'] as String),
      isRead: map['isRead'] as bool? ?? false,
      imageUrl: map['imageUrl'] as String?,
      audioUrl: map['audioUrl'] as String?,
      status: MessageStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (map['status'] ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
    );
  }
}

class Chat {
  final String id;
  final String orderId;
  final String customerId;
  final String customerName;
  final String storeId;
  final String storeName;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final String lastMessage;
  final bool isActive;
  final int unreadMessagesCount;
  final ChatStatus status;

  Chat({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.storeId,
    required this.storeName,
    required this.createdAt,
    required this.lastMessageAt,
    required this.lastMessage,
    this.isActive = true,
    this.unreadMessagesCount = 0,
    this.status = ChatStatus.active,
  });

  Chat copyWith({
    String? id,
    String? orderId,
    String? customerId,
    String? customerName,
    String? storeId,
    String? storeName,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    String? lastMessage,
    bool? isActive,
    int? unreadMessagesCount,
    ChatStatus? status,
  }) {
    return Chat(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessage: lastMessage ?? this.lastMessage,
      isActive: isActive ?? this.isActive,
      unreadMessagesCount: unreadMessagesCount ?? this.unreadMessagesCount,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'customerId': customerId,
      'customerName': customerName,
      'storeId': storeId,
      'storeName': storeName,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'lastMessage': lastMessage,
      'isActive': isActive,
      'unreadMessagesCount': unreadMessagesCount,
      'status': status.toString().split('.').last,
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] as String,
      orderId: map['orderId'] as String,
      customerId: map['customerId'] as String,
      customerName: map['customerName'] as String,
      storeId: map['storeId'] as String,
      storeName: map['storeName'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastMessageAt: DateTime.parse(map['lastMessageAt'] as String),
      lastMessage: map['lastMessage'] as String,
      isActive: map['isActive'] as bool? ?? true,
      unreadMessagesCount: map['unreadMessagesCount'] as int? ?? 0,
      status: ChatStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (map['status'] ?? 'active'),
        orElse: () => ChatStatus.active,
      ),
    );
  }
}

enum MessageType {
  text,
  image,
  audio,
  system, // Mensajes automáticos del sistema
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

enum UserRole {
  customer,
  store,
  deliverer,
  admin,
  system,
}

enum ChatStatus {
  active,
  archived,
  blocked,
}

extension MessageTypeExtension on MessageType {
  String get displayName {
    switch (this) {
      case MessageType.text:
        return 'Texto';
      case MessageType.image:
        return 'Imagen';
      case MessageType.audio:
        return 'Audio';
      case MessageType.system:
        return 'Sistema';
    }
  }

  IconData get icon {
    switch (this) {
      case MessageType.text:
        return Icons.message;
      case MessageType.image:
        return Icons.image;
      case MessageType.audio:
        return Icons.mic;
      case MessageType.system:
        return Icons.info;
    }
  }
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Cliente';
      case UserRole.store:
        return 'Tienda';
      case UserRole.deliverer:
        return 'Repartidor';
      case UserRole.admin:
        return 'Admin';
      case UserRole.system:
        return 'Sistema';
    }
  }

  Color get color {
    switch (this) {
      case UserRole.customer:
        return Colors.blue;
      case UserRole.store:
        return Colors.green;
      case UserRole.deliverer:
        return Colors.orange;
      case UserRole.admin:
        return Colors.red;
      case UserRole.system:
        return Colors.grey;
    }
  }
}

// Mensajes predefinidos para respuestas rápidas
class QuickReply {
  final String id;
  final String text;
  final String category;
  final UserRole targetRole;

  QuickReply({
    required this.id,
    required this.text,
    required this.category,
    required this.targetRole,
  });

  static List<QuickReply> get storeQuickReplies => [
    QuickReply(
      id: 'store_1',
      text: 'Tu pedido está siendo preparado. Tiempo estimado: 15 minutos.',
      category: 'preparacion',
      targetRole: UserRole.store,
    ),
    QuickReply(
      id: 'store_2',
      text: 'Tu pedido está listo y será entregado pronto.',
      category: 'listo',
      targetRole: UserRole.store,
    ),
    QuickReply(
      id: 'store_3',
      text: 'Disculpa la demora, tendremos tu pedido listo en 5 minutos más.',
      category: 'demora',
      targetRole: UserRole.store,
    ),
    QuickReply(
      id: 'store_4',
      text: 'Lamentamos informarte que el ingrediente solicitado no está disponible. ¿Te gustaría una alternativa?',
      category: 'disponibilidad',
      targetRole: UserRole.store,
    ),
    QuickReply(
      id: 'store_5',
      text: 'Gracias por tu paciencia. ¡Esperamos verte pronto!',
      category: 'agradecimiento',
      targetRole: UserRole.store,
    ),
  ];

  static List<QuickReply> get customerQuickReplies => [
    QuickReply(
      id: 'customer_1',
      text: '¿Cuánto tiempo falta para mi pedido?',
      category: 'tiempo',
      targetRole: UserRole.customer,
    ),
    QuickReply(
      id: 'customer_2',
      text: '¿Pueden agregar extra guacamole?',
      category: 'modificacion',
      targetRole: UserRole.customer,
    ),
    QuickReply(
      id: 'customer_3',
      text: 'Sin cebolla, por favor',
      category: 'modificacion',
      targetRole: UserRole.customer,
    ),
    QuickReply(
      id: 'customer_4',
      text: 'Gracias, perfecto!',
      category: 'agradecimiento',
      targetRole: UserRole.customer,
    ),
  ];
}