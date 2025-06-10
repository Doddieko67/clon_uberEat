enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
}

class Payment {
  final String id;
  final String orderId;
  final String customerId;
  final double amount;
  final String paymentMethod;
  final String transactionId;
  final PaymentStatus status;
  final DateTime paymentDate;

  Payment({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.amount,
    required this.paymentMethod,
    required this.transactionId,
    required this.status,
    required this.paymentDate,
  });

  Payment copyWith({
    String? id,
    String? orderId,
    String? customerId,
    double? amount,
    String? paymentMethod,
    String? transactionId,
    PaymentStatus? status,
    DateTime? paymentDate,
  }) {
    return Payment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'customerId': customerId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'status': status.toString().split('.').last,
      'paymentDate': paymentDate.toIso8601String(),
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as String,
      orderId: map['orderId'] as String,
      customerId: map['customerId'] as String,
      amount: (map['amount'] as num).toDouble(),
      paymentMethod: map['paymentMethod'] as String,
      transactionId: map['transactionId'] as String,
      status: PaymentStatus.values.firstWhere(
          (e) => e.toString().split('.').last == map['status'] as String),
      paymentDate: DateTime.parse(map['paymentDate'] as String),
    );
  }
}
