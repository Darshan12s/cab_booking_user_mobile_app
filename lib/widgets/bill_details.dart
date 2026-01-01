// widgets/bill_details.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BillDetailsSection extends StatelessWidget {
  const BillDetailsSection({super.key, required double baseFare, required double extraCharges, required double discount, required double totalAmount, required bool showFullDetails});

  Widget _buildBillRow(
    String label,
    String value,
    bool isDark, {
    bool isTotal = false,
    String? totalNote,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: isTotal ? 18 : 16,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              if (totalNote != null)
                Text(
                  totalNote,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Bill Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
            border: Border.all(
              color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: <Widget>[
              _buildBillRow('Estimated base fare', '₹ 143', isDark),
              Divider(
                height: 1,
                color: isDark ? Colors.grey[600] : Colors.grey,
              ),
              _buildBillRow('Tax', '₹ 20', isDark),
              Divider(
                height: 1,
                color: isDark ? Colors.grey[600] : Colors.grey,
              ),
              _buildBillRow('Toll Tax', '₹ 10', isDark),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3D3D3D) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: _buildBillRow(
                  'Total Bill(rounded)',
                  '₹ 143',
                  isDark,
                  isTotal: true,
                  totalNote: 'includes ₹5.0 Taxes',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
