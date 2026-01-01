import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRepository {
  final SupabaseClient _supabase;

  SupabaseRepository(this._supabase);

  // Get user preferences
  Future<Map<String, dynamic>> getUserPreferences() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');
    
    final response = await _supabase
        .from('user_preferences')
        .select()
        .eq('user_id', userId)
        .single();
    
    return response;
  }

  // Update dark mode preference
  Future<void> updateDarkModePreference(bool darkMode) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');
    
    await _supabase
        .from('user_preferences')
        .upsert({
          'user_id': userId,
          'dark_mode': darkMode,
          'updated_at': DateTime.now().toIso8601String(),
        });
  }

  // Update notification preferences
  Future<void> updateNotificationPreferences({
    required bool notificationsEnabled,
    required bool emailNotifications,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');
    
    await _supabase
        .from('user_preferences')
        .upsert({
          'user_id': userId,
          'notification_enabled': notificationsEnabled,
          'email_notifications': emailNotifications,
          'updated_at': DateTime.now().toIso8601String(),
        });
  }
}