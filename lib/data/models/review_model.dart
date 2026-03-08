class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    String userId;
    if (user is String) {
      userId = user;
    } else if (user is Map<String, dynamic>) {
      userId = user['_id'] ?? '';
    } else {
      userId = '';
    }

    final product = json['product'];
    String productId;
    if (product is String) {
      productId = product;
    } else if (product is Map<String, dynamic>) {
      productId = product['_id'] ?? '';
    } else {
      productId = '';
    }

    return ReviewModel(
      id: json['_id'] ?? json['id'] ?? '',
      productId: productId,
      userId: userId,
      userName: json['userName'] ?? '',
      rating: (json['rating'] ?? 0).toInt(),
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
    };
  }
}
