// widgets/my_Trip/payment_method_option.dart

import 'package:cab_booking_user_mobile_app/screens/my_Trip/payment_screen.dart';
import 'package:cab_booking_user_mobile_app/screens/settings_screen.dart';
import 'package:flutter/material.dart';

// Define custom colors for consistency with the design
const Color _primaryGreen = Color(0xFF34A853);

class PaymentMethodOption extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodOption({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: <Widget>[
            Icon(
              method.icon,
              color: isSelected ? _primaryGreen : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                method.name,
                style: TextStyle(
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? _primaryGreen : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: _primaryGreen,
              ),
          ],
        ),
      ),
    );
  }
}