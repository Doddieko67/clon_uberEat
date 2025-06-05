import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MenuManagementScreen extends StatefulWidget {
  @override
  _MenuManagementScreenState createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  // Datos simulados de productos por categoría
  Map<String, List<Map<String, dynamic>>> _menuItems = {
    'Tacos': [
      {
        'id': 'taco1',
        'name': 'Tacos de Pastor',
        'description':
            'Deliciosos tacos con carne de pastor, piña, cebolla y cilantro',
        'price': 45.0,
        'originalPrice': 55.0,
        'category': 'Tacos',
        'isAvailable': true,
        'preparationTime': '10-15 min',
        'calories': 320,
        'image': Icons.lunch_dining,
        'ingredients': [
          'Carne de pastor',
          'Tortilla',
          'Piña',
          'Cebolla',
          'Cilantro',
        ],
        'isPopular': true,
      },
      {
        'id': 'taco2',
        'name': 'Tacos de Carnitas',
        'description': 'Tacos con carnitas de cerdo, cebolla y salsa verde',
        'price': 42.0,
        'originalPrice': null,
        'category': 'Tacos',
        'isAvailable': true,
        'preparationTime': '8-12 min',
        'calories': 290,
        'image': Icons.lunch_dining,
        'ingredients': ['Carnitas', 'Tortilla', 'Cebolla', 'Salsa verde'],
        'isPopular': false,
      },
      {
        'id': 'taco3',
        'name': 'Tacos Vegetarianos',
        'description': 'Tacos con frijoles, aguacate, queso y verduras',
        'price': 35.0,
        'originalPrice': null,
        'category': 'Tacos',
        'isAvailable': false,
        'preparationTime': '5-10 min',
        'calories': 220,
        'image': Icons.lunch_dining,
        'ingredients': ['Frijoles', 'Aguacate', 'Queso', 'Verduras'],
        'isPopular': false,
      },
    ],
    'Quesadillas': [
      {
        'id': 'ques1',
        'name': 'Quesadilla Especial',
        'description':
            'Quesadilla gigante con queso oaxaca, champiñones y pollo',
        'price': 65.0,
        'originalPrice': null,
        'category': 'Quesadillas',
        'isAvailable': true,
        'preparationTime': '8-12 min',
        'calories': 580,
        'image': Icons.local_dining,
        'ingredients': ['Tortilla', 'Queso Oaxaca', 'Pollo', 'Champiñones'],
        'isPopular': true,
      },
      {
        'id': 'ques2',
        'name': 'Quesadilla de Queso',
        'description': 'Quesadilla tradicional con queso derretido',
        'price': 35.0,
        'originalPrice': null,
        'category': 'Quesadillas',
        'isAvailable': true,
        'preparationTime': '5-8 min',
        'calories': 380,
        'image': Icons.local_dining,
        'ingredients': ['Tortilla', 'Queso'],
        'isPopular': false,
      },
    ],
    'Bebidas': [
      {
        'id': 'beb1',
        'name': 'Agua de Horchata',
        'description': 'Refrescante agua de horchata con canela',
        'price': 25.0,
        'originalPrice': null,
        'category': 'Bebidas',
        'isAvailable': true,
        'preparationTime': '2-5 min',
        'calories': 150,
        'image': Icons.local_drink,
        'ingredients': ['Arroz', 'Canela', 'Azúcar', 'Leche'],
        'isPopular': false,
      },
      {
        'id': 'beb2',
        'name': 'Agua de Jamaica',
        'description': 'Agua fresca de jamaica natural',
        'price': 20.0,
        'originalPrice': null,
        'category': 'Bebidas',
        'isAvailable': true,
        'preparationTime': '2-5 min',
        'calories': 80,
        'image': Icons.local_drink,
        'ingredients': ['Flor de Jamaica', 'Azúcar', 'Agua'],
        'isPopular': false,
      },
    ],
  };

  final List<String> _categories = ['Tacos', 'Quesadillas', 'Bebidas'];

  List<Map<String, dynamic>> get _allProducts {
    return _menuItems.values.expand((products) => products).toList();
  }

  List<Map<String, dynamic>> get _filteredProducts {
    final selectedCategory = _tabController.index == 0
        ? null
        : _categories[_tabController.index - 1];

    List<Map<String, dynamic>> products = selectedCategory == null
        ? _allProducts
        : _menuItems[selectedCategory] ?? [];

    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      products = products
          .where(
            (product) =>
                product['name'].toLowerCase().contains(searchTerm) ||
                product['description'].toLowerCase().contains(searchTerm) ||
                product['category'].toLowerCase().contains(searchTerm),
          )
          .toList();
    }

    return products;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length + 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleProductAvailability(String productId) {
    setState(() {
      for (var category in _menuItems.values) {
        for (var product in category) {
          if (product['id'] == productId) {
            product['isAvailable'] = !product['isAvailable'];
            break;
          }
        }
      }
    });

    final product = _allProducts.firstWhere((p) => p['id'] == productId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${product['name']} ${product['isAvailable'] ? 'activado' : 'desactivado'}',
        ),
        backgroundColor: product['isAvailable']
            ? AppColors.success
            : AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteProduct(String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final product = _allProducts.firstWhere((p) => p['id'] == productId);
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Eliminar Producto',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar "${product['name']}"?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  for (var category in _menuItems.values) {
                    category.removeWhere((p) => p['id'] == productId);
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Producto eliminado'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(
                'Eliminar',
                style: TextStyle(color: AppColors.textOnPrimary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showProductForm({Map<String, dynamic>? product}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ProductFormModal(
        product: product,
        categories: _categories,
        onSave: (productData) {
          setState(() {
            if (product == null) {
              // Agregar nuevo producto
              final category = productData['category'];
              if (!_menuItems.containsKey(category)) {
                _menuItems[category] = [];
              }
              productData['id'] =
                  'prod_${DateTime.now().millisecondsSinceEpoch}';
              _menuItems[category]!.add(productData);
            } else {
              // Editar producto existente
              for (var category in _menuItems.values) {
                final index = category.indexWhere(
                  (p) => p['id'] == product['id'],
                );
                if (index != -1) {
                  category[index] = {...product, ...productData};
                  break;
                }
              }
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(child: _buildProductsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(),
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: AppColors.textOnPrimary),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back, color: AppColors.textSecondary),
      ),
      title: Text(
        'Gestión de Menú',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Importar/exportar menú
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Función de exportar próximamente'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: Icon(Icons.download, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Buscar productos...',
          hintStyle: TextStyle(color: AppColors.textTertiary),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                    });
                  },
                  icon: Icon(Icons.clear, color: AppColors.textSecondary),
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
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
        onTap: (index) {
          setState(() {});
        },
        tabs: [
          Tab(text: 'Todos (${_allProducts.length})'),
          ..._categories.map(
            (category) =>
                Tab(text: '$category (${_menuItems[category]?.length ?? 0})'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    final products = _filteredProducts;

    if (products.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 64, color: AppColors.textTertiary),
          SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty
                ? 'No se encontraron productos'
                : 'No hay productos en esta categoría',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Intenta con otra búsqueda'
                : 'Agrega productos para empezar',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showProductForm(),
            icon: Icon(Icons.add, color: AppColors.textOnPrimary),
            label: Text(
              'Agregar Producto',
              style: TextStyle(color: AppColors.textOnPrimary),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: !product['isAvailable']
            ? Border.all(color: AppColors.error.withOpacity(0.5), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.darkWithOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Product Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: product['isAvailable']
                        ? AppGradients.primary
                        : LinearGradient(
                            colors: [
                              AppColors.textTertiary,
                              AppColors.surfaceVariant,
                            ],
                          ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    product['image'],
                    color: AppColors.textOnPrimary,
                    size: 30,
                  ),
                ),

                SizedBox(width: 16),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product['name'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: product['isAvailable']
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ),
                          if (product['isPopular'] == true)
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
                        ],
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

                      Row(
                        children: [
                          Text(
                            '\$${product['price'].toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: product['isAvailable']
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
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
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: product['isAvailable']
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product['isAvailable']
                                  ? 'Disponible'
                                  : 'No disponible',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: product['isAvailable']
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                // Toggle availability
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleProductAvailability(product['id']),
                    icon: Icon(
                      product['isAvailable']
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 16,
                    ),
                    label: Text(
                      product['isAvailable'] ? 'Desactivar' : 'Activar',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: product['isAvailable']
                          ? AppColors.warning
                          : AppColors.success,
                      side: BorderSide(
                        color: product['isAvailable']
                            ? AppColors.warning
                            : AppColors.success,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 8),

                // Edit button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showProductForm(product: product),
                    icon: Icon(Icons.edit, size: 16),
                    label: Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),

                SizedBox(width: 8),

                // Delete button
                IconButton(
                  onPressed: () => _deleteProduct(product['id']),
                  icon: Icon(Icons.delete_outline, color: AppColors.error),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.error.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Modal para agregar/editar productos
class _ProductFormModal extends StatefulWidget {
  final Map<String, dynamic>? product;
  final List<String> categories;
  final Function(Map<String, dynamic>) onSave;

  const _ProductFormModal({
    this.product,
    required this.categories,
    required this.onSave,
  });

  @override
  _ProductFormModalState createState() => _ProductFormModalState();
}

class _ProductFormModalState extends State<_ProductFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _preparationTimeController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _ingredientsController = TextEditingController();

  String _selectedCategory = '';
  bool _isAvailable = true;
  bool _isPopular = false;
  IconData _selectedIcon = Icons.fastfood;

  final List<IconData> _availableIcons = [
    Icons.fastfood,
    Icons.lunch_dining,
    Icons.local_dining,
    Icons.local_drink,
    Icons.local_pizza,
    Icons.cake,
    Icons.coffee,
    Icons.restaurant,
  ];

  @override
  void initState() {
    super.initState();

    if (widget.product != null) {
      final product = widget.product!;
      _nameController.text = product['name'] ?? '';
      _descriptionController.text = product['description'] ?? '';
      _priceController.text = product['price']?.toString() ?? '';
      _originalPriceController.text =
          product['originalPrice']?.toString() ?? '';
      _preparationTimeController.text = product['preparationTime'] ?? '';
      _caloriesController.text = product['calories']?.toString() ?? '';
      _ingredientsController.text =
          (product['ingredients'] as List?)?.join(', ') ?? '';
      _selectedCategory = product['category'] ?? '';
      _isAvailable = product['isAvailable'] ?? true;
      _isPopular = product['isPopular'] ?? false;
      _selectedIcon = product['image'] ?? Icons.fastfood;
    } else {
      _selectedCategory = widget.categories.isNotEmpty
          ? widget.categories.first
          : '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _preparationTimeController.dispose();
    _caloriesController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final productData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text),
        'originalPrice': _originalPriceController.text.isNotEmpty
            ? double.parse(_originalPriceController.text)
            : null,
        'category': _selectedCategory,
        'isAvailable': _isAvailable,
        'preparationTime': _preparationTimeController.text.trim(),
        'calories': _caloriesController.text.isNotEmpty
            ? int.parse(_caloriesController.text)
            : null,
        'image': _selectedIcon,
        'ingredients': _ingredientsController.text
            .trim()
            .split(',')
            .map((e) => e.trim())
            .toList(),
        'isPopular': _isPopular,
      };

      widget.onSave(productData);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.product == null
                ? 'Producto agregado'
                : 'Producto actualizado',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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

            // Header
            Text(
              widget.product == null ? 'Agregar Producto' : 'Editar Producto',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: 24),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon selector
                      Text(
                        'Icono',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _availableIcons.length,
                          itemBuilder: (context, index) {
                            final icon = _availableIcons[index];
                            final isSelected = icon == _selectedIcon;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedIcon = icon;
                                });
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                margin: EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(8),
                                  border: isSelected
                                      ? Border.all(
                                          color: AppColors.primary,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Icon(
                                  icon,
                                  color: isSelected
                                      ? AppColors.textOnPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 20),

                      // Name
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Nombre del producto *',
                          hintText: 'Ej: Tacos de Pastor',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es requerido';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        style: TextStyle(color: AppColors.textPrimary),
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Descripción *',
                          hintText: 'Describe tu producto...',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La descripción es requerida';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      // Category
                      DropdownButtonFormField<String>(
                        value: _selectedCategory.isNotEmpty
                            ? _selectedCategory
                            : null,
                        style: TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(labelText: 'Categoría *'),
                        items: widget.categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Selecciona una categoría';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      // Price fields
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              style: TextStyle(color: AppColors.textPrimary),
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Precio *',
                                hintText: '0.00',
                                prefixText: '\$',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El precio es requerido';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Precio inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _originalPriceController,
                              style: TextStyle(color: AppColors.textPrimary),
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Precio original',
                                hintText: '0.00 (opcional)',
                                prefixText: '\$',
                              ),
                              validator: (value) {
                                if (value != null &&
                                    value.isNotEmpty &&
                                    double.tryParse(value) == null) {
                                  return 'Precio inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      // Additional fields
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _preparationTimeController,
                              style: TextStyle(color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Tiempo de preparación',
                                hintText: 'Ej: 10-15 min',
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _caloriesController,
                              style: TextStyle(color: AppColors.textPrimary),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Calorías',
                                hintText: 'Opcional',
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      // Ingredients
                      TextFormField(
                        controller: _ingredientsController,
                        style: TextStyle(color: AppColors.textPrimary),
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Ingredientes',
                          hintText: 'Separados por comas',
                        ),
                      ),

                      SizedBox(height: 20),

                      // Switches
                      Row(
                        children: [
                          Expanded(
                            child: SwitchListTile(
                              title: Text(
                                'Disponible',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                              value: _isAvailable,
                              onChanged: (value) {
                                setState(() {
                                  _isAvailable = value;
                                });
                              },
                              activeColor: AppColors.primary,
                            ),
                          ),
                          Expanded(
                            child: SwitchListTile(
                              title: Text(
                                'Popular',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                              value: _isPopular,
                              onChanged: (value) {
                                setState(() {
                                  _isPopular = value;
                                });
                              },
                              activeColor: AppColors.warning,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveProduct,
                    child: Text(
                      widget.product == null ? 'Agregar' : 'Guardar',
                      style: TextStyle(color: AppColors.textOnPrimary),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
