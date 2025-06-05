import 'package:flutter/material.dart';
import 'dart:async';
import '../../theme/app_theme.dart';

class OrderTrackingScreen extends StatefulWidget {
  @override
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  Timer? _statusTimer;
  int _currentStep = 0;

  // Datos simulados del pedido
  final String _orderNumber =
      '#CMP${DateTime.now().millisecondsSinceEpoch % 10000}';
  final String _storeName = 'Cafetería Central';
  final String _estimatedTime = '15-25 min';

  final List<Map<String, dynamic>> _orderItems = [
    {'name': 'Tacos de Pastor', 'quantity': 2, 'price': 45.0},
    {'name': 'Quesadilla Especial', 'quantity': 1, 'price': 65.0},
    {'name': 'Agua de Horchata', 'quantity': 2, 'price': 25.0},
  ];

  final List<Map<String, dynamic>> _trackingSteps = [
    {
      'title': 'Pedido confirmado',
      'subtitle': 'Tu pedido ha sido recibido',
      'icon': Icons.check_circle,
      'time': '14:32',
      'isCompleted': true,
    },
    {
      'title': 'Preparando tu pedido',
      'subtitle': 'La cocina está preparando tu comida',
      'icon': Icons.restaurant,
      'time': '14:35',
      'isCompleted': true,
    },
    {
      'title': 'Pedido listo',
      'subtitle': 'Tu pedido está listo para recoger',
      'icon': Icons.done_all,
      'time': '14:48',
      'isCompleted': true,
    },
    {
      'title': 'En camino',
      'subtitle': 'El repartidor va hacia tu ubicación',
      'icon': Icons.delivery_dining,
      'time': '14:50',
      'isCompleted': false,
    },
    {
      'title': 'Entregado',
      'subtitle': 'Tu pedido ha sido entregado',
      'icon': Icons.home,
      'time': '',
      'isCompleted': false,
    },
  ];

