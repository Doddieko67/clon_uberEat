import 'package:clonubereat/models/cart_item_model.dart';
import 'package:clonubereat/models/store_model.dart';

class Cart {
  final String id;
  final String? storeId;
  final Store? store;
  final List<CartItem> items;
  final String? promoCode;
  final double promoDiscount;
  final DateTime updatedAt;

  Cart({
    required this.id,
    this.storeId,
    this.store,
    this.items = const [],
    this.promoCode,
    this.promoDiscount = 0.0,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);
  double get deliveryFee => store?.deliveryFee ?? 30.0;
  double get tax => subtotal * 0.16; // 16% IVA
  double get total => subtotal + deliveryFee + tax - promoDiscount;
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  
  double get totalSavings => items.fold(0.0, (sum, item) {
    if (item.menuItem.hasDiscount) {
      return sum + ((item.menuItem.originalPrice! - item.menuItem.price) * item.quantity);
    }
    return sum;
  });

  Cart copyWith({
    String? id,
    String? storeId,
    Store? store,
    List<CartItem>? items,
    String? promoCode,
    double? promoDiscount,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      store: store ?? this.store,
      items: items ?? this.items,
      promoCode: promoCode ?? this.promoCode,
      promoDiscount: promoDiscount ?? this.promoDiscount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Cart addItem(CartItem item) {
    final existingIndex = items.indexWhere((cartItem) => 
        cartItem.menuItem.id == item.menuItem.id);
    
    if (existingIndex >= 0) {
      final updatedItems = List<CartItem>.from(items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + item.quantity,
      );
      return copyWith(items: updatedItems, updatedAt: DateTime.now());
    } else {
      return copyWith(
        items: [...items, item],
        storeId: storeId ?? item.menuItem.storeId,
        updatedAt: DateTime.now(),
      );
    }
  }

  Cart removeItem(String itemId) {
    return copyWith(
      items: items.where((item) => item.id != itemId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  Cart updateItemQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      return removeItem(itemId);
    }

    final updatedItems = items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    return copyWith(items: updatedItems, updatedAt: DateTime.now());
  }

  Cart applyPromoCode(String code, double discount) {
    return copyWith(
      promoCode: code,
      promoDiscount: discount,
      updatedAt: DateTime.now(),
    );
  }

  Cart removePromoCode() {
    return copyWith(
      promoCode: null,
      promoDiscount: 0.0,
      updatedAt: DateTime.now(),
    );
  }

  Cart clear() {
    return copyWith(
      items: [],
      promoCode: null,
      promoDiscount: 0.0,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'storeId': storeId,
      'store': store?.toMap(),
      'items': items.map((item) => item.toMap()).toList(),
      'promoCode': promoCode,
      'promoDiscount': promoDiscount,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      id: map['id'] as String,
      storeId: map['storeId'] as String?,
      store: map['store'] != null 
          ? Store.fromMap(map['store'] as Map<String, dynamic>)
          : null,
      items: map['items'] != null
          ? (map['items'] as List).map((item) => 
              CartItem.fromMap(item as Map<String, dynamic>)).toList()
          : [],
      promoCode: map['promoCode'] as String?,
      promoDiscount: (map['promoDiscount'] as num?)?.toDouble() ?? 0.0,
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  factory Cart.empty(String id) {
    return Cart(id: id);
  }
}