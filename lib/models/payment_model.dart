// models/payment_model.dart
class Payment {
  final String? id;
  final String bookingId;
  final String userId;
  final double amount;
  final String currency;
  final String? transactionId;
  final String? gatewayResponse;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? razorpayPaymentId;

  Payment({
    this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.currency,
    this.transactionId,
    this.gatewayResponse,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.razorpayPaymentId,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      bookingId: map['booking_id'],
      userId: map['user_id'],
      amount: map['amount']?.toDouble() ?? 0.0,
      currency: map['currency'] ?? 'INR',
      transactionId: map['transaction_id'],
      gatewayResponse: map['gateway_response'],
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      razorpayPaymentId: map['razorpay_payment_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'booking_id': bookingId,
      'user_id': userId,
      'amount': amount,
      'currency': currency,
      'transaction_id': transactionId,
      'gateway_response': gatewayResponse,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'razorpay_payment_id': razorpayPaymentId,
    };
  }
}
