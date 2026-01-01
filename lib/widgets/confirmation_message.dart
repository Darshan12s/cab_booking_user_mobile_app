// widgets/confirmation_message.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmationMessage extends StatelessWidget {
  const ConfirmationMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.red[900]?.withOpacity(0.3) : Colors.red[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Text(
        'You\'ll see driver and car details shortly before your pickup / after ride is confirmed.',
        style: GoogleFonts.poppins(
          color: Colors.red,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
