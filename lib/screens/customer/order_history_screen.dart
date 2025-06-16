import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/store_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/menu_item_model.dart';
import '../../models/store_model.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../models/operating_hours.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  // Helper methods to work with real Order data
  String _getOrderStatusString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pendiente';
      case OrderStatus.preparing:
        return 'en_preparacion';
      case OrderStatus.outForDelivery:
        return 'en_camino';
      case OrderStatus.delivered:
        return 'entregado';
      case OrderStatus.cancelled:
        return 'cancelado';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.orange;
      case OrderStatus.outForDelivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Populares':
        return Icons.local_fire_department;
      case 'Tacos':
        return Icons.lunch_dining;
      case 'Quesadillas':
        return Icons.local_dining;
      case 'Bebidas':
        return Icons.local_drink;
      case 'Pizza':
        return Icons.local_pizza;
      case 'Sushi':
        return Icons.set_meal;
      case 'Saludable':
        return Icons.eco;
      case 'Postres':
        return Icons.cake;
      default:
        return Icons.restaurant_menu;
    }
  }

  List<Order> _getFilteredOrders(List<Order> allOrders, String? currentUserId) {
    if (currentUserId == null) return [];
    
    // Filtrar solo pedidos del usuario actual
    List<Order> filtered = allOrders
        .where((order) => order.customerId == currentUserId)
        .toList();

    // Filtrar por tab seleccionado
    switch (_tabController.index) {
      case 1: // Entregados
        filtered = filtered
            .where((order) => order.status == OrderStatus.delivered)
            .toList();
        break;
      case 2: // En proceso
        filtered = filtered
            .where(
              (order) =>
                  order.status == OrderStatus.pending ||
                  order.status == OrderStatus.preparing ||
                  order.status == OrderStatus.outForDelivery,
            )
            .toList();
        break;
      case 3: // Cancelados
        filtered = filtered
            .where((order) => order.status == OrderStatus.cancelled)
            .toList();
        break;
    }

    // Filtrar por búsqueda
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((order) {
        // Buscar en ID de orden
        if (order.id.toLowerCase().contains(searchTerm)) return true;
        
        // Buscar en items del pedido
        return order.items.any((item) => 
          item.productName.toLowerCase().contains(searchTerm));
      }).toList();
    }

    // Ordenar por fecha, más reciente primero
    filtered.sort((a, b) => b.orderTime.compareTo(a.orderTime));

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'entregado':
        return 'Entregado';
      case 'en_preparacion':
        return 'En preparación';
      case 'en_camino':
        return 'En camino';
      case 'cancelado':
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} días atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  
  void _performReorder(Order order) {
    final cartNotifier = ref.read(cartProvider.notifier);
    final stores = ref.read(storeProvider);
    
    // Buscar la tienda del pedido
    final store = stores.firstWhere((s) => s.id == order.storeId, 
        orElse: () => stores.isNotEmpty ? stores.first : Store(
          id: order.storeId,
          name: 'Usuario Tienda',
          storeName: 'Tienda desconocida',
          description: '',
          address: '',
          category: 'Comida',
          rating: 0.0,
          deliveryTime: 30,
          deliveryFee: 0.0,
          isOpen: true,
          lastActive: DateTime.now(),
          openingHours: OperatingHours.standard('9:00 AM', '9:00 PM'),
          status: UserStatus.active,
          reviewCount: 0,
        ));
    
    // Verificar si el carrito es de otra tienda
    if (!cartNotifier.canAddItemFromStore(store.id)) {
      _showStoreChangeDialog(() {
        cartNotifier.clearCartForNewStore(store);
        _addOrderItemsToCart(order, store);
      });
    } else {
      cartNotifier.setStore(store);
      _addOrderItemsToCart(order, store);
    }
  }
  
  void _addOrderItemsToCart(Order order, Store store) {
    final cartNotifier = ref.read(cartProvider.notifier);
    final menuItems = ref.read(menuForStoreProvider(store.id));
    int itemsAdded = 0;
    
    // Agregar cada item del pedido al carrito
    for (var orderItem in order.items) {
      final menuItem = _findMenuItemByName(menuItems, orderItem.productName);
      if (menuItem != null) {
        cartNotifier.addItem(menuItem, quantity: orderItem.quantity);
        itemsAdded++;
      }
    }
    
    context.go('/customer/cart');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemsAdded productos agregados al carrito'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  MenuItem? _findMenuItemByName(List<MenuItem> menuItems, String name) {
    try {
      return menuItems.firstWhere((item) => item.name == name);
    } catch (e) {
      // Si no encuentra el item exacto, buscar uno similar o crear uno mock
      return _createMockMenuItem(name);
    }
  }
  
  MenuItem _createMockMenuItem(String name) {
    // Crear un MenuItem mock basado en el nombre para que el reorder funcione
    return MenuItem(
      id: 'reorder_${name.hashCode}',
      name: name,
      description: 'Producto reordenado',
      price: 50.0, // Precio mock
      category: 'Populares',
      isAvailable: true,
      storeId: '1', // ID mock
    );
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
            'Tu carrito actual será vaciado para agregar los productos de este pedido. ¿Deseas continuar?',
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
              child: Text('Continuar', style: TextStyle(color: AppColors.textOnPrimary)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        );
      },
    );
  }

  void _rateOrder(Order order) {
    int rating = order.rating ?? 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: AppGradients.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCategoryIcon('Comida'),
                        color: AppColors.textOnPrimary,
                        size: 30,
                      ),
                    ),

                    SizedBox(height: 16),

                    Text(
                      'Califica tu experiencia',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'Pedido #${order.id.substring(0, 8)}...',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () {
                            setDialogState(() {
                              rating = index + 1;
                            });
                          },
                          icon: Icon(
                            Icons.star,
                            size: 32,
                            color: index < rating
                                ? AppColors.warning
                                : AppColors.textTertiary,
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: rating > 0
                            ? () {
                                Navigator.pop(context);

                                // Update the order rating through the provider
                                ref.read(ordersProvider.notifier).updateOrderRating(order.id, rating);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '¡Gracias por tu calificación!',
                                    ),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            : null,
                        child: Text(
                          'Enviar calificación',
                          style: TextStyle(color: AppColors.textOnPrimary),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final ordersAsync = ref.watch(ordersProvider);
                final authState = ref.watch(authNotifierProvider);
                
                return ordersAsync.when(
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  error: (error, stack) => _buildErrorState(error.toString(), ref),
                  data: (orders) => _buildOrdersListWithData(orders, authState.user?.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        'Mis Pedidos',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Filtros avanzados
          },
          icon: Icon(Icons.filter_list, color: AppColors.textSecondary),
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
          hintText: 'Buscar pedidos, tiendas o productos...',
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
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicator: BoxDecoration(
          color: AppColors.primaryWithOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        onTap: (index) {
          setState(() {});
        },
        tabs: [
          Tab(text: 'Todos'),
          Tab(text: 'Entregados'),
          Tab(text: 'En proceso'),
          Tab(text: 'Cancelados'),
        ],
      ),
    );
  }

  Widget _buildOrdersListWithData(List<Order> allOrders, String? currentUserId) {
    final orders = _getFilteredOrders(allOrders, currentUserId);

    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildErrorState(String error, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 16),
          Text(
            'Error al cargar pedidos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.refresh(ordersProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Reintentar',
              style: TextStyle(color: AppColors.textOnPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_tabController.index) {
      case 1:
        message = 'No tienes pedidos entregados';
        icon = Icons.receipt_long_outlined;
        break;
      case 2:
        message = 'No tienes pedidos en proceso';
        icon = Icons.hourglass_empty;
        break;
      case 3:
        message = 'No tienes pedidos cancelados';
        icon = Icons.cancel_outlined;
        break;
      default:
        message = _searchController.text.isNotEmpty
            ? 'No se encontraron pedidos'
            : 'No tienes pedidos aún';
        icon = Icons.search_off;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textTertiary),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (_tabController.index == 0 && _searchController.text.isEmpty) ...[
            SizedBox(height: 8),
            Text(
              'Haz tu primer pedido para verlo aquí',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.go('/customer');
              },
              child: Text(
                'Explorar tiendas',
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
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
        onTap: () {
          _showOrderDetails(order);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Header del pedido
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: AppGradients.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon('Comida'),
                      color: AppColors.textOnSecondary,
                      size: 25,
                    ),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pedido #${order.id.substring(0, 8)}...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${order.items.length} producto(s)',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(_getOrderStatusString(order.status)),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Items del pedido
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    ...order.items
                        .take(2)
                        .map<Widget>(
                          (item) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item.quantity}x ${item.productName}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),

                    if (order.items.length > 2)
                      Text(
                        '+${order.items.length - 2} producto(s) más',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 12),

              // Footer del pedido
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: \$${order.totalAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        _formatDate(order.orderTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      // Botón de calificar (solo para entregados sin calificación)
                      if (order.status == OrderStatus.delivered)
                        IconButton(
                          onPressed: () => _rateOrder(order),
                          icon: Icon(
                            Icons.star_border,
                            color: AppColors.warning,
                          ),
                          tooltip: 'Calificar',
                        ),

                      SizedBox(width: 8),

                      // Botón de reordenar (siempre visible para pedidos entregados)
                      if (order.status == OrderStatus.delivered)
                        OutlinedButton(
                          onPressed: () => _performReorder(order),
                          child: Text(
                            'Reordenar',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(Order order) {
    // Estado persistente fuera del builder
    bool isDetailsExpanded = false;
    bool isProductsExpanded = true;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
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
                  Row(
                    children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppGradients.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon('Comida'),
                      color: AppColors.textOnSecondary,
                      size: 30,
                    ),
                  ),

                  SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pedido #${order.id.substring(0, 8)}...',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'ID: ${order.id}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(_getOrderStatusString(order.status)),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Detalles del pedido - Collapsible
              _buildCollapsibleSection(
                title: 'Detalles del pedido',
                isExpanded: isDetailsExpanded,
                onToggle: () {
                  setModalState(() {
                    isDetailsExpanded = !isDetailsExpanded;
                  });
                },
                content: Column(
                  children: [
                    _buildDetailRow('Fecha', _formatDate(order.orderTime)),
                    _buildDetailRow('Cliente', order.customerId),
                    _buildDetailRow('Tienda', order.storeId),
                    if (order.deliveryAddress != null)
                      _buildDetailRow('Dirección de entrega', order.deliveryAddress!),
                    if (order.specialInstructions != null && order.specialInstructions!.isNotEmpty)
                      _buildDetailRow('Instrucciones especiales', order.specialInstructions!),
                  ],
                ),
              ),

              // Productos ordenados - Collapsible
              _buildCollapsibleSection(
                title: 'Productos ordenados (${order.items.length})',
                isExpanded: isProductsExpanded,
                onToggle: () {
                  setModalState(() {
                    isProductsExpanded = !isProductsExpanded;
                  });
                },
                content: order.items.isEmpty 
                  ? Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No hay productos en este pedido',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Column(
                      children: order.items.map((item) => Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.border.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: AppGradients.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getCategoryIcon('Comida'),
                            color: AppColors.textOnPrimary,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (item.specialInstructions != null && item.specialInstructions!.isNotEmpty)
                                Text(
                                  item.specialInstructions!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${item.quantity}x',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '\$${(item.priceAtPurchase * item.quantity).toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                      )).toList(),
                    ),
              ),

              SizedBox(height: 16),

              // Total
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryWithOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total pagado',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '\$${order.totalAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget content,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: Duration(milliseconds: 250),
            crossFadeState: isExpanded 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            firstChild: SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: content,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
