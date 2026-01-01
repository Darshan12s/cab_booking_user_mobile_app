// models/booking_model.dart
class Booking {
  final String? id;
  final String userId;
  final String? driverId;
  final String? vehicleId;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final String pickupAddress;
  final String dropoffAddress;
  final double? fareAmount;
  final double? distanceKm;
  final String rideType;
  final DateTime startTime;
  final DateTime? endTime;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? serviceTypeId;
  final String? rentalPackageId;
  final String? zonePricingId;
  final DateTime? scheduledTime;
  final bool isScheduled;
  final bool isShared;
  final String? sharingGroupId;
  final int? totalStops;
  final int? packageHours;
  final int? includedKm;
  final double? extraKmUsed;
  final double? extraHoursUsed;
  final int? waitingTimeMinutes;
  final String? cancellationReason;
  final String? noShowReason;
  final double? upgradeCharges;
  final String? pickupLocationId;
  final String? dropoffLocationId;
  final bool? isRoundTrip;
  final DateTime? returnScheduledTime;
  final String? tripType;
  final String? vehicleType;
  final String? specialInstructions;
  final double? advanceAmount;
  final double? remainingAmount;

  Booking({
    this.id,
    required this.userId,
    this.driverId,
    this.vehicleId,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    required this.pickupAddress,
    required this.dropoffAddress,
    this.fareAmount,
    this.distanceKm,
    required this.rideType,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
    this.serviceTypeId,
    this.rentalPackageId,
    this.zonePricingId,
    this.scheduledTime,
    required this.isScheduled,
    required this.isShared,
    this.sharingGroupId,
    this.totalStops,
    this.packageHours,
    this.includedKm,
    this.extraKmUsed,
    this.extraHoursUsed,
    this.waitingTimeMinutes,
    this.cancellationReason,
    this.noShowReason,
    this.upgradeCharges,
    this.pickupLocationId,
    this.dropoffLocationId,
    this.isRoundTrip,
    this.returnScheduledTime,
    this.tripType,
    this.vehicleType,
    this.specialInstructions,
    this.advanceAmount,
    this.remainingAmount,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      userId: map['user_id'],
      driverId: map['driver_id'],
      vehicleId: map['vehicle_id'],
      pickupLatitude: map['pickup_latitude']?.toDouble(),
      pickupLongitude: map['pickup_longitude']?.toDouble(),
      dropoffLatitude: map['dropoff_latitude']?.toDouble(),
      dropoffLongitude: map['dropoff_longitude']?.toDouble(),
      pickupAddress: map['pickup_address'],
      dropoffAddress: map['dropoff_address'],
      fareAmount: map['fare_amount']?.toDouble(),
      distanceKm: map['distance_km']?.toDouble(),
      rideType: map['ride_type'],
      startTime: DateTime.parse(map['start_time']),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      status: map['status'],
      paymentStatus: map['payment_status'],
      paymentMethod: map['payment_method'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      serviceTypeId: map['service_type_id'],
      rentalPackageId: map['rental_package_id'],
      zonePricingId: map['zone_pricing_id'],
      scheduledTime: map['scheduled_time'] != null
          ? DateTime.parse(map['scheduled_time'])
          : null,
      isScheduled: map['is_scheduled'],
      isShared: map['is_shared'],
      sharingGroupId: map['sharing_group_id'],
      totalStops: map['total_stops'],
      packageHours: map['package_hours'],
      includedKm: map['included_km'],
      extraKmUsed: map['extra_km_used']?.toDouble(),
      extraHoursUsed: map['extra_hours_used']?.toDouble(),
      waitingTimeMinutes: map['waiting_time_minutes'],
      cancellationReason: map['cancellation_reason'],
      noShowReason: map['no_show_reason'],
      upgradeCharges: map['upgrade_charges']?.toDouble(),
      pickupLocationId: map['pickup_location_id'],
      dropoffLocationId: map['dropoff_location_id'],
      isRoundTrip: map['is_round_trip'],
      returnScheduledTime: map['return_scheduled_time'] != null
          ? DateTime.parse(map['return_scheduled_time'])
          : null,
      tripType: map['trip_type'],
      vehicleType: map['vehicle_type'],
      specialInstructions: map['special_instructions'],
      advanceAmount: map['advance_amount']?.toDouble(),
      remainingAmount: map['remaining_amount']?.toDouble(),
    );
  }

  String get date => startTime.toLocal().toString().split(' ')[0];

  String get time => startTime.toLocal().toString().split(' ')[1];

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'driver_id': driverId,
      'vehicle_id': vehicleId,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'dropoff_latitude': dropoffLatitude,
      'dropoff_longitude': dropoffLongitude,
      'pickup_address': pickupAddress,
      'dropoff_address': dropoffAddress,
      'fare_amount': fareAmount,
      'distance_km': distanceKm,
      'ride_type': rideType,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'status': status,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'service_type_id': serviceTypeId,
      'rental_package_id': rentalPackageId,
      'zone_pricing_id': zonePricingId,
      'scheduled_time': scheduledTime?.toIso8601String(),
      'is_scheduled': isScheduled,
      'is_shared': isShared,
      'sharing_group_id': sharingGroupId,
      'total_stops': totalStops,
      'package_hours': packageHours,
      'included_km': includedKm,
      'extra_km_used': extraKmUsed,
      'extra_hours_used': extraHoursUsed,
      'waiting_time_minutes': waitingTimeMinutes,
      'cancellation_reason': cancellationReason,
      'no_show_reason': noShowReason,
      'upgrade_charges': upgradeCharges,
      'pickup_location_id': pickupLocationId,
      'dropoff_location_id': dropoffLocationId,
      'is_round_trip': isRoundTrip,
      'return_scheduled_time': returnScheduledTime?.toIso8601String(),
      'trip_type': tripType,
      'vehicle_type': vehicleType,
      'special_instructions': specialInstructions,
      'advance_amount': advanceAmount,
      'remaining_amount': remainingAmount,
    };
  }
}