  // Datos del repartidor
  final Map<String, dynamic> _deliveryPerson = {
    'name': 'Carlos Mendoza',
    'phone': '+52 555 123 4567',
    'vehicle': 'Bicicleta Roja',
    'rating': 4.8,
    'estimatedArrival': '5-8 min',
    'currentLocation': 'A 2 cuadras de distancia',
  };

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupStatusTimer();
    _currentStep = 3; // Actualmente "En camino"
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );

    _pulseController.repeat(reverse: true);
    _progressController.forward();
  }

  void _setupStatusTimer() {
    // Simular actualizaciones de estado cada 10 segundos
    _statusTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (_currentStep < _trackingSteps.length - 1 && mounted) {
        setState(() {
          _trackingSteps[_currentStep]['isCompleted'] = true;
          _currentStep++;
          if (_currentStep < _trackingSteps.length) {
            _trackingSteps[_currentStep]['time'] =
                '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
          }
        });

        if (_currentStep == _trackingSteps.length - 1) {
          // Pedido entregado
          timer.cancel();
          _showDeliveryConfirmation();
        }
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _statusTimer?.cancel();
    super.dispose();
  }

  void _showDeliveryConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: AppColors.textOnPrimary,
                    size: 40,
                  ),
                ),

                SizedBox(height: 24),

                Text(
                  '¡Pedido entregado!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 12),

                Text(
                  '¿Cómo estuvo tu experiencia?',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      onPressed: () {
                        // TODO: Guardar calificación
                      },
                      icon: Icon(
                        Icons.star,
                        color: AppColors.warning,
                        size: 32,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/customer-home',
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Finalizar',
                      style: TextStyle(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w600,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(),
            SizedBox(height: 24),
            _buildMapSection(),
            SizedBox(height: 24),
            _buildTrackingTimeline(),
            SizedBox(height: 24),
            if (_currentStep == 3) _buildDeliveryPersonInfo(),
            if (_currentStep == 3) SizedBox(height: 24),
            _buildOrderSummary(),
            SizedBox(height: 24),
            _buildContactButtons(),
          ],
        ),
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
        'Rastrear pedido',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Compartir estado del pedido
          },
          icon: Icon(Icons.share, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryWithOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pedido $_orderNumber',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'De: $_storeName',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textOnPrimary.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _trackingSteps[_currentStep]['title'],
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
              Icon(Icons.access_time, color: AppColors.textOnPrimary, size: 16),
              SizedBox(width: 8),
              Text(
                'Tiempo estimado: ${_deliveryPerson['estimatedArrival']}',
                style: TextStyle(fontSize: 14, color: AppColors.textOnPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Simulación de mapa
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.surfaceVariant, AppColors.surface],
                ),
              ),
              child: CustomPaint(painter: MapPainter()),
            ),

            // Indicador de repartidor
            if (_currentStep == 3)
              Positioned(
                top: 60,
                left: 100,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.delivery_dining,
                          color: AppColors.textOnPrimary,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Indicador de destino
            Positioned(
              bottom: 40,
              right: 80,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on,
                  color: AppColors.textOnSecondary,
                  size: 18,
                ),
              ),
            ),

            // Información superpuesta
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.primary, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentStep == 3
                            ? _deliveryPerson['currentLocation']
                            : 'Ubicación: $_storeName',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingTimeline() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado del pedido',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 20),

          ..._trackingSteps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isActive = index == _currentStep;
            final isCompleted = step['isCompleted'];
            final isLast = index == _trackingSteps.length - 1;

            return IntrinsicHeight(
              child: Row(
                children: [
                  // Timeline indicator
                  Column(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isCompleted || isActive
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                          shape: BoxShape.circle,
                          border: isActive && !isCompleted
                              ? Border.all(color: AppColors.primary, width: 3)
                              : null,
                        ),
                        child: Icon(
                          step['icon'],
                          color: isCompleted || isActive
                              ? AppColors.textOnPrimary
                              : AppColors.textTertiary,
                          size: 20,
                        ),
                      ),

                      if (!isLast)
                        Container(
                          width: 2,
                          height: 40,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          color: isCompleted
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                    ],
                  ),

                  SizedBox(width: 16),

                  // Step content
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                step['title'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isCompleted || isActive
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              if (step['time'].isNotEmpty)
                                Text(
                                  step['time'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),

                          SizedBox(height: 4),

                          Text(
                            step['subtitle'],
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),

                          if (isActive && !isCompleted)
                            Container(
                              margin: EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'En progreso...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDeliveryPersonInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryWithOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.delivery_dining, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Tu repartidor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary,
                child: Icon(
                  Icons.person,
                  color: AppColors.textOnPrimary,
                  size: 30,
                ),
              ),

              SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _deliveryPerson['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(Icons.star, color: AppColors.warning, size: 14),
                        SizedBox(width: 4),
                        Text(
                          '${_deliveryPerson['rating']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          _deliveryPerson['vehicle'],
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

              IconButton(
                onPressed: () {
                  // TODO: Llamar al repartidor
                },
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone,
                    color: AppColors.textOnPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen del pedido',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 16),

          ..._orderItems
              .map(
                (item) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item['quantity']}x ${item['name']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '\$${(item['price'] * item['quantity']).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),

          Divider(color: AppColors.border, height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '\$${_orderItems.fold(0.0, (sum, item) => sum + (item['price'] * item['quantity'])).toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Contactar tienda
            },
            icon: Icon(Icons.store, color: AppColors.primary),
            label: Text(
              'Contactar tienda',
              style: TextStyle(color: AppColors.primary),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        SizedBox(width: 12),

        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Ayuda/soporte
            },
            icon: Icon(Icons.help_outline, color: AppColors.textOnPrimary),
            label: Text(
              'Ayuda',
              style: TextStyle(color: AppColors.textOnPrimary),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter para simular un mapa
class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;

    // Dibujar líneas de "calles"
    for (int i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (int i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Dibujar "ruta"
    final routePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.3);
    path.lineTo(size.width * 0.5, size.height * 0.3);
    path.lineTo(size.width * 0.5, size.height * 0.6);
    path.lineTo(size.width * 0.75, size.height * 0.6);
    path.lineTo(size.width * 0.75, size.height * 0.8);

    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
