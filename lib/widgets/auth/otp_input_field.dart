// widgets/auth/otp_input_field.dart
// TODO Implement this library.
// widgets/auth/otp_input_field.dart
import 'package:flutter/material.dart';

class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onResendPressed;

  const OtpInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onResendPressed,
    String? errorMessage,
    required String phoneNumber,
    required void Function(String otp) onVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 8,
            ),
            filled: true,
            fillColor: Colors.black12,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          style: const TextStyle(fontSize: 18, letterSpacing: 4),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          obscureText: true,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        if (onResendPressed != null)
          TextButton(
            onPressed: onResendPressed,
            child: const Text(
              'Resend OTP',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
