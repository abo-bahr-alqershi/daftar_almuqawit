import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/customer.dart';
import '../../blocs/customers/customers_bloc.dart';
import '../../blocs/customers/customers_event.dart';
import '../../widgets/common/confirm_dialog.dart';
import 'widgets/customer_history_tab.dart';
import 'widgets/customer_rating_widget.dart';
import 'edit_customer_screen.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailsScreen({super.key, required this.customer});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  late AnimationController _statsAnimationController;
  late AnimationController _tabsAnimationController;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _tabsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _statsAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _tabsAnimationController.forward();
    });

    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerAnimationController.dispose();
    _statsAnimationController.dispose();
    _tabsAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: NestedScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSliverAppBar(),
            SliverToBoxAdapter(child: _buildStatsSection()),
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                tabBar: _buildTabBar(),
                animation: _tabsAnimationController,
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildDetailsTab(),
              _buildDebtsTab(),
              _buildHistoryTab(),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomActions(),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final opacity = (_scrollOffset / 100).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white.withOpacity(opacity),
      surfaceTintColor: Colors.transparent,
      leading: _buildBackButton(),
      actions: [
        _buildIconAction(Icons.edit_outlined, _navigateToEdit),
        _buildIconAction(
          widget.customer.isBlocked ? Icons.lock_open : Icons.lock_outline,
          () => _toggleBlockStatus(context),
        ),
        _buildIconAction(
          Icons.more_horiz,
          () => _showMoreActionsSheet(context),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: FadeTransition(
          opacity: _headerAnimationController,
          child: _buildHeaderContent(),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF1A1A2E),
              size: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconAction(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(icon, color: const Color(0xFF1A1A2E), size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0F4F8), Color(0xFFF8F9FA)],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Hero(
              tag: 'customer-avatar-${widget.customer.id}',
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    widget.customer.name.isNotEmpty
                        ? widget.customer.name[0].toUpperCase()
                        : '؟',
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.customer.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            _buildStatusBadge(widget.customer),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Customer customer) {
    Color bgColor;
    Color textColor;
    String status = customer.getCustomerStatus();

    if (customer.isBlocked) {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFDC2626);
    } else if (customer.hasExceededCreditLimit) {
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFFF59E0B);
    } else if (customer.currentDebt > 0) {
      bgColor = const Color(0xFFDBEAFE);
      textColor = const Color(0xFF3B82F6);
    } else {
      bgColor = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF16A34A);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: AnimatedBuilder(
        animation: _statsAnimationController,
        builder: (context, child) {
          return Opacity(
            opacity: _statsAnimationController.value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - _statsAnimationController.value)),
              child: child,
            ),
          );
        },
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'المشتريات',
                    '${widget.customer.totalPurchases.toStringAsFixed(0)} ر.ي',
                    Icons.shopping_cart_outlined,
                    const Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'الدين الحالي',
                    '${widget.customer.currentDebt.toStringAsFixed(0)} ر.ي',
                    Icons.account_balance_wallet_outlined,
                    widget.customer.currentDebt > 0
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'حد الائتمان',
                    '${widget.customer.creditLimit.toStringAsFixed(0)} ر.ي',
                    Icons.credit_card_outlined,
                    const Color(0xFF0EA5E9),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'نوع العميل',
                    widget.customer.customerType,
                    Icons.category_outlined,
                    _getCustomerTypeColor(widget.customer.customerType),
                  ),
                ),
              ],
            ),
            if (widget.customer.creditLimit > 0) ...[
              const SizedBox(height: 12),
              _buildCreditUtilizationCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditUtilizationCard() {
    final utilization = widget.customer.creditUtilizationPercentage;
    Color progressColor;

    if (utilization >= 100) {
      progressColor = const Color(0xFFDC2626);
    } else if (utilization >= 80) {
      progressColor = const Color(0xFFF59E0B);
    } else {
      progressColor = const Color(0xFF16A34A);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'استخدام الائتمان',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${utilization.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: progressColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (utilization / 100).clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: progressColor,
                      borderRadius: BorderRadius.circular(6),
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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        labelColor: const Color(0xFF1A1A2E),
        unselectedLabelColor: const Color(0xFF9CA3AF),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        labelPadding: EdgeInsets.zero,
        onTap: (_) => HapticFeedback.selectionClick(),
        tabs: const [
          Tab(text: 'التفاصيل', height: 40),
          Tab(text: 'الديون', height: 40),
          Tab(text: 'السجل', height: 40),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      children: [
        _buildInfoSection(),
        const SizedBox(height: 16),
        CustomerRatingWidget(
          initialRating: 0,
          onRatingChanged: (rating) => HapticFeedback.lightImpact(),
          readOnly: false,
          showLabel: true,
        ),
        const SizedBox(height: 16),
        _buildQuickActionsSection(),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'معلومات الاتصال',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.phone_outlined,
            'رقم الهاتف',
            widget.customer.phone ?? 'غير محدد',
          ),
          if (widget.customer.nickname?.isNotEmpty ?? false) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.badge_outlined,
              'الكنية',
              widget.customer.nickname!,
            ),
          ],
          if (widget.customer.notes?.isNotEmpty ?? false) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.notes_outlined,
              'ملاحظات',
              widget.customer.notes!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF6366F1)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.flash_on_outlined,
                  size: 18,
                  color: Color(0xFF0EA5E9),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'إجراءات سريعة',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildQuickActionButton(
            'إضافة عملية بيع',
            Icons.add_shopping_cart_outlined,
            const Color(0xFF6366F1),
            () => Navigator.pushNamed(
              context,
              '/add-sale',
              arguments: {'customerId': widget.customer.id},
            ),
          ),
          const SizedBox(height: 10),
          _buildQuickActionButton(
            'سداد دين',
            Icons.payment_outlined,
            widget.customer.currentDebt > 0
                ? const Color(0xFF16A34A)
                : const Color(0xFFD1D5DB),
            widget.customer.currentDebt > 0
                ? () => Navigator.pushNamed(
                    context,
                    '/debt-payment',
                    arguments: {
                      'customerId': widget.customer.id,
                      'customerName': widget.customer.name,
                      'remainingAmount': widget.customer.currentDebt,
                    },
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    final isEnabled = onTap != null;
    return Material(
      color: isEnabled ? color : const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isEnabled
            ? () {
                HapticFeedback.mediumImpact();
                onTap();
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isEnabled ? Colors.white : const Color(0xFF9CA3AF),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isEnabled ? Colors.white : const Color(0xFF9CA3AF),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDebtsTab() {
    return _buildEmptyTab(
      Icons.account_balance_wallet_outlined,
      'الديون',
      'عرض قائمة الديون الخاصة بالعميل',
      const Color(0xFFFEF3C7),
      const Color(0xFFF59E0B),
    );
  }

  Widget _buildHistoryTab() {
    return const CustomerHistoryTab(sales: [], payments: [], isLoading: false);
  }

  Widget _buildEmptyTab(
    IconData icon,
    String title,
    String subtitle,
    Color bgColor,
    Color iconColor,
  ) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 20),
            const Text(
              'قريباً',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              'إضافة بيع',
              Icons.point_of_sale_outlined,
              const Color(0xFF6366F1),
              () => Navigator.pushNamed(
                context,
                '/add-sale',
                arguments: {'customerId': widget.customer.id},
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildSecondaryActionButton(
            Icons.payment_outlined,
            widget.customer.currentDebt > 0
                ? () => Navigator.pushNamed(
                    context,
                    '/debt-payment',
                    arguments: {
                      'customerId': widget.customer.id,
                      'customerName': widget.customer.name,
                      'remainingAmount': widget.customer.currentDebt,
                    },
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryActionButton(IconData icon, VoidCallback? onTap) {
    final isEnabled = onTap != null;
    return Material(
      color: isEnabled ? const Color(0xFFF3F4F6) : const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isEnabled
            ? () {
                HapticFeedback.mediumImpact();
                onTap();
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: isEnabled
                ? const Color(0xFF374151)
                : const Color(0xFFD1D5DB),
            size: 20,
          ),
        ),
      ),
    );
  }

  Color _getCustomerTypeColor(String type) {
    switch (type) {
      case 'VIP':
        return const Color(0xFFF59E0B);
      case 'جديد':
        return const Color(0xFF0EA5E9);
      default:
        return const Color(0xFF6B7280);
    }
  }

  void _navigateToEdit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditCustomerScreen(customer: widget.customer),
      ),
    );
  }

  void _toggleBlockStatus(BuildContext context) async {
    HapticFeedback.mediumImpact();

    final action = widget.customer.isBlocked ? 'إلغاء حظر' : 'حظر';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: '$action العميل',
        message: 'هل أنت متأكد من $action العميل "${widget.customer.name}"؟',
        confirmText: action,
        cancelText: 'إلغاء',
        isDestructive: !widget.customer.isBlocked,
      ),
    );

    if (confirmed == true && widget.customer.id != null) {
      if (context.mounted) {
        HapticFeedback.heavyImpact();
        context.read<CustomersBloc>().add(
          BlockCustomerEvent(widget.customer.id!, !widget.customer.isBlocked),
        );
        Navigator.of(context).pop();
      }
    }
  }

  void _showMoreActionsSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _MoreActionsBottomSheet(customer: widget.customer),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;
  final AnimationController animation;

  _StickyTabBarDelegate({required this.tabBar, required this.animation});

  @override
  double get minExtent => 64;

  @override
  double get maxExtent => 64;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return FadeTransition(
      opacity: animation,
      child: Container(color: const Color(0xFFF8F9FA), child: tabBar),
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}

class _MoreActionsBottomSheet extends StatelessWidget {
  final Customer customer;

  const _MoreActionsBottomSheet({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          _buildActionItem(context, Icons.share_outlined, 'مشاركة', () {
            Navigator.pop(context);
          }),
          _buildActionItem(context, Icons.print_outlined, 'طباعة', () {
            Navigator.pop(context);
          }),
          _buildActionItem(context, Icons.delete_outline, 'حذف العميل', () {
            Navigator.pop(context);
            _confirmDeleteCustomer(context);
          }, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? const Color(0xFFDC2626)
        : const Color(0xFF374151);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Color(0xFFD1D5DB),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteCustomer(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'حذف العميل',
        message: 'هل أنت متأكد من حذف العميل "${customer.name}"؟',
        confirmText: 'حذف',
        cancelText: 'إلغاء',
        isDestructive: true,
      ),
    );

    if (confirmed == true && customer.id != null && context.mounted) {
      HapticFeedback.heavyImpact();
      context.read<CustomersBloc>().add(DeleteCustomerEvent(customer.id!));
      Navigator.of(context).pop();
    }
  }
}
