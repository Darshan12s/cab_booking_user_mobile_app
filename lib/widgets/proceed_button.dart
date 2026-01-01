import 'package:flutter/material.dart';

class ProceedButton extends StatelessWidget {
  final bool acceptTerms;
  final VoidCallback onPressed;

  const ProceedButton({
    super.key,
    required this.acceptTerms,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: acceptTerms ? onPressed : null,
        child: const Text('PROCEED', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
