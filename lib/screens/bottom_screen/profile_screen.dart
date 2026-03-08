import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../core/providers/dashboard_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/network/api_endpoints.dart';
import '../../data/models/order_model.dart';
import '../login_screen.dart';
import '../edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, DashboardProvider>(
      builder: (context, authProvider, dashboard, _) {
        final user = authProvider.currentUser;
        final isLoading = authProvider.isLoading || dashboard.isLoading;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: isLoading && dashboard.orders.isEmpty
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    await Future.wait([
                      authProvider.fetchProfile(),
                      dashboard.loadDashboard(),
                    ]);
                  },
                  child: CustomScrollView(
                    slivers: [
                      _buildProfileHeader(context, authProvider, user),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                          child: _buildStatsGrid(dashboard),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                          child: _buildOrderSummary(dashboard),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                          child: _buildRecentOrders(dashboard),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                          child: _buildQuickActions(context, authProvider),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                          child: _buildThemeSection(context),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
                          child: _buildAccountInfo(user),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  // ── Header ──
  Widget _buildProfileHeader(BuildContext context, AuthProvider authProvider, dynamic user) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Profile',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        _headerIconButton(Icons.edit_outlined, () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(
                                userName: user?.name ?? 'User',
                                userEmail: user?.email ?? '',
                                userProfilePicture: user?.imageUrl,
                              ),
                            ),
                          );
                          if (!context.mounted) return;
                          authProvider.fetchProfile();
                        }),
                        const SizedBox(width: 8),
                        _headerIconButton(Icons.logout_rounded, () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text('Are you sure you want to logout?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            await authProvider.logout();
                            if (!context.mounted) return;
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                          }
                        }),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 3),
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      child: user?.image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Image.network(
                                user!.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 40, color: Colors.white70),
                              ),
                            )
                          : const Icon(Icons.person, size: 40, color: Colors.white70),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'User',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              (user?.role ?? 'user').toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // ── Stats Grid ──
  Widget _buildStatsGrid(DashboardProvider dashboard) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatCard(icon: Icons.shopping_bag_rounded, label: 'Total Orders', value: '${dashboard.totalOrders}', color: AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(icon: Icons.attach_money_rounded, label: 'Total Spent', value: 'Rs ${dashboard.totalSpent.toStringAsFixed(0)}', color: const Color(0xFF00B894))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatCard(icon: Icons.inventory_2_rounded, label: 'Items Bought', value: '${dashboard.totalItemsPurchased}', color: const Color(0xFFFDAA5E))),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(icon: Icons.chat_bubble_rounded, label: 'Unread Chats', value: '${dashboard.unreadChatCount}', color: const Color(0xFFE17055))),
          ],
        ),
      ],
    );
  }

  // ── Order Summary ──
  Widget _buildOrderSummary(DashboardProvider dashboard) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 14),
          Row(
            children: [
              _OrderStatusChip(label: 'Pending', count: dashboard.pendingOrders, color: const Color(0xFFFDAA5E), icon: Icons.schedule_rounded),
              const SizedBox(width: 8),
              _OrderStatusChip(label: 'Processing', count: dashboard.processingOrders, color: const Color(0xFF0984E3), icon: Icons.autorenew_rounded),
              const SizedBox(width: 8),
              _OrderStatusChip(label: 'Completed', count: dashboard.completedOrders, color: const Color(0xFF00B894), icon: Icons.check_circle_rounded),
              const SizedBox(width: 8),
              _OrderStatusChip(label: 'Cancelled', count: dashboard.cancelledOrders, color: const Color(0xFFD63031), icon: Icons.cancel_rounded),
            ],
          ),
          if (dashboard.totalOrders > 0) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 10,
                child: Row(
                  children: [
                    if (dashboard.completedOrders > 0) Expanded(flex: dashboard.completedOrders, child: Container(color: const Color(0xFF00B894))),
                    if (dashboard.processingOrders > 0) Expanded(flex: dashboard.processingOrders, child: Container(color: const Color(0xFF0984E3))),
                    if (dashboard.pendingOrders > 0) Expanded(flex: dashboard.pendingOrders, child: Container(color: const Color(0xFFFDAA5E))),
                    if (dashboard.cancelledOrders > 0) Expanded(flex: dashboard.cancelledOrders, child: Container(color: const Color(0xFFD63031))),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Recent Orders ──
  Widget _buildRecentOrders(DashboardProvider dashboard) {
    final recent = dashboard.recentOrders;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 12),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_rounded, size: 40, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text('No orders yet', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                  ],
                ),
              ),
            )
          else
            ...recent.map((order) => _buildOrderTile(order)),
        ],
      ),
    );
  }

  Widget _buildOrderTile(OrderModel order) {
    final statusColor = _getStatusColor(order.status);
    final itemCount = order.items.length;
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final productName = firstItem?.productName ?? 'Order';
    final displayName = itemCount > 1 ? '$productName +${itemCount - 1} more' : productName;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: firstItem?.productImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      ApiEndpoints.imageUrl(firstItem!.productImage),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.shopping_bag, color: statusColor, size: 22),
                    ),
                  )
                : Icon(Icons.shopping_bag, color: statusColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(_formatDate(order.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Rs ${order.totalAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(order.status.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Quick Actions ──
  Widget _buildQuickActions(BuildContext context, AuthProvider authProvider) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 12),
          Row(
            children: [
              _QuickActionButton(
                icon: Icons.edit_rounded,
                label: 'Edit Profile',
                color: AppColors.primary,
                onTap: () async {
                  final user = authProvider.currentUser;
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(userName: user?.name ?? 'User', userEmail: user?.email ?? '', userProfilePicture: user?.imageUrl)));
                  if (!context.mounted) return;
                  authProvider.fetchProfile();
                },
              ),
              _QuickActionButton(
                icon: Icons.receipt_long_rounded,
                label: 'My Orders',
                color: const Color(0xFF00B894),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order details shown above')));
                },
              ),
              _QuickActionButton(
                icon: Icons.chat_rounded,
                label: 'My Chats',
                color: const Color(0xFFE17055),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Visit a product page to start a chat')));
                },
              ),
              _QuickActionButton(
                icon: Icons.lock_outline_rounded,
                label: 'Security',
                color: const Color(0xFF0984E3),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Use Forgot Password to change your password')));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Theme Section ──
  Widget _buildThemeSection(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Theme', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Auto mode uses light sensor to match surroundings',
            style: TextStyle(fontSize: 11, color: subtextColor),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _ThemeOptionTile(
                icon: Icons.light_mode_rounded,
                label: 'Light',
                isSelected: themeProvider.themeOption == ThemeOption.light,
                onTap: () => themeProvider.setTheme(ThemeOption.light),
              ),
              const SizedBox(width: 10),
              _ThemeOptionTile(
                icon: Icons.dark_mode_rounded,
                label: 'Dark',
                isSelected: themeProvider.themeOption == ThemeOption.dark,
                onTap: () => themeProvider.setTheme(ThemeOption.dark),
              ),
              const SizedBox(width: 10),
              _ThemeOptionTile(
                icon: Icons.brightness_auto_rounded,
                label: 'Auto',
                isSelected: themeProvider.themeOption == ThemeOption.auto,
                onTap: () => themeProvider.setTheme(ThemeOption.auto),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Account Info ──
  Widget _buildAccountInfo(dynamic user) {
    final theme = Theme.of(context);
    final memberSince = user?.createdAt != null
        ? '${_monthName(user!.createdAt!.month)} ${user.createdAt!.year}'
        : 'N/A';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 14),
          _infoRow(Icons.email_outlined, 'Email', user?.email ?? 'N/A'),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.3)),
          _infoRow(Icons.phone_outlined, 'Phone', user?.phoneNumber ?? 'N/A'),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.3)),
          _infoRow(Icons.badge_outlined, 'Role', (user?.role ?? 'user').toString().toUpperCase()),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.3)),
          _infoRow(Icons.calendar_today_outlined, 'Member Since', memberSince),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.3)),
          _infoRow(Icons.verified_outlined, 'Status', 'Active', valueColor: const Color(0xFF00B894)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? valueColor}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? theme.colorScheme.onSurface)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed': return const Color(0xFF00B894);
      case 'processing': return const Color(0xFF0984E3);
      case 'pending': return const Color(0xFFFDAA5E);
      case 'cancelled': return const Color(0xFFD63031);
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

// ───── Stat Card ─────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───── Order Status Chip ─────
class _OrderStatusChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _OrderStatusChip({required this.label, required this.count, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text('$count', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ───── Quick Action Button ─────
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.12)
                : isDark
                    ? Colors.grey.shade800
                    : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: isSelected ? AppColors.primary : (isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
