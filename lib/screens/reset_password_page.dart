// screens/reset_password_page.dart
import 'package:flutter/material.dart';
import 'package:cab_booking_user_mobile_app/services/supabase_service.dart';
import 'package:cab_booking_user_mobile_app/widgets/auth/auth_text_field.dart';
import 'package:cab_booking_user_mobile_app/screens/auth/auth_page_template.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await SupabaseService.client.auth.resetPasswordForEmail(
        _emailController.text,
        redirectTo: 'yourapp://reset-password',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent to your email'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to send reset link. Please check your email.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    // Standard email format check
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    // Only allow Gmail addresses
    if (!value.toLowerCase().endsWith('@gmail.com')) {
      return 'Only Gmail addresses are allowed for password reset';
    }
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageTemplate(
      title: 'Reset Password',
      formFields: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              AuthTextField(
                controller: _emailController,
                hintText: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                inputFormatters: [],
                contentPadding: const EdgeInsets.all(16),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
      ],
      actionButtonText: 'Reset Password',
      onActionPressed: _isLoading ? null : _resetPassword,
      bottomText: 'Back to',
      bottomActionText: 'Login',
      navigateRoute: '/login',
      backgroundImage: 'https://wallpapercave.com/wp/wp5201676.jpg',
      actionButtonStyle: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      actionButtonPadding: const EdgeInsets.symmetric(horizontal: 24),
      titleStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      bottomTextStyle: const TextStyle(fontSize: 16),
      bottomActionTextStyle: const TextStyle(fontSize: 16, color: Colors.blue),
    );
  }
}
