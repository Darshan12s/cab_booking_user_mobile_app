// widgets/my_Trip/issue_chip.dart
import 'package:flutter/material.dart';

// Define custom colors for consistency with the design
const Color _primaryGreen = Color(0xFF34A853);

class IssueChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const IssueChip({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _primaryGreen),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
