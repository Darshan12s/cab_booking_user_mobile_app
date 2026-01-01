# Trip Management System with Supabase Integration

This is a complete Flutter trip management system with Supabase backend integration, organized following proper Flutter architecture patterns.

## Project Structure

```
lib/
├── models/
│   └── trip_model.dart           # Data models (Trip, Driver, Vehicle, BillDetails)
├── routes/
│   └── trip_routes.dart          # Navigation route definitions
├── screens/
│   ├── my_trip_screen_new.dart   # Main trip screen with tabs
│   ├── confirmed_trip_screen.dart # Confirmed trips screen
│   ├── pending_trip_screen.dart   # Pending trips screen
│   ├── cancelled_trip_screen.dart # Cancelled trips screen
│   └── completed_trip_screen.dart # Completed trips screen
├── widgets/
│   ├── trip_card.dart            # Trip display card widget
│   ├── driver_card.dart          # Driver information widget
│   ├── trip_details_widget.dart  # Trip details display
│   ├── vehicle_and_bill_details.dart # Vehicle and billing info
│   └── rating_widget.dart        # Rating/feedback widget
├── services/
│   └── trip_service.dart         # Supabase integration service
├── examples/
│   └── trip_service_integration_example.dart # Usage examples
└── database/
    └── trip_supabase_schema.sql  # Complete database schema
```

## Features

### 🚗 Trip Management
- Create, update, cancel trips
- Real-time trip status tracking
- Trip history and statistics
- GPS coordinate tracking

### 👤 Driver Management
- Driver profiles with ratings
- Vehicle information
- Availability tracking
- Performance metrics

### 💰 Billing & Payments
- Automatic fare calculation
- GST calculation (18%)
- Trip cost breakdown
- Payment tracking

### ⭐ Rating & Feedback
- Trip rating system
- Driver feedback
- Issue reporting
- Review management

### 📱 Real-time Features
- Live trip updates via Supabase subscriptions
- Real-time driver location tracking
- Instant notifications
- Status change updates

## Database Schema

The system uses 6 main tables:

1. **drivers** - Driver profiles and information
2. **vehicles** - Vehicle details linked to drivers
3. **trips** - Main trip records with all details
4. **trip_feedback** - User ratings and reviews
5. **trip_issues** - Problem reports and resolution
6. **trip_tracking** - GPS tracking points

## Setup Instructions

### 1. Supabase Setup

1. Create a new Supabase project at [supabase.com](https://supabase.com)
2. Execute the SQL schema from `database/trip_supabase_schema.sql`
3. Enable Row Level Security (RLS) for all tables
4. Copy your project URL and anon key

### 2. Flutter Configuration

1. Add Supabase dependency to `pubspec.yaml`:
```yaml
dependencies:
  supabase_flutter: ^2.3.4
```

2. Initialize Supabase in your `main.dart`:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

### 3. Authentication Setup

The service requires user authentication. Set up Supabase Auth:

```dart
// Sign in user
await Supabase.instance.client.auth.signInWithPassword(
  email: 'user@example.com',
  password: 'password',
);
```

## Usage Examples

### Creating a Trip
```dart
final tripId = await TripService.createTrip(
  pickup: "Airport Terminal 1",
  drop: "City Center Mall",
  pickupLatitude: "28.5562",
  pickupLongitude: "77.1000",
  dropLatitude: "28.6139",
  dropLongitude: "77.2090",
  scheduledTime: DateTime.now().add(Duration(hours: 1)),
  notes: "Please call when you arrive",
);
```

### Loading Trips
```dart
// Get current active trips
final currentTrips = await TripService.getCurrentTrips();

// Get trip history
final pastTrips = await TripService.getPastTrips();
```

### Real-time Updates
```dart
// Subscribe to trip updates
StreamBuilder<Trip?>(
  stream: TripService.subscribeToTrip(tripId),
  builder: (context, snapshot) {
    final trip = snapshot.data;
    return Text('Status: ${trip?.status}');
  },
);
```

### Rating and Feedback
```dart
await TripService.submitRating(
  tripId: tripId,
  rating: 4.5,
  comment: "Great service!",
);
```

### Trip Statistics
```dart
final stats = await TripService.getTripStatistics();
print('Total trips: ${stats['total_trips']}');
print('Total spent: ₹${stats['total_spent']}');
```

## API Reference

### TripService Methods

#### Trip Operations
- `getCurrentTrips([userId])` - Get active trips
- `getPastTrips([userId])` - Get completed/cancelled trips
- `getTripById(tripId)` - Get specific trip details
- `createTrip({...})` - Create new trip booking
- `cancelTrip(tripId, reason)` - Cancel existing trip
- `updateTripStatus(tripId, status)` - Update trip status

#### Driver Operations
- `getAvailableDrivers({...})` - Find nearby drivers
- `submitRating({...})` - Rate driver/trip
- `reportIssue({...})` - Report problems

#### Analytics
- `getTripStatistics([userId])` - Get user trip analytics
- `getTripTracking(tripId)` - Get GPS tracking data
- `addTrackingPoint({...})` - Add GPS coordinates

#### Real-time Subscriptions
- `subscribeToUserTrips([userId])` - Stream user trips
- `subscribeToTrip(tripId)` - Stream specific trip

#### Utilities
- `isUserAuthenticated()` - Check auth status
- `signOut()` - Sign out user

## Data Models

### Trip
- Complete trip information including pickup/drop locations
- Fare calculation with GST
- Status tracking and timestamps
- Driver and vehicle associations

### Driver
- Profile information with ratings
- Contact details and availability
- Performance metrics
- Vehicle associations

### Vehicle
- Vehicle specifications and details
- License plate and registration
- Capacity and type information

### BillDetails
- Fare breakdown and calculations
- Tax information
- Payment status tracking

## Security Features

- Row Level Security (RLS) enabled
- User-based data isolation
- Authenticated API access only
- Secure data validation

## Error Handling

All service methods include comprehensive error handling:
- Network connectivity issues
- Authentication failures
- Data validation errors
- Supabase service errors

## Testing

Use the provided example file `trip_service_integration_example.dart` to test all functionality:
- Create test trips
- Monitor real-time updates
- Test rating system
- Verify data persistence

## Performance Optimization

- Efficient database queries with proper indexing
- Real-time subscriptions for live updates
- Lazy loading for large datasets
- Optimized JSON serialization

## Contributing

When adding new features:
1. Follow the existing folder structure
2. Add proper error handling
3. Include JSON serialization
4. Update database schema if needed
5. Add usage examples

## Support

For issues and questions:
1. Check the example integration file
2. Verify Supabase configuration
3. Ensure proper authentication setup
4. Review database permissions

---

**Note**: This is a production-ready trip management system with complete Supabase integration. All files are properly organized following Flutter best practices and include comprehensive error handling, real-time features, and proper data modeling.
