# Google Places API Setup Instructions

This app uses Google Places API to provide real-time location search and auto-suggestions. Follow these steps to set up the API:

## Step 1: Get Google Cloud Account
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one

## Step 2: Enable Required APIs
Enable the following APIs in your Google Cloud Console:
1. **Places API** - For location autocomplete
2. **Geocoding API** - For converting addresses to coordinates
3. **Maps SDK for Android** - If you're building for Android
4. **Maps SDK for iOS** - If you're building for iOS

## Step 3: Create API Key
1. Go to **APIs & Services > Credentials**
2. Click **Create Credentials > API Key**
3. Copy the generated API key

## Step 4: Secure Your API Key (Recommended)
1. Click on your API key to edit it
2. Add application restrictions:
   - **Android apps**: Add your package name and SHA-1 certificate fingerprint
   - **iOS apps**: Add your bundle identifier
3. Add API restrictions to limit usage to only the APIs you need

## Step 5: Configure the App
Replace `AIzaSyA7sn0fs6f0vRDm3RIkRKn_R-haAgH4M0AI_KEY` in `/lib/config/api_config.dart` with your actual API key:

```dart
static const String googlePlacesApiKey = "YOUR_ACTUAL_API_KEY_HERE";
```

## Step 6: Test the Implementation
1. Run the app
2. Navigate to the location search screen
3. Start typing a location name
4. You should see real-time suggestions from Google Places

## Features Included
- ✅ Real-time location autocomplete
- ✅ Debounced search (500ms delay to avoid excessive API calls)
- ✅ Fallback to local search if API fails
- ✅ Current location-based suggestions (when location permission is granted)
- ✅ Loading indicator during search
- ✅ Mix of local and API search results

## Troubleshooting
- **No suggestions appearing**: Check if your API key is correctly set and the Places API is enabled
- **API errors**: Check the console logs for specific error messages
- **Quota exceeded**: Monitor your API usage in Google Cloud Console

## Cost Optimization Tips
- The app uses a 500ms debounce to reduce API calls
- Search falls back to local results if API fails
- Consider implementing caching for frequently searched locations
- Monitor your usage in Google Cloud Console to avoid unexpected charges
