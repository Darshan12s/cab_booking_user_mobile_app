// widgets/my_Trip/faq_option_tile.dart
import 'package:flutter/material.dart';

// Define custom colors for consistency with the design
const Color _primaryGreen = Color(0xFF34A853);

class FAQOptionTile extends StatelessWidget {
  final FeedbackItem item;
  final VoidCallback onTap;

  const FAQOptionTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      title: Text(
        item.title,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDark ? Colors.white : _primaryGreen,
      ),
      onTap: onTap,
    );
  }
}

class FeedbackItem {
  final String title;

  const FeedbackItem({required this.title});
}
