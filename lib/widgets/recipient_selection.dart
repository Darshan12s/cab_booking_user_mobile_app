// widgets/recipient_selection.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/app_theme.dart';

class RecipientSelectionDropdown extends StatelessWidget {
  final String selectedRecipient;
  final ValueChanged<String?> onChanged;

  const RecipientSelectionDropdown({
    super.key,
    required this.selectedRecipient,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.getBorderColor(context)),
          borderRadius: BorderRadius.circular(20),
          color: AppTheme.getCardColor(context),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.person, color: AppTheme.getTextColor(context), size: 20),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: selectedRecipient,
              items: <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  value: 'For me',
                  child: Text(
                    'For me',
                    style: TextStyle(color: AppTheme.getTextColor(context)),
                  ),
                ),
                DropdownMenuItem<String>(
                  value: 'For other',
                  child: Text(
                    'For other',
                    style: TextStyle(color: AppTheme.getTextColor(context)),
                  ),
                ),
              ],
              onChanged: onChanged,
              underline: Container(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: AppTheme.getTextColor(context),
              ),
              style: GoogleFonts.poppins(
                color: AppTheme.getTextColor(context),
                fontSize: 16,
              ),
              dropdownColor: AppTheme.getCardColor(context),
            ),
          ],
        ),
      ),
    );
  }
}
