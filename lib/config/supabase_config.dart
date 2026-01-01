import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Replace these with your actual Supabase project credentials
  // Get these from: https://supabase.com → Your Project → Settings → API
  static const String supabaseUrl =
      'https://hwdenesztocexhnzktnc.supabase.co'; // Replace with your URL
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh3ZGVuZXN6dG9jZXhobnprdG5jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIxMzQyMDIsImV4cCI6MjA2NzcxMDIwMn0.BSwDiNPoApZ3juKuvtvzn-OsP3KJOWyrE9tm-Tg7xVo'; // Replace with your anon key

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}

// Instructions to set up Supabase:
/*
1. Go to https://supabase.com and create a new project
2. Get your project URL and anon key from Settings > API
3. Replace the constants above with your actual values
4. Run the SQL schema from location_service.dart in your Supabase SQL editor
5. Enable Row Level Security and apply the policies from location_service.dart
*/
