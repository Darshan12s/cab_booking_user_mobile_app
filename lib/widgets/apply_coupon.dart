// widgets/apply_coupon.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/add_voucher.dart';

class ApplyCouponCodeSection extends StatelessWidget {
  final String? appliedCouponCode;
  final ValueChanged<String?> onCouponApplied;

  const ApplyCouponCodeSection({
    super.key,
    required this.appliedCouponCode,
    required this.onCouponApplied,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (appliedCouponCode != null && appliedCouponCode!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Apply Coupon Code',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF6FCF97)),
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFE8F7F0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.check_circle, color: Color(0xFF2EAB69)),
                    const SizedBox(width: 8),
                    Text(
                      appliedCouponCode!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF2EAB69),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => onCouponApplied(null),
                  splashRadius: 20,
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Navigate to AddVoucherPage on tap
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Apply Coupon Code',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final result = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddVoucherPage(onVoucherConfirmed: onCouponApplied),
                ),
              );
              if (result != null && result.isNotEmpty) {
                onCouponApplied(result);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: isDark ? Colors.grey[400] : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add Voucher Method',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }
}
