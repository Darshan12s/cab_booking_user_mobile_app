// screens/auth/signup_page.dart
import 'package:flutter/material.dart';
import 'package:cab_booking_user_mobile_app/services/auth_service.dart';
import 'package:cab_booking_user_mobile_app/widgets/auth/auth_text_field.dart';
import 'auth_page_template.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorMessage('Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup successful! Welcome!')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorMessage('Signup failed. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorMessage(String message) {
    setState(() => _errorMessage = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageTemplate(
      title: 'Sign Up',
      formFields: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              AuthTextField(
                controller: _nameController,
                hintText: 'Enter your full name',
                prefixIcon: Icons.person_outline,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter your name' : null,
                inputFormatters: const [],
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),
              AuthTextField(
                controller: _emailController,
                hintText: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                inputFormatters: const [],
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),
              AuthTextField(
                controller: _phoneController,
                hintText: 'Enter your phone number',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
                inputFormatters: const [],
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),
              AuthTextField(
                controller: _passwordController,
                hintText: 'Enter your password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: _buildVisibilityIcon(_obscurePassword, () {
                  setState(() => _obscurePassword = !_obscurePassword);
                }),
                validator: _validatePassword,
                inputFormatters: const [],
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),
              AuthTextField(
                controller: _confirmPasswordController,
                hintText: 'Confirm your password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscureConfirmPassword,
                suffixIcon: _buildVisibilityIcon(_obscureConfirmPassword, () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                }),
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please confirm your password'
                    : null,
                inputFormatters: const [],
                contentPadding: EdgeInsets.zero,
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
      actionButtonText: 'Sign Up',
      onActionPressed: _isLoading ? null : _submitForm,
      bottomText: 'Already have an account?',
      bottomActionText: 'Login',
      navigateRoute: '/login',
      backgroundImage: 'https://wallpapercave.com/wp/wp5201676.jpg',
      actionButtonStyle: _buildButtonStyle(),
      actionButtonPadding: const EdgeInsets.symmetric(horizontal: 24),
      titleStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bottomTextStyle: const TextStyle(fontSize: 16, color: Colors.black54),
      bottomActionTextStyle: const TextStyle(fontSize: 16, color: Colors.blue),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    // Only allow Gmail addresses
    if (!value.toLowerCase().endsWith('@gmail.com')) {
      return 'Only Gmail addresses are allowed';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your phone number';
    // Indian mobile: 10 digits, starts with 6,7,8,9
    if (!RegExp(r'^[6-9][0-9]{9}').hasMatch(value)) {
      return 'Please enter a valid 10-digit Indian mobile number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Widget _buildVisibilityIcon(bool obscure, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
      onPressed: onPressed,
    );
  }

  ButtonStyle _buildButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
