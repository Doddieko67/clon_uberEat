// providers/deliverer_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart' as app_models;

// Modelo para estadísticas del deliverer
class DelivererStats {
  final int todayDeliveries;
  final double todayEarnings;
  final double averageRating;
  final double completionRate;
  final int totalDeliveries;
  final DateTime lastActiveTime;

  DelivererStats({
    required this.todayDeliveries,
    required this.todayEarnings,
    required this.averageRating,
    required this.completionRate,
    required this.totalDeliveries,
    required this.lastActiveTime,
  });

  factory DelivererStats.empty() {
    return DelivererStats(
      todayDeliveries: 0,
      todayEarnings: 0.0,
      averageRating: 5.0,
      completionRate: 100.0,
      totalDeliveries: 0,
      lastActiveTime: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'todayDeliveries': todayDeliveries,
      'todayEarnings': todayEarnings,
      'averageRating': averageRating,
      'completionRate': completionRate,
      'totalDeliveries': totalDeliveries,
      'lastActiveTime': lastActiveTime.toIso8601String(),
    };
  }

  factory DelivererStats.fromMap(Map<String, dynamic> map) {
    return DelivererStats(
      todayDeliveries: map['todayDeliveries'] as int? ?? 0,
      todayEarnings: (map['todayEarnings'] as num?)?.toDouble() ?? 0.0,
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 5.0,
      completionRate: (map['completionRate'] as num?)?.toDouble() ?? 100.0,
      totalDeliveries: map['totalDeliveries'] as int? ?? 0,
      lastActiveTime: map['lastActiveTime'] != null 
          ? DateTime.parse(map['lastActiveTime'] as String)
          : DateTime.now(),
    );
  }
}

// Provider para estadísticas del deliverer
final delivererStatsProvider = StreamProvider.family<DelivererStats, String>((ref, delivererId) {
  final firestore = FirebaseFirestore.instance;
  
  return firestore
      .collection('deliverers')
      .doc(delivererId)
      .snapshots()
      .map((doc) {
        if (doc.exists && doc.data() != null) {
          return DelivererStats.fromMap(doc.data()!);
        }
        return DelivererStats.empty();
      });
});

// Provider para órdenes completadas del deliverer (historial)
final delivererOrderHistoryProvider = StreamProvider.family<List<app_models.Order>, String>((ref, delivererId) {
  final firestore = FirebaseFirestore.instance;
  
  return firestore
      .collection('orders')
      .where('delivererId', isEqualTo: delivererId)
      .where('status', isEqualTo: 'delivered')
      .orderBy('deliveryTime', descending: true)
      .limit(50) // Últimas 50 entregas
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return app_models.Order.fromMap(data);
        }).toList();
      });
});

// Provider para estadísticas calculadas desde órdenes reales
final calculatedDelivererStatsProvider = StreamProvider.family<DelivererStats, String>((ref, delivererId) {
  final firestore = FirebaseFirestore.instance;
  
  // Calcular estadísticas desde las órdenes reales
  return firestore
      .collection('orders')
      .where('delivererId', isEqualTo: delivererId)
      .snapshots()
      .map((snapshot) {
        final orders = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return app_models.Order.fromMap(data);
        }).toList();

        return _calculateStatsFromOrders(orders);
      });
});

