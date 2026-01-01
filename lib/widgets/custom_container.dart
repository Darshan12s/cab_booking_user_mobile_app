// widgets/custom_container.dart
import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const CustomContainer({
    Key? key,
    required this.child,
    this.color,
    this.borderRadius = 12.0,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: color ?? (isDark ? theme.colorScheme.surface : Colors.white),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(12),
      child: child,
    );
  }
}