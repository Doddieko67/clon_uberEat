import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String customerId;
  final String storeId;
  final double amount;
  final double taxAmount;
  final double tipAmount;

  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.customerId,
    required this.storeId,
    required this.amount,
    this.taxAmount = 0.0,
    this.tipAmount = 0.0,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _holderNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Configurar detalles del pago
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentPaymentProvider.notifier).setOrderDetails(
        orderId: widget.orderId,
        customerId: widget.customerId,
        storeId: widget.storeId,
        amount: widget.amount,
        taxAmount: widget.taxAmount,
        tipAmount: widget.tipAmount,
      );
      
      // Cargar métodos de pago del usuario
      ref.read(paymentMethodsProvider.notifier).loadPaymentMethods(widget.customerId);
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _holderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(currentPaymentProvider);
    final paymentMethods = ref.watch(paymentMethodsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Método de Pago'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: paymentState.isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Procesando pago...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderSummary(paymentState),
                  const SizedBox(height: 24),
                  _buildTipSection(paymentState),
                  const SizedBox(height: 24),
                  _buildPaymentMethods(paymentMethods),
                  const SizedBox(height: 24),
                  if (paymentState.selectedPaymentMethod?.type == PaymentType.creditCard ||
                      paymentState.selectedPaymentMethod?.type == PaymentType.debitCard)
                    _buildCardForm(),
                  const SizedBox(height: 32),
                  _buildPayButton(paymentState),
                  if (paymentState.error != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorMessage(paymentState.error!),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildOrderSummary(PaymentState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del Pedido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:'),
                Text('\$${state.amount?.toStringAsFixed(2) ?? '0.00'}'),
              ],
            ),
            if (state.taxAmount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Impuestos:'),
                  Text('\$${state.taxAmount.toStringAsFixed(2)}'),
                ],
              ),
            ],
            if (state.tipAmount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Propina:'),
                  Text('\$${state.tipAmount.toStringAsFixed(2)}'),
                ],
              ),
            ],
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${state.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipSection(PaymentState state) {
    final tipOptions = [0.0, 10.0, 15.0, 20.0];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Propina para el Repartidor',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: tipOptions.map((tip) {
                final isSelected = state.tipAmount == tip;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(currentPaymentProvider.notifier).setTipAmount(tip);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected ? Colors.red : Colors.transparent,
                        foregroundColor: isSelected ? Colors.white : Colors.red,
                      ),
                      child: Text('\$${tip.toStringAsFixed(0)}'),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods(AsyncValue<List<PaymentMethod>> paymentMethods) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Método de Pago',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            paymentMethods.when(
              data: (methods) {
                if (methods.isEmpty) {
                  return _buildDefaultPaymentMethods();
                }
                return Column(
                  children: methods.map((method) => _buildPaymentMethodTile(method)).toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => _buildDefaultPaymentMethods(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultPaymentMethods() {
    final defaultMethods = [
      PaymentMethod(
        id: 'card',
        name: 'Tarjeta de Crédito/Débito',
        type: PaymentType.creditCard,
        createdAt: DateTime.now(),
      ),
      PaymentMethod(
        id: 'cash',
        name: 'Efectivo',
        type: PaymentType.cash,
        createdAt: DateTime.now(),
      ),
    ];

    return Column(
      children: defaultMethods.map((method) => _buildPaymentMethodTile(method)).toList(),
    );
  }

  Widget _buildPaymentMethodTile(PaymentMethod method) {
    final currentPayment = ref.watch(currentPaymentProvider);
    final isSelected = currentPayment.selectedPaymentMethod?.id == method.id;

    return ListTile(
      leading: Icon(
        method.type.icon,
        color: method.type.color,
      ),
      title: Text(method.name),
      subtitle: method.cardNumber != null 
          ? Text('**** **** **** ${method.cardNumber}')
          : null,
      trailing: Radio<String>(
        value: method.id,
        groupValue: currentPayment.selectedPaymentMethod?.id,
        onChanged: (value) {
          ref.read(currentPaymentProvider.notifier).setPaymentMethod(method);
        },
      ),
      onTap: () {
        ref.read(currentPaymentProvider.notifier).setPaymentMethod(method);
      },
    );
  }

  Widget _buildCardForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información de la Tarjeta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Número de Tarjeta',
                  hintText: '1234 5678 9012 3456',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el número de tarjeta';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: const InputDecoration(
                        labelText: 'MM/YY',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese la fecha';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese el CVV';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _holderNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Titular',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el nombre del titular';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayButton(PaymentState state) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: state.canProcessPayment ? _processPayment : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        child: Text(
          'Pagar \$${state.totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    final currentPayment = ref.read(currentPaymentProvider);
    
    // Validar formulario de tarjeta si es necesario
    if ((currentPayment.selectedPaymentMethod?.type == PaymentType.creditCard ||
         currentPayment.selectedPaymentMethod?.type == PaymentType.debitCard) &&
        !_formKey.currentState!.validate()) {
      return;
    }

    // Preparar datos de la tarjeta
    Map<String, String>? cardData;
    if (currentPayment.selectedPaymentMethod?.type == PaymentType.creditCard ||
        currentPayment.selectedPaymentMethod?.type == PaymentType.debitCard) {
      cardData = {
        'number': _cardNumberController.text,
        'expiry': _expiryController.text,
        'cvv': _cvvController.text,
        'holder_name': _holderNameController.text,
      };
      
      ref.read(currentPaymentProvider.notifier).setCardData(cardData);
    }

    try {
      final transaction = await ref.read(currentPaymentProvider.notifier).processPayment();
      
      if (transaction.isCompleted) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            '/payment-success',
            arguments: transaction,
          );
        }
      } else {
        // Mostrar error específico del pago
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(transaction.failureReason ?? 'Error en el pago'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}