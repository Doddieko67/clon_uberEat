class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double priceAtPurchase; // El precio al momento de la compra

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.priceAtPurchase,
  });

  // toMap, fromMap...
}