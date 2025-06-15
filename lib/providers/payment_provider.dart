import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

// Provider para métodos de pago del usuario
class PaymentMethodsNotifier extends StateNotifier<AsyncValue<List<PaymentMethod>>> {
  PaymentMethodsNotifier() : super(const AsyncValue.loading());

  final PaymentService _paymentService = PaymentService();

  Future<void> loadPaymentMethods(String userId) async {
    state = const AsyncValue.loading();
    try {
      final methods = await _paymentService.getUserPaymentMethods(userId);
      state = AsyncValue.data(methods);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addPaymentMethod({
    required String userId,
    required String name,
    required PaymentType type,
    String? cardNumber,
    String? expiryDate,
    String? cardholderName,
    bool isDefault = false,
  }) async {
    try {
      await _paymentService.addPaymentMethod(
        userId: userId,
        name: name,
        type: type,
        cardNumber: cardNumber,
        expiryDate: expiryDate,
        cardholderName: cardholderName,
        isDefault: isDefault,
      );
      
      // Recargar métodos de pago
      await loadPaymentMethods(userId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> removePaymentMethod(String userId, String paymentMethodId) async {
    // Implementar eliminación de método de pago
    await loadPaymentMethods(userId);
  }
}

// Provider para transacciones de pago
class PaymentTransactionsNotifier extends StateNotifier<AsyncValue<List<PaymentTransaction>>> {
  PaymentTransactionsNotifier() : super(const AsyncValue.loading());

  final PaymentService _paymentService = PaymentService();

  Future<void> loadTransactionsByOrder(String orderId) async {
    state = const AsyncValue.loading();
    try {
      final transactions = await _paymentService.getTransactionsByOrder(orderId);
      state = AsyncValue.data(transactions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadTransactionsByStore(String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = const AsyncValue.loading();
    try {
      final transactions = await _paymentService.getTransactionsByStore(
        storeId,
        startDate: startDate,
        endDate: endDate,
      );
      state = AsyncValue.data(transactions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<PaymentTransaction> processPayment({
    required String orderId,
    required String customerId,
    required String storeId,
    required double amount,
    double taxAmount = 0.0,
    double tipAmount = 0.0,
    required PaymentMethod paymentMethod,
    Map<String, String>? cardData,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final transaction = await _paymentService.processPayment(
        orderId: orderId,
        customerId: customerId,
        storeId: storeId,
        amount: amount,
        taxAmount: taxAmount,
        tipAmount: tipAmount,
        paymentMethod: paymentMethod,
        cardData: cardData,
        metadata: metadata,
      );

      // Actualizar la lista de transacciones
      await loadTransactionsByOrder(orderId);
      
      return transaction;
    } catch (e) {
      rethrow;
    }
  }

  Future<PaymentTransaction> refundPayment(String transactionId, {
    double? refundAmount,
    String? reason,
  }) async {
    try {
      final transaction = await _paymentService.refundPayment(
        transactionId,
        refundAmount: refundAmount,
        reason: reason,
      );

      // Actualizar la lista de transacciones
      if (state.hasValue) {
        final currentTransactions = state.value!;
        final updatedTransactions = currentTransactions.map((t) {
          return t.id == transactionId ? transaction : t;
        }).toList();
        state = AsyncValue.data(updatedTransactions);
      }

      return transaction;
    } catch (e) {
      rethrow;
    }
  }
}

// Provider para el proceso de pago actual
class CurrentPaymentNotifier extends StateNotifier<PaymentState> {
  CurrentPaymentNotifier() : super(PaymentState.initial());

  final PaymentService _paymentService = PaymentService();

  void setOrderDetails({
    required String orderId,
    required String customerId,
    required String storeId,
    required double amount,
    double taxAmount = 0.0,
    double tipAmount = 0.0,
  }) {
    state = state.copyWith(
      orderId: orderId,
      customerId: customerId,
      storeId: storeId,
      amount: amount,
      taxAmount: taxAmount,
      tipAmount: tipAmount,
    );
  }

  void setPaymentMethod(PaymentMethod paymentMethod) {
    state = state.copyWith(selectedPaymentMethod: paymentMethod);
  }

  void setCardData(Map<String, String> cardData) {
    state = state.copyWith(cardData: cardData);
  }

  void setTipAmount(double tipAmount) {
    state = state.copyWith(tipAmount: tipAmount);
  }

  Map<String, String?> validateCardData() {
    if (state.cardData == null) {
      return {'general': 'Datos de tarjeta requeridos'};
    }
    return _paymentService.validateCardData(state.cardData!);
  }

  Future<PaymentTransaction> processPayment() async {
    if (state.selectedPaymentMethod == null) {
      throw Exception('Método de pago no seleccionado');
    }

    state = state.copyWith(isProcessing: true, error: null);

    try {
      final transaction = await _paymentService.processPayment(
        orderId: state.orderId!,
        customerId: state.customerId!,
        storeId: state.storeId!,
        amount: state.amount!,
        taxAmount: state.taxAmount,
        tipAmount: state.tipAmount,
        paymentMethod: state.selectedPaymentMethod!,
        cardData: state.cardData,
      );

      state = state.copyWith(
        isProcessing: false,
        transaction: transaction,
        isCompleted: transaction.isCompleted,
      );

      return transaction;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void reset() {
    state = PaymentState.initial();
  }
}

// Estado del pago actual
class PaymentState {
  final String? orderId;
  final String? customerId;
  final String? storeId;
  final double? amount;
  final double taxAmount;
  final double tipAmount;
  final PaymentMethod? selectedPaymentMethod;
  final Map<String, String>? cardData;
  final PaymentTransaction? transaction;
  final bool isProcessing;
  final bool isCompleted;
  final String? error;

  PaymentState({
    this.orderId,
    this.customerId,
    this.storeId,
    this.amount,
    this.taxAmount = 0.0,
    this.tipAmount = 0.0,
    this.selectedPaymentMethod,
    this.cardData,
    this.transaction,
    this.isProcessing = false,
    this.isCompleted = false,
    this.error,
  });

  PaymentState.initial()
      : orderId = null,
        customerId = null,
        storeId = null,
        amount = null,
        taxAmount = 0.0,
        tipAmount = 0.0,
        selectedPaymentMethod = null,
        cardData = null,
        transaction = null,
        isProcessing = false,
        isCompleted = false,
        error = null;

  PaymentState copyWith({
    String? orderId,
    String? customerId,
    String? storeId,
    double? amount,
    double? taxAmount,
    double? tipAmount,
    PaymentMethod? selectedPaymentMethod,
    Map<String, String>? cardData,
    PaymentTransaction? transaction,
    bool? isProcessing,
    bool? isCompleted,
    String? error,
  }) {
    return PaymentState(
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      storeId: storeId ?? this.storeId,
      amount: amount ?? this.amount,
      taxAmount: taxAmount ?? this.taxAmount,
      tipAmount: tipAmount ?? this.tipAmount,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      cardData: cardData ?? this.cardData,
      transaction: transaction ?? this.transaction,
      isProcessing: isProcessing ?? this.isProcessing,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error ?? this.error,
    );
  }

  double get totalAmount {
    return (amount ?? 0.0) + taxAmount + tipAmount;
  }

  bool get canProcessPayment {
    return orderId != null &&
           customerId != null &&
           storeId != null &&
           amount != null &&
           selectedPaymentMethod != null &&
           !isProcessing;
  }
}

// Providers
final paymentMethodsProvider = StateNotifierProvider<PaymentMethodsNotifier, AsyncValue<List<PaymentMethod>>>((ref) {
  return PaymentMethodsNotifier();
});

final paymentTransactionsProvider = StateNotifierProvider<PaymentTransactionsNotifier, AsyncValue<List<PaymentTransaction>>>((ref) {
  return PaymentTransactionsNotifier();
});

final currentPaymentProvider = StateNotifierProvider<CurrentPaymentNotifier, PaymentState>((ref) {
  return CurrentPaymentNotifier();
});

// Provider para métodos de pago por defecto
final defaultPaymentMethodProvider = Provider<PaymentMethod?>((ref) {
  final paymentMethods = ref.watch(paymentMethodsProvider);
  return paymentMethods.when(
    data: (methods) => methods.where((m) => m.isDefault).firstOrNull,
    loading: () => null,
    error: (_, __) => null,
  );
});

extension on Iterable<PaymentMethod> {
  PaymentMethod? get firstOrNull {
    return isEmpty ? null : first;
  }
}