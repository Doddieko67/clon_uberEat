import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Configuración de la pasarela de pago (ejemplo con Stripe/Conekta)
  late PaymentGatewayConfig _config;
  
  void initialize(PaymentGatewayConfig config) {
    _config = config;
  }

  // Procesar pago con tarjeta
  Future<PaymentGatewayResponse> processCardPayment({
    required String orderId,
    required double amount,
    required String currency,
    required Map<String, String> cardData,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Simular procesamiento de pago (en producción usar API real)
      await Future.delayed(const Duration(seconds: 2));
      
      // Generar respuesta simulada
      final random = Random();
      final isSuccess = random.nextDouble() > 0.1; // 90% de éxito
      
      if (isSuccess) {
        final transactionId = _generateTransactionId();
        final authCode = _generateAuthCode();
        
        return PaymentGatewayResponse.success(
          transactionId: transactionId,
          authorizationCode: authCode,
          message: 'Pago procesado exitosamente',
          rawResponse: {
            'transaction_id': transactionId,
            'auth_code': authCode,
            'amount': amount,
            'currency': currency,
            'status': 'approved',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      } else {
        final errorMessages = [
          'Tarjeta declinada',
          'Fondos insuficientes',
          'Tarjeta expirada',
          'Error de validación',
        ];
        
        return PaymentGatewayResponse.failure(
          message: errorMessages[random.nextInt(errorMessages.length)],
          errorCode: 'CARD_DECLINED',
        );
      }
    } catch (e) {
      return PaymentGatewayResponse.failure(
        message: 'Error interno del sistema de pagos',
        errorCode: 'INTERNAL_ERROR',
      );
    }
  }

  // Crear transacción de pago
  Future<PaymentTransaction> createPaymentTransaction({
    required String orderId,
    required String customerId,
    required String storeId,
    required double amount,
    double taxAmount = 0.0,
    double tipAmount = 0.0,
    required PaymentMethod paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    final transaction = PaymentTransaction(
      id: _generateTransactionId(),
      orderId: orderId,
      customerId: customerId,
      storeId: storeId,
      amount: amount,
      taxAmount: taxAmount,
      tipAmount: tipAmount,
      totalAmount: amount + taxAmount + tipAmount,
      paymentMethod: paymentMethod,
      status: PaymentStatus.pending,
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    // Guardar en Firestore
    await _firestore
        .collection('payment_transactions')
        .doc(transaction.id)
        .set(transaction.toMap());

    return transaction;
  }

  // Procesar pago completo
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
    // Crear transacción
    var transaction = await createPaymentTransaction(
      orderId: orderId,
      customerId: customerId,
      storeId: storeId,
      amount: amount,
      taxAmount: taxAmount,
      tipAmount: tipAmount,
      paymentMethod: paymentMethod,
      metadata: metadata,
    );

    try {
      // Actualizar estado a procesando
      transaction = transaction.copyWith(
        status: PaymentStatus.processing,
        processedAt: DateTime.now(),
      );
      await _updateTransaction(transaction);

      PaymentGatewayResponse response;

      // Procesar según el tipo de pago
      switch (paymentMethod.type) {
        case PaymentType.creditCard:
        case PaymentType.debitCard:
          if (cardData == null) {
            throw Exception('Datos de tarjeta requeridos');
          }
          response = await processCardPayment(
            orderId: orderId,
            amount: transaction.totalAmount,
            currency: transaction.currency,
            cardData: cardData,
            metadata: metadata,
          );
          break;
        case PaymentType.cash:
          response = await _processCashPayment(transaction);
          break;
        case PaymentType.digitalWallet:
          response = await _processDigitalWalletPayment(transaction);
          break;
        case PaymentType.bankTransfer:
          response = await _processBankTransferPayment(transaction);
          break;
      }

      // Actualizar transacción con resultado
      if (response.success) {
        transaction = transaction.copyWith(
          status: PaymentStatus.completed,
          transactionReference: response.transactionId,
          gatewayResponse: jsonEncode(response.rawResponse),
          completedAt: DateTime.now(),
        );
      } else {
        transaction = transaction.copyWith(
          status: PaymentStatus.failed,
          failureReason: response.message,
          gatewayResponse: response.errorCode,
        );
      }

      await _updateTransaction(transaction);
      return transaction;

    } catch (e) {
      // En caso de error, marcar como fallido
      transaction = transaction.copyWith(
        status: PaymentStatus.failed,
        failureReason: e.toString(),
      );
      await _updateTransaction(transaction);
      throw e;
    }
  }

  // Procesar pago en efectivo
  Future<PaymentGatewayResponse> _processCashPayment(PaymentTransaction transaction) async {
    // El pago en efectivo se marca como pendiente hasta la entrega
    return PaymentGatewayResponse.success(
      transactionId: transaction.id,
      message: 'Pago en efectivo programado para la entrega',
    );
  }

  // Procesar pago con billetera digital
  Future<PaymentGatewayResponse> _processDigitalWalletPayment(PaymentTransaction transaction) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Simular éxito 95%
    if (Random().nextDouble() > 0.05) {
      return PaymentGatewayResponse.success(
        transactionId: _generateTransactionId(),
        message: 'Pago procesado con billetera digital',
      );
    } else {
      return PaymentGatewayResponse.failure(
        message: 'Error de conexión con billetera digital',
        errorCode: 'WALLET_ERROR',
      );
    }
  }

  // Procesar transferencia bancaria
  Future<PaymentGatewayResponse> _processBankTransferPayment(PaymentTransaction transaction) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return PaymentGatewayResponse.success(
      transactionId: _generateTransactionId(),
      message: 'Transferencia bancaria iniciada',
    );
  }

  // Reembolsar pago
  Future<PaymentTransaction> refundPayment(String transactionId, {
    double? refundAmount,
    String? reason,
  }) async {
    final doc = await _firestore
        .collection('payment_transactions')
        .doc(transactionId)
        .get();
    
    if (!doc.exists) {
      throw Exception('Transacción no encontrada');
    }

    var transaction = PaymentTransaction.fromMap(doc.data()!);
    
    if (!transaction.isCompleted) {
      throw Exception('Solo se pueden reembolsar pagos completados');
    }

    final finalRefundAmount = refundAmount ?? transaction.totalAmount;
    
    // Simular procesamiento de reembolso
    await Future.delayed(const Duration(seconds: 1));
    
    transaction = transaction.copyWith(
      status: PaymentStatus.refunded,
      metadata: {
        ...?transaction.metadata,
        'refund_amount': finalRefundAmount,
        'refund_reason': reason,
        'refunded_at': DateTime.now().toIso8601String(),
      },
    );

    await _updateTransaction(transaction);
    return transaction;
  }

  // Obtener transacciones por orden
  Future<List<PaymentTransaction>> getTransactionsByOrder(String orderId) async {
    final querySnapshot = await _firestore
        .collection('payment_transactions')
        .where('orderId', isEqualTo: orderId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => PaymentTransaction.fromMap(doc.data()))
        .toList();
  }

  // Obtener transacciones por tienda
  Future<List<PaymentTransaction>> getTransactionsByStore(String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _firestore
        .collection('payment_transactions')
        .where('storeId', isEqualTo: storeId);

    if (startDate != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: endDate.toIso8601String());
    }

    final querySnapshot = await query
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => PaymentTransaction.fromMap(doc.data()))
        .toList();
  }

  // Obtener métodos de pago de un usuario
  Future<List<PaymentMethod>> getUserPaymentMethods(String userId) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('payment_methods')
        .where('isActive', isEqualTo: true)
        .orderBy('isDefault', descending: true)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => PaymentMethod.fromMap(doc.data()))
        .toList();
  }

  // Agregar método de pago
  Future<PaymentMethod> addPaymentMethod({
    required String userId,
    required String name,
    required PaymentType type,
    String? cardNumber,
    String? expiryDate,
    String? cardholderName,
    bool isDefault = false,
  }) async {
    final paymentMethod = PaymentMethod(
      id: _generatePaymentMethodId(),
      name: name,
      type: type,
      cardNumber: cardNumber,
      expiryDate: expiryDate,
      cardholderName: cardholderName,
      isDefault: isDefault,
      createdAt: DateTime.now(),
    );

    // Si es el método por defecto, quitar el flag de otros métodos
    if (isDefault) {
      final batch = _firestore.batch();
      final existingMethods = await getUserPaymentMethods(userId);
      
      for (final method in existingMethods.where((m) => m.isDefault)) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('payment_methods')
            .doc(method.id);
        batch.update(docRef, {'isDefault': false});
      }
      
      await batch.commit();
    }

    // Guardar nuevo método
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('payment_methods')
        .doc(paymentMethod.id)
        .set(paymentMethod.toMap());

    return paymentMethod;
  }

  // Actualizar transacción
  Future<void> _updateTransaction(PaymentTransaction transaction) async {
    await _firestore
        .collection('payment_transactions')
        .doc(transaction.id)
        .update(transaction.toMap());
  }

  // Generar ID de transacción
  String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999).toString().padLeft(6, '0');
    return 'txn_${timestamp}_$random';
  }

  // Generar código de autorización
  String _generateAuthCode() {
    final random = Random();
    return List.generate(6, (index) => random.nextInt(10)).join();
  }

  // Generar ID de método de pago
  String _generatePaymentMethodId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999).toString().padLeft(3, '0');
    return 'pm_${timestamp}_$random';
  }

  // Validar datos de tarjeta (básico)
  Map<String, String?> validateCardData(Map<String, String> cardData) {
    final errors = <String, String?>{};

    final cardNumber = cardData['number']?.replaceAll(' ', '') ?? '';
    final expiryDate = cardData['expiry'] ?? '';
    final cvv = cardData['cvv'] ?? '';
    final holderName = cardData['holder_name'] ?? '';

    // Validar número de tarjeta (Luhn algorithm básico)
    if (cardNumber.isEmpty || cardNumber.length < 13 || cardNumber.length > 19) {
      errors['number'] = 'Número de tarjeta inválido';
    }

    // Validar fecha de expiración (MM/YY)
    if (expiryDate.isEmpty || !RegExp(r'^\d{2}/\d{2}$').hasMatch(expiryDate)) {
      errors['expiry'] = 'Fecha de expiración inválida (MM/YY)';
    } else {
      final parts = expiryDate.split('/');
      final month = int.tryParse(parts[0]) ?? 0;
      final year = int.tryParse('20${parts[1]}') ?? 0;
      final now = DateTime.now();
      
      if (month < 1 || month > 12) {
        errors['expiry'] = 'Mes inválido';
      } else if (year < now.year || (year == now.year && month < now.month)) {
        errors['expiry'] = 'Tarjeta expirada';
      }
    }

    // Validar CVV
    if (cvv.isEmpty || cvv.length < 3 || cvv.length > 4) {
      errors['cvv'] = 'CVV inválido';
    }

    // Validar nombre del titular
    if (holderName.isEmpty || holderName.length < 2) {
      errors['holder_name'] = 'Nombre del titular requerido';
    }

    return errors;
  }
}