import '../config/api_config.dart';

/// Service responsible for making HTTP calls to the backend.
///
/// Implement methods with Dio or another HTTP client as needed.
class ApiService {
  ApiService();

  String get baseUrl => apiBaseUrl;
}


