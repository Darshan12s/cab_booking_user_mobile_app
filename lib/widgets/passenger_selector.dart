// widgets/passenger_selector.dart
import 'package:flutter/material.dart';
import '../booking_theme.dart';

class PassengerSelector extends StatelessWidget {
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool isMobile;

  const PassengerSelector({
    super.key,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
    this.isMobile = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 12,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: BookingTheme.getBorderColor(context)),
        borderRadius: BorderRadius.circular(12),
        color: BookingTheme.getCardColor(context),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onDecrement,
            child: Container(
              width: isMobile ? 28 : 32,
              height: isMobile ? 28 : 32,
              decoration: BoxDecoration(
                color: count > 1
                    ? BookingTheme.primaryColor
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.remove,
                color: Colors.white,
                size: isMobile ? 16 : 18,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person,
                  color: BookingTheme.primaryColor,
                  size: isMobile ? 18 : 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: BookingTheme.getTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onIncrement,
            child: Container(
              width: isMobile ? 28 : 32,
              height: isMobile ? 28 : 32,
              decoration: BoxDecoration(
                color: BookingTheme.primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: isMobile ? 16 : 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
