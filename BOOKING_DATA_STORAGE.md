# Booking Data Storage Documentation

## Overview
This document explains how all booking-related data is stored in the backend database using the `bookings` table schema. The system captures and stores comprehensive booking information including user selections, location details, timing, pricing, and special requests.

## Database Schema Fields Mapping

### Core Booking Information
- **id**: UUID (Primary Key) - Auto-generated unique identifier
- **user_id**: UUID - Current authenticated user's ID
- **driver_id**: UUID - Assigned driver's ID (null until assigned)
- **vehicle_id**: UUID - Assigned vehicle's ID (null until assigned)

### Location Information
- **pickup_latitude**: NUMERIC - Pickup location latitude coordinate
- **pickup_longitude**: NUMERIC - Pickup location longitude coordinate
- **dropoff_latitude**: NUMERIC - Dropoff location latitude coordinate
- **dropoff_longitude**: NUMERIC - Dropoff location longitude coordinate
- **pickup_address**: TEXT - User-selected pickup location address
- **dropoff_address**: TEXT - User-selected dropoff location address
- **pickup_location_id**: UUID - Reference to saved pickup location
- **dropoff_location_id**: UUID - Reference to saved dropoff location

### Trip Details
- **ride_type**: ENUM - Vehicle type (city, sedan, suv, premium)
- **trip_type**: TEXT - Trip category (one_way, round_trip, hourly, outstation)
- **vehicle_type**: TEXT - Vehicle type string
- **is_round_trip**: BOOLEAN - Whether it's a round trip booking
- **total_stops**: INT4 - Number of intermediate stops

### Timing Information
- **start_time**: TIMESTAMPTZ - Trip start time
- **end_time**: TIMESTAMPTZ - Trip end time (null until completed)
- **scheduled_time**: TIMESTAMPTZ - Scheduled pickup time
- **return_scheduled_time**: TIMESTAMPTZ - Return time for round trips
- **is_scheduled**: BOOLEAN - Whether booking is scheduled for future

### Package and Pricing
- **fare_amount**: NUMERIC - Total fare amount
- **distance_km**: NUMERIC - Trip distance in kilometers
- **advance_amount**: NUMERIC - 25% advance payment amount
- **remaining_amount**: NUMERIC - 75% remaining payment amount
- **upgrade_charges**: NUMERIC - Additional charges for special requests
- **service_type_id**: UUID - Reference to service type
- **rental_package_id**: UUID - Reference to rental package
- **zone_pricing_id**: UUID - Reference to zone pricing

### Package Details (for hourly rentals)
- **package_hours**: INT4 - Number of hours in package
- **included_km**: INT4 - Kilometers included in package
- **extra_km_used**: NUMERIC - Additional kilometers used
- **extra_hours_used**: NUMERIC - Additional hours used
- **waiting_time_minutes**: INT4 - Waiting time charges

### Booking Status
- **status**: ENUM - Booking status (pending, confirmed, in_progress, completed, cancelled)
- **payment_status**: ENUM - Payment status (pending, partial, completed, failed)
- **payment_method**: TEXT - Selected payment method

### Special Features
- **is_shared**: BOOLEAN - Whether it's a shared ride
- **sharing_group_id**: UUID - Group ID for shared rides
- **special_instructions**: TEXT - Special requests and instructions
- **passenger_count**: INT4 - Number of passengers (stored in related table)

### Cancellation and Issues
- **cancellation_reason**: TEXT - Reason for cancellation
- **no_show_reason**: TEXT - Reason for no-show

### Metadata
- **created_at**: TIMESTAMPTZ - Booking creation timestamp
- **updated_at**: TIMESTAMPTZ - Last update timestamp

## Data Flow in the Application

### 1. Initial Booking Creation (`_confirmBooking` method)
When user selects a vehicle and confirms booking:

```dart
final booking = Booking(
  userId: Supabase.instance.client.auth.currentUser?.id ?? '',
  pickupAddress: widget.pickupLocation,
  dropoffAddress: widget.dropoffLocation ?? '',
  rideType: vehicleTypeEnum,
  startTime: startTime,
  status: 'pending',
  paymentStatus: 'pending',
  paymentMethod: 'card',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  isScheduled: widget.bookingType == 'scheduled',
  isShared: widget.bookingType == 'shared',
  scheduledTime: scheduledTime,
  tripType: tripType,
  vehicleType: vehicleTypeEnum,
  fareAmount: baseFare,
  advanceAmount: advanceAmount,
  remainingAmount: remainingAmount,
  isRoundTrip: isRoundTrip,
  returnScheduledTime: returnScheduledTime,
  packageHours: packageHours,
  totalStops: 0,
  includedKm: null,
  extraKmUsed: 0.0,
  extraHoursUsed: 0.0,
  waitingTimeMinutes: 0,
  upgradeCharges: 0.0,
  specialInstructions: '',
);
```

