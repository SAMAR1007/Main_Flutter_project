import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'products_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final pad = constraints.maxWidth > 600 ? 32.0 : 20.0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildAppBar(context, pad),
                  const SizedBox(height: 28),
                  _buildExploreCard(context, pad),
                  const SizedBox(height: 32),
                  _buildStatsRow(context, pad),
                  const SizedBox(height: 32),
                  _buildFeatureHighlights(context, pad),
                  const SizedBox(height: 32),
                  _buildQuoteCard(context, pad),
                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Minimal App Bar ──
  Widget _buildAppBar(BuildContext context, double pad) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/logo.png',
              width: 42,
              height: 42,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'TechHive',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 24,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Explore Products – the only clickable section ──
  Widget _buildExploreCard(BuildContext context, double pad) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductsScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: pad),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.gradientWide,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.30),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -20,
              top: -30,
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
              right: 20,
              bottom: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Explore\nProducts',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Browse our full collection',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Browse',
                              style: TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded,
                                color: AppColors.primaryDark, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Decorative stats row (not clickable) ──
  Widget _buildStatsRow(BuildContext context, double pad) {
    final theme = Theme.of(context);
    final stats = [
      {'value': '100%', 'label': 'Authentic', 'icon': Icons.verified_outlined},
      {'value': '50+', 'label': 'Brands', 'icon': Icons.workspace_premium_outlined},
      {'value': '4.8', 'label': 'Rating', 'icon': Icons.star_outline_rounded},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: Row(
        children: stats.map((s) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: s != stats.last ? 12 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.10),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    s['icon'] as IconData,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s['value'] as String,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Feature highlights (decorative, not clickable) ──
  Widget _buildFeatureHighlights(BuildContext context, double pad) {
    final theme = Theme.of(context);
    final features = [
      {
        'icon': Icons.local_offer_outlined,
        'title': 'Great Offers',
        'subtitle': 'Deals & discounts available',
      },
      {
        'icon': Icons.verified_user_outlined,
        'title': 'Genuine Products',
        'subtitle': '100% authentic items',
      },
      {
        'icon': Icons.support_agent_outlined,
        'title': '24/7 Support',
        'subtitle': 'We\'re always here',
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: Column(
        children: features.map((f) {
          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(
              bottom: f != features.last ? 12 : 0,
            ),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    f['icon'] as IconData,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f['title'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      f['subtitle'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Decorative quote card ──
  Widget _buildQuoteCard(BuildContext context, double pad) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: pad),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.06),
            AppColors.primaryLight.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.format_quote_rounded,
            color: AppColors.primary.withValues(alpha: 0.4),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Technology is best when it brings people together.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '— Matt Mullenweg',
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}