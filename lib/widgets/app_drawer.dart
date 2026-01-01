// widgets/app_drawer.dart
import 'package:flutter/material.dart';
import '../screens/auth/home_screen.dart';
import '../screens/profile_screen.dart';

import '../screens/my_Trip/my_trip_screen.dart';
import '../screens/rewards_screen.dart';
import '../screens/about_screen.dart';
import '../screens/contact_screen.dart';
import '../screens/settings_screen.dart';
import '../profile_state.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  void _navigateToProfile(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
    setState(() {}); // Refresh drawer after returning from profile
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _performLogout(context); // Perform logout
              },
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) {
    // Here you would typically:
    // 1. Clear user session/tokens
    // 2. Clear any cached user data
    // 3. Navigate to login screen

    // Example logout logic:
    // authProvider.logout();

    // // Navigate to login screen and remove all previous routes
    // var pushAndRemoveUntil = Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(builder: (context) => const LoginScreen()),
    //   (Route<dynamic> route) => false, // Remove all previous routes
    // );

    // Show a logout confirmation message
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('You have been logged out')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              userProfile.name.isNotEmpty ? userProfile.name : 'User Name',
            ),
            accountEmail: Text(
              userProfile.email.isNotEmpty
                  ? userProfile.email
                  : 'user@example.com',
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40),
            ),
            decoration: const BoxDecoration(color: Colors.black38),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(Icons.home, color: colorScheme.onBackground),
                  title: Text(
                    'Home',
                    style: TextStyle(color: colorScheme.onBackground),
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person, color: colorScheme.onBackground),
                  title: Text(
                    'Profile',
                    style: TextStyle(color: colorScheme.onBackground),
                  ),
                  onTap: () => _navigateToProfile(context),
                ),

                ListTile(
                  leading: Icon(
                    Icons.directions_car,
                    color: colorScheme.onBackground,
                  ),
                  title: Text(
                    'My Trip',
                    style: TextStyle(color: colorScheme.onBackground),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyTripScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.star, color: colorScheme.onBackground),
                  title: Text(
                    'Rewards',
                    style: TextStyle(color: colorScheme.onBackground),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RewardsScreen(),
                      ),
                    );
                  },
                ),
                
                ListTile(
                  leading: Icon(Icons.phone, color: colorScheme.onBackground),
                  title: Text(
                    'Help & Support',
                    style: TextStyle(color: colorScheme.onBackground),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: colorScheme.onBackground,
                  ),
                  title: Text(
                    'Settings',
                    style: TextStyle(color: colorScheme.onBackground),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: colorScheme.onBackground),
            title: Text(
              'Log Out',
              style: TextStyle(color: colorScheme.onBackground),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              _showLogoutDialog(context); // Show logout confirmation
            },
          ),
        ],
      ),
    );
  }
}
