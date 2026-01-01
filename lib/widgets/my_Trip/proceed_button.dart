// widgets/my_Trip/proceed_button.dart
import 'package:flutter/material.dart';

// Define custom colors for consistency with the design
const Color _primaryGreen = Color(0xFF34A853);
const Color _advancePaymentBoxColor = Color(0xFFEEEEEE);

class ProceedButton extends StatelessWidget {
  final double advancePayment;
  final VoidCallback onPressed;

  const ProceedButton({
    super.key,
    required this.advancePayment,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _advancePaymentBoxColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Advance Payment: ₹${advancePayment.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Proceed to Pay',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}