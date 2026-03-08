// Environment configuration
enum Environment { development, staging, production }

class Config {
  static const String appName = 'TechHive';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // Active environment
  static const Environment environment = Environment.development;

  // API Configuration
  static String get baseUrl {
    switch (environment) {
      case Environment.development:
        return 'http://192.168.1.100:3000/api/v1';
      case Environment.staging:
        return 'https://staging-api.techhive.com/api/v1';
      case Environment.production:
        return 'https://api.techhive.com/api/v1';
    }
  }

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;

  // Pagination
  static const int defaultPageSize = 20;

  // Cache
  static const int cacheDurationMinutes = 30;

  // NOTE: Change the IP address to your backend server IP address
  // For local development: 192.168.x.x (your machine IP on local network)
  // For emulator on Mac: http://10.0.2.2:3000/api/v1
  // For production: your actual server URL
}
