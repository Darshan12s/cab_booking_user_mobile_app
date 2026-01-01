// config/api_config.dart
class ApiConfig {
  // Google Places API Configuration
  // Get your API key from: https://console.cloud.google.com/apis/library/places-backend.googleapis.com
  // Make sure to enable the following APIs:
  // 1. Places API
  // 2. Geocoding API
  // 3. Maps JavaScript API (if using web)

  static const String googlePlacesApiKey =
      "AIzaSyA7sn0fs6f0vRDm3RIkRKn_R-haAgH4M0A";

  // Alternative: Load from environment variables (recommended for production)
  // static const String googlePlacesApiKey = String.fromEnvironment('GOOGLE_PLACES_API_KEY');

  static const String placesApiUrl =
      "https://maps.googleapis.com/maps/api/place";

  // Validate if API key is set
  static bool get isApiKeyConfigured =>
      googlePlacesApiKey.isNotEmpty && googlePlacesApiKey.length > 20;
}
