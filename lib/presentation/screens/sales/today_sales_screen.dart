import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/sales/sales_bloc.dart';
import '../../blocs/sales/sales_event.dart';
import '../../blocs/sales/sales_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;

/// شاشة مبيعات اليوم - تصميم Tesla/iOS متطور
class TodaySalesScreen extends StatefulWidget {
  const TodaySalesScreen({super.key});

  @override
  State<TodaySalesScreen> createState() => _TodaySalesScreenState();
}

class _TodaySalesScreenState extends State<TodaySalesScreen>
    with TickerProviderStateMixin {
  late AnimationController _summaryAnimationController;
  late AnimationController _listAnimationController;
  late AnimationController _counterAnimationController;
  late Animation<double> _summarySlideAnimation;
  late Animation<double> _listFadeAnimation;
  late Animation<double> _counterAnimation;
  
  final ScrollController _scrollController = ScrollController();
  bool _isFilterExpanded = false;
  String _selectedPeriod = 'today';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadTodaySales();
  }

  void _initializeAnimations() {
    _summaryAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _counterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _summarySlideAnimation = Tween<double>(
      begin: -50,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _summaryAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _listFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeIn,
    ));
    
    _counterAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _counterAnimationController,
      curve: Curves.easeOutExpo,
    ));
    
    _summaryAnimationController.forward();
    _listAnimationController.forward();
    _counterAnimationController.forward();
  }

  void _loadTodaySales() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    context.read<SalesBloc>().add(LoadTodaySales(today));
  }

  @override
  void dispose() {
    _summaryAnimationController.dispose();
    _listAnimationController.dispose();
    _counterAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // خلفية متدرجة ديناميكية
          _buildAnimatedBackground(),
          
          // المحتوى الرئيسي
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // AppBar مخصص
              _buildModernAppBar(),
              
              // المحتوى
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
                      
                      return Column(
                        children: [
                          // بطاقة الملخص المتحركة
                          _buildAnimatedSummaryCard(sales),
                          
                          // الإحصائيات السريعة
                          _buildQuickStats(sales),
                          
                          // مخطط الأداء
                          _buildPerformanceChart(sales),
                          
                          // عنوان القائمة
                          _buildListHeader(sales.length),
                          
                          // قائمة المبيعات
                          _buildSalesList(sales),
                          
                          const SizedBox(height: 100),
                        ],
                      );
                    }

                    return _buildEmptyState();
                  },
                ),
              ),
            ],
          ),
          
          // FAB متطور
          _buildModernFAB(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.03),
            AppColors.accent.withOpacity(0.01),
            AppColors.background,
          ],
        ),
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          color: Colors.transparent,
          child: CustomPaint(
            painter: _BackgroundPatternPainter(),
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.today_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'مبيعات اليوم',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          background: Stack(
            children: [
              // Pattern Background
              Positioned.fill(
                child: CustomPaint(
                  painter: _AppBarPatternPainter(),
                ),
              ),
              
              // Date Display
              Positioned(
                bottom: 60,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(DateTime.now()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        _buildAnimatedActionButton(
          Icons.filter_list,
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() => _isFilterExpanded = !_isFilterExpanded);
          },
        ),
        _buildAnimatedActionButton(
          Icons.refresh,
          onPressed: () {
            HapticFeedback.lightImpact();
            _loadTodaySales();
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAnimatedActionButton(IconData icon, {required VoidCallback onPressed}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(icon, color: Colors.white, size: 22),
              onPressed: onPressed,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSummaryCard(List sales) {
    final total = sales.fold(0.0, (sum, s) => sum + s.totalAmount);
    final profit = sales.fold(0.0, (sum, s) => sum + s.profit);
    
    return AnimatedBuilder(
      animation: _summarySlideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _summarySlideAnimation.value),
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إجمالي المبيعات',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedBuilder(
                          animation: _counterAnimation,
                          builder: (context, child) {
                            return Text(
                              '${(total * _counterAnimation.value).toStringAsFixed(0)} ريال',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.trending_up_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Stats Row
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'العمليات',
                        sales.length.toString(),
                        Icons.receipt_long,
                      ),
                      Container(
                        height: 30,
                        width: 1,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _buildStatItem(
                        'الربح',
                        '${profit.toStringAsFixed(0)} ريال',
                        Icons.account_balance_wallet,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(List sales) {
    final stats = _calculateStats(sales);
    
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _QuickStatCard(
            title: 'متوسط الفاتورة',
            value: '${stats['average']} ريال',
            icon: Icons.calculate_rounded,
            color: AppColors.info,
          ),
          _QuickStatCard(
            title: 'أعلى فاتورة',
            value: '${stats['max']} ريال',
            icon: Icons.arrow_upward_rounded,
            color: AppColors.success,
          ),
          _QuickStatCard(
            title: 'نقدي',
            value: '${stats['cash']} ريال',
            icon: Icons.payments_rounded,
            color: AppColors.primary,
          ),
          _QuickStatCard(
            title: 'آجل',
            value: '${stats['credit']} ريال',
            icon: Icons.schedule_rounded,
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(List sales) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'توزيع المبيعات',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.pie_chart_rounded,
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Chart Placeholder - يمكن استبداله بمخطط حقيقي
          SizedBox(
            height: 200,
            child: Center(
              child: CustomPaint(
                size: const Size(200, 200),
                painter: _PieChartPainter(sales),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader(int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'تفاصيل المبيعات',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.accent.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count عملية',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesList(List sales) {
    return AnimatedBuilder(
      animation: _listFadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _listFadeAnimation,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: sales.length,
            itemBuilder: (context, index) {
              final sale = sales[index];
              return _ModernSaleCard(
                sale: sale,
                index: index,
                onTap: () => _showSaleDetails(sale),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildModernFAB() {
    return Positioned(
      bottom: 20,
      left: 20,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _summaryAnimationController,
          curve: Curves.elasticOut,
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.pushNamed(context, '/quick-sale');
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'بيع جديد',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(seconds: 1),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * math.pi,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.2),
                        AppColors.accent.withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'جاري تحميل مبيعات اليوم...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(SalesError state) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.danger.withOpacity(0.1),
                    AppColors.danger.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 60,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'حدث خطأ',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadTodaySales,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.05),
                          AppColors.accent.withOpacity(0.03),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inbox_rounded,
                      size: 70,
                      color: AppColors.textHint,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد مبيعات اليوم',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
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
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('إضافة بيع'),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateStats(List sales) {
    final total = sales.fold(0.0, (sum, s) => sum + s.totalAmount);
    final average = sales.isEmpty ? 0 : (total / sales.length).round();
    final max = sales.isEmpty ? 0 : sales.map((s) => s.totalAmount).reduce((a, b) => math.max(a, b)).round();
    final cash = sales.where((s) => s.paymentMethod == 'نقد').fold(0.0, (sum, s) => sum + s.totalAmount).round();
    final credit = sales.where((s) => s.paymentMethod == 'آجل').fold(0.0, (sum, s) => sum + s.totalAmount).round();
    
    return {
      'average': average,
      'max': max,
      'cash': cash,
      'credit': credit,
    };
  }

  String _formatDate(DateTime date) {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    final days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showSaleDetails(sale) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/sale-details', arguments: sale);
  }
}

// بطاقة إحصائية سريعة
class _QuickStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _QuickStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// بطاقة بيع محسنة
class _ModernSaleCard extends StatelessWidget {
  final dynamic sale;
  final int index;
  final VoidCallback onTap;

  const _ModernSaleCard({
    required this.sale,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.accent.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${sale.quantity}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'كيس',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sale.customerName ?? 'بيع مباشر',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: AppColors.textHint,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                sale.time,
                                style: TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${sale.totalAmount}',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ريال',
                          style: TextStyle(
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
      },
    );
  }
}

// رسامات مخصصة
class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // رسم النمط
    for (int i = 0; i < 5; i++) {
      paint.color = AppColors.primary.withOpacity(0.02 - (i * 0.003));
      canvas.drawCircle(
        Offset(size.width * (0.2 + i * 0.2), size.height * 0.3),
        50 + (i * 20).toDouble(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AppBarPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.05);

    // رسم الدوائر
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.2),
      60,
      paint,
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.7),
      80,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PieChartPainter extends CustomPainter {
  final List sales;
  
  _PieChartPainter(this.sales);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // رسم مخطط دائري بسيط
    final total = sales.fold(0.0, (sum, s) => sum + s.totalAmount);
    double startAngle = -math.pi / 2;
    
    for (int i = 0; i < math.min(sales.length, 5); i++) {
      final sale = sales[i];
      final sweepAngle = (sale.totalAmount / total) * 2 * math.pi;
      
      paint.color = [
        AppColors.primary,
        AppColors.accent,
        AppColors.success,
        AppColors.warning,
        AppColors.info,
      ][i % 5];
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
    }
    
    // رسم دائرة بيضاء في المنتصف
    paint.color = AppColors.surface;
    canvas.drawCircle(center, radius * 0.6, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}