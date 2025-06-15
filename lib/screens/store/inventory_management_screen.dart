import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/inventory_provider.dart';
import '../../models/inventory_model.dart';

class InventoryManagementScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<InventoryManagementScreen> createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends ConsumerState<InventoryManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryState = ref.watch(inventoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppColors.textSecondary),
        ),
        title: Text(
          'Gestión de Inventario',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddItemDialog(),
            icon: Icon(Icons.add, color: AppColors.primary),
            tooltip: 'Agregar Item',
          ),
          IconButton(
            onPressed: () => ref.read(inventoryProvider.notifier).refreshInventory(),
            icon: Icon(Icons.refresh, color: AppColors.textSecondary),
            tooltip: 'Refrescar',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'Inventario'),
            Tab(text: 'Alertas'),
            Tab(text: 'Movimientos'),
          ],
        ),
      ),
      body: inventoryState.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: AppColors.error, size: 64),
              SizedBox(height: 16),
              Text(
                'Error al cargar inventario',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.read(inventoryProvider.notifier).refreshInventory(),
                child: Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (items) => TabBarView(
          controller: _tabController,
          children: [
            _buildInventoryTab(items),
            _buildAlertsTab(items),
            _buildMovementsTab(items),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryTab(List<InventoryItem> items) {
    final filteredItems = _getFilteredItems(items);
    final summary = ref.read(inventoryProvider.notifier).getInventorySummary();

    return Column(
      children: [
        _buildSummaryCards(summary),
        _buildSearchAndFilters(),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return _buildInventoryItemCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlertsTab(List<InventoryItem> items) {
    final notifier = ref.read(inventoryProvider.notifier);
    final lowStockItems = notifier.getLowStockItems();
    final expiringSoonItems = notifier.getExpiringSoonItems();
    final expiredItems = notifier.getExpiredItems();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (expiredItems.isNotEmpty) ...[
            _buildAlertSection(
              'Productos Vencidos',
              expiredItems,
              Colors.red,
              Icons.warning,
            ),
            SizedBox(height: 16),
          ],
          if (expiringSoonItems.isNotEmpty) ...[
            _buildAlertSection(
              'Por Vencer (3 días)',
              expiringSoonItems,
              Colors.orange,
              Icons.schedule,
            ),
            SizedBox(height: 16),
          ],
          if (lowStockItems.isNotEmpty) ...[
            _buildAlertSection(
              'Stock Bajo',
              lowStockItems,
              Colors.amber,
              Icons.inventory,
            ),
            SizedBox(height: 16),
          ],
          if (expiredItems.isEmpty && expiringSoonItems.isEmpty && lowStockItems.isEmpty)
            Center(
              child: Column(
                children: [
                  SizedBox(height: 100),
                  Icon(Icons.check_circle, color: AppColors.success, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Todo está en orden',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No hay alertas de inventario',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMovementsTab(List<InventoryItem> items) {
    final allMovements = items
        .expand((item) => item.movements.map((movement) => {
              'movement': movement,
              'itemName': item.name,
            }))
        .toList();
    
    allMovements.sort((a, b) => (b['movement'] as StockMovement)
        .timestamp
        .compareTo((a['movement'] as StockMovement).timestamp));

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: allMovements.length,
      itemBuilder: (context, index) {
        final data = allMovements[index];
        final movement = data['movement'] as StockMovement;
        final itemName = data['itemName'] as String;
        
        return _buildMovementCard(movement, itemName);
      },
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> summary) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildSummaryCard(
                'Total Items',
                '${summary['totalItems']}',
                Icons.inventory,
                AppColors.primary,
              )),
              SizedBox(width: 12),
              Expanded(child: _buildSummaryCard(
                'Valor Total',
                '\$${NumberFormat('#,##0').format(summary['totalValue'])}',
                Icons.attach_money,
                AppColors.success,
              )),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildSummaryCard(
                'Stock Bajo',
                '${summary['lowStockCount']}',
                Icons.warning,
                AppColors.warning,
              )),
              SizedBox(width: 12),
              Expanded(child: _buildSummaryCard(
                'Por Vencer',
                '${summary['expiringSoonCount']}',
                Icons.schedule,
                AppColors.error,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Buscar productos...',
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
          SizedBox(height: 12),
          // Filtros por categoría
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryFilter('all', 'Todos'),
                ...InventoryCategory.defaultCategories.map((category) =>
                    _buildCategoryFilter(category.id, category.name)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(String categoryId, String name) {
    final isSelected = _selectedCategory == categoryId;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(name),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = categoryId;
          });
        },
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildInventoryItemCard(InventoryItem item) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: AppColors.surface,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: item.statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(item.category),
            color: item.statusColor,
            size: 24,
          ),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.currentStock.toStringAsFixed(1)} ${item.unit}',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: item.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.statusText,
                    style: TextStyle(
                      fontSize: 10,
                      color: item.statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () => _showItemDetailsDialog(item),
          icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildAlertSection(String title, List<InventoryItem> items, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(_getCategoryIcon(item.category), size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    Text(
                      '${item.currentStock.toStringAsFixed(1)} ${item.unit}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMovementCard(StockMovement movement, String itemName) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      color: AppColors.surface,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: movement.type.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            movement.type.icon,
            color: movement.type.color,
            size: 20,
          ),
        ),
        title: Text(
          itemName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${movement.type.displayName} - ${movement.quantity} unidades',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(movement.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        trailing: Text(
          movement.reason,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  List<InventoryItem> _getFilteredItems(List<InventoryItem> items) {
    List<InventoryItem> filtered = items;

    // Filtrar por categoría
    if (_selectedCategory != 'all') {
      filtered = filtered.where((item) => item.category == _selectedCategory).toList();
    }

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) =>
          item.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return filtered;
  }

  IconData _getCategoryIcon(String category) {
    final categoryData = InventoryCategory.defaultCategories
        .firstWhere((cat) => cat.id == category, orElse: () => 
            InventoryCategory.defaultCategories.last);
    return categoryData.icon;
  }

  void _showAddItemDialog() {
    // TODO: Implementar diálogo para agregar nuevo item
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función de agregar item próximamente'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showItemDetailsDialog(InventoryItem item) {
    // TODO: Implementar diálogo de detalles y edición
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detalles de ${item.name}'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}