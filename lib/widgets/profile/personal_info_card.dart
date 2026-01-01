// widgets/profile/personal_info_card.dart
import 'package:flutter/material.dart';
import 'profile_info_field.dart';

class PersonalInformationCard extends StatelessWidget {
  final bool isEditing;
  final String userName;
  final String phoneNumber;
  final String email;
  final String dob;
  final VoidCallback onToggleEdit;
  final ValueChanged<String> onUserNameChanged;
  final ValueChanged<String> onPhoneNumberChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onDobChanged;
  final VoidCallback? onDobTap;

  const PersonalInformationCard({
    required this.isEditing,
    required this.userName,
    required this.phoneNumber,
    required this.email,
    required this.dob,
    required this.onToggleEdit,
    required this.onUserNameChanged,
    required this.onPhoneNumberChanged,
    required this.onEmailChanged,
    required this.onDobChanged,
    this.onDobTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Personal Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isEditing ? Icons.save : Icons.edit_note_outlined,
                    color: Colors.green,
                  ),
                  onPressed: onToggleEdit,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ProfileInfoField(
              icon: Icons.call,
              label: 'Phone Number',
              value: phoneNumber,
              isEditing: isEditing,
              onChanged: onPhoneNumberChanged,
              isReadOnlyField:
                  true, // Make phone number permanently non-editable
            ),
            const SizedBox(height: 16),
            ProfileInfoField(
              icon: Icons.mail_outline,
              label: 'Email',
              value: email,
              isEditing: isEditing,
              onChanged: onEmailChanged,
            ),
            const SizedBox(height: 16),
            ProfileInfoField(
              icon: Icons.person_outline,
              label: 'Full Name',
              value: userName,
              isEditing: isEditing,
              onChanged: onUserNameChanged,
            ),
            const SizedBox(height: 16),
            ProfileInfoField(
              icon: Icons.calendar_today_outlined,
              label: 'Date of Birth',
              value: dob,
              isEditing: isEditing,
              onChanged: onDobChanged,
              onTap: onDobTap,
            ),
          ],
        ),
      ),
    );
  }
}
