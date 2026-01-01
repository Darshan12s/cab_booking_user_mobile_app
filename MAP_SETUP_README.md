# Map Integration Setup Guide

This guide will help you set up the map functionality with live tracking using Flutter, Google Maps, and Supabase.

## Prerequisites

1. **Google Maps API Key**
2. **Supabase Account**
3. **Flutter Development Environment**

## Setup Instructions

### 1. Google Maps Setup

#### Get Google Maps API Key:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API
   - Geocoding API
4. Create credentials (API Key)
5. Restrict the API key to your app (optional but recommended)

#### Configure Android:
1. Open `android/app/src/main/AndroidManifest.xml`
2. Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyBXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" />
```

#### Configure iOS:
1. Open `ios/Runner/AppDelegate.swift`
2. Add your API key:
```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 2. Supabase Setup

#### Create Supabase Project:
1. Go to [Supabase](https://supabase.com)
2. Create a new project
3. Get your project URL and anon key from Settings > API

#### Configure Supabase:
1. Open `lib/config/supabase_config.dart`
2. Replace the placeholders with your actual values:
```dart
static const String supabaseUrl = 'https://xxxxxxxxxxxxx.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

#### Create Database Tables:
Run this SQL in your Supabase SQL editor:

```sql
-- User locations table
CREATE TABLE user_locations (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  address TEXT NOT NULL,
  location_type VARCHAR(20) DEFAULT 'saved',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Live locations table for real-time tracking
CREATE TABLE live_locations (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id),
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Places table (optional - for cached place data)
CREATE TABLE places (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  place_type VARCHAR(50),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE user_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE live_locations ENABLE ROW LEVEL SECURITY;

-- Policies for user_locations
CREATE POLICY "Users can view own locations" ON user_locations
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own locations" ON user_locations
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own locations" ON user_locations
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own locations" ON user_locations
  FOR DELETE USING (auth.uid() = user_id);

-- Policies for live_locations
CREATE POLICY "Users can view own live location" ON live_locations
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can upsert own live location" ON live_locations
  FOR ALL USING (auth.uid() = user_id);
```

### 3. Install Dependencies

Run the following command to install all required packages:

```bash
flutter pub get
```

### 4. Permissions Setup

The permissions are already configured in the AndroidManifest.xml:
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`
- `ACCESS_BACKGROUND_LOCATION`
- `INTERNET`

For iOS, add these to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to show your current position on the map.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to provide live tracking features.</string>
```

### 5. Usage Examples

#### Basic Map Screen:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const MapScreen(
      title: 'Choose Location',
    ),
  ),
);
```

#### Live Tracking Map:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const LiveTrackingMapScreen(
      title: 'Live Tracking',
      userId: 'user123',
      enableLiveTracking: true,
    ),
  ),
);
```

#### Save Location to Supabase:
```dart
await LocationService.saveUserLocation(
  userId: 'user123',
  latitude: 12.9716,
  longitude: 77.5946,
  address: 'Bangalore, Karnataka',
  locationType: 'saved',
);
```

## Features

✅ **Basic Map Display**
✅ **Current Location Detection**
✅ **Location Search**
✅ **Address Geocoding**
✅ **Live Location Tracking**
✅ **Real-time Location Updates**
✅ **Supabase Integration**
✅ **Location History**
✅ **Route Tracking with Polylines**
✅ **Permission Handling**

## Troubleshooting

### Common Issues:

1. **Maps not loading**: Check your API key and make sure the required APIs are enabled
2. **Location permission denied**: The app will fallback to a default location
3. **Supabase connection issues**: Check your URL and keys in the config file
4. **Build errors**: Run `flutter clean` and `flutter pub get`

### Debug Tips:

1. Check the console for error messages
2. Verify API keys are correctly set
3. Ensure location services are enabled on the device
4. Test on a physical device for location features

## Security Notes

- Never commit API keys to version control
- Use environment variables or secure config files for production
- Enable API key restrictions in Google Cloud Console
- Configure Row Level Security policies in Supabase properly

## Support

For additional help:
- [Flutter Documentation](https://flutter.dev/docs)
- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
- [Supabase Flutter Documentation](https://supabase.com/docs/reference/dart/introduction)
