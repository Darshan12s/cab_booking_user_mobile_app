// screens/terms_conditions.dart
import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        title: Text(
          'Terms & Conditions',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This document outlines the terms and conditions ("Terms") for using the services offered by SDM E-Mobility Services Private Limited ("SDM," "we", "us", or "our"). These Terms govern your use of our electric vehicle (EV) rental services, including cab rentals, airport transfers, outstation trips, city rides, and taxi services.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Acceptance of Terms',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'By using our services, booking a ride, or accessing our mobile application, you agree to be bound by these Terms. If you do not agree to all the Terms, you are not authorised to use our services.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Services Offered',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'SDM provides a platform to connect you with eco-friendly electric vehicle (EV) transportation options. We offer the following services:',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• Cab Rentals: Book on EV cab for point-to-point travel within the city.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Airport Transfers: Pre-book a comfortable and reliable EV for your airport arrival or departure.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Outstation Trips: Travel to destinations outside the city limits in a spacious and efficient EV.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• City Rides: Get around town conveniently with our on-demand EV taxi service.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Booking and Payment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bookings can be made through our mobile application, website, or by calling our customer service center. You will be provided with fare estimates during the booking process. Fares may vary based on distance, duration, service type, and any applicable taxes or fees. We accept various payment methods, including online payment gateways, debit/credit cards, and cash (subject to availability).',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'User Eligibility',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'To use our services, you must be at least 18 years old and possess a valid government-issued ID. For airport transfers, you may be required to provide flight details during booking.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Rider Conduct',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You are responsible for the conduct of all passengers in the vehicle during your ride. Smoking, littering, and consumption of alcohol or illegal substances are strictly prohibited within the vehicle. We reserve the right to terminate your ride and remove you from the vehicle in case of disruptive or abusive behavior.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Vehicle Availability and Condition',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We strive to provide you with a clean and well-maintained EV for your ride. While we make every effort to ensure vehicle availability, we cannot guarantee a specific EV model for your booking. We reserve the right to substitute a similar EV in case of unforeseen circumstances.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Charging and Range',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Our EVs are equipped with long-range batteries. You are not responsible for charging the vehicle during your ride. In case of low battery, the driver will take the most appropriate route to reach a charging station to ensure uninterrupted service.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Cancellations and Refunds',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Our cancellation policy is outlined during the booking process and may vary depending on the service type and notice period. Refunds, if applicable, will be processed in accordance with our policy.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Liability and Indemnification',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'SDM is not liable for any delays, accidents, or damages caused by factors beyond our control, including weather conditions, traffic congestion, or mechanical breakdowns. We are committed to your safety. However, you agree to indemnify and hold harmless SDM from any claims, damages, or losses arising from your use of our services.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We respect your privacy. Please refer to our separate Privacy Policy for details on how we collect, use, and disclose your personal information.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Modifications to Terms',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We reserve the right to modify these Terms at any time. We will notify you of any significant changes by posting the updated Terms on our website or mobile application.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Governing Law and Dispute Resolution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'These Terms shall be governed by and construed in accordance with the laws of India. Any dispute arising out of or relating to these Terms shall be subject to the exclusive jurisdiction of the courts located in Bengaluru, Mysuru, Karnataka and across India.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'If you have any questions regarding these Terms, please contact us at +91 9900992220 or info@sdm-emobility.com.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Thank you for choosing SDM E-Mobility Services! We are committed to providing you with a safe, convenient, and environmentally friendly transportation experience.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
