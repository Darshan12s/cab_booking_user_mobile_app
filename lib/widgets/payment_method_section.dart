// widgets/payment_method_section.dart
import 'package:cab_booking_user_mobile_app/models/payment_method_model.dart';
import 'package:cab_booking_user_mobile_app/screens/my_trip/payment_screen.dart';
import 'package:cab_booking_user_mobile_app/widgets/payment_method_option.dart';
import 'package:flutter/material.dart';

import '../screens/my_Trip/payment_screen.dart';

class PaymentMethodSection extends StatelessWidget {
  final PaymentMethod currentMethod;
  final ValueChanged<PaymentMethod> onMethodSelected;

  const PaymentMethodSection({
    super.key,
    required this.currentMethod,
    required this.onMethodSelected,
    required void Function(PaymentMethod newMethod) onPaymentMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            showModalBottomSheet<void>(
              context: context,
              backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
              builder: (BuildContext bottomSheetContext) {
                return Theme(
                  data: Theme.of(context),
                  child: PaymentMethodSelectionSheet(
                    currentMethod: currentMethod,
                    onMethodSelected: onMethodSelected,
                  ),
                );
              },
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              ),
              isScrollControlled: true,
            );
          },
          child: Card(
            color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 30,
                    height: 30,
                    child: Image.asset(
                      currentMethod.imageAsset,
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.payment,
                          size: 30,
                          color: currentMethod.iconColor,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          currentMethod.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          currentMethod.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: isDark ? Colors.grey[400] : Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PaymentMethodSelectionSheet extends StatelessWidget {
  final PaymentMethod currentMethod;
  final ValueChanged<PaymentMethod> onMethodSelected;

  const PaymentMethodSelectionSheet({
    super.key,
    required this.currentMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<PaymentMethod> availableMethods =
        PaymentData.availablePaymentMethods;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 16.0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: availableMethods.length,
              itemBuilder: (BuildContext context, int index) {
                final PaymentMethod method = availableMethods[index];
                final bool isSelected = method.id == currentMethod.id;
                return PaymentMethodOption(
                  key: ValueKey<String>(method.id),
                  method: method,
                  isSelected: isSelected,
                  onTap: () {
                    onMethodSelected(method);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
            padding: EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              bottom: MediaQuery.of(context).padding.bottom + 16.0,
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6FCF97),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentData {
  static List<PaymentMethod> availablePaymentMethods = [];
}
