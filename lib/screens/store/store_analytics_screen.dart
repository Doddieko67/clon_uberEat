import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/analytics_provider.dart';
import '../../models/analytics_model.dart';

class StoreAnalyticsScreen extends ConsumerStatefulWidget {
  final String storeId;

  const StoreAnalyticsScreen({Key? key, required this.storeId}) : super(key: key);

  @override
  ConsumerState<StoreAnalyticsScreen> createState() => _StoreAnalyticsScreenState();
}

class _StoreAnalyticsScreenState extends ConsumerState<StoreAnalyticsScreen> {
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.today;

  @override
  void initState() {
    super.initState();
    // Evitar el error de Riverpod usando postFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalytics();
    });
  }

  void _loadAnalytics() {
    // Usar datos mock para demostración
    ref.read(analyticsProvider.notifier).generateMockAnalytics(widget.storeId);
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(analyticsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Analytics',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          PopupMenuButton<AnalyticsPeriod>(
            icon: Icon(Icons.calendar_today, color: AppColors.textSecondary),
            onSelected: (period) {
              setState(() {
                _selectedPeriod = period;
              });
              _loadAnalytics();
            },
            itemBuilder: (context) => AnalyticsPeriod.values
                .map((period) => PopupMenuItem(
                      value: period,
                      child: Text(period.displayName),
                    ))
                .toList(),
          ),
        ],
      ),
      body: analyticsState.when(
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
                'Error al cargar analytics',
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
                onPressed: _loadAnalytics,
                child: Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (analytics) {
          if (analytics == null) {
            return Center(
              child: Text(
                'No hay datos disponibles',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          return _buildAnalyticsContent(analytics);
        },
      ),
    );
  }

  Widget _buildAnalyticsContent(StoreAnalytics analytics) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodHeader(),
          SizedBox(height: 24),
          _buildOverviewCards(analytics),
          SizedBox(height: 24),
          _buildRevenueChart(analytics),
          SizedBox(height: 24),
          _buildOrdersChart(analytics),
          SizedBox(height: 24),
          _buildTopMenuItems(analytics),
          SizedBox(height: 24),
          _buildCustomerAnalytics(analytics),
        ],
      ),
    );
  }

  Widget _buildPeriodHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.analytics, color: AppColors.textOnPrimary, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics de Tienda',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textOnPrimary,
                  ),
                ),
                Text(
                  _selectedPeriod.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textOnPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(StoreAnalytics analytics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard(
              'Ventas Totales',
              '\$${NumberFormat('#,##0').format(analytics.totalRevenue)}',
              Icons.attach_money,
              AppColors.success,
            )),
            SizedBox(width: 12),
            Expanded(child: _buildMetricCard(
              'Pedidos Totales',
              '${analytics.totalOrders}',
              Icons.shopping_bag,
              AppColors.primary,
            )),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMetricCard(
              'Valor Promedio',
              '\$${analytics.averageOrderValue.toStringAsFixed(0)}',
              Icons.trending_up,
              AppColors.secondary,
            )),
            SizedBox(width: 12),
            Expanded(child: _buildMetricCard(
              'Tasa Completada',
              '${analytics.completionRate.toStringAsFixed(1)}%',
              Icons.check_circle,
              AppColors.warning,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Spacer(),
            ],
          ),
          SizedBox(height: 12),
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
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(StoreAnalytics analytics) {
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
          Row(
            children: [
              Text(
                'Ingresos por Hora',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
              Text(
                'Pico: ${analytics.peakHour}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${(value / 1000).toStringAsFixed(0)}K',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 4,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}h',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: analytics.hourlyData
                        .map((data) => FlSpot(data.hour.toDouble(), data.revenue))
                        .toList(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersChart(StoreAnalytics analytics) {
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
            'Pedidos por Hora',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 4,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}h',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: analytics.hourlyData
                    .map((data) => BarChartGroupData(
                          x: data.hour,
                          barRods: [
                            BarChartRodData(
                              toY: data.orders.toDouble(),
                              color: AppColors.secondary,
                              width: 12,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMenuItems(StoreAnalytics analytics) {
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
            'Productos Más Vendidos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          ...analytics.topMenuItems.take(5).map((item) => _buildTopMenuItem(item)),
        ],
      ),
    );
  }

  Widget _buildTopMenuItem(TopMenuItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
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
              Icons.fastfood,
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
                  item.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${item.orderCount} pedidos • \$${NumberFormat('#,##0').format(item.revenue)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${item.percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerAnalytics(StoreAnalytics analytics) {
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
            'Análisis de Clientes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCustomerMetric(
                  'Nuevos Clientes',
                  '${analytics.newCustomers}',
                  AppColors.success,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildCustomerMetric(
                  'Clientes Frecuentes',
                  '${analytics.returningCustomers}',
                  AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.star, color: AppColors.warning, size: 20),
              SizedBox(width: 8),
              Text(
                'Rating Promedio: ${analytics.averageRating.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerMetric(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
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
}