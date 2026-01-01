import 'package:supabase_flutter/supabase_flutter.dart';

class RewardsRepository {
  final SupabaseClient _supabase;

  RewardsRepository(this._supabase);

  Future<Map<String, dynamic>> getUserRewardsData() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final response = await _supabase
        .rpc('get_user_rewards_data', params: {'user_id': userId})
        .single();

    return response;
  }

  Future<List<Map<String, dynamic>>> getAvailableRewards() async {
    final response = await _supabase
        .from('rewards')
        .select()
        .eq('is_active', true)
        .order('points_required');

    return response;
  }

  Future<List<Map<String, dynamic>>> getClaimedRewards() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final response = await _supabase
        .from('user_claimed_rewards')
        .select('''
          *, 
          rewards:reward_id(*)
        ''')
        .eq('user_id', userId)
        .order('claimed_at', ascending: false);

    return response;
  }

  Future<void> claimReward(String rewardId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await _supabase.from('user_claimed_rewards').insert({
      'user_id': userId,
      'reward_id': rewardId,
    });
  }

  Future<void> updateTripStats({
    required double co2Reduced,
    required double fuelSaved,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await _supabase.rpc(
      'update_trip_stats',
      params: {
        'user_id': userId,
        'co2_reduced': co2Reduced,
        'fuel_saved': fuelSaved,
      },
    );
  }
}
