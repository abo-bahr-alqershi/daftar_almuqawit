import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/purchases_management_tutorial_service.dart';
import '../../../domain/entities/purchase.dart';
import '../../blocs/purchases/purchases_bloc.dart';
import '../../blocs/purchases/purchases_event.dart';
import '../../blocs/purchases/purchases_state.dart';
import 'widgets/purchase_item_card.dart';
import 'widgets/purchase_summary.dart';
import 'add_purchase_screen.dart';
import 'purchase_details_screen.dart';
import '../inventory/add_return_screen.dart';

/// الشاشة الرئيسية لإدارة المشتريات - تصميم راقي ونظيف
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

  final GlobalKey _statsCardKey = GlobalKey();
  final GlobalKey _filterChipsKey = GlobalKey();
  final GlobalKey _purchasesListKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();
  final GlobalKey _dateFilterButtonKey = GlobalKey();
  final GlobalKey _refreshButtonKey = GlobalKey();

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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animationController.forward();

    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
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
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Stats Card
                      BlocBuilder<PurchasesBloc, PurchasesState>(
                        builder: (context, state) {
                          if (state is PurchasesLoaded) {
                            final filtered = _filterPurchases(state.purchases);
                            return _buildStatsCard(filtered);
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      const SizedBox(height: 24),

                      // Filter Section
                      _buildSectionHeader('التصنيف', Icons.filter_list_rounded),
                      const SizedBox(height: 12),
                      _buildFilterChips(),

                      const SizedBox(height: 24),

                      // Purchases List
                      _buildSectionHeader(
                        'المشتريات',
                        Icons.shopping_cart_outlined,
                      ),
                      const SizedBox(height: 12),

                      BlocConsumer<PurchasesBloc, PurchasesState>(
                        listener: (context, state) {
                          if (state is PurchasesError) {
                            _showSnackBar(state.message, isError: true);
                          } else if (state is PurchaseOperationSuccess) {
                            _showSnackBar(state.message, isError: false);
                          }
                        },
                        builder: (context, state) {
                          if (state is PurchasesLoading) {
                            return _buildLoadingState();
                          }

                          if (state is PurchasesError) {
                            return _buildErrorState(state.message);
                          }

                          if (state is PurchasesLoaded) {
                            final filtered = _filterPurchases(state.purchases);
                            return _buildPurchasesList(filtered);
                          }

                          return _buildEmptyState();
                        },
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),

            // FAB
            _buildFAB(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final opacity = (_scrollOffset / 80).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Colors.white.withOpacity(opacity),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF8B5CF6).withOpacity(0.05),
                const Color(0xFFF8F9FA),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shopping_cart_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'إدارة المشتريات',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        BlocBuilder<PurchasesBloc, PurchasesState>(
                          builder: (context, state) {
                            if (state is PurchasesLoaded) {
                              return Text(
                                '${state.purchases.length} عملية شراء',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
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
            ),
          ),
        ),
      ),
      actions: [
        Container(
          key: _dateFilterButtonKey,
          margin: const EdgeInsets.only(left: 8),
          child: _buildAppBarAction(
            icon: Icons.calendar_today_outlined,
            onTap: () async {
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
        ),
        Container(
          key: _refreshButtonKey,
          margin: const EdgeInsets.only(left: 8),
          child: _buildAppBarAction(
            icon: Icons.refresh_rounded,
            onTap: () {
              HapticFeedback.mediumImpact();
              _loadPurchases();
            },
          ),
        ),
        _buildAppBarAction(
          icon: Icons.help_outline_rounded,
          onTap: () {
            HapticFeedback.lightImpact();
            PurchasesManagementTutorialService.showScreenTutorial(
              context: context,
              statsCardKey: _statsCardKey,
              filterChipsKey: _filterChipsKey,
              purchasesListKey: _purchasesListKey,
              fabKey: _fabKey,
              dateFilterButtonKey: _dateFilterButtonKey,
              refreshButtonKey: _refreshButtonKey,
              scrollController: _scrollController,
              onFinish: () {
                _showSnackBar('تمت جولة التعليمات بنجاح', isError: false);
              },
            );
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF374151)),
      ),
    );
  }

  Widget _buildStatsCard(List<Purchase> purchases) {
    final totalAmount = purchases.fold<double>(
      0,
      (sum, p) => sum + p.totalAmount,
    );
    final totalPaid = purchases.fold<double>(0, (sum, p) => sum + p.paidAmount);
    final totalRemaining = purchases.fold<double>(
      0,
      (sum, p) => sum + p.remainingAmount,
    );

    return Container(
      key: _statsCardKey,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Main Stats Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
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
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${purchases.length} عملية',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4ADE80),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'نشط',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween(begin: 0, end: totalAmount),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Text(
                            'ر.ي',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Secondary Stats
          Row(
            children: [
              Expanded(
                child: _buildSecondaryStatCard(
                  icon: Icons.check_circle_outline,
                  label: 'المدفوع',
                  value: totalPaid,
                  color: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSecondaryStatCard(
                  icon: Icons.pending_outlined,
                  label: 'المتبقي',
                  value: totalRemaining,
                  color: totalRemaining > 0
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryStatCard({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
  }) {
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
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0, end: value),
            curve: Curves.easeOutCubic,
            builder: (context, animValue, child) {
              return Text(
                '${animValue.toStringAsFixed(0)} ر.ي',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF8B5CF6)),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      key: _filterChipsKey,
      height: 42,
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
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF8B5CF6) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF8B5CF6)
                      : const Color(0xFFE5E7EB),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPurchasesList(List<Purchase> purchases) {
    if (purchases.isEmpty) {
      return _buildEmptyState();
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
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Container(
                  key: index == 0 ? _purchasesListKey : null,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: PurchaseItemCard(
                    purchase: purchase,
                    onTap: () => _showPurchaseDetails(purchase),
                    onDelete: () => _openRefundScreen(purchase),
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

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: List.generate(3, (index) => _buildShimmerCard())),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 32,
              color: Color(0xFFDC2626),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _loadPurchases();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
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
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 40,
              color: Color(0xFF8B5CF6),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'لا توجد مشتريات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ابدأ بإضافة عملية شراء جديدة',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showAddPurchaseScreen();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'إضافة مشترى',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Positioned(
      bottom: 20,
      left: 20,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          _showAddPurchaseScreen();
        },
        child: Container(
          key: _fabKey,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_shopping_cart, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'إضافة مشترى',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  void _openRefundScreen(Purchase purchase) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddReturnScreen()),
    ).then((_) => _loadPurchases());
  }

  Future<void> _cancelPurchase(Purchase purchase) async {
    HapticFeedback.mediumImpact();
    if (purchase.id != null) {
      context.read<PurchasesBloc>().add(CancelPurchaseEvent(purchase.id!));
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFDC2626)
            : const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
