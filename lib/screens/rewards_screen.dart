// screens/rewards_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/app_drawer.dart';
import 'app_theme.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic> _stats = {
    'co2_reduced': 0.0,
    'fuel_saved': 0.0,
    'trees_saved': 0.0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRewardsData();
  }

  Future<void> _loadRewardsData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final response = await _supabase
          .from('user_rewards')
          .select('co2_reduced, fuel_saved, trees_saved')
          .eq('id', userId)
          .single();

      setState(() {
        _stats = {
          'co2_reduced': (response['co2_reduced'] as num?)?.toDouble() ?? 0.0,
          'fuel_saved': (response['fuel_saved'] as num?)?.toDouble() ?? 0.0,
          'trees_saved': (response['trees_saved'] as num?)?.toDouble() ?? 0.0,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load rewards: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Rewards',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          centerTitle: true,
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Circular progress indicator
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: (_stats['co2_reduced']! / 200).clamp(
                                0.0,
                                1.0,
                              ),
                              strokeWidth: 10,
                              backgroundColor: AppTheme.isDarkMode(context)
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.orange,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${((_stats['co2_reduced']! / 200) * 100).toStringAsFixed(0)}%",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.getTextColor(context),
                                ),
                              ),
                              Text(
                                "Completed",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.getTextColor(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info message
                    Text(
                      "Start saving CO₂ from today to earn\nexciting rewards.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats Cards
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.cloud_outlined,
                            value:
                                "${_stats['co2_reduced']?.toStringAsFixed(2) ?? '0.00'}kg",
                            label: "CO₂ reduced\nfrom your trips",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.local_gas_station_outlined,
                            value:
                                "${_stats['fuel_saved']?.toStringAsFixed(2) ?? '0.00'}L",
                            label: "Fuel reduced\nfrom your trips",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.forest_outlined,
                            value:
                                "${_stats['trees_saved']?.toStringAsFixed(2) ?? '0.00'}",
                            label: "Trees saved\nfrom your trips",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Reward Goals
                    _RewardRow(
                      icon: Icons.cloud_outlined,
                      text:
                          "Save 200kg of Carbon Emission or more to earn exciting rewards",
                    ),
                    const SizedBox(height: 8),
                    const _PlusSeparator(),
                    const SizedBox(height: 8),
                    _RewardRow(
                      icon: Icons.local_gas_station_outlined,
                      text: "Save 50L Fuel or more to earn exciting rewards",
                    ),
                    const SizedBox(height: 8),
                    const _PlusSeparator(),
                    const SizedBox(height: 8),
                    _RewardRow(
                      icon: Icons.forest_outlined,
                      text: "Save 100 Trees or more to earn exciting rewards",
                    ),
                  ],
                ),
              ),
      ), // End of Scaffold
    ); // End of AnnotatedRegion
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.green),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: AppTheme.getTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _RewardRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.green, size: 26),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.5,
              color: AppTheme.getTextColor(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlusSeparator extends StatelessWidget {
  const _PlusSeparator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "+",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppTheme.getTextColor(context),
        ),
      ),
    );
  }
}
