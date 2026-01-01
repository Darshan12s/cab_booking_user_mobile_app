// services/location_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Save user location to Supabase
  static Future<void> saveUserLocation({
    required String userId,
    required double latitude,
    required double longitude,
    required String address,
    String? locationType, // 'pickup', 'dropoff', 'saved'
  }) async {
    try {
      await _supabase.from('bookings').insert({
        'user_id': userId,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'location_type': locationType ?? 'saved',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to save location: $e');
    }
  }

  // Get user's saved locations
  static Future<List<Map<String, dynamic>>> getUserLocations(
    String userId,
  ) async {
    try {
      final bookings = await _supabase
          .from('bookings')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(bookings);
    } catch (e) {
      throw Exception('Failed to fetch locations: $e');
    }
  }

  // Update live location (for tracking)
  static Future<void> updateLiveLocation({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _supabase.from('bookings').upsert({
        'user_id': userId,
        'latitude': latitude,
        'longitude': longitude,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update live location: $e');
    }
  }

  // Get live location of a user
  static Future<Map<String, dynamic>?> getLiveLocation(String userId) async {
    try {
      final bookings = await _supabase
          .from('bookings')
          .select()
          .eq('user_id', userId)
          .single();

      return bookings;
    } catch (e) {
      return null;
    }
  }

  // Delete a saved location
  static Future<void> deleteLocation(int locationId) async {
    try {
      await _supabase.from('user_locations').delete().eq('id', locationId);
    } catch (e) {
      throw Exception('Failed to delete location: $e');
    }
  }

  // Search for places (you can integrate with Google Places API here)
  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    // This is a placeholder - you can integrate with Google Places API
    // or use Supabase's built-in search functionality
    try {
      final response = await _supabase
          .from('places')
          .select()
          .textSearch('address', query)
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Real-time location tracking subscription
  static Stream<List<Map<String, dynamic>>> trackUserLocation(String userId) {
    return _supabase
        .from('live_locations')
        .stream(primaryKey: ['user_id'])
        .eq('user_id', userId);
  }

  // Get coordinates from address (placeholder - integrate with Google Geocoding API)
  static Future<Map<String, double>?> getCoordinatesFromAddress(
    String address,
  ) async {
    // This is a placeholder implementation
    // In a real app, you would integrate with Google Geocoding API
    // For now, return null to indicate coordinates are not available
    return null;
  }

  // Save location with coordinates
  static Future<Map<String, double>?> saveLocationWithCoordinates({
    required String userId,
    required String address,
    String? locationType,
  }) async {
    try {
      // Get coordinates from address
      final coordinates = await getCoordinatesFromAddress(address);

      if (coordinates != null) {
        await saveUserLocation(
          userId: userId,
          latitude: coordinates['latitude']!,
          longitude: coordinates['longitude']!,
          address: address,
          locationType: locationType,
        );
      }

      return coordinates;
    } catch (e) {
      throw Exception('Failed to save location with coordinates: $e');
    }
  }
}

// SQL Schema for Supabase tables
/*

-- User locations table
CREATE TABLE user_locations (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  address TEXT NOT NULL,
  location_type VARCHAR(20) DEFAULT 'saved',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Live locations table for real-time tracking
CREATE TABLE live_locations (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id),
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Places table (optional - for cached place data)
CREATE TABLE places (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  place_type VARCHAR(50),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE user_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE live_locations ENABLE ROW LEVEL SECURITY;

-- Policies for user_locations
CREATE POLICY "Users can view own locations" ON user_locations
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own locations" ON user_locations
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own locations" ON user_locations
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own locations" ON user_locations
  FOR DELETE USING (auth.uid() = user_id);

-- Policies for live_locations
CREATE POLICY "Users can view own live location" ON live_locations
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can upsert own live location" ON live_locations
  FOR ALL USING (auth.uid() = user_id);

*/
