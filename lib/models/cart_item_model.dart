import 'package:clonubereat/models/menu_item_model.dart';
import 'package:clonubereat/models/order_item_model.dart';

class CartItem {
  final String id;
  final MenuItem menuItem;
  final int quantity;
  final String? specialInstructions;
  final List<String>? customizations;

  CartItem({
    required this.id,
    required this.menuItem,
    required this.quantity,
    this.specialInstructions,
    this.customizations,
  });

  double get price => menuItem.price;
  double get total => menuItem.price * quantity;
  String get name => menuItem.name;
  String get description => menuItem.description;
  String? get imageUrl => menuItem.imageUrl;

  CartItem copyWith({
    String? id,
    MenuItem? menuItem,
    int? quantity,
    String? specialInstructions,
    List<String>? customizations,
  }) {
    return CartItem(
      id: id ?? this.id,
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      customizations: customizations ?? this.customizations,
    );
  }

  OrderItem toOrderItem() {
    return OrderItem(
      productId: menuItem.id,
      productName: menuItem.name,
      quantity: quantity,
      priceAtPurchase: menuItem.price,
      imageUrl: menuItem.imageUrl,
      specialInstructions: specialInstructions,
      customizations: customizations,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'menuItem': menuItem.toMap(),
      'quantity': quantity,
      'specialInstructions': specialInstructions,
      'customizations': customizations,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as String,
      menuItem: MenuItem.fromMap(map['menuItem'] as Map<String, dynamic>),
      quantity: map['quantity'] as int,
      specialInstructions: map['specialInstructions'] as String?,
      customizations: map['customizations'] != null 
          ? List<String>.from(map['customizations'])
          : null,
    );
  }

  factory CartItem.fromMenuItem(MenuItem menuItem, {int quantity = 1, String? specialInstructions, List<String>? customizations}) {
    // Generar ID único basado en timestamp y un valor aleatorio para evitar colisiones
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp % 10000;
    return CartItem(
      id: '${menuItem.id}_${timestamp}_$random',
      menuItem: menuItem,
      quantity: quantity,
      specialInstructions: specialInstructions,
      customizations: customizations,
    );
  }
}