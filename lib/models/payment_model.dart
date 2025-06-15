import 'package:flutter/material.dart';

class PaymentMethod {
  final String id;
  final String name;
  final PaymentType type;
  final String? cardNumber; // Últimos 4 dígitos
  final String? expiryDate;
  final String? cardholderName;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    this.cardNumber,
    this.expiryDate,
    this.cardholderName,
    this.isDefault = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  PaymentMethod copyWith({
    String? id,
    String? name,
    PaymentType? type,
    String? cardNumber,
    String? expiryDate,
    String? cardholderName,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cardholderName: cardholderName ?? this.cardholderName,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'cardholderName': cardholderName,
      'isDefault': isDefault,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'] as String,
      name: map['name'] as String,
      type: PaymentType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      cardNumber: map['cardNumber'] as String?,
      expiryDate: map['expiryDate'] as String?,
      cardholderName: map['cardholderName'] as String?,
      isDefault: map['isDefault'] as bool? ?? false,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }
}

enum PaymentType {
  creditCard,
  debitCard,
  cash,
  digitalWallet,
  bankTransfer,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
}

class PaymentTransaction {
  final String id;
  final String orderId;
  final String customerId;
  final String storeId;
  final double amount;
  final double taxAmount;
  final double tipAmount;
  final double totalAmount;
  final String currency;
  final PaymentMethod paymentMethod;
  final PaymentStatus status;
  final String? transactionReference;
  final String? gatewayResponse;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime? processedAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? metadata;

  PaymentTransaction({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.storeId,
    required this.amount,
    this.taxAmount = 0.0,
    this.tipAmount = 0.0,
    required this.totalAmount,
    this.currency = 'MXN',
    required this.paymentMethod,
    this.status = PaymentStatus.pending,
    this.transactionReference,
    this.gatewayResponse,
    this.failureReason,
    required this.createdAt,
    this.processedAt,
    this.completedAt,
    this.metadata,
  });

