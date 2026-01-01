// widgets/auth/alternative_auth_options.dart
import 'package:flutter/material.dart';

class AlternativeAuthOptions extends StatelessWidget {
  final String primaryText;
  final String secondaryText;
  final Future<void> Function() onPrimaryPressed;
  final Future<void> Function() onPressed;

  const AlternativeAuthOptions({
    super.key,
    required this.primaryText,
    required this.secondaryText,
    required this.onPrimaryPressed,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: onPrimaryPressed,
          child: Text(primaryText, style: const TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onPressed,
          child: Text(
            secondaryText,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
