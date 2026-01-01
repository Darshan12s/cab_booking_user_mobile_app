// screens/add_voucher.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../booking_theme.dart';
import 'terms_conditions.dart';

class AddVoucherPage extends StatefulWidget {
  final ValueChanged<String?> onVoucherConfirmed;
  const AddVoucherPage({super.key, required this.onVoucherConfirmed});

  @override
  State<AddVoucherPage> createState() => _AddVoucherPageState();
}

class _AddVoucherPageState extends State<AddVoucherPage> {
  final TextEditingController _voucherCodeController = TextEditingController();
  bool _termsAccepted = false;

  @override
  void dispose() {
    _voucherCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Voucher Code',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _voucherCodeController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter voucher code',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.blue[400]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF2D2D2D)
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Enter the code in order to claim and use your voucher',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    constraints: const BoxConstraints(
                      minHeight: 120,
                      maxHeight: 200,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                      color: isDark ? const Color(0xFF2D2D2D) : Colors.grey[50],
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1. Eligibility: Users must be 18 years of age or older to register and use our ride-hailing services. Proof of age may be required.',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '2. Account Responsibility: Users are solely responsible for maintaining the confidentiality of their account information, including passwords, and for all activities that occur under their account.',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '3. Booking Confirmation: All ride bookings are subject to the availability of drivers and vehicles at the time of the request.',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '4. Cancellation Policy: Our cancellation policies and associated fees apply to all ride cancellations. Users are advised to review these policies before canceling a ride.',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24.0,
                        height: 24.0,
                        child: Checkbox(
                          value: _termsAccepted,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _termsAccepted = newValue ?? false;
                            });
                          },
                          activeColor: const Color(0xFF6FCF97),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: BorderSide(
                            color: _termsAccepted
                                ? const Color(0xFF6FCF97)
                                : Colors.grey,
                            width: 2.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Accept Terms & Conditions',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              '(Please read T&C before accepting)',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2D2D2D)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1. Eligibility: Users must be 18 years of age or older to register and use our ride-hailing services. Proof of age may be required.',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey,
                              ),
                            ),
                            Text(
                              '2. Account Responsibility: Users are solely responsible for maintaining the confidentiality of their account information, including passwords, and for all activities that occur under their account.',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey,
                              ),
                            ),
                            Text(
                              '3. Booking Confirmation: All ride bookings are subject to the availability of drivers and vehicles at the time of the request.',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey,
                              ),
                            ),
                            Text(
                              '4. Cancellation Policy: Our cancellation policies and associated fees apply to all ride cancellations. Users are advised to review these policies before canceling a ride.',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TermsAndConditionsPage(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(0, 0, 0, 0.7),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4),
                                ),
                              ),
                              child: const Text(
                                'Click to view fully',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _termsAccepted
                    ? () {
                        widget.onVoucherConfirmed(_voucherCodeController.text);
                        Navigator.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _termsAccepted
                      ? const Color(0xFF6FCF97)
                      : Colors.grey[400],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Confirm',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
