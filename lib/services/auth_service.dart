// services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: unused_import
import 'package:cab_booking_user_mobile_app/services/supabase_service.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Email + Password Sign Up
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          if (name != null)
            'full_name': name, // Use 'full_name' to match trigger
          if (phone != null) 'phone': phone,
        },
      );

      return response;
    } catch (e) {
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  /// Email + Password Login
  Future<AuthResponse> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Phone OTP Login - Send OTP
  Future<void> sendOtpToPhone(String phoneNumber) async {
    try {
      await _supabase.auth.signInWithOtp(phone: phoneNumber);
    } catch (e) {
      throw Exception('Failed to send OTP: ${e.toString()}');
    }
  }

  /// Phone OTP Login - Verify OTP
  Future<AuthResponse> verifyPhoneOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      return await _supabase.auth.verifyOTP(
        phone: phoneNumber,
        token: otp,
        type: OtpType.sms,
      );
    } catch (e) {
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

  /// Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'yourapp://reset-password', // Your app's URL scheme
      );
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  /// Update Password (after reset)
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw Exception('Password update failed: ${e.toString()}');
    }
  }

  /// Google Sign-In
  Future<bool> signInWithGoogle() async {
    try {
      print('AuthService: Starting Google OAuth...');
      final result = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'yourapp://login-callback', // Your app's URL scheme
      );
      print('AuthService: OAuth result: $result');
      return result;
    } catch (e) {
      print('AuthService: Google sign-in error: $e');
      rethrow; // Re-throw to let the UI handle it
    }
  }

  /// Apple Sign-In
 

  /// Sign Out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }
}
