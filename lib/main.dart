// main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/app_theme.dart';

// Global theme notifier
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.system,
);

Future<void> saveThemeMode(ThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('theme_mode', mode.toString());
}

Future<ThemeMode> loadThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final mode = prefs.getString('theme_mode');
  switch (mode) {
    case 'ThemeMode.dark':
      return ThemeMode.dark;
    case 'ThemeMode.light':
      return ThemeMode.light;
    default:
      return ThemeMode.system;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://gmualcoqyztvtsqhjlzb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdtdWFsY29xeXp0dnRzcWhqbHpiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4NDg4NjIsImV4cCI6MjA2NjQyNDg2Mn0.qQxh6IPHrvDQ5Jsma42eHpRTjeG9vpa0rIkErPeCJe0',
  );

  themeModeNotifier.value = await loadThemeMode();

  runApp(const GreenMobilityApp());
}

class GreenMobilityApp extends StatelessWidget {
  const GreenMobilityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Green Mobility',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          initialRoute: AppRoutes.otpLogin,
          onGenerateRoute: RouteGenerator.generateRoute,
        );
      },
    );
  }
}
