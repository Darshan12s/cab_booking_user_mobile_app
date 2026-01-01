import 'package:flutter/material.dart';
import '../models/payment_type.dart';
import 'payment_option_widget.dart';

class PaymentOptionsSection extends StatelessWidget {
  final List<Map<String, dynamic>> paymentOptions;
  final PaymentType selectedType;
  final ValueChanged<PaymentType> onSelect;

  const PaymentOptionsSection({
    super.key,
    required this.paymentOptions,
    required this.selectedType,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: paymentOptions.map((option) {
        final type = option['type'] as PaymentType;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: PaymentOptionWidget(
            type: type,
            title: option['title'],
            amount: option['amount'],
            description: option['description'],
            isSelected: selectedType == type,
            onTap: () => onSelect(type),
          ),
        );
      }).toList(),
    );
  }
}
