class ApiEndpoints {
  // For Android emulator use 10.0.2.2, for real device use your machine's IP
  // static const String baseUrl = 'http://10.0.2.2:5000/api';
    static const String baseUrl = 'http://192.168.1.66:5000/api';
  static const String serverUrl = 'http://192.168.1.66:5000';

  // Auth
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String profile = '$baseUrl/auth/profile';
  static String updateUser(String id) => '$baseUrl/auth/$id';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String resetPassword = '$baseUrl/auth/reset-password';

  // OTP
  static const String otpRequest = '$baseUrl/otp/request';
  static const String otpVerify = '$baseUrl/otp/verify';

  // Public Products
  static const String products = '$baseUrl/products';
  static const String deals = '$baseUrl/products/deals';
  static String productById(String id) => '$baseUrl/products/$id';

  // Orders
  static const String orders = '$baseUrl/orders';
  static const String initiatePayment = '$baseUrl/orders/payment/initiate';
  static const String verifyPayment = '$baseUrl/orders/payment/verify';

  // Reviews
  static String reviews(String productId) => '$baseUrl/reviews/$productId';
  static String reviewById(String reviewId) => '$baseUrl/reviews/$reviewId';

  // Chat
  static const String chat = '$baseUrl/chat';
  static const String chatUnread = '$baseUrl/chat/unread';
  static String chatById(String id) => '$baseUrl/chat/$id';
  static String chatMessages(String id) => '$baseUrl/chat/$id/messages';
  static String chatMarkRead(String id) => '$baseUrl/chat/$id/read';

  // Image URL helper
  static String imageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    if (imagePath.startsWith('/')) return '$serverUrl$imagePath';
    return '$serverUrl/$imagePath';
  }
}
