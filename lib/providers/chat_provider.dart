import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import 'dart:math';

class ChatNotifier extends StateNotifier<AsyncValue<List<Chat>>> {
  ChatNotifier() : super(const AsyncValue.loading()) {
    _loadMockChats();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Para demostración, usar datos mock
  void _loadMockChats() async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(Duration(milliseconds: 300));
      final mockChats = _generateMockChats();
      state = AsyncValue.data(mockChats);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  List<Chat> _generateMockChats() {
    final now = DateTime.now();
    return [
      Chat(
        id: 'chat_001',
        orderId: 'order_001',
        customerId: 'customer_001',
        customerName: 'Ana García',
        storeId: 'store_001',
        storeName: 'Cafetería Central',
        createdAt: now.subtract(Duration(minutes: 15)),
        lastMessageAt: now.subtract(Duration(minutes: 2)),
        lastMessage: '¿Cuánto tiempo más falta para mi pedido?',
        unreadMessagesCount: 1,
        status: ChatStatus.active,
      ),
      Chat(
        id: 'chat_002',
        orderId: 'order_002',
        customerId: 'customer_002',
        customerName: 'Carlos Mendoza',
        storeId: 'store_001',
        storeName: 'Cafetería Central',
        createdAt: now.subtract(Duration(hours: 1)),
        lastMessageAt: now.subtract(Duration(minutes: 5)),
        lastMessage: 'Perfecto, gracias!',
        unreadMessagesCount: 0,
        status: ChatStatus.active,
      ),
      Chat(
        id: 'chat_003',
        orderId: 'order_003',
        customerId: 'customer_003',
        customerName: 'María López',
        storeId: 'store_001',
        storeName: 'Cafetería Central',
        createdAt: now.subtract(Duration(hours: 2)),
        lastMessageAt: now.subtract(Duration(minutes: 10)),
        lastMessage: '¿Pueden agregar extra queso?',
        unreadMessagesCount: 2,
        status: ChatStatus.active,
      ),
    ];
  }

  // Crear nuevo chat
  Future<String> createChat({
    required String orderId,
    required String customerId,
    required String customerName,
    required String storeId,
    required String storeName,
  }) async {
    try {
      final chatId = 'chat_${DateTime.now().millisecondsSinceEpoch}';
      final newChat = Chat(
        id: chatId,
        orderId: orderId,
        customerId: customerId,
        customerName: customerName,
        storeId: storeId,
        storeName: storeName,
        createdAt: DateTime.now(),
        lastMessageAt: DateTime.now(),
        lastMessage: 'Chat iniciado',
        status: ChatStatus.active,
      );

      final currentChats = state.value ?? [];
      state = AsyncValue.data([newChat, ...currentChats]);

      return chatId;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // Actualizar último mensaje del chat
  Future<void> updateLastMessage(String chatId, String lastMessage) async {
    try {
      final currentChats = state.value ?? [];
      final updatedChats = currentChats.map((chat) {
        if (chat.id == chatId) {
          return chat.copyWith(
            lastMessage: lastMessage,
            lastMessageAt: DateTime.now(),
          );
        }
        return chat;
      }).toList();

      state = AsyncValue.data(updatedChats);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Marcar mensajes como leídos
  Future<void> markAsRead(String chatId) async {
    try {
      final currentChats = state.value ?? [];
      final updatedChats = currentChats.map((chat) {
        if (chat.id == chatId) {
          return chat.copyWith(unreadMessagesCount: 0);
        }
        return chat;
      }).toList();

      state = AsyncValue.data(updatedChats);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Incrementar contador de mensajes no leídos
  Future<void> incrementUnreadCount(String chatId) async {
    try {
      final currentChats = state.value ?? [];
      final updatedChats = currentChats.map((chat) {
        if (chat.id == chatId) {
          return chat.copyWith(
            unreadMessagesCount: chat.unreadMessagesCount + 1,
          );
        }
        return chat;
      }).toList();

      state = AsyncValue.data(updatedChats);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Archivar chat
  Future<void> archiveChat(String chatId) async {
    try {
      final currentChats = state.value ?? [];
      final updatedChats = currentChats.map((chat) {
        if (chat.id == chatId) {
          return chat.copyWith(status: ChatStatus.archived);
        }
        return chat;
      }).toList();

      state = AsyncValue.data(updatedChats);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Obtener chats activos
  List<Chat> getActiveChats() {
    return state.value?.where((chat) => chat.status == ChatStatus.active).toList() ?? [];
  }

  // Obtener total de mensajes no leídos
  int getTotalUnreadCount() {
    return state.value?.fold(0, (sum, chat) => sum + chat.unreadMessagesCount) ?? 0;
  }

  // Refrescar chats
  Future<void> refreshChats() async {
    _loadMockChats();
  }
}

class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  ChatMessagesNotifier(this.chatId) : super(const AsyncValue.loading()) {
    _loadMessages();
  }

  final String chatId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _loadMessages() async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(Duration(milliseconds: 200));
      final mockMessages = _generateMockMessages();
      state = AsyncValue.data(mockMessages);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  List<ChatMessage> _generateMockMessages() {
    final now = DateTime.now();
    return [
      ChatMessage(
        id: 'msg_001',
        chatId: chatId,
        senderId: 'customer_001',
        senderName: 'Ana García',
        senderRole: UserRole.customer,
        content: 'Hola, hice un pedido hace 20 minutos',
        type: MessageType.text,
        timestamp: now.subtract(Duration(minutes: 15)),
        isRead: true,
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg_002',
        chatId: chatId,
        senderId: 'store_001',
        senderName: 'Cafetería Central',
        senderRole: UserRole.store,
        content: 'Hola Ana! Tu pedido está siendo preparado. Tiempo estimado: 10 minutos.',
        type: MessageType.text,
        timestamp: now.subtract(Duration(minutes: 12)),
        isRead: true,
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg_003',
        chatId: chatId,
        senderId: 'customer_001',
        senderName: 'Ana García',
        senderRole: UserRole.customer,
        content: 'Perfecto, gracias por la información',
        type: MessageType.text,
        timestamp: now.subtract(Duration(minutes: 10)),
        isRead: true,
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg_004',
        chatId: chatId,
        senderId: 'system',
        senderName: 'Sistema',
        senderRole: UserRole.system,
        content: 'Tu pedido está listo y será entregado pronto',
        type: MessageType.system,
        timestamp: now.subtract(Duration(minutes: 5)),
        isRead: true,
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg_005',
        chatId: chatId,
        senderId: 'customer_001',
        senderName: 'Ana García',
        senderRole: UserRole.customer,
        content: '¿Cuánto tiempo más falta para mi pedido?',
        type: MessageType.text,
        timestamp: now.subtract(Duration(minutes: 2)),
        isRead: false,
        status: MessageStatus.delivered,
      ),
    ];
  }

  // Enviar mensaje
  Future<void> sendMessage({
    required String senderId,
    required String senderName,
    required UserRole senderRole,
    required String content,
    MessageType type = MessageType.text,
    String? imageUrl,
    String? audioUrl,
  }) async {
    try {
      final messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
      final newMessage = ChatMessage(
        id: messageId,
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        content: content,
        type: type,
        timestamp: DateTime.now(),
        isRead: false,
        imageUrl: imageUrl,
        audioUrl: audioUrl,
        status: MessageStatus.sending,
      );

      final currentMessages = state.value ?? [];
      state = AsyncValue.data([...currentMessages, newMessage]);

      // Simular envío exitoso
      await Future.delayed(Duration(milliseconds: 500));
      
      final updatedMessages = currentMessages.map((msg) {
        if (msg.id == messageId) {
          return msg.copyWith(status: MessageStatus.sent);
        }
        return msg;
      }).toList();
      updatedMessages.add(newMessage.copyWith(status: MessageStatus.sent));
      
      state = AsyncValue.data(updatedMessages);

    } catch (e, stack) {
      // Marcar mensaje como fallido
      final currentMessages = state.value ?? [];
      final updatedMessages = currentMessages.map((msg) {
        if (msg.id.contains(DateTime.now().millisecondsSinceEpoch.toString())) {
          return msg.copyWith(status: MessageStatus.failed);
        }
        return msg;
      }).toList();
      
      state = AsyncValue.data(updatedMessages);
    }
  }

  // Marcar mensajes como leídos
  Future<void> markMessagesAsRead(String userId) async {
    try {
      final currentMessages = state.value ?? [];
      final updatedMessages = currentMessages.map((msg) {
        if (msg.senderId != userId && !msg.isRead) {
          return msg.copyWith(isRead: true, status: MessageStatus.read);
        }
        return msg;
      }).toList();

      state = AsyncValue.data(updatedMessages);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Obtener mensajes no leídos
  List<ChatMessage> getUnreadMessages(String userId) {
    return state.value?.where((msg) => 
        msg.senderId != userId && !msg.isRead).toList() ?? [];
  }

  // Refrescar mensajes
  Future<void> refreshMessages() async {
    _loadMessages();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, AsyncValue<List<Chat>>>((ref) {
  return ChatNotifier();
});

final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, AsyncValue<List<ChatMessage>>, String>((ref, chatId) {
  return ChatMessagesNotifier(chatId);
});