### 2. Final Details Update (`_updateBookingWithFinalDetails` method)
When user confirms booking with special requests:

```dart
await _bookingService.updateBookingDetails(
  widget.bookingId.toString(),
  {
    'special_instructions': specialInstructions,
    'upgrade_charges': upgradeCharges,
    'fare_amount': _totalAmount - _discountAmount,
    'advance_amount': (_totalAmount - _discountAmount) * 0.25,
    'remaining_amount': (_totalAmount - _discountAmount) * 0.75,
    'updated_at': DateTime.now().toIso8601String(),
  },
);
```

## User Selections Stored

### Location Data
- **Pickup Location**: Stored in `pickup_address` and optionally `pickup_latitude`/`pickup_longitude`
- **Dropoff Location**: Stored in `dropoff_address` and optionally `dropoff_latitude`/`dropoff_longitude`
- **Location Coordinates**: Retrieved via Google Geocoding API (placeholder implementation)

### Date and Time
- **Selected Date**: Combined with selected time to create `scheduled_time`
- **Selected Time**: Used for `scheduled_time` and `start_time`
- **Return Date/Time**: For round trips, stored in `return_scheduled_time`

### Vehicle and Package
- **Vehicle Type**: Mapped to `ride_type` and `vehicle_type`
- **Package Selection**: Determines `package_hours` for hourly rentals
- **Booking Type**: Affects `is_scheduled`, `is_shared`, `trip_type`

### Passenger Information
- **Passenger Count**: Stored in related table or as `special_instructions`
- **Recipient Selection**: Can be stored as part of `special_instructions`

### Special Requests
- **Roof Carrier**: Stored in `special_instructions`
- **New Vehicle**: Stored in `special_instructions`
- **Additional Charges**: Calculated and stored in `upgrade_charges`

### Payment Information
- **Coupon Codes**: Applied discounts reflected in `fare_amount`
- **Payment Method**: Stored in `payment_method`
- **Advance/Remaining**: Split stored in respective fields

## Database Operations

### Creating a Booking
```dart
final createdBooking = await _bookingService.createBooking(booking);
```

### Updating Booking Details
```dart
await _bookingService.updateBookingDetails(bookingId, updateData);
```

### Fetching User Bookings
```dart
final userBookings = await _bookingService.getUserBookings(userId);
```

### Cancelling a Booking
```dart
await _bookingService.cancelBooking(bookingId, reason);
```

## Integration Points

### Location Services
- Google Places API for address autocomplete
- Google Geocoding API for coordinate conversion
- Real-time location tracking for live updates

### Payment Services
- Payment gateway integration for processing payments
- Payment status updates to booking record

### Notification Services
- Booking confirmation notifications
- Driver assignment notifications
- Trip status updates

## Data Validation

### Required Fields
- `user_id`, `pickup_address`, `dropoff_address`, `ride_type`, `start_time`, `status`, `payment_status`, `payment_method`, `created_at`, `updated_at`, `is_scheduled`, `is_shared`

### Optional Fields
- All other fields are optional and can be null initially, updated as booking progresses

### Data Types
- UUIDs for IDs and references
- NUMERIC for monetary amounts and coordinates
- TIMESTAMPTZ for all date/time fields
- TEXT for addresses and descriptions
- BOOLEAN for flags
- INT4 for counts and durations

## Security Considerations

### Row Level Security (RLS)
- Users can only access their own bookings
- Drivers can only access assigned bookings
- Admin access for all bookings

### Data Privacy
- Sensitive information encrypted at rest
- Location data anonymized where possible
- Payment information handled securely

## Future Enhancements

### Additional Fields
- Driver rating and feedback
- Trip photos and documents
- Insurance and liability information
- Corporate booking details

### Analytics
- Trip patterns and preferences
- Revenue and performance metrics
- Customer behavior analysis

This comprehensive data storage system ensures that all user selections and booking details are properly captured and stored in the backend database, providing a complete audit trail and enabling full booking management functionality.


