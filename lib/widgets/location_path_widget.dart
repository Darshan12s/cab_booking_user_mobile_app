import 'package:flutter/material.dart';

class LocationPathWidget extends StatelessWidget {
  final String pickupName;
  final String pickupAddress;
  final String dropoffName;
  final String dropoffAddress;

  const LocationPathWidget({
    super.key,
    required this.pickupName,
    required this.pickupAddress,
    required this.dropoffName,
    required this.dropoffAddress,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double iconColumnWidth = constraints.maxWidth < 350 ? 20 : 32;
        double spacing = constraints.maxWidth < 400 ? 8 : 16;
        double iconSize = constraints.maxWidth < 350 ? 16 : 24;
        double dotSize = constraints.maxWidth < 350 ? 3 : 6;
        double textFont = constraints.maxWidth < 350 ? 12 : 16;
        double addressFont = constraints.maxWidth < 350 ? 10 : 14;
        double verticalGap = constraints.maxWidth < 350 ? 16 : 32;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: iconColumnWidth,
              child: Column(
                children: [
                  Icon(Icons.location_on, color: Colors.green, size: iconSize),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (i) => Container(
                        margin: EdgeInsets.symmetric(vertical: dotSize / 2),
                        width: dotSize,
                        height: dotSize,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.location_on_outlined,
                    color: Colors.green,
                    size: iconSize,
                  ),
                ],
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pickupName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: textFont,
                          ),
                        ),
                        Text(
                          pickupAddress,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: addressFont,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: verticalGap),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dropoffName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: textFont,
                          ),
                        ),
                        Text(
                          dropoffAddress,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: addressFont,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
