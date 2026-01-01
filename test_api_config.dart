// test_api_config.dart
// Quick test to verify API configuration
import 'lib/config/api_config.dart';

void main() {
  print('API Key configured: ${ApiConfig.isApiKeyConfigured}');
  print('API Key length: ${ApiConfig.googlePlacesApiKey.length}');
  print('Places API URL: ${ApiConfig.placesApiUrl}');

  if (ApiConfig.isApiKeyConfigured) {
    print('✅ API key is properly configured');
  } else {
    print('❌ API key needs to be configured');
  }
}
