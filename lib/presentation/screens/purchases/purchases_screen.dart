import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/purchase.dart';
import '../../blocs/purchases/purchases_bloc.dart';
import '../../blocs/purchases/purchases_event.dart';
import '../../blocs/purchases/purchases_state.dart';
import 'widgets/purchase_item_card.dart';
import 'widgets/purchase_summary.dart';
import 'add_purchase_screen.dart';
import 'purchase_details_screen.dart';

/// الشاشة الرئيسية لإدارة المشتريات - تصميم راقي
class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  String _filterType = 'الكل';
  DateTime _selectedDate = DateTime.now();

  final List<String> _filterTypes = [
    'الكل',
    'اليوم',
    'الأسبوع',
    'الشهر',
    'مدفوع',
    'غير مدفوع',
    'مدفوع جزئياً',
  ];

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPurchases();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadPurchases() {
    if (_filterType == 'اليوم') {
      context.read<PurchasesBloc>().add(
        LoadTodayPurchases(_selectedDate.toIso8601String().split('T')[0]),
      );
    } else {
      context.read<PurchasesBloc>().add(LoadPurchases());
    }
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      BlocBuilder<PurchasesBloc, PurchasesState>(
                        builder: (context, state) {
                          if (state is PurchasesLoaded) {
                            final filteredPurchases = _filterPurchases(
                              state.purchases,
                            );
                            return _buildQuickStatsWidget(filteredPurchases);
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      const SizedBox(height: 32),

                      _buildSectionTitle(
                        'تصنيف المشتريات',
                        Icons.filter_list_rounded,
                      ),

                      const SizedBox(height: 16),

                      _buildFilterChips(),

                      const SizedBox(height: 32),

                      _buildSectionTitle(
                        'قائمة المشتريات',
                        Icons.shopping_cart_rounded,
                      ),

                      const SizedBox(height: 16),

                      BlocConsumer<PurchasesBloc, PurchasesState>(
                        listener: (context, state) {
                          if (state is PurchasesError) {
                            _showErrorSnackBar(state.message);
                          } else if (state is PurchaseOperationSuccess) {
                            _showSuccessSnackBar(state.message);
                          }
                        },
                        builder: (context, state) {
                          if (state is PurchasesLoading) {
                            return _buildLoadingState();
                          }

                          if (state is PurchasesError) {
                            return _buildErrorState(state);
                          }

                          if (state is PurchasesLoaded) {
                            final filteredPurchases = _filterPurchases(
                              state.purchases,
                            );
                            return _buildPurchasesList(filteredPurchases);
                          }

                          return _buildEmptyState(
                            'لا يوجد بيانات',
                            Icons.shopping_cart_outlined,
                          );
                        },
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),

            _buildFloatingActionButton(context),
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
          AppColors.purchases.withOpacity(0.08),
          AppColors.info.withOpacity(0.05),
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
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.surface, AppColors.surface.withOpacity(0.95)],
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
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.purchases, Color(0xFF6A1B9A)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.purchases.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shopping_cart_rounded,
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
                              'إدارة المشتريات',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            BlocBuilder<PurchasesBloc, PurchasesState>(
                              builder: (context, state) {
                                if (state is PurchasesLoaded) {
                                  return Text(
                                    '${state.purchases.length} عملية شراء',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
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
      actions: [
        _buildIconButton(
          Icons.calendar_today,
          onPressed: () async {
            HapticFeedback.lightImpact();
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _selectedDate = date;
                _filterType = 'اليوم';
              });
              _loadPurchases();
            }
          },
        ),
        _buildIconButton(
          Icons.refresh_rounded,
          onPressed: () {
            HapticFeedback.mediumImpact();
            _loadPurchases();
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, {required VoidCallback onPressed}) =>
      Container(
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: IconButton(
          icon: Icon(icon, color: AppColors.textPrimary, size: 20),
          onPressed: onPressed,
        ),
      );

  Widget _buildSectionTitle(String title, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.purchases.withOpacity(0.1),
                AppColors.info.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.purchases),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ],
    ),
  );

  Widget _buildQuickStatsWidget(List<Purchase> purchases) {
    final totalAmount = purchases.fold<double>(
      0,
      (sum, purchase) => sum + purchase.totalAmount,
    );
    final totalPaid = purchases.fold<double>(
      0,
      (sum, purchase) => sum + purchase.paidAmount,
    );
    final totalRemaining = purchases.fold<double>(
      0,
      (sum, purchase) => sum + purchase.remainingAmount,
    );
    final operationCount = purchases.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.purchases, Color(0xFF6A1B9A)],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purchases.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _StatsBackgroundPainter()),
                ),
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(color: Colors.white.withOpacity(0.05)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'إجمالي المشتريات',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'عدد العمليات: $operationCount',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
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
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.success,
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'نشط',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            totalAmount.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'ريال',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.trending_up_rounded,
                              size: 16,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'مدفوع: ${totalPaid.toStringAsFixed(0)} ر.ي',
                              style: const TextStyle(
                                color: AppColors.success,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ModernStatCard(
                  title: 'المتبقي',
                  value: totalRemaining.toStringAsFixed(0),
                  icon: Icons.account_balance_wallet_rounded,
                  color: totalRemaining > 0
                      ? AppColors.danger
                      : AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModernStatCard(
                  title: 'العمليات',
                  value: operationCount.toString(),
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() => SizedBox(
    height: 50,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filterTypes.length,
      itemBuilder: (context, index) {
        final type = _filterTypes[index];
        final isSelected = _filterType == type;

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _filterType = type);
            _loadPurchases();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(left: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [AppColors.purchases, Color(0xFF6A1B9A)],
                    )
                  : null,
              color: isSelected ? null : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? null
                  : Border.all(color: AppColors.border.withOpacity(0.3)),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.purchases.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _buildPurchasesList(List<Purchase> purchases) {
    if (purchases.isEmpty) {
      return _buildEmptyState('لا توجد مشتريات', Icons.shopping_cart_outlined);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: purchases.asMap().entries.map((entry) {
          final index = entry.key;
          final purchase = entry.value;

          return TweenAnimationBuilder<double>(
            key: ValueKey(purchase.id),
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 400 + (index * 50)),
            curve: Curves.easeOutBack,
            builder: (context, value, child) => Transform.scale(
              scale: value.clamp(0.0, 1.0),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: PurchaseItemCard(
                    purchase: purchase,
                    onTap: () => _showPurchaseDetails(purchase),
                    onDelete: () => _deletePurchase(purchase),
                    onCancel: purchase.status == 'نشط'
                        ? () => _cancelPurchase(purchase)
                        : null,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLoadingState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) => _buildShimmerCard()),
    ),
  );

  Widget _buildShimmerCard() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.border.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 14,
                width: 150,
                decoration: BoxDecoration(
                  color: AppColors.border.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 10,
                width: 100,
                decoration: BoxDecoration(
                  color: AppColors.border.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildErrorState(PurchasesError state) => Center(
    child: Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.bounceOut,
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: Container(
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
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 60,
                  color: AppColors.danger,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'حدث خطأ',
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
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
            onPressed: () {
              HapticFeedback.lightImpact();
              _loadPurchases();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purchases,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(
              'إعادة المحاولة',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildEmptyState(String message, IconData icon) => Center(
    child: Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.purchases.withOpacity(0.05),
                      AppColors.info.withOpacity(0.03),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 70, color: AppColors.textHint),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          const Text(
            'ابدأ بإضافة مشتريات جديدة',
            style: TextStyle(color: AppColors.textHint, fontSize: 14),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showAddPurchaseScreen();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purchases,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'إضافة مشترى',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildFloatingActionButton(BuildContext context) => Positioned(
    bottom: 20,
    left: 20,
    child: FloatingActionButton.extended(
      onPressed: _showAddPurchaseScreen,
      backgroundColor: AppColors.purchases,
      icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white),
      label: const Text(
        'إضافة مشترى',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      elevation: 8,
    ),
  );

  List<Purchase> _filterPurchases(List<Purchase> purchases) {
    var filtered = purchases;

    if (_filterType != 'الكل' && _filterType != 'اليوم') {
      final now = DateTime.now();

      filtered = filtered.where((purchase) {
        final purchaseDate = DateTime.parse(purchase.date);

        switch (_filterType) {
          case 'الأسبوع':
            return now.difference(purchaseDate).inDays <= 7;
          case 'الشهر':
            return purchaseDate.year == now.year &&
                purchaseDate.month == now.month;
          case 'مدفوع':
            return purchase.paymentStatus == 'مدفوع';
          case 'غير مدفوع':
            return purchase.paymentStatus == 'غير مدفوع';
          case 'مدفوع جزئياً':
            return purchase.paymentStatus == 'مدفوع جزئياً';
          default:
            return true;
        }
      }).toList();
    }

    filtered.sort((a, b) {
      final dateComparison = b.date.compareTo(a.date);
      if (dateComparison != 0) return dateComparison;
      return b.time.compareTo(a.time);
    });

    return filtered;
  }

  void _showAddPurchaseScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPurchaseScreen()),
    ).then((_) => _loadPurchases());
  }

  void _showPurchaseDetails(Purchase purchase) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PurchaseDetailsScreen(purchase: purchase),
      ),
    ).then((_) => _loadPurchases());
  }

  Future<void> _deletePurchase(Purchase purchase) async {
    HapticFeedback.mediumImpact();
    if (purchase.id != null) {
      context.read<PurchasesBloc>().add(DeletePurchaseEvent(purchase.id!));
    }
  }

  Future<void> _cancelPurchase(Purchase purchase) async {
    HapticFeedback.mediumImpact();
    if (purchase.id != null) {
      context.read<PurchasesBloc>().add(CancelPurchaseEvent(purchase.id!));
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ModernStatCard extends StatelessWidget {
  const _ModernStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
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
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ],
    ),
  );
}

class _StatsBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.8,
      size.width * 0.5,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.6,
      size.width,
      size.height * 0.7,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
