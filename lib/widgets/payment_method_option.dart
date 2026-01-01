// widgets/payment_method_option.dart
import 'package:cab_booking_user_mobile_app/models/payment_method_model.dart';
import 'package:cab_booking_user_mobile_app/screens/my_trip/payment_screen.dart';
import 'package:flutter/material.dart';

import '../screens/my_Trip/payment_screen.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          color: isSelected
              ? (isDark
                    ? Colors.green[900]?.withOpacity(0.3)
                    : Colors.green[50])
              : (isDark ? const Color(0xFF2D2D2D) : Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            side: BorderSide(
              color: isSelected
                  ? Colors.green
                  : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 30,
                  height: 30,
                  child: Image.asset(
                    method.imageAsset,
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.payment,
                        size: 30,
                        color: method.iconColor,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        method.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        method.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                        width: 1.0,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
