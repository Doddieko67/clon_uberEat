import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class StoreProfileSettingsScreen extends StatefulWidget {
  @override
  _StoreProfileSettingsScreenState createState() =>
      _StoreProfileSettingsScreenState();
}

class _StoreProfileSettingsScreenState extends State<StoreProfileSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controladores para información básica
  final _storeNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  // Datos de la tienda (simulados)
  Map<String, dynamic> _storeData = {
    'name': 'Cafetería Central',
    'description':
        'Comida tradicional mexicana preparada fresca todos los días',
    'phone': '+52 555 123 4567',
    'email': 'cafeteria.central@escuela.edu',
    'address': 'Edificio Principal, Planta Baja',
    'logo': Icons.restaurant,
    'rating': 4.8,
    'isVerified': true,
  };

  // Horarios de operación
  Map<String, Map<String, dynamic>> _operatingHours = {
    'Lunes': {'isOpen': true, 'openTime': '07:00', 'closeTime': '18:00'},
    'Martes': {'isOpen': true, 'openTime': '07:00', 'closeTime': '18:00'},
    'Miércoles': {'isOpen': true, 'openTime': '07:00', 'closeTime': '18:00'},
    'Jueves': {'isOpen': true, 'openTime': '07:00', 'closeTime': '18:00'},
    'Viernes': {'isOpen': true, 'openTime': '07:00', 'closeTime': '18:00'},
    'Sábado': {'isOpen': true, 'openTime': '08:00', 'closeTime': '16:00'},
    'Domingo': {'isOpen': false, 'openTime': '08:00', 'closeTime': '16:00'},
  };

  // Configuraciones de entrega
  Map<String, dynamic> _deliverySettings = {
    'minimumOrderAmount': 50.0,
    'deliveryFee': 0.0,
    'freeDeliveryMinimum': 100.0,
    'estimatedDeliveryTime': '15-25 min',
    'deliveryRadius': 'Campus únicamente',
    'acceptPreOrders': true,
    'maxPreOrderDays': 3,
  };

  // Configuraciones de notificaciones
  Map<String, bool> _notificationSettings = {
    'newOrders': true,
    'orderUpdates': true,
    'paymentReceived': true,
    'lowStock': false,
    'promotions': true,
    'systemUpdates': false,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStoreData();
  }

  void _loadStoreData() {
    _storeNameController.text = _storeData['name'] ?? '';
    _descriptionController.text = _storeData['description'] ?? '';
    _phoneController.text = _storeData['phone'] ?? '';
    _emailController.text = _storeData['email'] ?? '';
    _addressController.text = _storeData['address'] ?? '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _storeNameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveStoreInfo() {
    setState(() {
      _storeData['name'] = _storeNameController.text.trim();
      _storeData['description'] = _descriptionController.text.trim();
      _storeData['phone'] = _phoneController.text.trim();
      _storeData['email'] = _emailController.text.trim();
      _storeData['address'] = _addressController.text.trim();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.textPrimary),
            SizedBox(width: 8),
            Text('Información guardada correctamente'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateOperatingHours(String day, String field, dynamic value) {
    setState(() {
      _operatingHours[day]![field] = value;
    });
  }

  void _selectTime(String day, String field) async {
    final currentTime = _operatingHours[day]![field] as String;
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      _updateOperatingHours(day, field, formattedTime);
    }
  }

  void _changeStoreLogo() {
    final List<IconData> availableIcons = [
      Icons.restaurant,
      Icons.store,
      Icons.local_dining,
      Icons.fastfood,
      Icons.local_pizza,
      Icons.coffee,
      Icons.bakery_dining,
      Icons.ramen_dining,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Seleccionar Logo',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Container(
            width: double.maxFinite,
            height: 200,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: availableIcons.length,
              itemBuilder: (context, index) {
                final icon = availableIcons[index];
                final isSelected = icon == _storeData['logo'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _storeData['logo'] = icon;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? AppColors.textOnPrimary
                          : AppColors.textSecondary,
                      size: 30,
                    ),
                  ),
                );
              },
            ),
          ),
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
          _buildTabBar(),
          Expanded(child: _buildTabBarView()),
        ],
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
        'Configuración de Tienda',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Ayuda
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Centro de ayuda próximamente'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: Icon(Icons.help_outline, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.all(20),
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
        tabs: [
          Tab(text: 'Info General'),
          Tab(text: 'Horarios'),
          Tab(text: 'Entrega'),
          Tab(text: 'Notificaciones'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildGeneralInfoTab(),
        _buildOperatingHoursTab(),
        _buildDeliverySettingsTab(),
        _buildNotificationSettingsTab(),
      ],
    );
  }

  Widget _buildGeneralInfoTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppGradients.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _storeData['logo'],
                        color: AppColors.textOnSecondary,
                        size: 50,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _changeStoreLogo,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.textOnPrimary,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.edit,
                            color: AppColors.textOnPrimary,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _storeData['name'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (_storeData['isVerified'] == true) ...[
                      SizedBox(width: 8),
                      Icon(Icons.verified, color: AppColors.primary, size: 20),
                    ],
                  ],
                ),

                SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: AppColors.warning, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '${_storeData['rating']} • Tienda verificada',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Form fields
          Text(
            'Información de la Tienda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 16),

          _buildFormCard([
            TextFormField(
              controller: _storeNameController,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Nombre de la tienda',
                prefixIcon: Icon(Icons.store, color: AppColors.textSecondary),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              style: TextStyle(color: AppColors.textPrimary),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descripción',
                prefixIcon: Icon(
                  Icons.description,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              style: TextStyle(color: AppColors.textPrimary),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: Icon(Icons.phone, color: AppColors.textSecondary),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              style: TextStyle(color: AppColors.textPrimary),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email, color: AppColors.textSecondary),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Ubicación en el campus',
                prefixIcon: Icon(
                  Icons.location_on,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ]),

          SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveStoreInfo,
              icon: Icon(Icons.save, color: AppColors.textOnPrimary),
              label: Text(
                'Guardar Información',
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
    );
  }

  Widget _buildOperatingHoursTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Horarios de Operación',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 16),

          _buildFormCard([
            Column(
              children: _operatingHours.entries.map((entry) {
                final day = entry.key;
                final hours = entry.value;
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),

                      Switch(
                        value: hours['isOpen'],
                        onChanged: (value) {
                          _updateOperatingHours(day, 'isOpen', value);
                        },
                        activeColor: AppColors.primary,
                      ),

                      if (hours['isOpen']) ...[
                        SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectTime(day, 'openTime'),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      hours['openTime'],
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  '-',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectTime(day, 'closeTime'),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      hours['closeTime'],
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: Text(
                            'Cerrado',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ]),

          SizedBox(height: 24),

          // Quick actions
          Text(
            'Acciones Rápidas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Aplicar horario estándar
                    setState(() {
                      for (String day in [
                        'Lunes',
                        'Martes',
                        'Miércoles',
                        'Jueves',
                        'Viernes',
                      ]) {
                        _operatingHours[day] = {
                          'isOpen': true,
                          'openTime': '07:00',
                          'closeTime': '18:00',
                        };
                      }
                    });
                  },
                  icon: Icon(Icons.schedule, size: 16),
                  label: Text('Horario Estándar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Cerrar todos los días
                    setState(() {
                      _operatingHours.forEach((day, hours) {
                        hours['isOpen'] = false;
                      });
                    });
                  },
                  icon: Icon(Icons.close, size: 16),
                  label: Text('Cerrar Todos'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverySettingsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración de Entrega',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 16),

          _buildFormCard([
            _buildSettingRow(
              'Pedido mínimo',
              '\$${_deliverySettings['minimumOrderAmount'].toStringAsFixed(0)}',
              Icons.shopping_cart,
              onTap: () => _showEditDialog(
                'Pedido Mínimo',
                _deliverySettings['minimumOrderAmount'].toString(),
                (value) {
                  setState(() {
                    _deliverySettings['minimumOrderAmount'] = double.parse(
                      value,
                    );
                  });
                },
              ),
            ),
            Divider(color: AppColors.border),
            _buildSettingRow(
              'Costo de envío',
              _deliverySettings['deliveryFee'] == 0
                  ? 'Gratis'
                  : '\$${_deliverySettings['deliveryFee'].toStringAsFixed(0)}',
              Icons.delivery_dining,
              onTap: () => _showEditDialog(
                'Costo de Envío',
                _deliverySettings['deliveryFee'].toString(),
                (value) {
                  setState(() {
                    _deliverySettings['deliveryFee'] = double.parse(value);
                  });
                },
              ),
            ),
            Divider(color: AppColors.border),
            _buildSettingRow(
              'Envío gratis desde',
              '\$${_deliverySettings['freeDeliveryMinimum'].toStringAsFixed(0)}',
              Icons.local_shipping,
              onTap: () => _showEditDialog(
                'Envío Gratis Desde',
                _deliverySettings['freeDeliveryMinimum'].toString(),
                (value) {
                  setState(() {
                    _deliverySettings['freeDeliveryMinimum'] = double.parse(
                      value,
                    );
                  });
                },
              ),
            ),
            Divider(color: AppColors.border),
            _buildSettingRow(
              'Tiempo estimado',
              _deliverySettings['estimatedDeliveryTime'],
              Icons.access_time,
              onTap: () => _showEditDialog(
                'Tiempo Estimado de Entrega',
                _deliverySettings['estimatedDeliveryTime'],
                (value) {
                  setState(() {
                    _deliverySettings['estimatedDeliveryTime'] = value;
                  });
                },
                isText: true,
              ),
            ),
            Divider(color: AppColors.border),
            _buildSettingRow(
              'Área de entrega',
              _deliverySettings['deliveryRadius'],
              Icons.location_on,
              onTap: () => _showEditDialog(
                'Área de Entrega',
                _deliverySettings['deliveryRadius'],
                (value) {
                  setState(() {
                    _deliverySettings['deliveryRadius'] = value;
                  });
                },
                isText: true,
              ),
            ),
          ]),

          SizedBox(height: 24),

          Text(
            'Pedidos Adelantados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 12),

          _buildFormCard([
            SwitchListTile(
              title: Text(
                'Aceptar pedidos adelantados',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: Text(
                'Permite que los clientes ordenen con anticipación',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              value: _deliverySettings['acceptPreOrders'],
              onChanged: (value) {
                setState(() {
                  _deliverySettings['acceptPreOrders'] = value;
                });
              },
              activeColor: AppColors.primary,
            ),
            if (_deliverySettings['acceptPreOrders']) ...[
              Divider(color: AppColors.border),
              ListTile(
                leading: Icon(
                  Icons.calendar_today,
                  color: AppColors.textSecondary,
                ),
                title: Text(
                  'Máximo días adelantados',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                trailing: Text(
                  '${_deliverySettings['maxPreOrderDays']} días',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => _showEditDialog(
                  'Máximo Días Adelantados',
                  _deliverySettings['maxPreOrderDays'].toString(),
                  (value) {
                    setState(() {
                      _deliverySettings['maxPreOrderDays'] = int.parse(value);
                    });
                  },
                ),
              ),
            ],
          ]),
        ],
      ),
    );
  }

  Widget _buildNotificationSettingsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración de Notificaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 16),

          _buildFormCard([
            _buildNotificationTile(
              'Nuevos pedidos',
              'Recibe notificaciones cuando lleguen nuevos pedidos',
              Icons.notification_add,
              _notificationSettings['newOrders']!,
              (value) {
                setState(() {
                  _notificationSettings['newOrders'] = value;
                });
              },
            ),
            Divider(color: AppColors.border),
            _buildNotificationTile(
              'Actualizaciones de pedidos',
              'Notificaciones sobre cambios en el estado de pedidos',
              Icons.update,
              _notificationSettings['orderUpdates']!,
              (value) {
                setState(() {
                  _notificationSettings['orderUpdates'] = value;
                });
              },
            ),
            Divider(color: AppColors.border),
            _buildNotificationTile(
              'Pagos recibidos',
              'Confirmación cuando se procesen los pagos',
              Icons.payment,
              _notificationSettings['paymentReceived']!,
              (value) {
                setState(() {
                  _notificationSettings['paymentReceived'] = value;
                });
              },
            ),
            Divider(color: AppColors.border),
            _buildNotificationTile(
              'Stock bajo',
              'Alertas cuando los productos estén por agotarse',
              Icons.inventory,
              _notificationSettings['lowStock']!,
              (value) {
                setState(() {
                  _notificationSettings['lowStock'] = value;
                });
              },
            ),
            Divider(color: AppColors.border),
            _buildNotificationTile(
              'Promociones',
              'Información sobre promociones y ofertas especiales',
              Icons.local_offer,
              _notificationSettings['promotions']!,
              (value) {
                setState(() {
                  _notificationSettings['promotions'] = value;
                });
              },
            ),
            Divider(color: AppColors.border),
            _buildNotificationTile(
              'Actualizaciones del sistema',
              'Información sobre nuevas funciones y mantenimiento',
              Icons.system_update,
              _notificationSettings['systemUpdates']!,
              (value) {
                setState(() {
                  _notificationSettings['systemUpdates'] = value;
                });
              },
            ),
          ]),

          SizedBox(height: 24),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _notificationSettings.updateAll((key, value) => false);
                    });
                  },
                  icon: Icon(Icons.notifications_off, size: 16),
                  label: Text('Desactivar Todas'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _notificationSettings.updateAll((key, value) => true);
                    });
                  },
                  icon: Icon(Icons.notifications_active, size: 16),
                  label: Text('Activar Todas'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSettingRow(
    String title,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: TextStyle(color: AppColors.textPrimary)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.edit, color: AppColors.textTertiary, size: 16),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildNotificationTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: TextStyle(color: AppColors.textPrimary)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  void _showEditDialog(
    String title,
    String currentValue,
    Function(String) onSave, {
    bool isText = false,
  }) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Editar $title',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: TextField(
            controller: controller,
            style: TextStyle(color: AppColors.textPrimary),
            keyboardType: isText
                ? TextInputType.text
                : TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: title,
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
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
                final value = controller.text.trim();
                if (value.isNotEmpty) {
                  if (!isText && double.tryParse(value) == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Valor inválido'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                  onSave(value);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                'Guardar',
                style: TextStyle(color: AppColors.textOnPrimary),
              ),
            ),
          ],
        );
      },
    );
  }
}
