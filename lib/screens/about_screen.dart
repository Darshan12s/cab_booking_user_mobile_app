// screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_drawer.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  Map<String, dynamic>? aboutData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAboutData();
  }

  Future<void> _fetchAboutData() async {
    try {
      final response = await supabase
          .from('about_page')
          .select()
          .limit(1)
          .single();

      if (mounted) {
        setState(() {
          aboutData = response;
          isLoading = false;
        });
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Database error: ${e.message}';
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load information. Please try again.';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    await _fetchAboutData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _refreshData, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            aboutData?['title'] ?? 'About Our App',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            aboutData?['version'] ?? 'Version 1.0.0',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Text(
            aboutData?['description'] ?? 'Default description text',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
          Text(
            aboutData?['copyright'] ?? 'Default copyright text',
            style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 40),
          if (supabase.auth.currentUser?.role == 'supabase_admin')
            ElevatedButton(
              onPressed: _navigateToEditScreen,
              child: const Text('Edit Content'),
            ),
        ],
      ),
    );
  }

  void _navigateToEditScreen() {
    // Implement navigation to edit screen for admin users
    // Navigator.push(context, MaterialPageRoute(builder: (_) => EditAboutScreen()));
  }
}
