// widgets/date_time_passengers.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DateTimePassengersRow extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final int passengerCount;

  const DateTimePassengersRow({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.passengerCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.calendar_today,
              size: 20,
              color: isDark ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('dd-MM-yyyy').format(selectedDate),
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isDark ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Icon(
              Icons.access_time,
              size: 20,
              color: isDark ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 8),
            Text(
              selectedTime.format(context),
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isDark ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Icon(
              Icons.person,
              size: 20,
              color: isDark ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 8),
            Text(
              passengerCount.toString(),
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isDark ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