  PaymentTransaction copyWith({
    String? id,
    String? orderId,
    String? customerId,
    String? storeId,
    double? amount,
    double? taxAmount,
    double? tipAmount,
    double? totalAmount,
    String? currency,
    PaymentMethod? paymentMethod,
    PaymentStatus? status,
    String? transactionReference,
    String? gatewayResponse,
    String? failureReason,
    DateTime? createdAt,
    DateTime? processedAt,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentTransaction(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      storeId: storeId ?? this.storeId,
      amount: amount ?? this.amount,
      taxAmount: taxAmount ?? this.taxAmount,
      tipAmount: tipAmount ?? this.tipAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      transactionReference: transactionReference ?? this.transactionReference,
      gatewayResponse: gatewayResponse ?? this.gatewayResponse,
      failureReason: failureReason ?? this.failureReason,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'customerId': customerId,
      'storeId': storeId,
      'amount': amount,
      'taxAmount': taxAmount,
      'tipAmount': tipAmount,
      'totalAmount': totalAmount,
      'currency': currency,
      'paymentMethod': paymentMethod.toMap(),
      'status': status.toString().split('.').last,
      'transactionReference': transactionReference,
      'gatewayResponse': gatewayResponse,
      'failureReason': failureReason,
      'createdAt': createdAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory PaymentTransaction.fromMap(Map<String, dynamic> map) {
    return PaymentTransaction(
      id: map['id'] as String,
      orderId: map['orderId'] as String,
      customerId: map['customerId'] as String,
      storeId: map['storeId'] as String,
      amount: (map['amount'] as num).toDouble(),
      taxAmount: (map['taxAmount'] as num?)?.toDouble() ?? 0.0,
      tipAmount: (map['tipAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'MXN',
      paymentMethod: PaymentMethod.fromMap(map['paymentMethod'] as Map<String, dynamic>),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
      ),
      transactionReference: map['transactionReference'] as String?,
      gatewayResponse: map['gatewayResponse'] as String?,
      failureReason: map['failureReason'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      processedAt: map['processedAt'] != null 
          ? DateTime.parse(map['processedAt'] as String)
          : null,
      completedAt: map['completedAt'] != null 
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  bool get isCompleted => status == PaymentStatus.completed;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isPending => status == PaymentStatus.pending;
  bool get isProcessing => status == PaymentStatus.processing;
}

extension PaymentTypeExtension on PaymentType {
  String get displayName {
    switch (this) {
      case PaymentType.creditCard:
        return 'Tarjeta de Crédito';
      case PaymentType.debitCard:
        return 'Tarjeta de Débito';
      case PaymentType.cash:
        return 'Efectivo';
      case PaymentType.digitalWallet:
        return 'Billetera Digital';
      case PaymentType.bankTransfer:
        return 'Transferencia Bancaria';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentType.creditCard:
        return Icons.credit_card;
      case PaymentType.debitCard:
        return Icons.credit_card;
      case PaymentType.cash:
        return Icons.attach_money;
      case PaymentType.digitalWallet:
        return Icons.account_balance_wallet;
      case PaymentType.bankTransfer:
        return Icons.account_balance;
    }
  }

  Color get color {
    switch (this) {
      case PaymentType.creditCard:
        return Colors.blue;
      case PaymentType.debitCard:
        return Colors.green;
      case PaymentType.cash:
        return Colors.orange;
      case PaymentType.digitalWallet:
        return Colors.purple;
      case PaymentType.bankTransfer:
        return Colors.teal;
    }
  }
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pendiente';
      case PaymentStatus.processing:
        return 'Procesando';
      case PaymentStatus.completed:
        return 'Completado';
      case PaymentStatus.failed:
        return 'Fallido';
      case PaymentStatus.cancelled:
        return 'Cancelado';
      case PaymentStatus.refunded:
        return 'Reembolsado';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.processing:
        return Colors.blue;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.cancelled:
        return Colors.grey;
      case PaymentStatus.refunded:
        return Colors.purple;
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentStatus.pending:
        return Icons.schedule;
      case PaymentStatus.processing:
        return Icons.sync;
      case PaymentStatus.completed:
        return Icons.check_circle;
      case PaymentStatus.failed:
        return Icons.error;
      case PaymentStatus.cancelled:
        return Icons.cancel;
      case PaymentStatus.refunded:
        return Icons.undo;
    }
  }
}

// Configuración de pasarela de pago
class PaymentGatewayConfig {
  final String gatewayName;
  final String publicKey;
  final String secretKey;
  final bool isTestMode;
  final String baseUrl;
  final Map<String, String> headers;
  final List<PaymentType> supportedMethods;

  PaymentGatewayConfig({
    required this.gatewayName,
    required this.publicKey,
    required this.secretKey,
    this.isTestMode = true,
    required this.baseUrl,
    this.headers = const {},
    this.supportedMethods = const [
      PaymentType.creditCard,
      PaymentType.debitCard,
    ],
  });
}

// Respuesta de pasarela de pago
class PaymentGatewayResponse {
  final bool success;
  final String? transactionId;
  final String? authorizationCode;
  final String? message;
  final String? errorCode;
  final Map<String, dynamic>? rawResponse;

  PaymentGatewayResponse({
    required this.success,
    this.transactionId,
    this.authorizationCode,
    this.message,
    this.errorCode,
    this.rawResponse,
  });

  factory PaymentGatewayResponse.success({
    required String transactionId,
    String? authorizationCode,
    String? message,
    Map<String, dynamic>? rawResponse,
  }) {
    return PaymentGatewayResponse(
      success: true,
      transactionId: transactionId,
      authorizationCode: authorizationCode,
      message: message ?? 'Pago procesado exitosamente',
      rawResponse: rawResponse,
    );
  }

  factory PaymentGatewayResponse.failure({
    required String message,
    String? errorCode,
    Map<String, dynamic>? rawResponse,
  }) {
    return PaymentGatewayResponse(
      success: false,
      message: message,
      errorCode: errorCode,
      rawResponse: rawResponse,
    );
  }
}