// widgets/car_info_card.dart
import 'package:flutter/material.dart';
import '../models/car.dart';

class CarInfoCard extends StatelessWidget {
  final Car car;

  const CarInfoCard({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double imageWidth = constraints.maxWidth < 350 ? 70 : constraints.maxWidth < 500 ? 90 : 120;
        double imageHeight = constraints.maxWidth < 350 ? 50 : constraints.maxWidth < 500 ? 70 : 100;
        double titleFont = constraints.maxWidth < 350 ? 14 : constraints.maxWidth < 500 ? 16 : 20;
        double priceFont = constraints.maxWidth < 350 ? 15 : constraints.maxWidth < 500 ? 18 : 24;
        double spacing = constraints.maxWidth < 350 ? 6 : constraints.maxWidth < 500 ? 10 : 16;
        double infoFont = constraints.maxWidth < 350 ? 10 : constraints.maxWidth < 500 ? 12 : 14;
        double labelFont = constraints.maxWidth < 350 ? 11 : constraints.maxWidth < 500 ? 13 : 15;
        return Card(
          child: Padding(
            padding: EdgeInsets.all(spacing),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: spacing,
                        runSpacing: 2,
                        children: [
                          Text(
                            car.modelName,
                            style: TextStyle(fontSize: titleFont, fontWeight: FontWeight.bold),
                          ),
                          Text(car.bodyType, style: TextStyle(fontSize: labelFont)),
                          Text(car.distance, style: TextStyle(fontSize: labelFont)),
                          Text(car.extraCostPerKm, style: TextStyle(fontSize: labelFont)),
                        ],
                      ),
                      SizedBox(height: spacing),
                      Text(
                        car.serviceType,
                        style: TextStyle(color: Colors.green, fontSize: infoFont, fontWeight: FontWeight.w600),
                      ),
                      Text(car.serviceDetails, style: TextStyle(fontSize: infoFont)),
                      SizedBox(height: spacing),
                      Text(
                        car.price,
                        style: TextStyle(fontSize: priceFont, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: spacing),
                Image.network(
                  car.imageUrl,
                  width: imageWidth,
                  height: imageHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.car_repair, size: imageWidth * 0.7),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
