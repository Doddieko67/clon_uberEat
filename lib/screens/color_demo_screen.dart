import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Esta pantalla muestra todos los colores y componentes de la nueva paleta
class ColorDemoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('UBERecus Eats - Nueva Paleta'),
        backgroundColor: AppColors.dark,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Paleta principal
            _buildSection('Paleta Principal', [
              _buildColorCard('Primary', AppColors.primary, '#AB5472'),
              _buildColorCard('Secondary', AppColors.secondary, '#D49892'),
              _buildColorCard('Dark', AppColors.dark, '#231117'),
            ]),

            SizedBox(height: 24),

            // Gradientes
            _buildSection('Gradientes', [
              _buildGradientCard('Primary Gradient', AppGradients.primary),
              _buildGradientCard('Secondary Gradient', AppGradients.secondary),
              _buildGradientCard('Splash Gradient', AppGradients.splash),
            ]),

            SizedBox(height: 24),

            // Botones
            _buildSection('Botones', [
              SizedBox(height: 8),
              ElevatedButton(onPressed: () {}, child: Text('Botón Principal')),
              SizedBox(height: 8),
              OutlinedButton(onPressed: () {}, child: Text('Botón Secundario')),
              SizedBox(height: 8),
              TextButton(onPressed: () {}, child: Text('Botón de Texto')),
            ]),

            SizedBox(height: 24),

            // Cards de ejemplo
            _buildSection('Cards y Componentes', [
              _buildExampleCard(),
              SizedBox(height: 16),
              _buildExampleListTile(),
              SizedBox(height: 16),
              _buildExampleChips(),
            ]),

            SizedBox(height: 24),

            // Inputs
            _buildSection('Campos de Entrada', [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: Icon(Icons.visibility),
                ),
                obscureText: true,
              ),
            ]),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildColorCard(String name, Color color, String hex) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  hex,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientCard(String name, LinearGradient gradient) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
          ),
          SizedBox(width: 16),
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryWithOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.restaurant, color: AppColors.primary),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cafetería Central',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Abierto • 15 min',
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
                    color: AppColors.secondaryWithOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '4.8',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Comida tradicional mexicana preparada fresca todos los días. Especialidades: tacos, quesadillas y aguas frescas.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleListTile() {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.secondary,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          'María González',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          'Repartidor • En línea',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        trailing: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildExampleChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Chip(
          label: Text('Mexicana'),
          backgroundColor: AppColors.primaryWithOpacity(0.1),
          labelStyle: TextStyle(color: AppColors.primary),
        ),
        Chip(
          label: Text('Vegetariano'),
          backgroundColor: AppColors.secondaryWithOpacity(0.1),
          labelStyle: TextStyle(color: AppColors.secondary),
        ),
        Chip(
          label: Text('Rápido'),
          backgroundColor: AppColors.surfaceVariant,
          labelStyle: TextStyle(color: AppColors.textSecondary),
        ),
        ActionChip(
          label: Text('Favorito'),
          onPressed: () {},
          backgroundColor: AppColors.success.withOpacity(0.1),
          labelStyle: TextStyle(color: AppColors.success),
          avatar: Icon(Icons.favorite, size: 16, color: AppColors.success),
        ),
      ],
    );
  }
}

// Widget de ejemplo para mostrar una tarjeta de producto
class ProductCard extends StatelessWidget {
  final String name;
  final String description;
  final String price;
  final String? imageUrl;
  final VoidCallback? onTap;

  const ProductCard({
    Key? key,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                gradient: AppGradients.secondary,
              ),
              child: Center(
                child: Icon(Icons.fastfood, size: 40, color: Colors.white),
              ),
            ),

            // Información del producto
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 4),

                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: onTap,
                          icon: Icon(Icons.add, color: Colors.white, size: 20),
                          constraints: BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
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
      ),
    );
  }
}

// Widget de ejemplo para mostrar el estado de un pedido
class OrderStatusCard extends StatelessWidget {
  final String orderId;
  final String status;
  final String estimatedTime;
  final String storeName;

  const OrderStatusCard({
    Key? key,
    required this.orderId,
    required this.status,
    required this.estimatedTime,
    required this.storeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'preparando':
        statusColor = AppColors.warning;
        statusIcon = Icons.restaurant;
        break;
      case 'listo':
        statusColor = AppColors.primary;
        statusIcon = Icons.check_circle;
        break;
      case 'en camino':
        statusColor = AppColors.secondary;
        statusIcon = Icons.delivery_dining;
        break;
      case 'entregado':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_outline;
        break;
      default:
        statusColor = AppColors.textTertiary;
        statusIcon = Icons.hourglass_empty;
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),

                SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pedido #$orderId',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        storeName,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      estimatedTime,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
