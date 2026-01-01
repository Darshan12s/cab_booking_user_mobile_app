// widgets/my_Trip/schedule_section.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'schedule_detail_card.dart';

// Define custom colors for consistency with the design
const Color _primaryGreen = Color(0xFF34A853);
const Color _darkGreyText = Color(0xFF424242);
const Color _cardBorderColor = Color(0xFFE0E0E0);

class ScheduleSection extends StatelessWidget {
  final bool isNowSelected;
  final VoidCallback onSelectNow;
  final VoidCallback onSelectLater;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<TimeOfDay> onTimeSelected;

  const ScheduleSection({
    super.key,
    required this.isNowSelected,
    required this.onSelectNow,
    required this.onSelectLater,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateSelected,
    required this.onTimeSelected,
  });
  
  BuildContext? get context => null;

  String _formatDate(DateTime date) => DateFormat('MMM dd, yyyy').format(date);

  String _formatTime(TimeOfDay time) => time.format(context!);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      onDateSelected(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      onTimeSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Schedule Your Ride',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                onPressed: onSelectNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isNowSelected ? _primaryGreen : Colors.white,
                  foregroundColor:
                      isNowSelected ? Colors.white : _darkGreyText,
                  side: const BorderSide(color: _cardBorderColor),
                ),
                child: Text(
                  'Now',
                  style: TextStyle(
                    color: isNowSelected ? Colors.white : _darkGreyText,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: onSelectLater,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      !isNowSelected ? _primaryGreen : Colors.white,
                  foregroundColor:
                      !isNowSelected ? Colors.white : _darkGreyText,
                  side: const BorderSide(color: _cardBorderColor),
                ),
                child: Text(
                  'Later',
                  style: TextStyle(
                    color: !isNowSelected ? Colors.white : _darkGreyText,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (!isNowSelected)
          Row(
            children: <Widget>[
              Expanded(
                child: ScheduleDetailCard(
                  label: 'Date',
                  value: _formatDate(selectedDate),
                  onTap: () => _selectDate(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ScheduleDetailCard(
                  label: 'Time',
                  value: _formatTime(selectedTime),
                  onTap: () => _selectTime(context),
                ),
              ),
            ],
          ),
      ],
    );
  }
}