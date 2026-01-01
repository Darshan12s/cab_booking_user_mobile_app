// widgets/my_Trip/gradient_button.dart
import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final LinearGradient gradient;
  final VoidCallback? onPressed;
  final Widget child;

  const GradientButton({
    super.key,
    required this.gradient,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        // Using foregroundColor as transparent to allow gradient to show
        foregroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.black26,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Center(child: child),
      ),
    );
  }
}