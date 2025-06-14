class MenuItem {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String category;
  final bool isAvailable;
  final List<String>? ingredients;
  final int? calories;
  final int? preparationTime;
  final bool isPopular;
  final double? originalPrice;

  MenuItem({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.category,
    required this.isAvailable,
    this.ingredients,
    this.calories,
    this.preparationTime,
    this.isPopular = false,
    this.originalPrice,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  MenuItem copyWith({
    String? id,
    String? storeId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    bool? isAvailable,
    List<String>? ingredients,
    int? calories,
    int? preparationTime,
    bool? isPopular,
    double? originalPrice,
  }) {
    return MenuItem(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      ingredients: ingredients ?? this.ingredients,
      calories: calories ?? this.calories,
      preparationTime: preparationTime ?? this.preparationTime,
      isPopular: isPopular ?? this.isPopular,
      originalPrice: originalPrice ?? this.originalPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'storeId': storeId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isAvailable': isAvailable,
      'ingredients': ingredients,
      'calories': calories,
      'preparationTime': preparationTime,
      'isPopular': isPopular,
      'originalPrice': originalPrice,
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'] as String,
      storeId: map['storeId'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      imageUrl: map['imageUrl'] as String?,
      category: map['category'] as String,
      isAvailable: map['isAvailable'] as bool,
      ingredients: map['ingredients'] != null 
          ? List<String>.from(map['ingredients'])
          : null,
      calories: map['calories'] as int?,
      preparationTime: map['preparationTime'] as int?,
      isPopular: map['isPopular'] as bool? ?? false,
      originalPrice: map['originalPrice'] != null 
          ? (map['originalPrice'] as num).toDouble()
          : null,
    );
  }
}
