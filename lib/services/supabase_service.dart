// services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> sendOtp(String phoneNumber) async {
    await client.auth.signInWithOtp(phone: '+91$phoneNumber');
  }

  static Future<AuthResponse> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    return await client.auth.verifyOTP(
      phone: '+91$phoneNumber',
      token: otp,
      type: OtpType.sms,
    );
  }
}
