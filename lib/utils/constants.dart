import '../models/score_parameter.dart';

class Constants {
  // API Endpoints
  static const String mockApiEndpoint = 'https://webhook.site/YOUR_WEBHOOK_ID';
  static const String httpbinEndpoint = 'https://httpbin.org/post';

  // Form Keys
  static const String stationNameKey = 'station_name';
  static const String inspectionDateKey = 'inspection_date';
  static const String inspectorNameKey = 'inspector_name';

  // Storage Keys
  static const String formDataKey = 'form_data';
  static const String autoSaveKey = 'auto_save_data';

  // Score Options
  static const List<int> scoreOptions = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  // Form Sections Data
  static List<FormSection> getFormSections() {
    return [
      FormSection(
        id: 'platform_cleanliness',
        title: 'Platform Cleanliness',
        parameters: [
          ScoreParameter(
            id: 'platform_floor',
            name: 'Platform Floor',
            description: 'Cleanliness of platform floor surface',
          ),
          ScoreParameter(
            id: 'platform_roof',
            name: 'Platform Roof',
            description: 'Cleanliness of platform roof and overhead structures',
          ),
          ScoreParameter(
            id: 'platform_walls',
            name: 'Platform Walls',
            description: 'Cleanliness of platform walls and pillars',
          ),
          ScoreParameter(
            id: 'platform_seating',
            name: 'Platform Seating',
            description: 'Cleanliness of benches and seating areas',
          ),
        ],
      ),
      FormSection(
        id: 'toilet_facilities',
        title: 'Toilet Facilities',
        parameters: [
          ScoreParameter(
            id: 'mens_toilet',
            name: 'Men\'s Toilet',
            description: 'Cleanliness of men\'s toilet facilities',
          ),
          ScoreParameter(
            id: 'womens_toilet',
            name: 'Women\'s Toilet',
            description: 'Cleanliness of women\'s toilet facilities',
          ),
          ScoreParameter(
            id: 'urinals',
            name: 'Urinals',
            description: 'Cleanliness and maintenance of urinals',
          ),
          ScoreParameter(
            id: 'toilet_supplies',
            name: 'Toilet Supplies',
            description: 'Availability of soap, water, and toilet paper',
          ),
        ],
      ),
      FormSection(
        id: 'water_facilities',
        title: 'Water Facilities',
        parameters: [
          ScoreParameter(
            id: 'water_booths',
            name: 'Water Booths',
            description: 'Cleanliness and functionality of water booths',
          ),
          ScoreParameter(
            id: 'drinking_water',
            name: 'Drinking Water',
            description: 'Quality and cleanliness of drinking water facilities',
          ),
          ScoreParameter(
            id: 'water_storage',
            name: 'Water Storage',
            description: 'Cleanliness of water storage tanks and containers',
          ),
        ],
      ),
      FormSection(
        id: 'waste_management',
        title: 'Waste Management',
        parameters: [
          ScoreParameter(
            id: 'dustbins',
            name: 'Dustbins',
            description: 'Availability and cleanliness of dustbins',
          ),
          ScoreParameter(
            id: 'waste_segregation',
            name: 'Waste Segregation',
            description: 'Proper segregation of dry and wet waste',
          ),
          ScoreParameter(
            id: 'waste_collection',
            name: 'Waste Collection',
            description: 'Timely collection and disposal of waste',
          ),
        ],
      ),
      FormSection(
        id: 'station_premises',
        title: 'Station Premises',
        parameters: [
          ScoreParameter(
            id: 'entrance_exit',
            name: 'Entrance/Exit',
            description: 'Cleanliness of station entrance and exit areas',
          ),
          ScoreParameter(
            id: 'parking_area',
            name: 'Parking Area',
            description: 'Cleanliness and organization of parking areas',
          ),
          ScoreParameter(
            id: 'garden_landscaping',
            name: 'Garden/Landscaping',
            description: 'Maintenance of garden and landscaping areas',
          ),
          ScoreParameter(
            id: 'signage',
            name: 'Signage',
            description: 'Cleanliness and visibility of station signage',
          ),
        ],
      ),
      FormSection(
        id: 'food_stalls',
        title: 'Food Stalls & Vendors',
        parameters: [
          ScoreParameter(
            id: 'food_hygiene',
            name: 'Food Hygiene',
            description: 'Hygiene standards of food preparation areas',
          ),
          ScoreParameter(
            id: 'vendor_cleanliness',
            name: 'Vendor Cleanliness',
            description: 'Personal hygiene of food vendors',
          ),
          ScoreParameter(
            id: 'food_waste',
            name: 'Food Waste Management',
            description: 'Proper disposal of food waste and leftovers',
          ),
        ],
      ),
    ];
  }

  // Validation Messages
  static const String requiredFieldMessage = 'This field is required';
  static const String selectScoreMessage = 'Please select a score';
  static const String fillAllFieldsMessage = 'Please fill all required fields';
  static const String submissionSuccessMessage = 'Form submitted successfully!';
  static const String submissionErrorMessage = 'Error submitting form. Please try again.';

  // Rating Labels
  static Map<int, String> getRatingLabels() {
    return {
      0: 'Poor',
      1: 'Very Poor',
      2: 'Poor',
      3: 'Below Average',
      4: 'Below Average',
      5: 'Average',
      6: 'Above Average',
      7: 'Good',
      8: 'Very Good',
      9: 'Excellent',
      10: 'Outstanding',
    };
  }

  // Colors for scores
  static Map<int, String> getScoreColors() {
    return {
      0: '#FF0000', // Red
      1: '#FF3333',
      2: '#FF6666',
      3: '#FF9999',
      4: '#FFCC99',
      5: '#FFFF99', // Yellow
      6: '#CCFF99',
      7: '#99FF99',
      8: '#66FF99',
      9: '#33FF99',
      10: '#00FF00', // Green
    };
  }
}