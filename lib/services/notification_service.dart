import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> sendNotification({
    required String userId,
    required String heading,
    required String content,
    required String icon,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'heading': heading,
        'content': content,
        'icon': icon,
        'metadata': metadata,
      });
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false)
          .count(CountOption.exact)
          .execute();

      return response.count;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }
}

extension
    on
        ResponsePostgrestBuilder<
          PostgrestResponse<PostgrestList>,
          PostgrestList,
          PostgrestList
        > {
  Future<PostgrestResponse<PostgrestList>> execute() async {
    final response = await this;
    if (response.error != null) {
      throw Exception('Failed to execute query: ${response.error!.message}');
    }
    return response;
  }
}

extension on PostgrestResponse<PostgrestList> {
  get error => null;
}
