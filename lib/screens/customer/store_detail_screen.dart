import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../models/store_model.dart';
import '../../models/menu_item_model.dart';
import '../../providers/store_provider.dart';
import '../../providers/cart_provider.dart';

class StoreDetailScreen extends ConsumerStatefulWidget {
  @override
  _StoreDetailScreenState createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends ConsumerState<StoreDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  Store? _store;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    
    // Obtener store de los argumentos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Store) {
        setState(() {
          _store = args;
          _categories = ref.read(categoriesForStoreProvider(args.id));
          _tabController = TabController(length: _categories.length, vsync: this);
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

  void _addToCart(MenuItem menuItem) {
    if (_store != null) {
      final cartNotifier = ref.read(cartProvider.notifier);
      
      // Verificar si el carrito es de otra tienda
      if (!cartNotifier.canAddItemFromStore(_store!.id)) {
        _showStoreChangeDialog(() {
          cartNotifier.clearCartForNewStore(_store!);
          cartNotifier.addItem(menuItem);
          _showSuccessSnackBar('Producto agregado al carrito');
        });
      } else {
        cartNotifier.setStore(_store!);
        cartNotifier.addItem(menuItem);
        _showSuccessSnackBar('Producto agregado al carrito');
      }
    }
  }

  void _incrementItem(MenuItem menuItem) {
    final cartNotifier = ref.read(cartProvider.notifier);
    cartNotifier.addItem(menuItem);
  }

  void _decrementItem(String menuItemId) {
    final cartNotifier = ref.read(cartProvider.notifier);
    final cartItem = cartNotifier.getCartItem(menuItemId);
    if (cartItem != null) {
      cartNotifier.decrementItem(cartItem.id);
    }
  }

  void _showStoreChangeDialog(VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Cambiar restaurante',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            'Tu carrito actual será vaciado. ¿Deseas continuar?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Populares':
        return Icons.local_fire_department;
      case 'Tacos':
        return Icons.lunch_dining;
      case 'Quesadillas':
        return Icons.local_dining;
      case 'Bebidas':
        return Icons.local_drink;
      default:
        return Icons.restaurant_menu;
    }
  }

  IconData _getStoreIcon(String category) {
    switch (category) {
      case 'Mexicana':
        return Icons.restaurant;
      case 'Italiana':
        return Icons.local_pizza;
      case 'Asiática':
        return Icons.set_meal;
      case 'Saludable':
        return Icons.eco;
      case 'Postres':
        return Icons.cake;
      case 'Bebidas':
        return Icons.local_drink;
      case 'Americana':
        return Icons.lunch_dining;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_store == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Cargando...'),
          backgroundColor: AppColors.surface,
        ),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final cartItemsCount = ref.watch(cartItemsCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildStoreInfo(),
          _buildSearchBar(),
          if (_categories.isNotEmpty) _buildTabBar(),
          _buildProductsList(),
        ],
      ),
      bottomNavigationBar: cartItemsCount > 0 ? _buildCartBottomBar() : null,
    );
  }

  Widget _buildSliverAppBar() {
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
              _getStoreIcon(_store!.category),
              size: 80,
              color: AppColors.textOnSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreInfo() {
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
                        _store!.storeName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _store!.description ?? 'Restaurante en ${_store!.category}',
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
                    color: _store!.isOpen
                        ? AppColors.success
                        : AppColors.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _store!.isOpen ? 'Abierto' : 'Cerrado',
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
                  '${_store!.rating}',
                  AppColors.warning,
                ),
                SizedBox(width: 12),
                _buildInfoChip(
                  Icons.access_time,
                  '${_store!.deliveryTime} min',
                  AppColors.textSecondary,
                ),
                SizedBox(width: 12),
                _buildInfoChip(
                  Icons.delivery_dining,
                  _store!.deliveryFee == 0
                      ? 'Gratis'
                      : '\$${_store!.deliveryFee.toInt()}',
                  _store!.deliveryFee == 0
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
              ],
            ),

            if (_store!.hasSpecialOffer && _store!.specialOffer != null) ...[
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
                      _store!.specialOffer!,
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
          tabs: _categories.map((category) => Tab(text: category)).toList(),
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    if (_store == null || _categories.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.restaurant_menu, size: 64, color: AppColors.textTertiary),
              SizedBox(height: 16),
              Text(
                'Sin menú disponible',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final selectedCategory = _categories[_tabController.index];
    
    // Usar provider para obtener los productos filtrados
    final allProducts = ref.watch(menuByCategoryProvider((
      storeId: _store!.id,
      category: selectedCategory,
    )));

    // Filtrar por búsqueda
    final products = _searchController.text.isEmpty
        ? allProducts
        : allProducts.where((product) =>
            product.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            product.description.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            product.ingredients?.any((ingredient) => 
              ingredient.toLowerCase().contains(_searchController.text.toLowerCase())) == true
          ).toList();

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
        final cartItemsCount = ref.watch(cartItemsCountProvider);
        final extraBottomPadding = isLast && cartItemsCount > 0 ? 100.0 : 0.0;

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

  Widget _buildProductCard(MenuItem product) {
    final quantity = ref.watch(cartItemQuantityProvider(product.id));

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
                  _getIconForCategory(product.category),
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
                    if (product.isPopular) ...[
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
                      product.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 8),

                    if (product.preparationTime != null)
                      Text(
                        '${product.preparationTime} min',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    Row(
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w100,
                            color: AppColors.primaryLight,
                          ),
                        ),

                        if (product.hasDiscount) ...[
                          SizedBox(width: 8),
                          Text(
                            '\$${product.originalPrice!.toStringAsFixed(0)}',
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
                      onPressed: () => _addToCart(product),
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
                            onPressed: () => _decrementItem(product.id),
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
                            onPressed: () => _incrementItem(product),
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
    final cartItemsCount = ref.watch(cartItemsCountProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    
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
                  '$cartItemsCount ${cartItemsCount == 1 ? 'producto' : 'productos'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '\$${cartTotal.toStringAsFixed(0)}',
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

  void _showProductDetail(MenuItem product) {
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
                    _getIconForCategory(product.category),
                    color: AppColors.textOnPrimary,
                    size: 60,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Product name and price
              Text(
                product.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: 8),

              Text(
                product.description,
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
                    '\$${product.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  if (product.hasDiscount) ...[
                    SizedBox(width: 12),
                    Text(
                      '\$${product.originalPrice!.toStringAsFixed(0)}',
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
                      product.calories != null ? '${product.calories} cal' : 'N/A cal',
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
                children: (product.ingredients ?? [])
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
                    _addToCart(product);
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
                    'Agregar al carrito - \$${product.price.toStringAsFixed(0)}',
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
