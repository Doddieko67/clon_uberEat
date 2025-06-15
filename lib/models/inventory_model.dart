import 'package:flutter/material.dart';

class InventoryItem {
  final String id;
  final String name;
  final String category;
  final double currentStock;
  final double minimumStock;
  final double maximumStock;
  final String unit; // kg, l, unidades, etc.
  final double costPerUnit;
  final DateTime? lastRestocked;
  final DateTime? expirationDate;
  final String? supplier;
  final String? notes;
  final bool isActive;
  final List<StockMovement> movements;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.currentStock,
    required this.minimumStock,
    required this.maximumStock,
    required this.unit,
    required this.costPerUnit,
    this.lastRestocked,
    this.expirationDate,
    this.supplier,
    this.notes,
    this.isActive = true,
    this.movements = const [],
  });

  bool get isLowStock => currentStock <= minimumStock;
  bool get isOutOfStock => currentStock <= 0;
  bool get isExpiringSoon {
    if (expirationDate == null) return false;
    final daysUntilExpiry = expirationDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 3 && daysUntilExpiry >= 0;
  }
  bool get isExpired {
    if (expirationDate == null) return false;
    return expirationDate!.isBefore(DateTime.now());
  }

  double get totalValue => currentStock * costPerUnit;
  
  StockStatus get status {
    if (isExpired) return StockStatus.expired;
    if (isOutOfStock) return StockStatus.outOfStock;
    if (isLowStock) return StockStatus.lowStock;
    if (isExpiringSoon) return StockStatus.expiringSoon;
    return StockStatus.normal;
  }

  Color get statusColor {
    switch (status) {
      case StockStatus.expired:
        return Colors.red.shade700;
      case StockStatus.outOfStock:
        return Colors.red;
      case StockStatus.lowStock:
        return Colors.orange;
      case StockStatus.expiringSoon:
        return Colors.amber;
      case StockStatus.normal:
        return Colors.green;
    }
  }

  String get statusText {
    switch (status) {
      case StockStatus.expired:
        return 'Vencido';
      case StockStatus.outOfStock:
        return 'Agotado';
      case StockStatus.lowStock:
        return 'Stock Bajo';
      case StockStatus.expiringSoon:
        return 'Por Vencer';
      case StockStatus.normal:
        return 'Normal';
    }
  }

  InventoryItem copyWith({
    String? id,
    String? name,
    String? category,
    double? currentStock,
    double? minimumStock,
    double? maximumStock,
    String? unit,
    double? costPerUnit,
    DateTime? lastRestocked,
    DateTime? expirationDate,
    String? supplier,
    String? notes,
    bool? isActive,
    List<StockMovement>? movements,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      maximumStock: maximumStock ?? this.maximumStock,
      unit: unit ?? this.unit,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      lastRestocked: lastRestocked ?? this.lastRestocked,
      expirationDate: expirationDate ?? this.expirationDate,
      supplier: supplier ?? this.supplier,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      movements: movements ?? this.movements,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'currentStock': currentStock,
      'minimumStock': minimumStock,
      'maximumStock': maximumStock,
      'unit': unit,
      'costPerUnit': costPerUnit,
      'lastRestocked': lastRestocked?.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'supplier': supplier,
      'notes': notes,
      'isActive': isActive,
      'movements': movements.map((m) => m.toMap()).toList(),
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      currentStock: (map['currentStock'] as num).toDouble(),
      minimumStock: (map['minimumStock'] as num).toDouble(),
      maximumStock: (map['maximumStock'] as num).toDouble(),
      unit: map['unit'] as String,
      costPerUnit: (map['costPerUnit'] as num).toDouble(),
      lastRestocked: map['lastRestocked'] != null
          ? DateTime.parse(map['lastRestocked'] as String)
          : null,
      expirationDate: map['expirationDate'] != null
          ? DateTime.parse(map['expirationDate'] as String)
          : null,
      supplier: map['supplier'] as String?,
      notes: map['notes'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      movements: (map['movements'] as List<dynamic>?)
              ?.map((m) => StockMovement.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class StockMovement {
  final String id;
  final String inventoryItemId;
  final MovementType type;
  final double quantity;
  final String reason;
  final DateTime timestamp;
  final String? userId;
  final String? notes;
  final double? costPerUnit;

  StockMovement({
    required this.id,
    required this.inventoryItemId,
    required this.type,
    required this.quantity,
    required this.reason,
    required this.timestamp,
    this.userId,
    this.notes,
    this.costPerUnit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'inventoryItemId': inventoryItemId,
      'type': type.toString().split('.').last,
      'quantity': quantity,
      'reason': reason,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'notes': notes,
      'costPerUnit': costPerUnit,
    };
  }

  factory StockMovement.fromMap(Map<String, dynamic> map) {
    return StockMovement(
      id: map['id'] as String,
      inventoryItemId: map['inventoryItemId'] as String,
      type: MovementType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      quantity: (map['quantity'] as num).toDouble(),
      reason: map['reason'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      userId: map['userId'] as String?,
      notes: map['notes'] as String?,
      costPerUnit: map['costPerUnit'] != null
          ? (map['costPerUnit'] as num).toDouble()
          : null,
    );
  }
}

enum StockStatus {
  normal,
  lowStock,
  outOfStock,
  expiringSoon,
  expired,
}

enum MovementType {
  stockIn,    // Entrada de inventario
  stockOut,   // Salida de inventario
  adjustment, // Ajuste manual
  expired,    // Producto vencido
  damaged,    // Producto dañado
  sold,       // Producto vendido
}

extension MovementTypeExtension on MovementType {
  String get displayName {
    switch (this) {
      case MovementType.stockIn:
        return 'Entrada';
      case MovementType.stockOut:
        return 'Salida';
      case MovementType.adjustment:
        return 'Ajuste';
      case MovementType.expired:
        return 'Vencido';
      case MovementType.damaged:
        return 'Dañado';
      case MovementType.sold:
        return 'Vendido';
    }
  }

  IconData get icon {
    switch (this) {
      case MovementType.stockIn:
        return Icons.add_circle;
      case MovementType.stockOut:
        return Icons.remove_circle;
      case MovementType.adjustment:
        return Icons.edit;
      case MovementType.expired:
        return Icons.schedule;
      case MovementType.damaged:
        return Icons.warning;
      case MovementType.sold:
        return Icons.shopping_cart;
    }
  }

  Color get color {
    switch (this) {
      case MovementType.stockIn:
        return Colors.green;
      case MovementType.stockOut:
      case MovementType.expired:
      case MovementType.damaged:
        return Colors.red;
      case MovementType.adjustment:
        return Colors.blue;
      case MovementType.sold:
        return Colors.purple;
    }
  }
}

class InventoryCategory {
  final String id;
  final String name;
  final String? description;
  final IconData icon;
  final Color color;

  InventoryCategory({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.color,
  });

  static List<InventoryCategory> get defaultCategories => [
    InventoryCategory(
      id: 'carnes',
      name: 'Carnes',
      description: 'Productos cárnicos',
      icon: Icons.set_meal,
      color: Colors.red,
    ),
    InventoryCategory(
      id: 'vegetales',
      name: 'Vegetales',
      description: 'Verduras y hortalizas',
      icon: Icons.eco,
      color: Colors.green,
    ),
    InventoryCategory(
      id: 'lacteos',
      name: 'Lácteos',
      description: 'Productos lácteos',
      icon: Icons.breakfast_dining,
      color: Colors.blue,
    ),
    InventoryCategory(
      id: 'condimentos',
      name: 'Condimentos',
      description: 'Especias y condimentos',
      icon: Icons.scatter_plot,
      color: Colors.orange,
    ),
    InventoryCategory(
      id: 'bebidas',
      name: 'Bebidas',
      description: 'Bebidas y líquidos',
      icon: Icons.local_drink,
      color: Colors.cyan,
    ),
    InventoryCategory(
      id: 'otros',
      name: 'Otros',
      description: 'Otros ingredientes',
      icon: Icons.category,
      color: Colors.grey,
    ),
  ];
}