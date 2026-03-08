class MessageSender {
  final String id;
  final String name;
  final String? image;
  final String? role;

  MessageSender({
    required this.id,
    required this.name,
    this.image,
    this.role,
  });

  factory MessageSender.fromJson(Map<String, dynamic> json) {
    return MessageSender(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'],
      role: json['role'],
    );
  }
}

class MessageModel {
  final String id;
  final MessageSender? sender;
  final String senderId;
  final String senderRole;
  final String content;
  final DateTime? readAt;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    this.sender,
    required this.senderId,
    required this.senderRole,
    required this.content,
    this.readAt,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // sender can be a populated object or just an ID string
    MessageSender? sender;
    String senderId;
    if (json['sender'] is Map<String, dynamic>) {
      sender = MessageSender.fromJson(json['sender']);
      senderId = sender.id;
    } else {
      senderId = json['sender']?.toString() ?? '';
    }

    return MessageModel(
      id: json['_id'] ?? json['id'] ?? '',
      sender: sender,
      senderId: senderId,
      senderRole: json['senderRole'] ?? 'user',
      content: json['content'] ?? '',
      readAt: json['readAt'] != null ? DateTime.tryParse(json['readAt']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class ConversationUser {
  final String id;
  final String name;
  final String? email;
  final String? image;

  ConversationUser({
    required this.id,
    required this.name,
    this.email,
    this.image,
  });

  factory ConversationUser.fromJson(Map<String, dynamic> json) {
    return ConversationUser(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      image: json['image'],
    );
  }
}

class ConversationProduct {
  final String id;
  final String name;
  final double price;
  final String? image;
  final String? category;

  ConversationProduct({
    required this.id,
    required this.name,
    required this.price,
    this.image,
    this.category,
  });

  factory ConversationProduct.fromJson(Map<String, dynamic> json) {
    return ConversationProduct(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'],
      category: json['category'],
    );
  }
}

class ConversationModel {
  final String id;
  final ConversationUser? user;
  final ConversationProduct? product;
  final String subject;
  final List<MessageModel> messages;
  final String status;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConversationModel({
    required this.id,
    this.user,
    this.product,
    required this.subject,
    required this.messages,
    required this.status,
    this.lastMessage,
    this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['_id'] ?? json['id'] ?? '',
      user: json['user'] is Map<String, dynamic>
          ? ConversationUser.fromJson(json['user'])
          : null,
      product: json['product'] is Map<String, dynamic>
          ? ConversationProduct.fromJson(json['product'])
          : null,
      subject: json['subject'] ?? '',
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status'] ?? 'active',
      lastMessage: json['lastMessage'],
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  bool get isActive => status == 'active';
}
