// widgets/my_Trip/payment_method_section.dart

import 'package:cab_booking_user_mobile_app/models/payment_method_model.dart';
import 'package:cab_booking_user_mobile_app/screens/my_trip/payment_screen.dart';
import 'package:flutter/material.dart';
import 'payment_method_option.dart';
import 'package:cab_booking_user_mobile_app/screens/my_Trip/payment_screen.dart';

// Define custom colors for consistency with the design
const Color _cardBorderColor = Color(0xFFE0E0E0);

class PaymentMethodSection extends StatelessWidget {
  final PaymentMethod currentMethod;
  final ValueChanged<PaymentMethod> onPaymentMethodChanged;

  const PaymentMethodSection({
    super.key,
    required this.currentMethod,
    required this.onPaymentMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Payment Method',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: _cardBorderColor),
          ),
          child: Column(
            children: PaymentMethod.allPaymentMethods.map((method) {
              return PaymentMethodOption(
                method: method,
                isSelected: currentMethod.id == method.id,
                onTap: () => onPaymentMethodChanged(method),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

extension on List<PaymentMethod>? {
  List<PaymentMethodOption> map(PaymentMethodOption Function(PaymentMethod method) toElement) {
    if (this == null) return [];
    return this!.map(toElement).toList();
  }
}