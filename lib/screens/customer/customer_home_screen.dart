import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class CustomerHomeScreen extends StatefulWidget {
  @override
  _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Todos';
  int _currentIndex = 0;

  final List<String> _categories = [
    'Todos',
    'Mexicana',
    'Italiana',
    'Asiática',
    'Postres',
    'Bebidas',
    'Saludable',
  ];

  final List<Map<String, dynamic>> _stores = [
    {
      'id': '1',
      'name': 'Cafetería Central',
      'description': 'Comida tradicional mexicana',
      'category': 'Mexicana',
      'rating': 4.8,
      'deliveryTime': '15-25 min',
      'deliveryFee': 0,
      'image': Icons.restaurant,
      'isOpen': true,
      'specialOffer': '20% OFF en tu primer pedido',
      'products': ['Tacos', 'Quesadillas', 'Tortas'],
    },
    {
      'id': '2',
      'name': 'Pizza Campus',
      'description': 'Las mejores pizzas del campus',
      'category': 'Italiana',
      'rating': 4.6,
      'deliveryTime': '20-30 min',
      'deliveryFee': 15,
      'image': Icons.local_pizza,
      'isOpen': true,
      'specialOffer': null,
      'products': ['Pizza Margarita', 'Pizza Pepperoni', 'Lasaña'],
    },
    {
      'id': '3',
      'name': 'Sushi Express',
      'description': 'Sushi fresco y rápido',
      'category': 'Asiática',
      'rating': 4.9,
      'deliveryTime': '25-35 min',
      'deliveryFee': 20,
      'image': Icons.set_meal,
      'isOpen': false,
      'specialOffer': null,
      'products': ['California Roll', 'Salmon Roll', 'Tempura'],
    },
    {
      'id': '4',
      'name': 'Healthy Corner',
      'description': 'Opciones saludables y nutritivas',
      'category': 'Saludable',
      'rating': 4.5,
      'deliveryTime': '10-20 min',
      'deliveryFee': 0,
      'image': Icons.eco,
      'isOpen': true,
      'specialOffer': 'Combo saludable desde \$89',
      'products': ['Ensaladas', 'Smoothies', 'Wraps'],
    },
    {
      'id': '5',
      'name': 'Sweet Dreams',
      'description': 'Postres artesanales',
      'category': 'Postres',
      'rating': 4.7,
      'deliveryTime': '15-25 min',
      'deliveryFee': 10,
      'image': Icons.cake,
      'isOpen': true,
      'specialOffer': null,
      'products': ['Cheesecake', 'Brownies', 'Frappés'],
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredStores {
    return _stores.where((store) {
      final matchesCategory =
          _selectedCategory == 'Todos' ||
          store['category'] == _selectedCategory;
      final matchesSearch =
          _searchController.text.isEmpty ||
          store['name'].toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Search Bar
            _buildSearchBar(),

            // Categories
            _buildCategories(),

            // Featured Banner
            // _buildFeaturedBanner(),

            // Stores List
            Expanded(child: _buildStoresList()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Hola ${user?.name?.split(' ')[0] ?? 'Usuario'}! 👋',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.secondary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Campus Universitario',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: Notificaciones
                        },
                        icon: Stack(
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              color: AppColors.textSecondary,
                              size: 24,
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                        icon: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary,
                          child: Icon(
                            Icons.person,
                            color: AppColors.textOnPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Buscar restaurantes o comida...',
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
              : Icon(Icons.tune, color: AppColors.textSecondary),
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

  Widget _buildCategories() {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return Container(
            margin: EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: AppColors.surfaceVariant,
              selectedColor: AppColors.primaryWithOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget _buildFeaturedBanner() {
  //   return Container(
  //     margin: EdgeInsets.all(20),
  //     height: 140,
  //     decoration: BoxDecoration(
  //       gradient: AppGradients.primary,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: AppColors.primaryWithOpacity(0.3),
  //           blurRadius: 12,
  //           offset: Offset(0, 6),
  //         ),
  //       ],
  //     ),
  //     child: Stack(
  //       children: [
  //         Positioned(
  //           right: -20,
  //           top: -20,
  //           child: Icon(
  //             Icons.local_offer,
  //             size: 100,
  //             color: AppColors.primaryWithOpacity(0.2),
  //           ),
  //         ),
  //         Padding(
  //           padding: EdgeInsets.all(20),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Text(
  //                 '🔥 Oferta Especial',
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                   color: AppColors.textOnPrimary,
  //                 ),
  //               ),
  //               SizedBox(height: 8),
  //               Text(
  //                 'Envío gratis en pedidos mayores a \$200',
  //                 style: TextStyle(
  //                   fontSize: 14,
  //                   color: AppColors.textOnPrimary.withOpacity(0.9),
  //                 ),
  //               ),
  //               SizedBox(height: 12),
  //               Container(
  //                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //                 decoration: BoxDecoration(
  //                   color: AppColors.textOnPrimary,
  //                   borderRadius: BorderRadius.circular(20),
  //                 ),
  //                 child: Text(
  //                   'Válido hoy',
  //                   style: TextStyle(
  //                     fontSize: 12,
  //                     fontWeight: FontWeight.w600,
  //                     color: AppColors.primary,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildStoresList() {
    final stores = _filteredStores;

    if (stores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textTertiary),
            SizedBox(height: 16),
            Text(
              'No encontramos tiendas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Intenta con otra búsqueda o categoría',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return _buildStoreCard(store);
      },
    );
  }

  Widget _buildStoreCard(Map<String, dynamic> store) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/customer-store-detail',
            arguments: store,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Store Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppGradients.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      store['image'],
                      color: AppColors.textOnSecondary,
                      size: 30,
                    ),
                  ),

                  SizedBox(width: 16),

                  // Store Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                store['name'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: store['isOpen']
                                    ? AppColors.success
                                    : AppColors.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                store['isOpen'] ? 'Abierto' : 'Cerrado',
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
                          store['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        SizedBox(height: 8),

                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: AppColors.warning,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${store['rating']}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(width: 16),
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              store['deliveryTime'],
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.delivery_dining,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              store['deliveryFee'] == 0
                                  ? 'Gratis'
                                  : '\$${store['deliveryFee']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: store['deliveryFee'] == 0
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                                fontWeight: store['deliveryFee'] == 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Special Offer
              if (store['specialOffer'] != null) ...[
                SizedBox(height: 12),
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
                      Icon(
                        Icons.local_offer,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        store['specialOffer'],
                        style: TextStyle(
                          fontSize: 12,
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
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
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
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
              // Ya estamos en Home
              break;
            case 1:
              Navigator.pushNamed(context, '/customer-cart');
              break;
            case 2:
              Navigator.pushNamed(context, '/customer-order-history');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
