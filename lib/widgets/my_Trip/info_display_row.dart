// widgets/my_Trip/info_display_row.dart
import 'package:flutter/material.dart';

class InfoDisplayRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isValueBold;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const InfoDisplayRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.isValueBold = false,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: labelStyle ?? Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            value,
            style:
                valueStyle ??
                Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontWeight: isValueBold ? FontWeight.bold : FontWeight.normal,
                  color:
                      valueColor ??
                      Theme.of(context).textTheme.titleSmall!.color,
                ),
          ),
        ],
      ),
    );
  }
}