// screens/my_Trip/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/booking_model.dart';
import '../../models/booking_id.dart';
import '../booking_confirmed.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/service_types.dart';
import '../terms_conditions.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final BookingID bookingId;
  final ServiceTypes serviceType;
  // Add these fields to receive summary data from previous page
  final String pickupLocation;
  final String dropLocation;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final int passengerCount;
  final String vehicleModel;
  final String vehicleTypeDisplay;
  final String vehicleServiceType;
  final DateTime? returnDate;
  final TimeOfDay? returnTime;

  const PaymentScreen({
    super.key,
    required this.totalAmount,
    required this.bookingId,
    required this.serviceType,
    required this.pickupLocation,
    required this.dropLocation,
    required this.selectedDate,
    required this.selectedTime,
    required this.passengerCount,
    required this.vehicleModel,
    required this.vehicleTypeDisplay,
    required this.vehicleServiceType,
    this.returnDate,
    this.returnTime,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _paymentMethod = "upi";
  String _paymentAmountType = "partial";
  bool _isProcessing = false;
  late Razorpay _razorpay;

  double get _partialPayment => (widget.totalAmount * 0.25).ceilToDouble();
  double get _currentPaymentAmount =>
      _paymentAmountType == "full" ? widget.totalAmount : _partialPayment;
  double get _remainingAmount =>
      _paymentAmountType == "full" ? 0 : widget.totalAmount - _partialPayment;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Validate totalAmount on init
    if (widget.totalAmount <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid fare amount. Please try again.'),
          ),
        );
        Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    if (!mounted) return;
    setState(() => _isProcessing = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to continue booking')),
        );
        return;
      }

      // Always ensure a valid fare is selected
      double selectedFare = _paymentAmountType == "full"
          ? widget.totalAmount
          : _partialPayment;

      // Ensure minimum fare is at least ₹1 for Razorpay and backend
      if (selectedFare < 1.0) {
        selectedFare = 1.0;
      }

      // Defensive: fallback to totalAmount if partial is invalid
      if (selectedFare.isNaN || selectedFare.isInfinite || selectedFare <= 0) {
        selectedFare = widget.totalAmount > 0 ? widget.totalAmount : 1.0;
      }

      // Additional check: Prompt user to enter a valid amount if still invalid
      if (selectedFare.isNaN || selectedFare.isInfinite || selectedFare <= 0) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please enter a valid, positive fare amount before proceeding to payment.',
            ),
          ),
        );
        return;
      }

      int paymentAmountPaise = (selectedFare * 100).round();
      if (paymentAmountPaise < 100) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Minimum payment amount is ₹1. Please select a valid fare.',
            ),
          ),
        );
        return;
      }

      // Debug print to verify the amount sent to backend
      debugPrint('Selected fare to send to backend: $selectedFare');

      if (selectedFare > widget.totalAmount * 2) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment amount exceeds maximum limit.'),
          ),
        );
        return;
      }

      // 1. Get service type from Supabase
      final serviceTypeResp = await Supabase.instance.client
          .from('service_types')
          .select('id, display_name')
          .eq('display_name', widget.serviceType.displayName)
          .maybeSingle();

      if (serviceTypeResp == null || serviceTypeResp['id'] == null) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service type not found. Please try again.'),
          ),
        );
        return;
      }
      final serviceTypeId = serviceTypeResp['id'];

      Map<String, dynamic>? bookingResp;
      String? bookingId;
      try {
        bookingResp = await Supabase.instance.client
            .from('bookings')
            .insert({
              'user_id': user.id,
              'pickup_address': 'N/A',
              'dropoff_address': 'N/A',
              'pickup_latitude': 0.0,
              'pickup_longitude': 0.0,
              'dropoff_latitude': 0.0,
              'dropoff_longitude': 0.0,
              'fare_amount': selectedFare,
              'status': 'pending',
              'payment_status': 'pending',
              'scheduled_time': DateTime.now().toIso8601String(),
              'service_type_id': serviceTypeId,
              'payment_method': _paymentMethod,
              'is_scheduled': false,
              'is_round_trip': false,
              'return_scheduled_time': DateTime.now().toIso8601String(),
              'trip_type': 'one-way',
              'vehicle_type': 'standard',
              'special_instructions': '',
              'package_hours': 0,
              'distance_km': 0.0,
              'advance_amount': _paymentAmountType == 'partial'
                  ? selectedFare
                  : 0.0,
              'remaining_amount': _paymentAmountType == 'partial'
                  ? widget.totalAmount - selectedFare
                  : 0.0,
            })
            .select()
            .single();
        bookingId = bookingResp['id'];
      } catch (e) {
        String errorMsg =
            'Booking could not be created. Please contact support.';
        if (e.toString().contains('row-level security') ||
            e.toString().contains('Forbidden')) {
          errorMsg =
              'You do not have permission to create a booking. Please login again or contact support. '
              'If this persists, the app administrator must update Supabase Row Level Security (RLS) policies for the bookings table:\n'
              '1. Allow insert: create policy "Allow insert for authenticated users" on public.bookings for insert using (auth.uid() = user_id);\n'
              '2. Allow update: create policy "Allow update for authenticated users" on public.bookings for update using (auth.uid() = user_id);';
        }
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
        return;
      }

      if (paymentAmountPaise < 100) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Minimum payment amount is ₹1. Please select a valid fare.',
            ),
          ),
        );
        return;
      }

      // Debug prints to check values before sending to backend
      debugPrint('Selected fare: $selectedFare');

      final requestBody = {
        'bookingId': bookingId,
        'paymentMethod': _paymentMethod,
        'paymentAmount': selectedFare,

        'bookingData': {
          'serviceType': widget.serviceType.name,
          'selectedFare': {'type': 'fixed', 'price': selectedFare},
        },
      };
      debugPrint('Request body: ${jsonEncode(requestBody)}');

      final orderResp = await http.post(
        Uri.parse(
          'https://gmualcoqyztvtsqhjlzb.supabase.co/functions/v1/create-razorpay-order',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${Supabase.instance.client.auth.currentSession?.accessToken}',
        },
        body: jsonEncode(requestBody),
      );

      if (orderResp.statusCode < 200 || orderResp.statusCode >= 300) {
        setState(() => _isProcessing = false);
        final errorBody = jsonDecode(orderResp.body);
        final errorMessage =
            errorBody['error'] ?? errorBody['message'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create Razorpay order: $errorMessage'),
          ),
        );
        return;
      }

      final orderData = jsonDecode(orderResp.body);

      if (orderData['key_id'] == null || orderData['order_id'] == null) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid Razorpay order response')),
        );
        return;
      }
      print('Razorpay order created successfully: ${orderData}');

      var options = {
        'key': orderData['key_id'],
        'amount': orderData['amount'].toString(),
        'currency': orderData['currency'] ?? 'INR',
        'name': 'SDM E-Mobility',
        'description': '${widget.serviceType.displayName} Ride',
        'order_id': orderData['order_id'],
        // 'prefill': {'contact': user.phone ?? '', 'email': user.email ?? ''},
        'notes': {'booking_id': bookingId},
        'theme': {'color': '#6366f1'},
        'method': {
          'upi': _paymentMethod == 'upi',
          'card': _paymentMethod == 'card',
          'wallet': _paymentMethod == 'wallet',
        },
      };

      // Print Razorpay options for debugging
      debugPrint('Razorpay options: ${jsonEncode(options)}');

      try {
        _razorpay.open(options);
      } catch (e) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to open Razorpay: $e')));
        return;
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Payment error: ${e.toString()}')));
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isProcessing = false);
    try {
      final verifyResp = await http.post(
        Uri.parse(
          'https://gmualcoqyztvtsqhjlzb.supabase.co/functions/v1/verify-razorpay-payment',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${Supabase.instance.client.auth.currentSession?.accessToken}',
        },
        body: jsonEncode({
          'razorpay_order_id': response.orderId,
          'razorpay_payment_id': response.paymentId,
          'razorpay_signature': response.signature,
        }),
      );

      if (verifyResp.statusCode < 200 || verifyResp.statusCode >= 300) {
        throw Exception('Payment verification failed: ${verifyResp.body}');
      }

      // Use bookingId from widget.bookingId.id, ensure it's a non-empty String
      final bookingId = widget.bookingId.id.toString();
      if (bookingId.isEmpty || bookingId == 'null') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Booking ID is missing or invalid. Please contact support.',
            ),
          ),
        );
        return;
      }

      await Supabase.instance.client
          .from('bookings')
          .update({
            'payment_status': _paymentAmountType == "full"
                ? 'paid'
                : 'partially_paid',
            'status': 'confirmed',
          })
          .eq('id', bookingId);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmedPage(
            bookingDetails: BookingDetails(
              bookingId: bookingId,
              serviceType: widget.serviceType.name,
              dateTime: DateFormat(
                'MMM dd, yyyy • h:mm a',
              ).format(DateTime.now()),
              paymentStatus: _paymentAmountType == "full"
                  ? 'Fully Paid'
                  : 'Advance Paid',
              totalAmount: widget.totalAmount,
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment verification failed: ${e.toString()}')),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message ?? 'Unknown error'}'),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet selected: ${response.walletName}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? const Color(0xFF2D2D2D) : Colors.white;
    final screenWidth = MediaQuery.of(context).size.width;

    final displayDate = DateFormat('dd-MM-yyyy').format(widget.selectedDate);
    final displayTime = widget.selectedTime.format(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Ride Summary Card (like summary page, second image) ---
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Car details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.vehicleModel,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: themeColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.vehicleTypeDisplay,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.vehicleServiceType,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '₹${widget.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Car image (replace with your asset or network image)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/tiago_ev_yellow.png',
                          width: screenWidth * 0.32 > 120
                              ? 120
                              : screenWidth * 0.32,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: screenWidth * 0.32 > 120
                                    ? 120
                                    : screenWidth * 0.32,
                                height: 70,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.directions_car,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // --- Date, Time, Passenger Row ---
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: themeColor),
                    const SizedBox(width: 6),
                    Text(
                      displayDate,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: themeColor,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Icon(Icons.access_time, size: 18, color: themeColor),
                    const SizedBox(width: 6),
                    Text(
                      displayTime,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: themeColor,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Icon(Icons.person, size: 18, color: themeColor),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.passengerCount}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // --- Pickup and Dropoff locations ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.circle, size: 10, color: Colors.black),
                        const SizedBox(width: 8),
                        Text(
                          widget.pickupLocation,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: themeColor,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 18.0,
                        top: 2,
                        bottom: 8,
                      ),
                      child: Text(
                        'Karnataka, India',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.circle, size: 10, color: Colors.black),
                        const SizedBox(width: 8),
                        Text(
                          widget.dropLocation,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: themeColor,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 18.0,
                        top: 2,
                        bottom: 8,
                      ),
                      child: Text(
                        'Karnataka, India',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                // --- Ride status info ---
                // Remove the red border info bar (the image you pasted)
                // Container(
                //   width: double.infinity,
                //   margin: const EdgeInsets.only(top: 8, bottom: 8),
                //   padding: const EdgeInsets.all(12),
                //   decoration: BoxDecoration(
                //     color: Colors.red[50],
                //     borderRadius: BorderRadius.circular(8),
                //     border: Border.all(color: Colors.red[200]!),
                //   ),
                //   // child: const Text(
                //   //   "You'll see driver and car details shortly before your pickup / after ride is confirmed.",
                //   //   style: TextStyle(
                //   //     color: Colors.red,
                //   //     fontWeight: FontWeight.w500,
                //   //     fontSize: 14,
                //   //   ),
                //   // ),
                // ),
                const SizedBox(height: 16),
                // Payment Amount Selection
                _buildSectionTitle('Choose Payment Amount'),
                _buildPaymentOption(
                  "Partial Payment (25%)",
                  "Pay remaining after ride",
                  "partial",
                  '₹${_partialPayment.toStringAsFixed(0)}',
                ),
                _buildPaymentOption(
                  "Full Payment",
                  "Pay complete fare now",
                  "full",
                  '₹${widget.totalAmount.toStringAsFixed(0)}',
                ),
                if (_paymentAmountType == "partial" && _remainingAmount > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 8),
                    child: Text(
                      "Remaining ₹${_remainingAmount.toStringAsFixed(0)} will be collected after ride completion",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 24),

                // Payment Method Selection
                _buildSectionTitle('Select Payment Method'),
                _buildPaymentMethodOption(
                  "UPI",
                  "PhonePe, GooglePay, Paytm",
                  "upi",
                ),
                _buildPaymentMethodOption(
                  "Credit/Debit Card",
                  "Visa, Mastercard, RuPay",
                  "card",
                ),
                _buildPaymentMethodOption(
                  "Digital Wallet",
                  "Paytm, Mobikwik, Amazon Pay",
                  "wallet",
                ),
                const SizedBox(height: 24),

                // Fare Breakdown
                _buildFareBreakdown(isDark, cardColor, themeColor),
              ],
            ),
          ),

          // Proceed to Pay Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Proceed to Pay ₹${_currentPaymentAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPaymentOption(
    String title,
    String subtitle,
    String value,
    String amount,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      leading: Radio<String>(
        value: value,
        groupValue: _paymentAmountType,
        onChanged: (val) {
          if (val != null) {
            setState(() {
              _paymentAmountType = val;
            });
          }
        },
      ),
      trailing: Text(
        amount,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPaymentMethodOption(
    String title,
    String subtitle,
    String value,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      leading: Radio<String>(
        value: value,
        groupValue: _paymentMethod,
        onChanged: (val) {
          if (val != null) {
            setState(() {
              _paymentMethod = val;
            });
          }
        },
      ),
    );
  }

  Widget _buildFareBreakdown(bool isDark, Color cardColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Fare Breakdown'),
        Card(
          color: cardColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildFareRow('Base Fare', '₹143.00', textColor),
                const SizedBox(height: 8),
                _buildFareRow('Tax', '₹20.00', textColor),
                const SizedBox(height: 8),
                _buildFareRow('Toll Tax', '₹10.00', textColor),
                const Divider(),
                // Move Total row closer to the above rows, reduce vertical space
                _buildFareRow(
                  'Total',
                  '₹${widget.totalAmount.toStringAsFixed(2)}',
                  Colors.green,
                  isTotal: true,
                ),
                // Reduce space before T&C
                const SizedBox(height: 10),
                _TermsAndConditionsCheckbox(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFareRow(
    String label,
    String value,
    Color color, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }
}

// Add this widget at the end of the file (or in a suitable place)
class _TermsAndConditionsCheckbox extends StatefulWidget {
  @override
  State<_TermsAndConditionsCheckbox> createState() =>
      _TermsAndConditionsCheckboxState();
}

class _TermsAndConditionsCheckboxState
    extends State<_TermsAndConditionsCheckbox> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _accepted,
              onChanged: (val) {
                setState(() {
                  _accepted = val ?? false;
                });
              },
              activeColor: Colors.black,
            ),
            Expanded(
              child: Row(
                children: [
                  Text(
                    'Accept Terms & Conditions',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TermsAndConditionsPage(),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(left: 44.0, top: 18, bottom: 2),
          child: Text(
            '(Please read T&C before accepting)',
            style: TextStyle(
              color: Colors.red,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        // Do NOT show the T&C summary below the checkbox
      ],
    );
  }
}
