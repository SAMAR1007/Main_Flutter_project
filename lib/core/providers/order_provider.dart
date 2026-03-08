import 'package:flutter/foundation.dart';
import '../../data/models/order_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

class OrderProvider extends ChangeNotifier {
  final ApiClient apiClient;

  OrderProvider({required this.apiClient});

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Create a new order
  Future<OrderModel?> createOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> shippingAddress,
    String paymentMethod = 'cash_on_delivery',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await apiClient.post(
        endpoint: ApiEndpoints.orders,
        body: {
          'items': items,
          'shippingAddress': shippingAddress,
          'paymentMethod': paymentMethod,
        },
      );

      final order = OrderModel.fromJson(response['data']);
      _orders.insert(0, order);
      notifyListeners();
      return order;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      if (kDebugMode) {
        print('Create Order Error: $e');
      }
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch user's orders
  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await apiClient.get(
        endpoint: ApiEndpoints.orders,
      );

      final data = response['data'] as List<dynamic>;
      _orders = data.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      if (kDebugMode) {
        print('Fetch Orders Error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Initiate eSewa payment — returns formUrl + formData from backend
  Future<Map<String, dynamic>?> initiateEsewaPayment({
    required String orderId,
    required double amount,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await apiClient.post(
        endpoint: ApiEndpoints.initiatePayment,
        body: {
          'orderId': orderId,
          'amount': amount,
          'successUrl': 'https://techhive.app/checkout/success',
          'failureUrl': 'https://techhive.app/checkout/failure',
        },
      );
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      if (kDebugMode) {
        print('Initiate eSewa Payment Error: $e');
      }
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verify eSewa payment after redirect
  Future<bool> verifyEsewaPayment({
    required String orderId,
    required String encodedData,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await apiClient.post(
        endpoint: ApiEndpoints.verifyPayment,
        body: {
          'orderId': orderId,
          'encodedData': encodedData,
          'transactionId': '',
          'status': 'completed',
        },
      );

      // Refresh orders after successful payment
      await fetchOrders();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      if (kDebugMode) {
        print('Verify eSewa Payment Error: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