// Función helper para calcular estadísticas desde órdenes
DelivererStats _calculateStatsFromOrders(List<app_models.Order> orders) {
  if (orders.isEmpty) {
    return DelivererStats.empty();
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  // Filtrar órdenes de hoy
  final todayOrders = orders.where((order) {
    final orderDate = DateTime(
      order.orderTime.year,
      order.orderTime.month,
      order.orderTime.day,
    );
    return orderDate.isAtSameMomentAs(today);
  }).toList();

  // Filtrar órdenes completadas
  final completedOrders = orders.where((order) => 
      order.status == app_models.OrderStatus.delivered).toList();
  
  final todayCompletedOrders = todayOrders.where((order) => 
      order.status == app_models.OrderStatus.delivered).toList();

  // Calcular estadísticas
  final todayDeliveries = todayCompletedOrders.length;
  final todayEarnings = todayCompletedOrders.fold<double>(
    0.0, 
    (sum, order) => sum + (order.totalAmount * 0.1), // 10% comisión del deliverer
  );

  // Calcular rating promedio (simulado por ahora - en app real vendría de reviews)
  final averageRating = completedOrders.isNotEmpty 
      ? completedOrders.fold<double>(0.0, (sum, order) => sum + (order.rating ?? 5.0)) / completedOrders.length
      : 5.0;

  // Calcular tasa de completitud
  final totalOrdersAssigned = orders.length;
  final completionRate = totalOrdersAssigned > 0 
      ? (completedOrders.length / totalOrdersAssigned) * 100
      : 100.0;

  return DelivererStats(
    todayDeliveries: todayDeliveries,
    todayEarnings: todayEarnings,
    averageRating: averageRating,
    completionRate: completionRate,
    totalDeliveries: completedOrders.length,
    lastActiveTime: DateTime.now(),
  );
}

// Notifier para actualizar estadísticas del deliverer
class DelivererStatsNotifier extends StateNotifier<AsyncValue<DelivererStats>> {
  DelivererStatsNotifier(this._delivererId) : super(const AsyncValue.loading()) {
    _loadStats();
  }

  final String _delivererId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _loadStats() async {
    try {
      final doc = await _firestore
          .collection('deliverers')
          .doc(_delivererId)
          .get();

      if (doc.exists && doc.data() != null) {
        final stats = DelivererStats.fromMap(doc.data()!);
        state = AsyncValue.data(stats);
      } else {
        // Crear estadísticas iniciales
        final initialStats = DelivererStats.empty();
        await _updateStats(initialStats);
        state = AsyncValue.data(initialStats);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _updateStats(DelivererStats stats) async {
    try {
      await _firestore
          .collection('deliverers')
          .doc(_delivererId)
          .set(stats.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Error updating deliverer stats: $e');
    }
  }

  // Método para incrementar entregas del día
  Future<void> incrementTodayDeliveries(double earnings) async {
    final currentState = state;
    if (currentState is AsyncData<DelivererStats>) {
      final currentStats = currentState.value;
      final updatedStats = DelivererStats(
        todayDeliveries: currentStats.todayDeliveries + 1,
        todayEarnings: currentStats.todayEarnings + earnings,
        averageRating: currentStats.averageRating,
        completionRate: currentStats.completionRate,
        totalDeliveries: currentStats.totalDeliveries + 1,
        lastActiveTime: DateTime.now(),
      );

      await _updateStats(updatedStats);
      state = AsyncValue.data(updatedStats);
    }
  }

  // Método para actualizar rating
  Future<void> updateRating(double newRating) async {
    final currentState = state;
    if (currentState is AsyncData<DelivererStats>) {
      final currentStats = currentState.value;
      
      // Calcular nuevo promedio de rating
      final totalRatings = currentStats.totalDeliveries;
      final currentTotalRating = currentStats.averageRating * totalRatings;
      final newAverageRating = (currentTotalRating + newRating) / (totalRatings + 1);

      final updatedStats = DelivererStats(
        todayDeliveries: currentStats.todayDeliveries,
        todayEarnings: currentStats.todayEarnings,
        averageRating: newAverageRating,
        completionRate: currentStats.completionRate,
        totalDeliveries: currentStats.totalDeliveries,
        lastActiveTime: DateTime.now(),
      );

      await _updateStats(updatedStats);
      state = AsyncValue.data(updatedStats);
    }
  }
}

final delivererStatsNotifierProvider = StateNotifierProvider.family<DelivererStatsNotifier, AsyncValue<DelivererStats>, String>((ref, delivererId) {
  return DelivererStatsNotifier(delivererId);
});