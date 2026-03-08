import 'package:flutter/foundation.dart';
import '../../data/models/order_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiClient apiClient;

  DashboardProvider({required this.apiClient});

  List<OrderModel> _orders = [];
  int _unreadChatCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  int get unreadChatCount => _unreadChatCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Computed stats
  int get totalOrders => _orders.length;
  int get pendingOrders => _orders.where((o) => o.status == 'pending').length;
  int get processingOrders => _orders.where((o) => o.status == 'processing').length;
  int get completedOrders => _orders.where((o) => o.status == 'completed').length;
  int get cancelledOrders => _orders.where((o) => o.status == 'cancelled').length;

  double get totalSpent => _orders
      .where((o) => o.status != 'cancelled' && o.paymentStatus == 'completed')
      .fold(0.0, (sum, o) => sum + o.totalAmount);

  int get totalItemsPurchased => _orders
      .where((o) => o.status != 'cancelled')
      .fold(0, (sum, o) => sum + o.items.fold(0, (s, i) => s + i.quantity));

  List<OrderModel> get recentOrders {
    final sorted = List<OrderModel>.from(_orders)
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime(2000);
        final bDate = b.createdAt ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });
    return sorted.take(5).toList();
  }

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        _fetchOrders(),
        _fetchUnreadCount(),
      ]);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      if (kDebugMode) print('Dashboard load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchOrders() async {
    try {
      final response = await apiClient.get(endpoint: ApiEndpoints.orders);
      final data = response['data'] as List<dynamic>;
      _orders = data.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) print('Dashboard fetch orders error: $e');
    }
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final response = await apiClient.get(endpoint: ApiEndpoints.chatUnread);
      _unreadChatCount = response['data']?['count'] ?? response['count'] ?? 0;
    } catch (e) {
      if (kDebugMode) print('Dashboard fetch unread error: $e');
    }
  }
}
