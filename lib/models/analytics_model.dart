class StoreAnalytics {
  final String storeId;
  final DateTime date;
  final int totalOrders;
  final double totalRevenue;
  final double averageOrderValue;
  final int completedOrders;
  final int cancelledOrders;
  final double completionRate;
  final int newCustomers;
  final int returningCustomers;
  final double averageRating;
  final double peakHourRevenue;
  final String peakHour;
  final List<TopMenuItem> topMenuItems;
  final List<HourlyData> hourlyData;

  StoreAnalytics({
    required this.storeId,
    required this.date,
    required this.totalOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.completionRate,
    required this.newCustomers,
    required this.returningCustomers,
    required this.averageRating,
    required this.peakHourRevenue,
    required this.peakHour,
    required this.topMenuItems,
    required this.hourlyData,
  });

  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'date': date.toIso8601String(),
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'averageOrderValue': averageOrderValue,
      'completedOrders': completedOrders,
      'cancelledOrders': cancelledOrders,
      'completionRate': completionRate,
      'newCustomers': newCustomers,
      'returningCustomers': returningCustomers,
      'averageRating': averageRating,
      'peakHourRevenue': peakHourRevenue,
      'peakHour': peakHour,
      'topMenuItems': topMenuItems.map((item) => item.toMap()).toList(),
      'hourlyData': hourlyData.map((data) => data.toMap()).toList(),
    };
  }

  factory StoreAnalytics.fromMap(Map<String, dynamic> map) {
    return StoreAnalytics(
      storeId: map['storeId'] as String,
      date: DateTime.parse(map['date'] as String),
      totalOrders: map['totalOrders'] as int,
      totalRevenue: (map['totalRevenue'] as num).toDouble(),
      averageOrderValue: (map['averageOrderValue'] as num).toDouble(),
      completedOrders: map['completedOrders'] as int,
      cancelledOrders: map['cancelledOrders'] as int,
      completionRate: (map['completionRate'] as num).toDouble(),
      newCustomers: map['newCustomers'] as int,
      returningCustomers: map['returningCustomers'] as int,
      averageRating: (map['averageRating'] as num).toDouble(),
      peakHourRevenue: (map['peakHourRevenue'] as num).toDouble(),
      peakHour: map['peakHour'] as String,
      topMenuItems: (map['topMenuItems'] as List<dynamic>)
          .map((item) => TopMenuItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      hourlyData: (map['hourlyData'] as List<dynamic>)
          .map((data) => HourlyData.fromMap(data as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TopMenuItem {
  final String itemId;
  final String name;
  final int orderCount;
  final double revenue;
  final double percentage;

  TopMenuItem({
    required this.itemId,
    required this.name,
    required this.orderCount,
    required this.revenue,
    required this.percentage,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'name': name,
      'orderCount': orderCount,
      'revenue': revenue,
      'percentage': percentage,
    };
  }

  factory TopMenuItem.fromMap(Map<String, dynamic> map) {
    return TopMenuItem(
      itemId: map['itemId'] as String,
      name: map['name'] as String,
      orderCount: map['orderCount'] as int,
      revenue: (map['revenue'] as num).toDouble(),
      percentage: (map['percentage'] as num).toDouble(),
    );
  }
}

class HourlyData {
  final int hour;
  final int orders;
  final double revenue;
  final double averageOrderValue;

  HourlyData({
    required this.hour,
    required this.orders,
    required this.revenue,
    required this.averageOrderValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'hour': hour,
      'orders': orders,
      'revenue': revenue,
      'averageOrderValue': averageOrderValue,
    };
  }

  factory HourlyData.fromMap(Map<String, dynamic> map) {
    return HourlyData(
      hour: map['hour'] as int,
      orders: map['orders'] as int,
      revenue: (map['revenue'] as num).toDouble(),
      averageOrderValue: (map['averageOrderValue'] as num).toDouble(),
    );
  }
}

enum AnalyticsPeriod {
  today,
  yesterday,
  week,
  month,
  quarter,
  year,
}

extension AnalyticsPeriodExtension on AnalyticsPeriod {
  String get displayName {
    switch (this) {
      case AnalyticsPeriod.today:
        return 'Hoy';
      case AnalyticsPeriod.yesterday:
        return 'Ayer';
      case AnalyticsPeriod.week:
        return 'Última semana';
      case AnalyticsPeriod.month:
        return 'Último mes';
      case AnalyticsPeriod.quarter:
        return 'Último trimestre';
      case AnalyticsPeriod.year:
        return 'Último año';
    }
  }

  DateTime get startDate {
    final now = DateTime.now();
    switch (this) {
      case AnalyticsPeriod.today:
        return DateTime(now.year, now.month, now.day);
      case AnalyticsPeriod.yesterday:
        return DateTime(now.year, now.month, now.day - 1);
      case AnalyticsPeriod.week:
        return now.subtract(Duration(days: 7));
      case AnalyticsPeriod.month:
        return DateTime(now.year, now.month - 1, now.day);
      case AnalyticsPeriod.quarter:
        return DateTime(now.year, now.month - 3, now.day);
      case AnalyticsPeriod.year:
        return DateTime(now.year - 1, now.month, now.day);
    }
  }

  DateTime get endDate {
    final now = DateTime.now();
    switch (this) {
      case AnalyticsPeriod.today:
      case AnalyticsPeriod.yesterday:
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
      default:
        return now;
    }
  }
}