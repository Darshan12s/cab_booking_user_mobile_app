// widgets/my_Trip/price_row_widget.dart
import 'package:flutter/material.dart';

class PriceRowWidget extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;

  const PriceRowWidget(
    this.label,
    this.value, {
    super.key,
    this.bold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}