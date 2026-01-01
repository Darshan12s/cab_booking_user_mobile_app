// services/booking_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

class BookingService {
  final SupabaseClient _supabase;

  BookingService(this._supabase);

  Future<Booking?> createBooking(Booking booking) async {
    try {
      final bookings = await _supabase
          .from('bookings')
          .insert(booking.toMap())
          .select()
          .single();
      return Booking.fromMap(bookings);
    } catch (e) {
      print('Error creating booking: $e');
      return null;
    }
  }

  Future<List<Booking>> getUserBookings({required String userId}) async {
    try {
      final bookings = await _supabase
          .from('bookings')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return (bookings as List).map((item) => Booking.fromMap(item)).toList();
    } catch (e) {
      print('Error fetching user bookings: $e');
      return [];
    }
  }

  Future<Booking?> updateBookingStatus(String bookingId, String status) async {
    try {
      final bookings = await _supabase
          .from('bookings')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId)
          .select()
          .single();
      return Booking.fromMap(bookings);
    } catch (e) {
      print('Error updating booking status: $e');
      return null;
    }
  }

  Future<Booking?> cancelBooking(String bookingId, String reason) async {
    try {
      final bookings = await _supabase
          .from('bookings')
          .update({
            'status': 'cancelled',
            'cancellation_reason': reason,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId)
          .select()
          .single();
      return Booking.fromMap(bookings);
    } catch (e) {
      print('Error cancelling booking: $e');
      return null;
    }
  }

  Future<Booking?> updateBookingDetails(
    String bookingId,
    Map<String, dynamic> details,
  ) async {
    try {
      final bookings = await _supabase
          .from('bookings')
          .update(details)
          .eq('id', bookingId)
          .select()
          .single();
      return Booking.fromMap(bookings);
    } catch (e) {
      print('Error updating booking details: $e');
      return null;
    }
  }
}
