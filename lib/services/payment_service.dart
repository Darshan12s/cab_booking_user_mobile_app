// services/payment_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_model.dart';

class PaymentService {
  final SupabaseClient _supabase;

  PaymentService(this._supabase);

  Future<Payment?> createPayment(Payment payment) async {
    try {
      final response = await _supabase
          .from('payments')
          .insert(payment.toMap())
          .select()
          .single();
      return Payment.fromMap(response);
    } catch (e) {
      print('Error creating payment: $e');
      return null;
    }
  }

  Future<List<Payment>> getPaymentsForBooking(String bookingId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select()
          .eq('booking_id', bookingId)
          .order('created_at', ascending: false);
      return (response as List).map((item) => Payment.fromMap(item)).toList();
    } catch (e) {
      print('Error fetching payments: $e');
      return [];
    }
  }
}
