import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/analytics_model.dart';
import '../models/order_model.dart' as order_model;
import 'dart:math';

class AnalyticsNotifier extends StateNotifier<AsyncValue<StoreAnalytics?>> {
  AnalyticsNotifier() : super(const AsyncValue.loading());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> generateAnalytics(String storeId, AnalyticsPeriod period) async {
    state = const AsyncValue.loading();
    try {
      final analytics = await _calculateAnalytics(storeId, period);
      state = AsyncValue.data(analytics);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<StoreAnalytics> _calculateAnalytics(String storeId, AnalyticsPeriod period) async {
    final startDate = period.startDate;
    final endDate = period.endDate;

    // Consultar órdenes del período
    final ordersQuery = await _firestore
        .collection('orders')
        .where('storeId', isEqualTo: storeId)
        .where('orderTime', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('orderTime', isLessThanOrEqualTo: endDate.toIso8601String())
        .get();

    final orders = ordersQuery.docs
        .map((doc) => order_model.Order.fromMap(doc.data()))
        .toList();

    // Calcular métricas básicas
    final totalOrders = orders.length;
    final completedOrders = orders.where((order) => order.status == order_model.OrderStatus.delivered).length;
    final cancelledOrders = orders.where((order) => order.status == order_model.OrderStatus.cancelled).length;
    final totalRevenue = orders
        .where((order) => order.status == order_model.OrderStatus.delivered)
        .fold(0.0, (sum, order) => sum + order.totalAmount);
    
    final averageOrderValue = completedOrders > 0 ? totalRevenue / completedOrders : 0.0;
    final completionRate = totalOrders > 0 ? (completedOrders / totalOrders) * 100 : 0.0;

    // Calcular clientes nuevos vs recurrentes (simulado)
    final customerIds = orders.map((order) => order.customerId).toSet();
    final newCustomers = (customerIds.length * 0.3).round(); // 30% nuevos
    final returningCustomers = customerIds.length - newCustomers;

    // Calcular rating promedio (simulado)
    final averageRating = 4.2 + (Random().nextDouble() * 0.6); // 4.2-4.8

    // Calcular datos por hora
    final hourlyData = _calculateHourlyData(orders);
    final peakHourData = hourlyData.isNotEmpty
        ? hourlyData.reduce((a, b) => a.revenue > b.revenue ? a : b)
        : HourlyData(hour: 12, orders: 0, revenue: 0, averageOrderValue: 0);

    // Calcular top items
    final topMenuItems = _calculateTopMenuItems(orders);

    return StoreAnalytics(
      storeId: storeId,
      date: DateTime.now(),
      totalOrders: totalOrders,
      totalRevenue: totalRevenue,
      averageOrderValue: averageOrderValue,
      completedOrders: completedOrders,
      cancelledOrders: cancelledOrders,
      completionRate: completionRate,
      newCustomers: newCustomers,
      returningCustomers: returningCustomers,
      averageRating: averageRating,
      peakHourRevenue: peakHourData.revenue,
      peakHour: '${peakHourData.hour.toString().padLeft(2, '0')}:00',
      topMenuItems: topMenuItems,
      hourlyData: hourlyData,
    );
  }

  List<HourlyData> _calculateHourlyData(List<order_model.Order> orders) {
    final hourlyMap = <int, List<order_model.Order>>{};
    
    // Agrupar órdenes por hora
    for (final order in orders) {
      final hour = order.orderTime.hour;
      hourlyMap.putIfAbsent(hour, () => []).add(order);
    }

    // Crear datos para todas las horas (0-23)
    final hourlyData = <HourlyData>[];
    for (int hour = 0; hour < 24; hour++) {
      final hourOrders = hourlyMap[hour] ?? [];
      final completedOrders = hourOrders.where((order) => order.status == order_model.OrderStatus.delivered);
      final revenue = completedOrders.fold(0.0, (sum, order) => sum + order.totalAmount);
      final avgOrderValue = completedOrders.isNotEmpty ? revenue / completedOrders.length : 0.0;

      hourlyData.add(HourlyData(
        hour: hour,
        orders: hourOrders.length,
        revenue: revenue,
        averageOrderValue: avgOrderValue,
      ));
    }

    return hourlyData;
  }

  List<TopMenuItem> _calculateTopMenuItems(List<order_model.Order> orders) {
    final itemMap = <String, Map<String, dynamic>>{};
    
    // Agrupar items por ID
    for (final order in orders) {
      if (order.status == order_model.OrderStatus.delivered) {
        for (final item in order.items) {
          if (itemMap.containsKey(item.productId)) {
            itemMap[item.productId]!['count'] += item.quantity;
            itemMap[item.productId]!['revenue'] += item.priceAtPurchase * item.quantity;
          } else {
            itemMap[item.productId] = {
              'name': item.productName,
              'count': item.quantity,
              'revenue': item.priceAtPurchase * item.quantity,
            };
          }
        }
      }
    }

    // Convertir a lista y ordenar por cantidad
    final topItems = itemMap.entries
        .map((entry) => TopMenuItem(
              itemId: entry.key,
              name: entry.value['name'],
              orderCount: entry.value['count'],
              revenue: entry.value['revenue'],
              percentage: 0.0, // Se calculará después
            ))
        .toList();

    topItems.sort((a, b) => b.orderCount.compareTo(a.orderCount));

    // Calcular porcentajes
    final totalItems = topItems.fold(0, (sum, item) => sum + item.orderCount);
    if (totalItems > 0) {
      for (int i = 0; i < topItems.length; i++) {
        final percentage = (topItems[i].orderCount / totalItems) * 100;
        topItems[i] = TopMenuItem(
          itemId: topItems[i].itemId,
          name: topItems[i].name,
          orderCount: topItems[i].orderCount,
          revenue: topItems[i].revenue,
          percentage: percentage,
        );
      }
    }

    return topItems.take(10).toList(); // Top 10 items
  }

  // Generar datos de ejemplo para demostración
  Future<void> generateMockAnalytics(String storeId) async {
    state = const AsyncValue.loading();
    try {
      final mockAnalytics = _generateMockData(storeId);
      state = AsyncValue.data(mockAnalytics);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  StoreAnalytics _generateMockData(String storeId) {
    final random = Random();
    final now = DateTime.now();

    // Generar datos por hora
    final hourlyData = List.generate(24, (hour) {
      final baseOrders = hour >= 11 && hour <= 14 || hour >= 18 && hour <= 21 
          ? random.nextInt(15) + 5 // Horas pico
          : random.nextInt(8); // Horas normales
      final revenue = baseOrders * (150 + random.nextDouble() * 100);
      return HourlyData(
        hour: hour,
        orders: baseOrders,
        revenue: revenue,
        averageOrderValue: baseOrders > 0 ? revenue / baseOrders : 0,
      );
    });

    // Calcular totales
    final totalOrders = hourlyData.fold(0, (sum, data) => sum + data.orders);
    final totalRevenue = hourlyData.fold(0.0, (sum, data) => sum + data.revenue);
    final completedOrders = (totalOrders * 0.92).round();
    final cancelledOrders = totalOrders - completedOrders;

    // Top menu items
    final topMenuItems = [
      TopMenuItem(itemId: '1', name: 'Taco al Pastor', orderCount: 45, revenue: 2250, percentage: 25.5),
      TopMenuItem(itemId: '2', name: 'Quesadilla de Queso', orderCount: 38, revenue: 1900, percentage: 21.6),
      TopMenuItem(itemId: '3', name: 'Taco de Carnitas', orderCount: 32, revenue: 1600, percentage: 18.2),
      TopMenuItem(itemId: '4', name: 'Coca Cola', orderCount: 28, revenue: 840, percentage: 15.9),
      TopMenuItem(itemId: '5', name: 'Taco de Pollo', orderCount: 22, revenue: 1100, percentage: 12.5),
    ];

    // Hora pico
    final peakHourData = hourlyData.reduce((a, b) => a.revenue > b.revenue ? a : b);

    return StoreAnalytics(
      storeId: storeId,
      date: now,
      totalOrders: totalOrders,
      totalRevenue: totalRevenue,
      averageOrderValue: totalOrders > 0 ? totalRevenue / totalOrders : 0,
      completedOrders: completedOrders,
      cancelledOrders: cancelledOrders,
      completionRate: totalOrders > 0 ? (completedOrders / totalOrders) * 100 : 0,
      newCustomers: 15,
      returningCustomers: 42,
      averageRating: 4.3 + random.nextDouble() * 0.5,
      peakHourRevenue: peakHourData.revenue,
      peakHour: '${peakHourData.hour.toString().padLeft(2, '0')}:00',
      topMenuItems: topMenuItems,
      hourlyData: hourlyData,
    );
  }
}

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AsyncValue<StoreAnalytics?>>((ref) {
  return AnalyticsNotifier();
});