import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/wish_list_provider.dart';
import '../../core/providers/product_provider.dart';
import '../../data/models/product_model.dart';
import '../product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _categories = [
    {'label': 'All', 'icon': Icons.grid_view_rounded},
    {'label': 'Smartphones', 'icon': Icons.phone_android},
    {'label': 'Laptops', 'icon': Icons.laptop_mac},
    {'label': 'Audio', 'icon': Icons.headphones_rounded},
    {'label': 'Wearables', 'icon': Icons.watch_rounded},
    {'label': 'Cameras', 'icon': Icons.camera_alt_rounded},
    {'label': 'Gaming', 'icon': Icons.sports_esports_rounded},
  ];

  // Category-specific gradient colors
  static const Map<String, List<Color>> _categoryGradients = {
    'Smartphones': [Color(0xFF0097A7), Color(0xFF4DD0E1)],
    'Laptops': [Color(0xFFFF6F00), Color(0xFFFF8F00)],
    'Audio': [Color(0xFFE91E63), Color(0xFFF06292)],
    'Wearables': [Color(0xFFFF5722), Color(0xFFFF8A65)],
    'Cameras': [Color(0xFF37474F), Color(0xFF78909C)],
    'Gaming': [Color(0xFF1565C0), Color(0xFF42A5F5)],
  };

  static const Map<String, Color> _categoryBgColors = {
    'Smartphones': Color(0xFFE0F7FA),
    'Laptops': Color(0xFFFFF3E0),
    'Audio': Color(0xFFFCE4EC),
    'Wearables': Color(0xFFFBE9E7),
    'Cameras': Color(0xFFECEFF1),
    'Gaming': Color(0xFFE3F2FD),
  };

  static const Map<String, IconData> _categoryIconMap = {
    'Smartphones': Icons.phone_android,
    'Laptops': Icons.laptop_mac,
    'Audio': Icons.headphones_rounded,
    'Wearables': Icons.watch_rounded,
    'Cameras': Icons.camera_alt_rounded,
    'Gaming': Icons.sports_esports_rounded,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final label = _categories[_tabController.index]['label'] as String;
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.setCategory(label == 'All' ? null : label);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Color> _getGradient(String category) {
    return _categoryGradients[category] ?? [const Color(0xFF0097A7), const Color(0xFF4DD0E1)];
  }

  Color _getBgColor(String category) {
    return _categoryBgColors[category] ?? const Color(0xFFE0F7FA);
  }

  IconData _getCategoryIcon(String category) {
    return _categoryIconMap[category] ?? Icons.devices_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Consumer<ProductProvider>(
          builder: (context, productProvider, _) {
            final products = productProvider.filteredProducts;

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                // App Bar
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  expandedHeight: 140,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF42A5F5)],
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
                                color: Colors.white.withValues(alpha: 0.07),
                              ),
                            ),
                          ),
                          Positioned(
                            left: -10,
                            bottom: -10,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
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
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'All Products',
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
                                  '${productProvider.products.length} items available',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
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

                // Category Tabs
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: Colors.white,
                      unselectedLabelColor: theme.colorScheme.onSurface,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicator: const BoxDecoration(),
                      dividerColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      tabAlignment: TabAlignment.start,
                      tabs: List.generate(_categories.length, (i) {
                        final selected = _tabController.index == i;
                        return Tab(
                          height: 40,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              gradient: selected
                                  ? const LinearGradient(colors: [Color(0xFF0097A7), Color(0xFF4DD0E1)])
                                  : null,
                              color: selected ? null : theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: selected ? null : Border.all(color: theme.dividerColor),
                              boxShadow: selected
                                  ? [BoxShadow(color: const Color(0xFF0097A7).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _categories[i]['icon'] as IconData,
                                  size: 16,
                                  color: selected ? Colors.white : Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(_categories[i]['label'] as String),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
              body: productProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : productProvider.errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              Text(
                                productProvider.errorMessage!,
                                style: TextStyle(color: Colors.grey[500], fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => productProvider.fetchProducts(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : products.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                                  const SizedBox(height: 12),
                                  Text('No products in this category', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () => productProvider.fetchProducts(),
                              child: GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 14,
                                  crossAxisSpacing: 14,
                                  childAspectRatio: 0.68,
                                ),
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  return _buildProductCard(context, products[index]);
                                },
                              ),
                            ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    final gradientColors = _getGradient(product.category);
    final bgColor = _getBgColor(product.category);
    final categoryIcon = _getCategoryIcon(product.category);

    return Consumer2<CartProvider, WishListProvider>(
      builder: (context, cartProvider, wishListProvider, _) {
        final isInWishList = wishListProvider.isInWishList(product.id);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(productId: product.id),
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
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image area
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -10,
                        left: -10,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: gradientColors),
                          ),
                        ),
                      ),
                      Center(
                        child: product.image != null && product.image!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  product.imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    categoryIcon,
                                    size: 52,
                                    color: gradientColors[0],
                                  ),
                                ),
                              )
                            : Icon(
                                categoryIcon,
                                size: 52,
                                color: gradientColors[0],
                              ),
                      ),
                      // Category tag
                      if (product.brand.isNotEmpty)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: gradientColors),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.brand,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      // Wishlist
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
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
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(
                              isInWishList ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isInWishList ? Colors.red : Colors.grey[400],
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Details area
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, size: 14, color: Colors.amber[600]),
                          const SizedBox(width: 3),
                          Text(
                            '${product.rating}',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
                          ),
                          if (product.reviews > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '(${product.reviews})',
                              style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                            ),
                          ],
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (product.isDeal && product.discountPercent > 0) ...[
                                  Text(
                                    'Rs.${product.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[400],
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                                Text(
                                  'Rs.${product.discountedPrice.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: gradientColors[0],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              cartProvider.addToCart(
                                CartItem(
                                  id: product.id,
                                  name: product.name,
                                  price: product.discountedPrice,
                                  imageUrl: product.imageUrl,
                                  rating: product.rating,
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                                      const SizedBox(width: 8),
                                      Flexible(child: Text('${product.name} added to cart', overflow: TextOverflow.ellipsis)),
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
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: gradientColors),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: gradientColors[0].withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
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

// Persistent header delegate for the tab bar
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => true;
}