// screens/contact_screen.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _supabase.from('contact_messages').insert({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'message': _messageController.text.trim(),
      });

      if (mounted) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Message Sent"),
            content: const Text("Thank you! We will get back to you soon."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _firstNameController.clear();
                  _lastNameController.clear();
                  _emailController.clear();
                  _messageController.clear();
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _makePhoneCall() async {
    const phoneNumber = '+91 9900992290';
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      // Only check permissions on Android
      if (Theme.of(context).platform == TargetPlatform.android) {
        final status = await Permission.phone.status;

        if (status.isDenied) {
          final result = await Permission.phone.request();
          if (!result.isGranted) {
            await _showPermissionDialog(
              "Phone call permission is needed to make calls.",
              "Please grant the permission to continue.",
            );
            return;
          }
        }

        if (status.isPermanentlyDenied) {
          await _showPermissionDialog(
            "Phone call permission was permanently denied.",
            "Please enable it in app settings to make calls.",
          );
          return;
        }
      }

      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'Could not launch phone dialer. Please check if your device supports phone calls.';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () async => await openAppSettings(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _sendEmail() async {
    const email = 'info@sdmemobility.com';
    final Uri launchUri = Uri(scheme: 'mailto', path: email);

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        await _showEmailClientDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to launch email: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _showPermissionDialog(String title, String content) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text('$title\n\n$content'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEmailClientDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Client Not Found'),
        content: const Text(
          'No email client is installed on your device. '
          'Please install an email app to contact us.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final Uri playStoreUri = Uri(
                scheme: 'https',
                host: 'play.google.com',
                path: '/store/search',
                queryParameters: {'q': 'email client', 'c': 'apps'},
              );
              if (await canLaunchUrl(playStoreUri)) {
                await launchUrl(playStoreUri);
              }
            },
            child: const Text('Get Email App'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.onBackground,
        title: Text(
          'Contact Us',
          style: TextStyle(color: colorScheme.onBackground),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Get In Touch',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Have a question? Get in touch with us.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? colorScheme.onSurface
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      'First Name',
                      controller: _firstNameController,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'Last Name',
                      controller: _lastNameController,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'Email',
                      controller: _emailController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value!)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'Message',
                      controller: _messageController,
                      maxLines: 4,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Send Message',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ListTile(
                      leading: const Icon(
                        Icons.location_on,
                        color: Colors.green,
                      ),
                      title: Text(
                        'Location',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        'Bengaluru,Mysuru,karnataka,India',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black87,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.green),
                      title: Text(
                        'Phone Number',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        '+91 9900992290',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black87,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.phone_forwarded,
                          color: Colors.green,
                        ),
                        onPressed: _makePhoneCall,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.green),
                      title: Text(
                        'Email',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        'info@sdmemobility.com',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black87,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.email_outlined,
                          color: Colors.green,
                        ),
                        onPressed: _sendEmail,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String labelText, {
    int maxLines = 1,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: isDark ? Colors.white.withOpacity(0.6) : Colors.grey[600],
        ),
        filled: true,
        fillColor: isDark ? colorScheme.surface : Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
