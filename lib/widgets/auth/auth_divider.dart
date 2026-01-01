// widgets/auth/auth_divider.dart
import 'package:flutter/material.dart';

class AuthDivider extends StatelessWidget {
  final String text;

  const AuthDivider({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: Colors.white30,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: Colors.white30,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}