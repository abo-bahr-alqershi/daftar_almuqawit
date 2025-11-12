import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/sales/sales_bloc.dart';
import '../../blocs/sales/sales_event.dart';
import '../../blocs/sales/sales_state.dart';

/// شاشة مبيعات اليوم - تصميم هادئ وراقي
class TodaySalesScreen extends StatefulWidget {
  const TodaySalesScreen({super.key});

  @override
  State<TodaySalesScreen> createState() => _TodaySalesScreenState();
}

class _TodaySalesScreenState extends State<TodaySalesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadTodaySales();
    
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  void _loadTodaySales() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    context.read<SalesBloc>().add(LoadTodaySales(today));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
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
            _buildGradientBackground(),

            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildModernAppBar(topPadding),

                SliverToBoxAdapter(
                  child: BlocBuilder<SalesBloc, SalesState>(
                    builder: (context, state) {
                      if (state is SalesLoading) {
                        return _buildLoadingState();
                      }

                      if (state is SalesError) {
                        return _buildErrorState(state);
                      }

                      if (state is SalesLoaded) {
                        final sales = state.sales;
                        
                        if (sales.isEmpty) {
                          return _buildEmptyState();
                        }
                        
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              children: [
                                _buildSummaryCards(sales),
                                const SizedBox(height: 24),
                                _buildSalesListHeader(sales.length),
                                _buildSalesList(sales),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        );
                      }

                      return _buildEmptyState();
                    },
                  ),
                ),
              ],
            ),

            _buildFloatingActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground() => Container(
        height: 500,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.sales.withOpacity(0.08),
              AppColors.success.withOpacity(0.05),
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
      backgroundColor: AppColors.surface.withOpacity(opacity),
      elevation: opacity * 2,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: opacity < 0.5
                ? AppColors.surface.withOpacity(0.9)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border.withOpacity(opacity < 0.5 ? 0.5 : 0),
            ),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: opacity < 0.5
                  ? AppColors.surface.withOpacity(0.9)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withOpacity(opacity < 0.5 ? 0.5 : 0),
              ),
            ),
            child: const Icon(
              Icons.refresh,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            _loadTodaySales();
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.sales.withOpacity(0.05),
                AppColors.success.withOpacity(0.03),
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
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.sales, AppColors.success],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.sales.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: AppColors.sales.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shopping_cart_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'مبيعات اليوم',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(DateTime.now()),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
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
    );
  }

  Widget _buildSummaryCards(List sales) {
    final total = sales.fold<double>(0.0, (sum, s) => sum + s.totalAmount);
    final profit = sales.fold<double>(0.0, (sum, s) => sum + s.profit);
    final count = sales.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _SummaryCard(
              title: 'إجمالي المبيعات',
              value: '${total.toStringAsFixed(0)} ريال',
              icon: Icons.monetization_on_rounded,
              gradient: const LinearGradient(
                colors: [AppColors.sales, AppColors.success],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryCard(
              title: 'العمليات',
              value: '$count',
              icon: Icons.receipt_long_rounded,
              gradient: LinearGradient(
                colors: [
                  AppColors.info.withOpacity(0.8),
                  AppColors.info,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryCard(
              title: 'الأرباح',
              value: '${profit.toStringAsFixed(0)} ريال',
              icon: Icons.trending_up_rounded,
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.8),
                  AppColors.success,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesListHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.sales, AppColors.success],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'تفاصيل المبيعات',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.sales.withOpacity(0.15),
                  AppColors.success.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count عملية',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.sales,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesList(List sales) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: sales.length,
      itemBuilder: (context, index) {
        final sale = sales[index];
        return _SaleCard(
          sale: sale,
          onTap: () => _showSaleDetails(sale),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: 24,
      left: 20,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.pushNamed(context, '/quick-sale');
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.sales, AppColors.success],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sales.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'بيع جديد',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.sales.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'جاري تحميل مبيعات اليوم...',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(SalesError state) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.danger.withOpacity(0.2),
                  AppColors.danger.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.danger,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'حدث خطأ',
            style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadTodaySales,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sales,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.refresh, size: 20),
            label: Text(
              'إعادة المحاولة',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.sales.withOpacity(0.15),
                  AppColors.success.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.inbox_rounded,
              size: 64,
              color: AppColors.textHint.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد مبيعات اليوم',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ يومك بإضافة أول عملية بيع',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pushNamed(context, '/add-sale');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sales,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.add, size: 20),
            label: Text(
              'إضافة بيع',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    final days = [
      'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'
    ];
    
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  void _showSaleDetails(sale) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/sale-details', arguments: sale);
  }
}

// بطاقة ملخص أنيقة
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// بطاقة بيع بسيطة وأنيقة
class _SaleCard extends StatelessWidget {
  final dynamic sale;
  final VoidCallback onTap;

  const _SaleCard({
    required this.sale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.border.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.sales.withOpacity(0.15),
                        AppColors.success.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.sales,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'فاتورة ${sale.invoiceNumber ?? '#${sale.id}'}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getPaymentColor(sale.paymentMethod)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              sale.paymentMethod ?? 'نقد',
                              style: AppTextStyles.caption.copyWith(
                                color: _getPaymentColor(sale.paymentMethod),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(sale.createdAt),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.trending_up,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${sale.profit?.toStringAsFixed(0) ?? '0'} ريال',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${sale.totalAmount?.toStringAsFixed(0) ?? '0'}',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.sales,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ريال',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
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

  Color _getPaymentColor(String? method) {
    switch (method) {
      case 'نقد':
        return AppColors.success;
      case 'آجل':
        return AppColors.warning;
      case 'بطاقة':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatTime(dynamic time) {
    if (time == null) return '';
    try {
      final dateTime = time is DateTime ? time : DateTime.parse(time.toString());
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      return '';
    }
  }
}
