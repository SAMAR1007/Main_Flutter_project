import 'package:flutter/foundation.dart';
import '../../data/models/conversation_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../services/socket_service.dart';

class ChatProvider extends ChangeNotifier {
  final ApiClient apiClient;
  final SocketService socketService;

  ChatProvider({
    required this.apiClient,
    required this.socketService,
  });

  // State
  ConversationModel? _currentConversation;
  List<ConversationModel> _conversations = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  int _unreadCount = 0;
  bool _adminTyping = false;

  // Getters
  ConversationModel? get currentConversation => _currentConversation;
  List<ConversationModel> get conversations => _conversations;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  bool get adminTyping => _adminTyping;

  /// Connect socket with the user's auth token.
  void connectSocket(String token) {
    socketService.connect(token);
    _setupSocketListeners();
  }

  /// Disconnect socket.
  void disconnectSocket() {
    socketService.removeAllListeners();
    socketService.disconnect();
  }

  void _setupSocketListeners() {
    socketService.onNewMessage((data) {
      if (data != null && data['conversationId'] != null) {
        if (_currentConversation != null &&
            data['conversationId'] == _currentConversation!.id) {
          // Refetch full conversation from API to get complete message data
          fetchConversation(_currentConversation!.id);
        }
      }
    });

    socketService.onConversationUpdated((data) {
      // Refresh conversations list when update notified
      fetchUnreadCount();
      if (_currentConversation != null &&
          data?['conversationId'] == _currentConversation!.id) {
        fetchConversation(_currentConversation!.id);
      }
    });

    socketService.onUserTyping((data) {
      if (data?['role'] == 'admin') {
        _adminTyping = data['isTyping'] == true;
        notifyListeners();
      }
    });
  }

  /// Start or get existing conversation for a product.
  Future<ConversationModel?> startOrGetConversation({
    required String productId,
    required String productName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Try to find an existing active conversation for this product
      await fetchConversations();
      final existing = _conversations.where(
        (c) => c.product?.id == productId && c.isActive,
      );
      if (existing.isNotEmpty) {
        await fetchConversation(existing.first.id);
        return _currentConversation;
      }

      // Create new conversation
      final response = await apiClient.post(
        endpoint: ApiEndpoints.chat,
        body: {
          'subject': 'Inquiry about $productName',
          'message': 'Hi, I have a question about $productName.',
          'productId': productId,
        },
      );

      final conversation = ConversationModel.fromJson(response['data']);
      _currentConversation = conversation;
      _conversations.insert(0, conversation);

      // Join socket room
      socketService.joinConversation(conversation.id);

      return conversation;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      if (kDebugMode) print('Start conversation error: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch a single conversation by ID.
  Future<void> fetchConversation(String conversationId) async {
    try {
      final response = await apiClient.get(
        endpoint: ApiEndpoints.chatById(conversationId),
      );

      _currentConversation = ConversationModel.fromJson(response['data']);

      // Join socket room
      socketService.joinConversation(conversationId);

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      if (kDebugMode) print('Fetch conversation error: $e');
      notifyListeners();
    }
  }

  /// Fetch all user conversations.
  Future<void> fetchConversations() async {
    try {
      final response = await apiClient.get(
        endpoint: ApiEndpoints.chat,
      );

      final data = response['data'] as List<dynamic>;
      _conversations = data
          .map((json) => ConversationModel.fromJson(json as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Fetch conversations error: $e');
    }
  }

  /// Send a message in the current conversation.
  Future<bool> sendMessage(String content) async {
    if (_currentConversation == null || content.trim().isEmpty) return false;

    _isSending = true;
    notifyListeners();

    try {
      final response = await apiClient.post(
        endpoint: ApiEndpoints.chatMessages(_currentConversation!.id),
        body: {'content': content.trim()},
      );

      final updated = ConversationModel.fromJson(response['data']);
      _currentConversation = updated;

      // Broadcast via socket
      final lastMsg = updated.messages.isNotEmpty ? updated.messages.last : null;
      if (lastMsg != null) {
        socketService.sendMessage(_currentConversation!.id, {
          '_id': lastMsg.id,
          'sender': lastMsg.senderId,
          'senderRole': lastMsg.senderRole,
          'content': lastMsg.content,
          'createdAt': lastMsg.createdAt.toIso8601String(),
          'conversation': {'user': updated.user?.id},
        });
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      if (kDebugMode) print('Send message error: $e');
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  /// Mark messages as read.
  Future<void> markAsRead(String conversationId) async {
    try {
      await apiClient.patch(
        endpoint: ApiEndpoints.chatMarkRead(conversationId),
      );
    } catch (e) {
      if (kDebugMode) print('Mark read error: $e');
    }
  }

  /// Fetch unread message count.
  Future<void> fetchUnreadCount() async {
    try {
      final response = await apiClient.get(
        endpoint: ApiEndpoints.chatUnread,
      );
      _unreadCount = response['data']?['count'] ?? 0;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Fetch unread count error: $e');
    }
  }

  /// Send typing indicator.
  void sendTyping(bool isTyping) {
    if (_currentConversation != null) {
      socketService.sendTyping(_currentConversation!.id, isTyping);
    }
  }

  /// Leave the current conversation room (when navigating away).
  void leaveCurrentConversation() {
    if (_currentConversation != null) {
      socketService.leaveConversation(_currentConversation!.id);
      _currentConversation = null;
      _adminTyping = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
