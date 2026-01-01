import 'package:flutter/material.dart';
import '../models/payment_type.dart';

class PaymentOptionWidget extends StatelessWidget {
  final PaymentType type;
  final String title;
  final String amount;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentOptionWidget({
    super.key,
    required this.type,
    required this.title,
    required this.amount,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double radioSize = constraints.maxWidth < 350 ? 18 : 24;
        double fontSize = constraints.maxWidth < 350 ? 13 : 16;
        double descFont = constraints.maxWidth < 350 ? 11 : 14;
        double amountFont = constraints.maxWidth < 350 ? 13 : 16;
        double spacing = constraints.maxWidth < 350 ? 8 : 12;
        return Card(
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(spacing),
              child: Row(
                children: [
                  Container(
                    width: radioSize,
                    height: radioSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.grey,
                        width: 2,
                      ),
                      color: isSelected ? Colors.green : null,
                    ),
                  ),
                  SizedBox(width: spacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.green : Colors.black,
                            fontSize: fontSize,
                          ),
                        ),
                        if (description.isNotEmpty)
                          Text(
                            description,
                            style: TextStyle(
                              color: isSelected ? Colors.green : Colors.grey,
                              fontSize: descFont,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (amount.isNotEmpty)
                    Text(
                      amount,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.green : Colors.black,
                        fontSize: amountFont,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
