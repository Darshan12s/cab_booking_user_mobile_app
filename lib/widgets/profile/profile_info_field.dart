// widgets/profile/profile_info_field.dart
import 'package:flutter/material.dart';

class ProfileInfoField extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isEditing;
  final ValueChanged<String> onChanged;
  final VoidCallback? onTap;
  final bool
  isReadOnlyField; // New parameter to make fields permanently non-editable

  const ProfileInfoField({
    required this.icon,
    required this.label,
    required this.value,
    required this.isEditing,
    required this.onChanged,
    this.onTap,
    this.isReadOnlyField = false, // Default to false for backward compatibility
    super.key,
  });

  @override
  State<ProfileInfoField> createState() => _ProfileInfoFieldState();
}

class _ProfileInfoFieldState extends State<ProfileInfoField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant ProfileInfoField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (_controller.text != widget.value) {
        _controller.text = widget.value;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              widget.icon,
              size: 20,
              color: Theme.of(context).iconTheme.color,
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (widget.label == 'Date of Birth')
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(12),
              splashColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              highlightColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.05),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color:
                              widget.value.contains('DD-MM-YYYY') ||
                                  widget.value.contains('select')
                              ? Theme.of(context).textTheme.bodySmall?.color
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Calendar',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          TextField(
            controller: _controller,
            onChanged: (widget.isEditing && !widget.isReadOnlyField)
                ? widget.onChanged
                : null,
            enabled: widget.isEditing && !widget.isReadOnlyField,
            readOnly: !widget.isEditing || widget.isReadOnlyField,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: widget.isReadOnlyField
                  ? Theme.of(context).disabledColor.withOpacity(0.1)
                  : Theme.of(context).colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              isDense: true,
              suffixIcon: widget.isReadOnlyField
                  ? Icon(
                      Icons.lock_outline,
                      size: 18,
                      color: Theme.of(context).disabledColor,
                    )
                  : (widget.isEditing && !widget.isReadOnlyField)
                  ? Icon(
                      Icons.edit,
                      size: 18,
                      color: Theme.of(context).iconTheme.color,
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}
