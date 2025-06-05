import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class StoreDetailScreen extends StatefulWidget {
  @override
  _StoreDetailScreenState createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  Map<String, int> _cartItems = {}; // productId -> quantity

  // Datos simulados de productos por categoría
  final Map<String, List<Map<String, dynamic>>> _products = {
    'Populares': [
      {
        'id': 'pop1',
        'name': 'Tacos de Pastor',
        'description':
            'Deliciosos tacos con carne de pastor, piña, cebolla y cilantro',
        'price': 45.0,
        'originalPrice': 55.0,
        'image': Icons.lunch_dining,
        'isPopular': true,
        'preparationTime': '10-15 min',
        'calories': 320,
        'ingredients': [
          'Carne de pastor',
          'Tortilla',
          'Piña',
          'Cebolla',
          'Cilantro',
        ],
      },
      {
        'id': 'pop2',
        'name': 'Quesadilla Especial',
        'description':
            'Quesadilla gigante con queso oaxaca, champiñones y pollo',
        'price': 65.0,
        'originalPrice': null,
        'image': Icons.local_dining,
        'isPopular': true,
        'preparationTime': '8-12 min',
        'calories': 580,
        'ingredients': ['Tortilla', 'Queso Oaxaca', 'Pollo', 'Champiñones'],
      },
    ],
    'Tacos': [
      {
        'id': 'taco1',
        'name': 'Tacos de Carnitas',
        'description': 'Tacos con carnitas de cerdo, cebolla y salsa verde',
        'price': 42.0,
        'originalPrice': null,
        'image': Icons.lunch_dining,
        'isPopular': false,
        'preparationTime': '8-12 min',
        'calories': 290,
        'ingredients': ['Carnitas', 'Tortilla', 'Cebolla', 'Salsa verde'],
      },
      {
        'id': 'taco2',
        'name': 'Tacos de Pollo',
        'description': 'Tacos de pollo a la plancha con guacamole',
        'price': 38.0,
        'originalPrice': null,
        'image': Icons.lunch_dining,
        'isPopular': false,
        'preparationTime': '10-15 min',
        'calories': 250,
        'ingredients': ['Pollo', 'Tortilla', 'Guacamole', 'Lechuga'],
      },
      {
        'id': 'taco3',
        'name': 'Tacos Vegetarianos',
        'description': 'Tacos con frijoles, aguacate, queso y verduras',
        'price': 35.0,
        'originalPrice': null,
        'image': Icons.lunch_dining,
        'isPopular': false,
        'preparationTime': '5-10 min',
        'calories': 220,
        'ingredients': ['Frijoles', 'Aguacate', 'Queso', 'Verduras'],
      },
    ],
    'Quesadillas': [
      {
        'id': 'ques1',
        'name': 'Quesadilla de Queso',
        'description': 'Quesadilla tradicional con queso derretido',
        'price': 35.0,
        'originalPrice': null,
        'image': Icons.local_dining,
        'isPopular': false,
        'preparationTime': '5-8 min',
        'calories': 380,
        'ingredients': ['Tortilla', 'Queso'],
      },
      {
        'id': 'ques2',
        'name': 'Quesadilla de Jamón',
        'description': 'Quesadilla con jamón y queso amarillo',
        'price': 45.0,
        'originalPrice': null,
        'image': Icons.local_dining,
        'isPopular': false,
        'preparationTime': '8-10 min',
        'calories': 420,
        'ingredients': ['Tortilla', 'Jamón', 'Queso amarillo'],
      },
    ],
    'Bebidas': [
      {
        'id': 'beb1',
        'name': 'Agua de Horchata',
        'description': 'Refrescante agua de horchata con canela',
        'price': 25.0,
        'originalPrice': null,
        'image': Icons.local_drink,
        'isPopular': false,
        'preparationTime': '2-5 min',
        'calories': 150,
        'ingredients': ['Arroz', 'Canela', 'Azúcar', 'Leche'],
      },
      {
        'id': 'beb2',
        'name': 'Agua de Jamaica',
        'description': 'Agua fresca de jamaica natural',
        'price': 20.0,
        'originalPrice': null,
        'image': Icons.local_drink,
        'isPopular': false,
        'preparationTime': '2-5 min',
        'calories': 80,
        'ingredients': ['Flor de Jamaica', 'Azúcar', 'Agua'],
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _products.keys.length, vsync: this);

    // Listener para detectar cambios de tab
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          // Actualizar cuando cambie el tab
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(String productId) {
    setState(() {
      _cartItems[productId] = (_cartItems[productId] ?? 0) + 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Producto agregado al carrito'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _removeFromCart(String productId) {
    setState(() {
      if (_cartItems[productId] != null && _cartItems[productId]! > 0) {
        _cartItems[productId] = _cartItems[productId]! - 1;
        if (_cartItems[productId] == 0) {
          _cartItems.remove(productId);
        }
      }
    });
  }

  int get _totalItems {
    return _cartItems.values.fold(0, (sum, quantity) => sum + quantity);
  }

  double get _totalPrice {
    double total = 0.0;
    _cartItems.forEach((productId, quantity) {
      // Buscar el producto en todas las categorías
      for (var category in _products.values) {
        final product = category.firstWhere(
          (p) => p['id'] == productId,
          orElse: () => {},
        );
        if (product.isNotEmpty) {
          total += product['price'] * quantity;
          break;
        }
      }
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? storeData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (storeData == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Error'),
          backgroundColor: AppColors.surface,
        ),
        body: Center(
          child: Text(
            'No se pudieron cargar los datos de la tienda',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(storeData),
          _buildStoreInfo(storeData),
          _buildSearchBar(),
          _buildTabBar(),
          _buildProductsList(),
        ],
      ),
      bottomNavigationBar: _totalItems > 0 ? _buildCartBottomBar() : null,
    );
  }

  Widget _buildSliverAppBar(Map<String, dynamic> storeData) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.surface,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Favoritos
          },
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite_border, color: AppColors.textPrimary),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(gradient: AppGradients.secondary),
          child: Center(
            child: Icon(
              storeData['image'],
              size: 80,
              color: AppColors.textOnSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreInfo(Map<String, dynamic> storeData) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkWithOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storeData['name'],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        storeData['description'],
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: storeData['isOpen']
                        ? AppColors.success
                        : AppColors.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    storeData['isOpen'] ? 'Abierto' : 'Cerrado',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            Row(
              children: [
                _buildInfoChip(
                  Icons.star,
                  '${storeData['rating']}',
                  AppColors.warning,
                ),
                SizedBox(width: 12),
                _buildInfoChip(
                  Icons.access_time,
                  storeData['deliveryTime'],
                  AppColors.textSecondary,
                ),
                SizedBox(width: 12),
                _buildInfoChip(
                  Icons.delivery_dining,
                  storeData['deliveryFee'] == 0
                      ? 'Gratis'
                      : '\$${storeData['deliveryFee']}',
                  storeData['deliveryFee'] == 0
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
              ],
            ),

            if (storeData['specialOffer'] != null) ...[
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryWithOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_offer, size: 16, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      storeData['specialOffer'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: TextField(
          controller: _searchController,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Buscar en el menú...',
            hintStyle: TextStyle(color: AppColors.textTertiary),
            prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicator: BoxDecoration(
            color: AppColors.primaryWithOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          tabs: _products.keys.map((category) => Tab(text: category)).toList(),
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    // SOLUCIÓN: Eliminar TabBarView completamente y usar solo SliverList
    final selectedCategory = _products.keys.elementAt(_tabController.index);
    final allProducts = _products[selectedCategory] ?? [];

    // Filtrar por búsqueda
    final products = _searchController.text.isEmpty
        ? allProducts
        : allProducts
              .where(
                (product) =>
                    product['name'].toLowerCase().contains(
                      _searchController.text.toLowerCase(),
                    ) ||
                    product['description'].toLowerCase().contains(
                      _searchController.text.toLowerCase(),
                    ),
              )
              .toList();

    if (products.isEmpty && _searchController.text.isNotEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 64, color: AppColors.textTertiary),
              SizedBox(height: 16),
              Text(
                'No se encontraron productos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Intenta con otra búsqueda',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index >= products.length) return null;

        final product = products[index];
        final isLast = index == products.length - 1;
        final extraBottomPadding = isLast && _totalItems > 0 ? 100.0 : 0.0;

        return Container(
          margin: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 16 + extraBottomPadding,
            top: index == 0 ? 8 : 0,
          ),
          child: _buildProductCard(product),
        );
      }, childCount: products.length),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final quantity = _cartItems[product['id']] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkWithOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showProductDetail(product),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  product['image'],
                  color: AppColors.textOnPrimary,
                  size: 40,
                ),
              ),

              SizedBox(width: 16),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product['isPopular']) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '🔥 Popular',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                    Text(
                      product['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      product['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 8),

                    Text(
                      '${product['preparationTime']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '\$${product['price'].toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w100,
                            color: AppColors.primaryLight,
                          ),
                        ),

                        if (product['originalPrice'] != null) ...[
                          SizedBox(width: 8),
                          Text(
                            '\$${product['originalPrice'].toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textTertiary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8),

              // Add to Cart Button
              quantity == 0
                  ? ElevatedButton(
                      onPressed: () => _addToCart(product['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        'Agregar',
                        style: TextStyle(
                          color: AppColors.textOnPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryWithOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _removeFromCart(product['id']),
                            icon: Icon(
                              Icons.remove,
                              color: AppColors.primary,
                              size: 16,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                          Text(
                            '$quantity',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _addToCart(product['id']),
                            icon: Icon(
                              Icons.add,
                              color: AppColors.primary,
                              size: 16,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartBottomBar() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.darkWithOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_totalItems ${_totalItems == 1 ? 'producto' : 'productos'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '\$${_totalPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/customer-cart');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ver Carrito',
                  style: TextStyle(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.shopping_cart,
                  color: AppColors.textOnPrimary,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProductDetail(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Product image
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    product['image'],
                    color: AppColors.textOnPrimary,
                    size: 60,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Product name and price
              Text(
                product['name'],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: 8),

              Text(
                product['description'],
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              SizedBox(height: 16),

              Row(
                children: [
                  Text(
                    '\$${product['price'].toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  if (product['originalPrice'] != null) ...[
                    SizedBox(width: 12),
                    Text(
                      '\$${product['originalPrice'].toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textTertiary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],

                  Spacer(),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${product['calories']} cal',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Ingredients
              Text(
                'Ingredientes:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (product['ingredients'] as List<String>)
                    .map(
                      (ingredient) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          ingredient,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),

              Spacer(),

              // Add to cart button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _addToCart(product['id']);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Agregar al carrito - \$${product['price'].toStringAsFixed(0)}',
                    style: TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
