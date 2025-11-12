import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/customer.dart';
import '../../blocs/customers/customers_bloc.dart';
import '../../blocs/customers/customers_event.dart';
import '../../blocs/customers/customers_state.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import '../../widgets/common/loading_widget.dart';
import 'customer_details_screen.dart';

/// شاشة العملاء المحظورين - تصميم متطور
class BlockedCustomersScreen extends StatefulWidget {
  const BlockedCustomersScreen({super.key});

  @override
  State<BlockedCustomersScreen> createState() => _BlockedCustomersScreenState();
}

class _BlockedCustomersScreenState extends State<BlockedCustomersScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  List<Customer> _filteredCustomers = [];
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animationController.forward();

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    context.read<CustomersBloc>().add(LoadCustomers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _filterCustomers(List<Customer> allCustomers, String query) {
    final blocked = allCustomers.where((c) => c.isBlocked).toList();

    if (query.isEmpty) {
      setState(() {
        _filteredCustomers = blocked;
      });
    } else {
      setState(() {
        _filteredCustomers = blocked
            .where((customer) =>
                customer.name.toLowerCase().contains(query.toLowerCase()) ||
                (customer.phone?.contains(query) ?? false))
            .toList();
      });
    }
  }

  void _unblockCustomer(Customer customer) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          'إلغاء حظر العميل',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'هل تريد إلغاء حظر ${customer.name}؟',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: Text(
              'إلغاء',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).pop();
              context.read<CustomersBloc>().add(
                    BlockCustomerEvent(customer.id!, false),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'إلغاء الحظر',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // خلفية متدرجة ديناميكية
            _buildGradientBackground(),

            // المحتوى الرئيسي
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // AppBar مخصص مع تأثيرات
                _buildModernAppBar(topPadding),

                // محتوى الشاشة
                SliverToBoxAdapter(
                  child: BlocConsumer<CustomersBloc, CustomersState>(
                    listener: (context, state) {
                      if (state is CustomerOperationSuccess) {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                        context.read<CustomersBloc>().add(LoadCustomers());
                      } else if (state is CustomersError) {
                        HapticFeedback.heavyImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppColors.danger,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is CustomersLoading) {
                        return _buildShimmerLoading();
                      }

                      if (state is CustomersError) {
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: custom_error.AppErrorWidget(
                            message: state.message,
                            onRetry: () {
                              context.read<CustomersBloc>().add(LoadCustomers());
                            },
                          ),
                        );
                      }

                      if (state is CustomersLoaded) {
                        final blockedCustomers =
                            state.customers.where((c) => c.isBlocked).toList();

                        if (_filteredCustomers.isEmpty &&
                            _searchController.text.isEmpty) {
                          _filteredCustomers = blockedCustomers;
                        }

                        return Column(
                          children: [
                            const SizedBox(height: 20),

                            // شريط البحث
                            _buildSearchBar(state.customers),

                            const SizedBox(height: 20),

                            // إحصائيات العملاء المحظورين
                            _buildStatisticsCard(blockedCustomers.length),

                            const SizedBox(height: 24),

                            // قائمة العملاء المحظورين
                            _filteredCustomers.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(40),
                                    child: EmptyWidget(
                                      title: _searchController.text.isEmpty
                                          ? 'لا يوجد عملاء محظورون'
                                          : 'لم يتم العثور على عملاء',
                                      message: _searchController.text.isEmpty
                                          ? 'لم يتم حظر أي عميل بعد'
                                          : 'جرب البحث بكلمات مختلفة',
                                      icon: Icons.block,
                                    ),
                                  )
                                : _buildCustomersList(),

                            const SizedBox(height: 100),
                          ],
                        );
                      }

                      return const Padding(
                        padding: EdgeInsets.all(40),
                        child: EmptyWidget(
                          title: 'لا يوجد بيانات',
                          message: 'لم يتم تحميل بيانات العملاء',
                          icon: Icons.block,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground() => Container(
        height: 400,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.danger.withOpacity(0.12),
              AppColors.danger.withOpacity(0.06),
              Colors.transparent,
            ],
          ),
        ),
      );

  Widget _buildModernAppBar(double topPadding) {
    final opacity = (_scrollOffset / 100).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColors.danger.withOpacity(0.95),
      elevation: opacity * 8,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.danger,
                AppColors.danger.withOpacity(0.85),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      // أيقونة الشاشة
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.block_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'العملاء المحظورون',
                              style: AppTextStyles.h2.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'إدارة العملاء المحظورين',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
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
      ),
      leading: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(List<Customer> customers) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: AppColors.danger.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AppTextField.search(
            controller: _searchController,
            hint: 'البحث عن عميل محظور...',
            onChanged: (query) {
              HapticFeedback.selectionClick();
              _filterCustomers(customers, query);
            },
          ),
        ),
      );

  Widget _buildStatisticsCard(int count) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.danger.withOpacity(0.1),
                AppColors.danger.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.danger.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.danger.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.block_rounded,
                  color: AppColors.danger,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'عدد العملاء المحظورين',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                      fontSize: 32,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildCustomersList() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredCustomers.length,
          itemBuilder: (context, index) {
            final customer = _filteredCustomers[index];
            final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  (index / _filteredCustomers.length) * 0.5,
                  ((index + 1) / _filteredCustomers.length) * 0.5 + 0.5,
                  curve: Curves.easeOutCubic,
                ),
              ),
            );
            return _buildCustomerCard(customer, animation);
          },
        ),
      );

  Widget _buildCustomerCard(Customer customer, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.danger.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppColors.danger.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      CustomerDetailsScreen(customer: customer),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        )),
                        child: child,
                      ),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // أيقونة العميل
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.danger.withOpacity(0.15),
                              AppColors.danger.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.block_rounded,
                          color: AppColors.danger,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: AppTextStyles.h3.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_rounded,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  customer.phone ?? 'غير محدد',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // زر إلغاء الحظر
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.lock_open_rounded),
                          color: AppColors.success,
                          iconSize: 24,
                          onPressed: () => _unblockCustomer(customer),
                          tooltip: 'إلغاء الحظر',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // معلومات العميل
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          'الدين الحالي',
                          '${customer.currentDebt.toStringAsFixed(2)} ريال',
                          Icons.account_balance_wallet_rounded,
                          customer.currentDebt > 0
                              ? AppColors.danger
                              : AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoItem(
                          'إجمالي المشتريات',
                          '${customer.totalPurchases.toStringAsFixed(2)} ريال',
                          Icons.shopping_cart_rounded,
                          AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (customer.notes != null && customer.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 20,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              customer.notes!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // شريط البحث Shimmer
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 20),
            // بطاقة الإحصائيات Shimmer
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 24),
            // بطاقات العملاء Shimmer
            ...List.generate(
              3,
              (index) => Container(
                height: 180,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      );
}
