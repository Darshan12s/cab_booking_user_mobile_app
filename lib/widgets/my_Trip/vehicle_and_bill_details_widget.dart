// widgets/my_Trip/vehicle_and_bill_details_widget.dart
import 'package:flutter/material.dart';
import 'price_row_widget.dart';

class VehicleAndBillDetailsWidget extends StatelessWidget {
  final String? vehicleMakeModel;
  final String? vehicleNumber;
  final int? vehicleSeats;
  final double? baseFare;
  final double? tax;
  final double? tollFee;
  final double? totalBilledAmount;
  final double? amountPaid;
  final double? balanceToBePaid;

  const VehicleAndBillDetailsWidget({
    super.key,
    this.vehicleMakeModel,
    this.vehicleNumber,
    this.vehicleSeats,
    this.baseFare,
    this.tax,
    this.tollFee,
    this.totalBilledAmount,
    this.amountPaid,
    this.balanceToBePaid,
  });

  @override
  Widget build(BuildContext context) {
    final vehicleDetails = [
      if (vehicleMakeModel != null &&
          vehicleNumber != null &&
          vehicleSeats != null)
        Text("$vehicleMakeModel  |  $vehicleNumber  |  $vehicleSeats Seater")
      else
        const Text("Vehicle details not available"),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Vehicle Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ...vehicleDetails,
        const SizedBox(height: 8),
        const Text(
          "Bill Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        PriceRowWidget(
          "Estimated base fare",
          baseFare != null ? "₹${baseFare!.toStringAsFixed(0)}" : "-",
        ),
        PriceRowWidget(
          "Tax",
          tax != null ? "₹${tax!.toStringAsFixed(0)}" : "-",
        ),
        PriceRowWidget(
          "Toll Fee",
          tollFee != null ? "₹${tollFee!.toStringAsFixed(0)}" : "-",
        ),
        const Divider(),
        PriceRowWidget(
          "Total Billed Amount",
          totalBilledAmount != null
              ? "₹${totalBilledAmount!.toStringAsFixed(0)}"
              : "-",
          bold: true,
        ),
        PriceRowWidget(
          "Amount Paid",
          amountPaid != null ? "₹${amountPaid!.toStringAsFixed(0)}" : "-",
        ),
        PriceRowWidget(
          "Balance to be paid",
          balanceToBePaid != null
              ? "₹${balanceToBePaid!.toStringAsFixed(0)}"
              : "-",
          color: Colors.red,
        ),
      ],
    );
  }
}
