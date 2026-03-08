import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/product_provider.dart';
import '../../data/models/product_model.dart';
import '../product_detail_screen.dart';

class DealsScreen extends StatelessWidget {
  const DealsScreen({super.key});

  static const Map<String, List<Color>> _categoryGradients = {
    'Smartphones': [Color(0xFF0097A7), Color(0xFF4DD0E1)],
    'Laptops': [Color(0xFFFF6F00), Color(0xFFFF8F00)],
    'Audio': [Color(0xFFE91E63), Color(0xFFF06292)],
    'Wearables': [Color(0xFFFF5722), Color(0xFFFF8A65)],
    'Cameras': [Color(0xFF37474F), Color(0xFF78909C)],
    'Gaming': [Color(0xFF1565C0), Color(0xFF42A5F5)],
  };

  static const Map<String, Color> _categoryBgColors = {
    'Smartphones': Color(0xFFEDE7F6),
    'Laptops': Color(0xFFFFF3E0),
    'Audio': Color(0xFFFCE4EC),
    'Wearables': Color(0xFFFBE9E7),
    'Cameras': Color(0xFFECEFF1),
    'Gaming': Color(0xFFE3F2FD),
  };

  static const Map<String, IconData> _categoryIcons = {
    'Smartphones': Icons.phone_android,
    'Laptops': Icons.laptop_mac,
    'Audio': Icons.headphones_rounded,
    'Wearables': Icons.watch_rounded,
    'Cameras': Icons.camera_alt_rounded,
    'Gaming': Icons.sports_esports_rounded,
  };

  List<Color> _getGradient(String category) {
    return _categoryGradients[category] ?? [const Color(0xFFFF6F00), const Color(0xFFFF9800)];
  }

  Color _getBgColor(String category) {
    return _categoryBgColors[category] ?? const Color(0xFFFFF3E0);
  }

  IconData _getCategoryIcon(String category) {
    return _categoryIcons[category] ?? Icons.local_offer_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<ProductProvider>(
          builder: (context, productProvider, _) {
            final deals = productProvider.deals;

            return CustomScrollView(
              slivers: [
                // Header
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  expandedHeight: 130,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF6F00), Color(0xFFFF9800), Color(0xFFFFCA28)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 20,
                            bottom: 20,
                            child: Icon(
                              Icons.local_fire_department_rounded,
                              size: 60,
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Hot Deals',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Limited time offers — grab them fast!',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Content
                if (productProvider.isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (deals.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text('No deals available right now', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
                        ],
                      ),
                    ),
                  )
                else
                  // Deals List
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: index < deals.length - 1 ? 14 : 0),
                            child: _buildDealCard(context, deals[index]),
                          );
                        },
                        childCount: deals.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDealCard(BuildContext context, ProductModel deal) {
    final gradientColors = _getGradient(deal.category);
    final bgColor = _getBgColor(deal.category);
    final categoryIcon = _getCategoryIcon(deal.category);
    final discountText = deal.discountPercent > 0 ? '${deal.discountPercent.toStringAsFixed(0)}% OFF' : 'DEAL';

    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(productId: deal.id),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
            children: [
              // Image area
              Container(
                width: 110,
                height: 120,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -10,
                      left: -10,
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: gradientColors),
                        ),
                      ),
                    ),
                    Center(
                      child: deal.image != null && deal.image!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                deal.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  categoryIcon,
                                  size: 44,
                                  color: gradientColors[0],
                                ),
                              ),
                            )
                          : Icon(
                              categoryIcon,
                              size: 44,
                              color: gradientColors[0],
                            ),
                    ),
                  ],
                ),
              ),
              // Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: gradientColors),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              discountText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (deal.dealType != null) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.local_fire_department_rounded, size: 13, color: Colors.orange[400]),
                            const SizedBox(width: 3),
                            Text(
                              deal.dealType!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        deal.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            'Rs.${deal.discountedPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: gradientColors[0],
                            ),
                          ),
                          if (deal.discountPercent > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              'Rs.${deal.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[400],
                                decoration: TextDecoration.lineThrough,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Cart button
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    cartProvider.addToCart(
                      CartItem(
                        id: deal.id,
                        name: deal.name,
                        price: deal.discountedPrice,
                        imageUrl: deal.imageUrl,
                        rating: deal.rating,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Flexible(child: Text('${deal.name} added to cart', overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        backgroundColor: gradientColors[0],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        duration: const Duration(milliseconds: 800),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 20),
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
}
