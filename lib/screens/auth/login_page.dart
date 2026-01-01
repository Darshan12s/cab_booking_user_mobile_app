// screens/auth/login_page.dart
import 'package:flutter/material.dart';
import 'package:cab_booking_user_mobile_app/widgets/auth/auth_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_page_template.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user?.emailConfirmedAt == null) {
        throw AuthException('Please verify your email before logging in');
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 375; // iPhone 5/SE size
    final isMediumScreen = screenSize.width < 414; // iPhone 6/7/8 Plus size

    return AuthPageTemplate(
      title: 'Login',
      formFields: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthTextField(
                controller: _emailController,
                hintText: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: isSmallScreen ? 14 : 16,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                inputFormatters: [],
                contentPadding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 12 : 16,
                  horizontal: isSmallScreen ? 12 : 16,
                ),
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),

              AuthTextField(
                controller: _passwordController,
                hintText: 'Enter your password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: isSmallScreen ? 14 : 16,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                    size: isSmallScreen ? 20 : 24,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                inputFormatters: [],
                contentPadding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 12 : 16,
                  horizontal: isSmallScreen ? 12 : 16,
                ),
              ),
              SizedBox(height: isSmallScreen ? 10 : 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RememberMeCheckbox(
                    value: _rememberMe,
                    onChanged: (value) => setState(() => _rememberMe = value ?? false),
                    label: 'Remember me',
                    isSmallScreen: isSmallScreen,
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/reset-password'),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.blue[200],
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        fontSize: isSmallScreen ? 12 : isMediumScreen ? 14 : 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
      actionButtonText: 'Login',
      onActionPressed: _isLoading ? null : _login,
      bottomText: 'Don\'t have an account?',
      bottomActionText: 'Sign Up',
      navigateRoute: '/signup',
      backgroundImage: 'https://wallpapercave.com/wp/wp5201676.jpg',
      actionButtonStyle: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 14 : 16,
          horizontal: isSmallScreen ? 24 : 32,
        ),
        textStyle: TextStyle(
          fontSize: isSmallScreen ? 16 : 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actionButtonPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 20 : 24,
      ),
      titleStyle: TextStyle(
        fontSize: isSmallScreen ? 24 : isMediumScreen ? 28 : 32,
        fontWeight: FontWeight.bold,
      ),
      bottomTextStyle: TextStyle(
        fontSize: isSmallScreen ? 14 : 16,
      ),
      bottomActionTextStyle: TextStyle(
        fontSize: isSmallScreen ? 14 : 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class RememberMeCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;
  final bool isSmallScreen;

  const RememberMeCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.label,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: isSmallScreen ? 24 : 32,
          height: isSmallScreen ? 24 : 32,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
          ),
        ),
      ],
    );
  }
}