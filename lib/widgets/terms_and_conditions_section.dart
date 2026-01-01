import 'package:flutter/material.dart';

class TermsAndConditionsSection extends StatelessWidget {
  final bool acceptTerms;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onViewTerms;

  const TermsAndConditionsSection({
    super.key,
    required this.acceptTerms,
    required this.onChanged,
    required this.onViewTerms,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize = constraints.maxWidth < 350 ? 12 : 16;
        double leftPad = constraints.maxWidth < 350 ? 24 : 40;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(value: acceptTerms, onChanged: onChanged),
                Text(
                  'Accept Terms & Conditions',
                  style: TextStyle(fontSize: fontSize),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: leftPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary of key terms:',
                    style: TextStyle(fontSize: fontSize - 2),
                  ),
                  Text(
                    '• Data privacy and usage',
                    style: TextStyle(fontSize: fontSize - 2),
                  ),
                  Text(
                    '• Payment and cancellation policy',
                    style: TextStyle(fontSize: fontSize - 2),
                  ),
                  TextButton(
                    onPressed: onViewTerms,
                    child: Text(
                      'View full terms and conditions',
                      style: TextStyle(fontSize: fontSize - 2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
