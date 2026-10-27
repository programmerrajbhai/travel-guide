class ApiConfig {
  // OpenWeatherMap API Key (বিনামূল্যে সাইনআপ করে নিতে পারবেন)
  static const String weatherApiKey = '5d8a1371933e4197b91c471c35534186';
  static const String weatherBaseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  // Google Places API Key (Nearby Masjid ও Geocoding এর জন্য)
  static const String googleApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  static const String googlePlacesUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
 static const String googleGeocodingUrl = 'https://maps.googleapis.com/maps/api/geocode/json';
}