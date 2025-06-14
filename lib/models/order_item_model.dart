class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double priceAtPurchase;
  final String? imageUrl;
  final String? specialInstructions;
  final List<String>? customizations;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.priceAtPurchase,
    this.imageUrl,
    this.specialInstructions,
    this.customizations,
  });

  double get total => priceAtPurchase * quantity;

  OrderItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? priceAtPurchase,
    String? imageUrl,
    String? specialInstructions,
    List<String>? customizations,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      priceAtPurchase: priceAtPurchase ?? this.priceAtPurchase,
      imageUrl: imageUrl ?? this.imageUrl,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      customizations: customizations ?? this.customizations,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'priceAtPurchase': priceAtPurchase,
      'imageUrl': imageUrl,
      'specialInstructions': specialInstructions,
      'customizations': customizations,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      quantity: map['quantity'] as int,
      priceAtPurchase: (map['priceAtPurchase'] as num).toDouble(),
      imageUrl: map['imageUrl'] as String?,
      specialInstructions: map['specialInstructions'] as String?,
      customizations: map['customizations'] != null 
          ? List<String>.from(map['customizations'])
          : null,
    );
  }
}