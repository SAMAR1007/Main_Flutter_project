import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../network/api_endpoints.dart';

/// Service that manages the Socket.IO connection for real-time chat.
class SocketService {
  io.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  io.Socket? get socket => _socket;

  /// Connect to Socket.IO server with JWT token auth.
  void connect(String token) {
    if (_socket != null && _isConnected) return;

    _socket = io.io(
      ApiEndpoints.serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionAttempts(10)
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      if (kDebugMode) print('[SocketService] Connected');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      if (kDebugMode) print('[SocketService] Disconnected');
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
      if (kDebugMode) print('[SocketService] Connection error: $error');
    });

    _socket!.onError((error) {
      if (kDebugMode) print('[SocketService] Error: $error');
    });

    _socket!.connect();
  }

  /// Disconnect from Socket.IO server.
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }

  /// Join a conversation room to receive real-time messages.
  void joinConversation(String conversationId) {
    _socket?.emit('join-conversation', conversationId);
  }

  /// Leave a conversation room.
  void leaveConversation(String conversationId) {
    _socket?.emit('leave-conversation', conversationId);
  }

  /// Emit a send-message event for real-time broadcast.
  void sendMessage(String conversationId, Map<String, dynamic> message) {
    _socket?.emit('send-message', {
      'conversationId': conversationId,
      'message': message,
    });
  }

  /// Emit typing indicator.
  void sendTyping(String conversationId, bool isTyping) {
    _socket?.emit('typing', {
      'conversationId': conversationId,
      'isTyping': isTyping,
    });
  }

  /// Listen for new messages in real-time.
  void onNewMessage(void Function(dynamic data) callback) {
    _socket?.on('new-message', callback);
  }

  /// Listen for conversation updates.
  void onConversationUpdated(void Function(dynamic data) callback) {
    _socket?.on('conversation-updated', callback);
  }

  /// Listen for typing indicators.
  void onUserTyping(void Function(dynamic data) callback) {
    _socket?.on('user-typing', callback);
  }

  /// Remove all listeners (cleanup).
  void removeAllListeners() {
    _socket?.off('new-message');
    _socket?.off('conversation-updated');
    _socket?.off('user-typing');
  }
}
