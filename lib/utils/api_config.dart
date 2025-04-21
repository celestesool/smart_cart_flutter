// lib/utils/api_config.dart

const String apiBaseURL = "http://192.168.0.12:5000";

Map<String, String> headersWithToken(String token) => {
      "Authorization": "Bearer $token",
    };
