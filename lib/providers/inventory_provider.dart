import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_model.dart';
import 'dart:math';

class InventoryNotifier extends StateNotifier<AsyncValue<List<InventoryItem>>> {
  InventoryNotifier() : super(const AsyncValue.loading()) {
    _loadMockInventory();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Para demostración, usar datos mock
  void _loadMockInventory() async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(Duration(milliseconds: 500)); // Simular carga
      final mockItems = _generateMockInventory();
      state = AsyncValue.data(mockItems);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  List<InventoryItem> _generateMockInventory() {
    final random = Random();
    return [
      // Carnes
      InventoryItem(
        id: 'inv_001',
        name: 'Carne de Cerdo (Pastor)',
        category: 'carnes',
        currentStock: 5.2,
        minimumStock: 2.0,
        maximumStock: 10.0,
        unit: 'kg',
        costPerUnit: 180.0,
        lastRestocked: DateTime.now().subtract(Duration(days: 2)),
        expirationDate: DateTime.now().add(Duration(days: 3)),
        supplier: 'Carnicería San Juan',
        movements: [
          StockMovement(
            id: 'mov_001',
            inventoryItemId: 'inv_001',
            type: MovementType.stockIn,
            quantity: 8.0,
            reason: 'Compra semanal',
            timestamp: DateTime.now().subtract(Duration(days: 2)),
          ),
        ],
      ),
      InventoryItem(
        id: 'inv_002',
        name: 'Pollo Deshebrado',
        category: 'carnes',
        currentStock: 1.8,
        minimumStock: 2.0,
        maximumStock: 8.0,
        unit: 'kg',
        costPerUnit: 120.0,
        lastRestocked: DateTime.now().subtract(Duration(days: 1)),
        expirationDate: DateTime.now().add(Duration(days: 2)),
        supplier: 'Carnicería San Juan',
      ),
      InventoryItem(
        id: 'inv_003',
        name: 'Carnitas',
        category: 'carnes',
        currentStock: 0.0,
        minimumStock: 1.5,
        maximumStock: 6.0,
        unit: 'kg',
        costPerUnit: 200.0,
        lastRestocked: DateTime.now().subtract(Duration(days: 5)),
        supplier: 'Carnicería San Juan',
      ),

      // Vegetales
      InventoryItem(
        id: 'inv_004',
        name: 'Cebolla Blanca',
        category: 'vegetales',
        currentStock: 3.5,
        minimumStock: 1.0,
        maximumStock: 5.0,
        unit: 'kg',
        costPerUnit: 25.0,
        lastRestocked: DateTime.now().subtract(Duration(days: 1)),
        expirationDate: DateTime.now().add(Duration(days: 7)),
        supplier: 'Verdulería Central',
      ),
      InventoryItem(
        id: 'inv_005',
        name: 'Tomate',
        category: 'vegetales',
        currentStock: 2.2,
        minimumStock: 1.5,
        maximumStock: 4.0,
        unit: 'kg',
        costPerUnit: 35.0,
        lastRestocked: DateTime.now().subtract(Duration(days: 1)),
        expirationDate: DateTime.now().add(Duration(days: 5)),
        supplier: 'Verdulería Central',
      ),
      InventoryItem(
        id: 'inv_006',
        name: 'Aguacate',
        category: 'vegetales',
        currentStock: 0.8,
        minimumStock: 1.0,
        maximumStock: 3.0,
        unit: 'kg',
        costPerUnit: 80.0,
        lastRestocked: DateTime.now().subtract(Duration(days: 2)),
        expirationDate: DateTime.now().add(Duration(days: 2)),
        supplier: 'Verdulería Central',
      ),

      // Lácteos
      InventoryItem(
        id: 'inv_007',
        name: 'Queso Oaxaca',
        category: 'lacteos',
        currentStock: 1.2,
        minimumStock: 0.5,
        maximumStock: 2.0,
        unit: 'kg',
        costPerUnit: 150.0,
        lastRestocked: DateTime.now().subtract(Duration(days: 3)),
        expirationDate: DateTime.now().add(Duration(days: 8)),
        supplier: 'Lácteos Aurora',
      ),
      InventoryItem(
        id: 'inv_008',
        name: 'Crema Ácida',
        category: 'lacteos',
        currentStock: 0.5,
        minimumStock: 0.5,
        maximumStock: 1.5,
        unit: 'kg',
        costPerUnit: 90.0,
        lastRestocked: DateTime.now().subtract(Duration(days: 4)),
        expirationDate: DateTime.now().add(Duration(days: 6)),
        supplier: 'Lácteos Aurora',
      ),

      // Condimentos
      InventoryItem(
        id: 'inv_009',
        name: 'Salsa Verde',
        category: 'condimentos',
        currentStock: 2.0,
        minimumStock: 1.0,
        maximumStock: 3.0,
        unit: 'l',
        costPerUnit: 45.0,
        lastRestocked: DateTime.now().subtract(Duration(days: 1)),
        expirationDate: DateTime.now().add(Duration(days: 14)),
        supplier: 'Salsas Caseras',
      ),
      InventoryItem(
        id: 'inv_010',
        name: 'Salsa Roja',
        category: 'condimentos',
        currentStock: 1.8,
        minimumStock: 1.0,
        maximumStock: 3.0,
        unit: 'l',
        costPerUnit: 45.0,
        lastRestocked: DateTime.now().subtract(Duration(days: 1)),
        expirationDate: DateTime.now().add(Duration(days: 14)),
        supplier: 'Salsas Caseras',
      ),

      // Bebidas
      InventoryItem(
        id: 'inv_011',
        name: 'Coca Cola',
        category: 'bebidas',
        currentStock: 24.0,
        minimumStock: 12.0,
        maximumStock: 48.0,
        unit: 'unidades',
        costPerUnit: 15.0,
        lastRestocked: DateTime.now().subtract(Duration(days: 2)),
        expirationDate: DateTime.now().add(Duration(days: 180)),
        supplier: 'Distribuidora Pepsi',
      ),
      InventoryItem(
        id: 'inv_012',
        name: 'Agua Natural',
        category: 'bebidas',
        currentStock: 8.0,
        minimumStock: 12.0,
        maximumStock: 36.0,
        unit: 'unidades',
        costPerUnit: 10.0,
        lastRestocked: DateTime.now().subtract(Duration(days: 3)),
        expirationDate: DateTime.now().add(Duration(days: 365)),
        supplier: 'Distribuidora Pepsi',
      ),
    ];
  }

  // Filtrar inventario por categoría
  List<InventoryItem> getItemsByCategory(String category) {
    return state.value?.where((item) => item.category == category).toList() ?? [];
  }

  // Obtener items con stock bajo
  List<InventoryItem> getLowStockItems() {
    return state.value?.where((item) => item.isLowStock).toList() ?? [];
  }

  // Obtener items que están por vencer
  List<InventoryItem> getExpiringSoonItems() {
    return state.value?.where((item) => item.isExpiringSoon).toList() ?? [];
  }

  // Obtener items vencidos
  List<InventoryItem> getExpiredItems() {
    return state.value?.where((item) => item.isExpired).toList() ?? [];
  }

  // Agregar nuevo item al inventario
  Future<void> addInventoryItem(InventoryItem item) async {
    state = const AsyncValue.loading();
    try {
      // En una app real, esto se guardaría en Firestore
      final currentItems = state.value ?? [];
      final newItems = [...currentItems, item];
      state = AsyncValue.data(newItems);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Actualizar item del inventario
  Future<void> updateInventoryItem(InventoryItem updatedItem) async {
    state = const AsyncValue.loading();
    try {
      final currentItems = state.value ?? [];
      final newItems = currentItems.map((item) {
        return item.id == updatedItem.id ? updatedItem : item;
      }).toList();
      state = AsyncValue.data(newItems);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Eliminar item del inventario
  Future<void> deleteInventoryItem(String itemId) async {
    state = const AsyncValue.loading();
    try {
      final currentItems = state.value ?? [];
      final newItems = currentItems.where((item) => item.id != itemId).toList();
      state = AsyncValue.data(newItems);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Agregar movimiento de stock
  Future<void> addStockMovement(String itemId, StockMovement movement) async {
    state = const AsyncValue.loading();
    try {
      final currentItems = state.value ?? [];
      final newItems = currentItems.map((item) {
        if (item.id == itemId) {
          double newStock = item.currentStock;
          
          // Calcular nuevo stock basado en el tipo de movimiento
          switch (movement.type) {
            case MovementType.stockIn:
              newStock += movement.quantity;
              break;
            case MovementType.stockOut:
            case MovementType.sold:
            case MovementType.expired:
            case MovementType.damaged:
              newStock -= movement.quantity;
              break;
            case MovementType.adjustment:
              newStock = movement.quantity; // Ajuste directo
              break;
          }

          // Asegurar que el stock no sea negativo
          newStock = newStock < 0 ? 0 : newStock;

          final updatedMovements = [...item.movements, movement];
          
          return item.copyWith(
            currentStock: newStock,
            movements: updatedMovements,
            lastRestocked: movement.type == MovementType.stockIn 
                ? movement.timestamp 
                : item.lastRestocked,
          );
        }
        return item;
      }).toList();
      
      state = AsyncValue.data(newItems);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Buscar items por nombre
  List<InventoryItem> searchItems(String query) {
    if (query.isEmpty) return state.value ?? [];
    
    return state.value?.where((item) {
      return item.name.toLowerCase().contains(query.toLowerCase()) ||
             item.category.toLowerCase().contains(query.toLowerCase()) ||
             (item.supplier?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList() ?? [];
  }

  // Obtener resumen del inventario
  Map<String, dynamic> getInventorySummary() {
    final items = state.value ?? [];
    final totalItems = items.length;
    final lowStockCount = items.where((item) => item.isLowStock).length;
    final outOfStockCount = items.where((item) => item.isOutOfStock).length;
    final expiringSoonCount = items.where((item) => item.isExpiringSoon).length;
    final expiredCount = items.where((item) => item.isExpired).length;
    final totalValue = items.fold(0.0, (sum, item) => sum + item.totalValue);

    return {
      'totalItems': totalItems,
      'lowStockCount': lowStockCount,
      'outOfStockCount': outOfStockCount,
      'expiringSoonCount': expiringSoonCount,
      'expiredCount': expiredCount,
      'totalValue': totalValue,
    };
  }

  // Refrescar inventario
  Future<void> refreshInventory() async {
    _loadMockInventory();
  }
}

final inventoryProvider = StateNotifierProvider<InventoryNotifier, AsyncValue<List<InventoryItem>>>((ref) {
  return InventoryNotifier();
});