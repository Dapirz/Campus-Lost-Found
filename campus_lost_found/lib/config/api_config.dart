class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static const Duration timeout = Duration(seconds: 15);

  static Map<String, String> headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
