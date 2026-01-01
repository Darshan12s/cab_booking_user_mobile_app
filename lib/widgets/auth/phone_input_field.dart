// widgets/auth/phone_input_field.dart
// TODO Implement this library.
// widgets/auth/phone_input_field.dart
import 'package:flutter/material.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isLoading;
  final VoidCallback onSendOtp;
  final FormFieldValidator<String>? validator;

  const PhoneInputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.isLoading,
    required this.onSendOtp,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            validator: validator,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 16,
              ),
              prefix: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Text(
                  '+91 ',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton(
                  onPressed: isLoading ? null : onSendOtp,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green,
                            ),
                          ),
                        )
                      : const Text(
                          'Send OTP',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              counterText: '',
              filled: true,
              fillColor: isDark ? Colors.grey[800] : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[600]! : Colors.grey,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[600]! : Colors.grey,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter 10-digit mobile number without country code',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
