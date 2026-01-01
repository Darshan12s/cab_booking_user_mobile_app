// screens/auth/otp_login_page.dart
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:cab_booking_user_mobile_app/widgets/auth/otp_input_field.dart';
import 'package:cab_booking_user_mobile_app/widgets/auth/phone_input_field.dart';
import 'package:cab_booking_user_mobile_app/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_page_template.dart';

class OtpLoginPage extends StatefulWidget {
  const OtpLoginPage({super.key});

  @override
  State<OtpLoginPage> createState() => _OtpLoginPageState();
}

class _OtpLoginPageState extends State<OtpLoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _showOtpField = false;
  bool _isLoading = false;
  bool _otpEntered = false;
  final _phoneFormKey = GlobalKey<FormState>();

  Future<void> _sendOtp() async {
    if (!_phoneFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await SupabaseService.sendOtp(_phoneController.text);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _showOtpField = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent to +91 ${_phoneController.text}'),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP: ${e.toString()}')),
      );
    }
  }

  Future<void> _handleOtpVerification() async {
    setState(() => _isLoading = true);
    try {
      final response = await SupabaseService.client.auth.verifyOTP(
        phone: '+91${_phoneController.text}',
        token: _otpController.text,
        type: OtpType.sms,
      );
      if (response.user != null) {
        // Save phone number to user profile after successful OTP verification
        await _savePhoneNumberToProfile(response.user!.id);

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('OTP verification failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePhoneNumberToProfile(String userId) async {
    try {
      final phoneNumber = '+91${_phoneController.text}';

      // Update the users table with phone number
      await SupabaseService.client.from('users').upsert({
        'id': userId,
        'phone_no': phoneNumber,
        'updated_at': DateTime.now().toIso8601String(),
      });

      print('📱 Phone number saved to profile: $phoneNumber');
    } catch (e) {
      print('❌ Failed to save phone number to profile: $e');
      // Don't throw error as login should still proceed
    }
  }

  void _onOtpChanged(String otp) {
    setState(() {
      _otpEntered = otp.length == 6;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageTemplate(
      title: _showOtpField ? 'Verify OTP' : 'Phone Login',
      formFields: [
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _showOtpField
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Form(
            key: _phoneFormKey,
            child: Column(
              children: [
                const Text(
                  'Enter phone number',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                PhoneInputField(
                  controller: _phoneController,
                  hintText: 'Enter your phone number',
                  isLoading: _isLoading,
                  onSendOtp: _sendOtp,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    if (value.length != 10) {
                      return 'Phone number must be 10 digits';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Only numbers are allowed';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          secondChild: Column(
            children: [
              OtpInputField(
                controller: _otpController,
                hintText: '6-digit code',
                phoneNumber: _phoneController.text,
                onResendPressed: _sendOtp,
                onChanged: _onOtpChanged,
                onVerified: (String otp) {},
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
      onActionPressed: _showOtpField
          ? _otpEntered
                ? _handleOtpVerification
                : null
          : _sendOtp,
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
      actionButtonText: 'Continue',
      titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      bottomTextStyle: const TextStyle(fontSize: 14, color: Colors.black54),
      bottomActionTextStyle: const TextStyle(fontSize: 14, color: Colors.blue),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
