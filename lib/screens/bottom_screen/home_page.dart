// lib/screens/home_page.dart
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.white,
              elevation: 0,
              title: Row(
                children: [
                  Icon(Icons.devices, color: Colors.deepPurple, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'TechHive',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.black87),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
                  onPressed: () {},
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isTablet = constraints.maxWidth > 600;
                  final horizontalPadding = isTablet ? 32.0 : 16.0;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Banner
                      _buildHeroBanner(horizontalPadding, isTablet),
                      const SizedBox(height: 24),

                      // Categories
                      _buildSectionTitle('Categories', horizontalPadding),
                      const SizedBox(height: 12),
                      _buildCategories(horizontalPadding, isTablet),
                      const SizedBox(height: 24),

                      // Featured Products
                      _buildSectionTitle('Featured Products', horizontalPadding),
                      const SizedBox(height: 12),
                      _buildFeaturedProducts(horizontalPadding, isTablet),
                      const SizedBox(height: 24),

                      // Hot Deals
                      _buildSectionTitle('Hot Deals 🔥', horizontalPadding),
                      const SizedBox(height: 12),
                      _buildHotDeals(horizontalPadding, isTablet),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner(double horizontalPadding, bool isTablet) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      height: isTablet ? 250 : 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.phonelink_ring,
              size: isTablet ? 200 : 160,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isTablet ? 32 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'New Arrivals',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Latest Gadgets\nUp to 50% Off',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 32 : 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: isTablet ? 16 : 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32 : 24,
                      vertical: isTablet ? 16 : 12,
                    ),
                  ),
                  child: Text(
                    'Shop Now',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCategories(double horizontalPadding, bool isTablet) {
    final categories = [
      {'icon': Icons.phone_android, 'name': 'Phones', 'color': Colors.blue},
      {'icon': Icons.laptop, 'name': 'Laptops', 'color': Colors.orange},
      {'icon': Icons.watch, 'name': 'Watches', 'color': Colors.green},
      {'icon': Icons.headphones, 'name': 'Audio', 'color': Colors.red},
      {'icon': Icons.tablet, 'name': 'Tablets', 'color': Colors.purple},
    ];

    if (isTablet) {
      // Grid layout for tablets
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: categories.map((category) {
            return SizedBox(
              width: 100,
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: (category['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      category['icon'] as IconData,
                      color: category['color'] as Color,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category['name'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }

    // Horizontal scroll for mobile
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: (category['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: category['color'] as Color,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedProducts(double horizontalPadding, bool isTablet) {
    final products = [
      {
        'name': 'iPhone 15 Pro',
        'price': '\$999',
        'image': Icons.phone_iphone,
        'rating': 4.8
      },
      {
        'name': 'Samsung Galaxy',
        'price': '\$849',
        'image': Icons.smartphone,
        'rating': 4.6
      },
      {
        'name': 'MacBook Pro',
        'price': '\$1,999',
        'image': Icons.laptop_mac,
        'rating': 4.9
      },
      {
        'name': 'iPad Air',
        'price': '\$599',
        'image': Icons.tablet_mac,
        'rating': 4.7
      },
    ];

    final itemWidth = isTablet ? 200.0 : 160.0;
    final itemHeight = isTablet ? 280.0 : 240.0;

    if (isTablet) {
      // Grid layout for tablets
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: products.map((product) {
            return _buildProductCard(product, itemWidth, itemHeight);
          }).toList(),
        ),
      );
    }

    // Horizontal scroll for mobile
    return SizedBox(
      height: itemHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Container(
            margin: const EdgeInsets.only(right: 16),
            child: _buildProductCard(product, itemWidth, itemHeight),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: height * 0.6,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                product['image'] as IconData,
                size: width * 0.4,
                color: Colors.deepPurple,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${product['rating']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  product['price'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotDeals(double horizontalPadding, bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[400]!, Colors.orange[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Limited Time Offer',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AirPods Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 28 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$199',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 36 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Was \$249',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isTablet ? 16 : 14,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(isTablet ? 28 : 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.headset,
              size: isTablet ? 64 : 48,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}