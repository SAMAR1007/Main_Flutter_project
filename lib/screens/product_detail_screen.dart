import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/di/service_locator.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/providers/cart_provider.dart';
import '../core/providers/wish_list_provider.dart';
import '../data/models/product_model.dart';
import '../data/models/review_model.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'chat_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductModel? _product;
  List<ReviewModel> _reviews = [];
  bool _isLoading = true;
  bool _isReviewsLoading = true;
  String? _error;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
    _fetchReviews();
  }

  Future<void> _fetchProduct() async {
    try {
      final apiClient = getIt<ApiClient>();
      final response = await apiClient.get(
        endpoint: ApiEndpoints.productById(widget.productId),
      );
      if (!mounted) return;
      setState(() {
        _product = ProductModel.fromJson(response['data']);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
      if (kDebugMode) print('Fetch product detail error: $e');
    }
  }

  Future<void> _fetchReviews() async {
    try {
      final apiClient = getIt<ApiClient>();
      final response = await apiClient.get(
        endpoint: ApiEndpoints.reviews(widget.productId),
      );
      if (!mounted) return;
      final data = response['data'] as List<dynamic>;
      setState(() {
        _reviews = data.map((json) => ReviewModel.fromJson(json)).toList();
        _isReviewsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isReviewsLoading = false;
      });
      if (kDebugMode) print('Fetch reviews error: $e');
    }
  }

  Future<void> _submitReview(int rating, String comment) async {
    try {
      final apiClient = getIt<ApiClient>();
      final response = await apiClient.post(
        endpoint: ApiEndpoints.reviews(widget.productId),
        body: {
          'rating': rating,
          'comment': comment,
        },
      );
      if (!mounted) return;

      // Refresh reviews list
      await _fetchReviews();
      // Also refresh product to update rating/review count
      await _fetchProduct();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
        ),
      );
      if (kDebugMode) print('Submit review error: $e');
    }
  }

  void _showReviewDialog() {
    int selectedRating = 5;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Write a Review',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Rating stars
                  Text(
                    'Your Rating',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () {
                          setModalState(() => selectedRating = i + 1);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            i < selectedRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 36,
                            color: Colors.amber[600],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  // Comment field
                  Text(
                    'Your Review',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    maxLength: 1000,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: 'Share your experience with this product...',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final comment = commentController.text.trim();
                              if (comment.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please write a comment'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              setModalState(() => isSubmitting = true);
                              Navigator.of(ctx).pop();
                              await _submitReview(selectedRating, comment);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isSubmitting ? 'Submitting...' : 'Submit Review',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Color> _getGradient(String category) {
    const map = {
      'Smartphones': [Color(0xFF0097A7), Color(0xFF4DD0E1)],
      'Laptops': [Color(0xFF0984E3), Color(0xFF74B9FF)],
      'Audio': [Color(0xFFE17055), Color(0xFFFAB1A0)],
      'Wearables': [Color(0xFF00B894), Color(0xFF55EFC4)],
      'Cameras': [Color(0xFFFDAC53), Color(0xFFFECB69)],
      'Gaming': [Color(0xFFE84393), Color(0xFFFD79A8)],
    };
    return map[category] ?? [const Color(0xFF0097A7), const Color(0xFF4DD0E1)];
  }

  IconData _getCategoryIcon(String category) {
    const icons = {
      'Smartphones': Icons.phone_android_rounded,
      'Laptops': Icons.laptop_mac_rounded,
      'Audio': Icons.headphones_rounded,
      'Wearables': Icons.watch_rounded,
      'Cameras': Icons.camera_alt_rounded,
      'Gaming': Icons.sports_esports_rounded,
    };
    return icons[category] ?? Icons.devices_rounded;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: _backButton(context),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_error != null || _product == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: _backButton(context),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Product not found',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _fetchProduct();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final product = _product!;
    final gradientColors = _getGradient(product.category);
    final categoryIcon = _getCategoryIcon(product.category);
    final hasImage = product.image != null && product.image!.isNotEmpty;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero image area
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: gradientColors[0],
            leading: _backButton(context, light: true),
            actions: [
              Consumer<WishListProvider>(
                builder: (context, wishListProvider, _) {
                  final isInWishList = wishListProvider.isInWishList(product.id);
                  return GestureDetector(
                    onTap: () {
                      wishListProvider.toggleWishList(
                        WishListItem(
                          id: product.id,
                          name: product.name,
                          price: product.discountedPrice,
                          imageUrl: product.imageUrl,
                          rating: product.rating,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isInWishList ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isInWishList ? Colors.red[300] : Colors.white,
                        size: 22,
                      ),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      gradientColors[0].withValues(alpha: 0.15),
                      gradientColors[1].withValues(alpha: 0.08),
                    ],
                  ),
                ),
                child: Center(
                  child: hasImage
                      ? Hero(
                          tag: 'product_${product.id}',
                          child: Image.network(
                            product.imageUrl,
                            width: 220,
                            height: 220,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              categoryIcon,
                              size: 120,
                              color: gradientColors[0].withValues(alpha: 0.6),
                            ),
                          ),
                        )
                      : Hero(
                          tag: 'product_${product.id}',
                          child: Icon(
                            categoryIcon,
                            size: 120,
                            color: gradientColors[0].withValues(alpha: 0.6),
                          ),
                        ),
                ),
              ),
            ),
          ),

          // Product details
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              transform: Matrix4.translationValues(0, -28, 0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & brand tags
                    Row(
                      children: [
                        _buildTag(product.category, gradientColors),
                        if (product.brand.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _buildTag(product.brand, [Colors.grey[600]!, Colors.grey[400]!]),
                        ],
                        if (product.isDeal && product.dealType != null) ...[
                          const SizedBox(width: 8),
                          _buildTag(
                            product.dealType!.toUpperCase(),
                            [Colors.orange[600]!, Colors.orange[400]!],
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Name
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Rating row
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          final filled = i < product.rating.floor();
                          final half = i == product.rating.floor() &&
                              product.rating - product.rating.floor() >= 0.5;
                          return Icon(
                            half
                                ? Icons.star_half_rounded
                                : filled
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                            size: 20,
                            color: Colors.amber[600],
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '${product.rating}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${product.reviews} ${product.reviews == 1 ? 'review' : 'reviews'})',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Price section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: gradientColors[0].withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: gradientColors[0].withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.isDeal && product.discountPercent > 0) ...[
                                Row(
                                  children: [
                                    Text(
                                      'Rs.${product.price.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[400],
                                        decoration: TextDecoration.lineThrough,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${product.discountPercent.toStringAsFixed(0)}% OFF',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.red[600],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                              ],
                              Text(
                                'Rs.${product.discountedPrice.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: gradientColors[0],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Quantity selector
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                _quantityButton(
                                  Icons.remove_rounded,
                                  () {
                                    if (_quantity > 1) {
                                      setState(() => _quantity--);
                                    }
                                  },
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    '$_quantity',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                _quantityButton(
                                  Icons.add_rounded,
                                  () => setState(() => _quantity++),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description
                    if (product.description.isNotEmpty) ...[
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Product info chips
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _infoChip(Icons.category_rounded, product.category),
                        if (product.brand.isNotEmpty)
                          _infoChip(Icons.business_rounded, product.brand),
                        if (product.isDeal)
                          _infoChip(Icons.local_offer_rounded, 'Deal'),
                        if (product.dealType != null)
                          _infoChip(
                              Icons.flash_on_rounded, product.dealType!),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Chat with Admin section
                    _buildChatSection(gradientColors),
                    const SizedBox(height: 24),

                    // Reviews section
                    _buildReviewsSection(gradientColors),

                    const SizedBox(height: 100), // bottom padding for FAB
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(product, gradientColors),
    );
  }

  Widget _buildTag(String label, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatSection(List<Color> gradientColors) {
    final isAuthenticated = context.read<AuthProvider>().isAuthenticated;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primaryLight.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Have a Question?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Chat with our team about this product',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (!isAuthenticated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please login to chat with admin'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      productId: _product!.id,
                      productName: _product!.name,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat_rounded, size: 18),
              label: Text(
                isAuthenticated ? 'Chat with Admin' : 'Login to Chat',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(List<Color> gradientColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Customer Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (_reviews.isNotEmpty)
              Text(
                '${_reviews.length} ${_reviews.length == 1 ? 'review' : 'reviews'}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        // Write a Review button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showReviewDialog,
            icon: const Icon(Icons.rate_review_outlined, size: 18),
            label: const Text('Write a Review'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (_isReviewsLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (_reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.rate_review_outlined, size: 40, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Text(
                  'No reviews yet',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Be the first to review this product',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          )
        else
          ...List.generate(
            _reviews.length > 5 ? 5 : _reviews.length,
            (i) => _buildReviewCard(_reviews[i], gradientColors),
          ),
      ],
    );
  }

  Widget _buildReviewCard(ReviewModel review, List<Color> gradientColors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: gradientColors[1].withValues(alpha: 0.3),
                child: Text(
                  review.userName.isNotEmpty ? review.userName[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: gradientColors[0],
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName.isNotEmpty ? review.userName : 'Anonymous',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (review.createdAt != null)
                      Text(
                        _formatDate(review.createdAt!),
                        style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                      ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 14,
                    color: Colors.amber[600],
                  ),
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar(ProductModel product, List<Color> gradientColors) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Total price
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Price',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Rs.${(product.discountedPrice * _quantity).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: gradientColors[0],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Add to cart button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      for (int i = 0; i < _quantity; i++) {
                        cartProvider.addToCart(
                          CartItem(
                            id: product.id,
                            name: product.name,
                            price: product.discountedPrice,
                            imageUrl: product.imageUrl,
                            rating: product.rating,
                          ),
                        );
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  _quantity == 1
                                      ? '${product.name} added to cart'
                                      : '$_quantity × ${product.name} added to cart',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: gradientColors[0],
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: const Duration(milliseconds: 1200),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradientColors),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors[0].withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Add to Cart',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _backButton(BuildContext context, {bool light = false}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: light ? Colors.white.withValues(alpha: 0.2) : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: light
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: light ? Colors.white : theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
