import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/product_provider.dart';
import '../brand_products_screen.dart';

class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});

  // Assign gradients/colors/icons per brand name for visual variety
  static const List<List<Color>> _brandGradientPalette = [
    [Color(0xFF1A1A2E), Color(0xFF37474F)],
    [Color(0xFF1565C0), Color(0xFF42A5F5)],
    [Color(0xFF0097A7), Color(0xFF4DD0E1)],
    [Color(0xFF4CAF50), Color(0xFF81C784)],
    [Color(0xFFFF6F00), Color(0xFFFF9800)],
    [Color(0xFFE91E63), Color(0xFFF06292)],
    [Color(0xFF00838F), Color(0xFF26C6DA)],
    [Color(0xFF2E7D32), Color(0xFF66BB6A)],
    [Color(0xFFFF5722), Color(0xFFFF8A65)],
    [Color(0xFF37474F), Color(0xFF78909C)],
  ];

  static const List<Color> _brandBgPalette = [
    Color(0xFFF5F5F5),
    Color(0xFFE3F2FD),
    Color(0xFFEDE7F6),
    Color(0xFFE8F5E9),
    Color(0xFFFFF3E0),
    Color(0xFFFCE4EC),
    Color(0xFFE0F7FA),
    Color(0xFFE8F5E9),
    Color(0xFFFBE9E7),
    Color(0xFFECEFF1),
  ];

  static const List<IconData> _brandIconPalette = [
    Icons.business_rounded,
    Icons.devices_rounded,
    Icons.headphones_rounded,
    Icons.phone_android_rounded,
    Icons.laptop_mac_rounded,
    Icons.watch_rounded,
    Icons.sports_esports_rounded,
    Icons.camera_alt_rounded,
    Icons.speaker_rounded,
    Icons.computer_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Consumer<ProductProvider>(
          builder: (context, productProvider, _) {
            final brands = productProvider.brands;

            return CustomScrollView(
              slivers: [
                // Header
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  expandedHeight: 130,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00838F), Color(0xFF00BCD4), Color(0xFF4DD0E1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -30,
                            top: -30,
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.07),
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
                                      child: const Icon(Icons.verified_rounded, color: Colors.white, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Top Brands',
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
                                  'Trusted names in tech',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
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
                else if (brands.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_outlined, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text('No brands found', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
                        ],
                      ),
                    ),
                  )
                else
                  // Brands Grid
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1.1,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final brandName = brands[index];
                          final productCount = productProvider.getProductsByBrand(brandName).length;
                          final colors = _brandGradientPalette[index % _brandGradientPalette.length];
                          return _buildBrandCard(
                            context,
                            brandName,
                            productCount,
                            colors,
                            _brandBgPalette[index % _brandBgPalette.length],
                            _brandIconPalette[index % _brandIconPalette.length],
                          );
                        },
                        childCount: brands.length,
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

  Widget _buildBrandCard(
    BuildContext context,
    String brandName,
    int productCount,
    List<Color> gradientColors,
    Color bgColor,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BrandProductsScreen(
              brandName: brandName,
              gradientColors: gradientColors,
            ),
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
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background accent
          Positioned(
            right: -15,
            bottom: -15,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Text(
                  brandName,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$productCount Product${productCount != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
