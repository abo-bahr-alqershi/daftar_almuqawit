import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../domain/entities/sale.dart';
import '../../blocs/sales/sales_bloc.dart';
import '../../blocs/sales/sales_event.dart';
import '../../blocs/sales/sales_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as app_error;
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../navigation/route_names.dart';
import 'widgets/sale_item_card.dart';
import 'widgets/sale_summary.dart';
import 'widgets/sale_filters.dart';

/// الشاشة الرئيسية لإدارة المبيعات - تصميم Tesla/iOS متطور
class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> 
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _listFadeAnimation;
  
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  String _filterType = 'الكل';
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';
  bool _isSearchVisible = false;
  bool _isFabExpanded = false;
  
  final List<String> _filterTypes = [
    'الكل',
    'اليوم', 
    'الأسبوع',
    'الشهر',
    'مدفوع',
    'غير مدفوع',
    'بيع سريع',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSales();
    _scrollController.addListener(_onScroll);
  }

  void _initializeAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _headerSlideAnimation = Tween<double>(
      begin: -100,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _listFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeIn,
    ));
    
    _headerAnimationController.forward();
    _listAnimationController.forward();
    _fabAnimationController.forward();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && _isFabExpanded) {
      setState(() => _isFabExpanded = false);
    }
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _headerAnimationController.dispose();
    _listAnimationController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadSales() {
    if (_filterType == 'اليوم') {
      context.read<SalesBloc>().add(
        LoadTodaySales(_selectedDate.toIso8601String().split('T')[0]),
      );
    } else {
      context.read<SalesBloc>().add(LoadSales());
    }
  }

  void _showAddSaleScreen() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, RouteNames.addSale).then((_) => _loadSales());
  }

  void _showQuickSaleScreen() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, RouteNames.quickSale).then((_) => _loadSales());
  }

  void _showSaleDetails(Sale sale) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      RouteNames.saleDetails,
      arguments: sale,
    ).then((_) => _loadSales());
  }

  Future<void> _deleteSale(Sale sale) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showConfirmDialog(
      context,
      title: 'حذف البيع',
      message: 'هل أنت متأكد من حذف هذا البيع؟\nسيتم حذف جميع البيانات المرتبطة به.',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      isDangerous: true,
    );

    if (confirmed == true && sale.id != null) {
      context.read<SalesBloc>().add(DeleteSaleEvent(sale.id!));
    }
  }

  Future<void> _cancelSale(Sale sale) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showConfirmDialog(
      context,
      title: 'إلغاء البيع',
      message: 'هل أنت متأكد من إلغاء هذا البيع؟\nسيتم تحديث حالته إلى "ملغي".',
      confirmText: 'إلغاء البيع',
      cancelText: 'رجوع',
      isDangerous: true,
    );

    if (confirmed == true && sale.id != null) {
      context.read<SalesBloc>().add(CancelSaleEvent(sale.id!));
    }
  }

  List<Sale> _filterSales(List<Sale> sales) {
    var filtered = sales;

    // تصفية حسب البحث
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((sale) {
        final customerName = sale.customerName?.toLowerCase() ?? '';
        final qatTypeName = sale.qatTypeName?.toLowerCase() ?? '';
        final invoiceNumber = sale.invoiceNumber?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        
        return customerName.contains(query) ||
               qatTypeName.contains(query) ||
               invoiceNumber.contains(query);
      }).toList();
    }

    // تصفية حسب النوع
    if (_filterType != 'الكل' && _filterType != 'اليوم') {
      final now = DateTime.now();
      
      filtered = filtered.where((sale) {
        final saleDate = DateTime.parse(sale.date);
        
        switch (_filterType) {
          case 'الأسبوع':
            return now.difference(saleDate).inDays <= 7;
          case 'الشهر':
            return saleDate.year == now.year && 
                   saleDate.month == now.month;
          case 'مدفوع':
            return sale.paymentStatus == 'مدفوع';
          case 'غير مدفوع':
            return sale.paymentStatus == 'غير مدفوع' ||
                   sale.paymentStatus == 'مدفوع جزئياً';
          case 'بيع سريع':
            return sale.isQuickSale;
          default:
            return true;
        }
      }).toList();
    }

    // الترتيب حسب التاريخ والوقت
    filtered.sort((a, b) {
      final dateComparison = b.date.compareTo(a.date);
      if (dateComparison != 0) return dateComparison;
      return b.time.compareTo(a.time);
    });

    return filtered;
  }

  double _calculateTotalAmount(List<Sale> sales) {
    return sales.fold(0, (sum, sale) => sum + sale.totalAmount);
  }

  double _calculateTotalProfit(List<Sale> sales) {
    return sales.fold(0, (sum, sale) => sum + sale.profit);
  }

  double _calculateTotalPaid(List<Sale> sales) {
    return sales.fold(0, (sum, sale) => sum + sale.paidAmount);
  }

  double _calculateTotalRemaining(List<Sale> sales) {
    return sales.fold(0, (sum, sale) => sum + sale.remainingAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // خلفية متحركة
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
                  child: BlocConsumer<SalesBloc, SalesState>(
                    listener: (context, state) {
                      if (state is SaleOperationSuccess) {
                        _showSuccessMessage(state.message);
                        _loadSales();
                      } else if (state is SalesError) {
                        _showErrorMessage(state.message);
                      }
                    },
                    builder: (context, state) {
                      if (state is SalesLoading) {
                        return _buildLoadingState();
                      }

                      if (state is SalesError && state is! SalesLoaded) {
                        return _buildErrorState(state);
                      }

                      if (state is SalesLoaded) {
                        final filteredSales = _filterSales(state.sales);

                        if (state.sales.isEmpty) {
                          return _buildEmptyState();
                        }

                        if (filteredSales.isEmpty) {
                          return _buildNoResultsState();
                        }

                        return AnimatedBuilder(
                          animation: _listFadeAnimation,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _listFadeAnimation,
                              child: Column(
                                children: [
                                  // شريط البحث المتقدم
                                  _buildAdvancedSearchBar(),

                                  // ملخص المبيعات
                                  _buildAnimatedSummary(filteredSales),

                                  // عنوان القائمة
                                  _buildListHeader(filteredSales.length),

                                  // قائمة المبيعات
                                  _buildSalesList(filteredSales),
                                  
                                  const SizedBox(height: 100),
                                ],
                              ),
                            );
                          },
                        );
                      }

                      return _buildEmptyState();
                    },
                  ),
                ),
              ],
            ),
            
            // Floating Action Button المتطور
            _buildModernFAB(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: CustomPaint(
        painter: _SalesBackgroundPainter(),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: AnimatedBuilder(
        animation: _headerSlideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _headerSlideAnimation.value),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: FlexibleSpaceBar(
                title: _buildAppBarTitle(),
                background: _buildAppBarBackground(),
              ),
            ),
          );
        },
      ),
      actions: [
        // زر البحث المتقدم
        _buildAnimatedIconButton(
          icon: _isSearchVisible ? Icons.close : Icons.search,
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() => _isSearchVisible = !_isSearchVisible);
          },
        ),
        
        // زر البيع السريع
        _buildAnimatedIconButton(
          icon: Icons.flash_on,
          onPressed: _showQuickSaleScreen,
          color: Colors.amber,
        ),
        
        // زر التحديث
        _buildAnimatedIconButton(
          icon: Icons.refresh,
          onPressed: () {
            HapticFeedback.lightImpact();
            _loadSales();
          },
        ),
        
        // زر الفلاتر
        _buildAnimatedIconButton(
          icon: Icons.filter_list,
          onPressed: () => _showFiltersSheet(),
        ),
        
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.point_of_sale,
            size: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'المبيعات',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAppBarBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
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
              icon: Icon(
                icon,
                color: color ?? Colors.white,
                size: 22,
              ),
              onPressed: onPressed,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdvancedSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isSearchVisible ? 80 : 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'البحث عن عميل، نوع قات، أو رقم فاتورة...',
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.primary,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSummary(List<Sale> sales) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (value * 0.1),
          child: Opacity(
            opacity: value,
            child: SaleSummary(
              totalAmount: _calculateTotalAmount(sales),
              totalProfit: _calculateTotalProfit(sales),
              totalPaid: _calculateTotalPaid(sales),
              totalRemaining: _calculateTotalRemaining(sales),
              salesCount: sales.length,
            ),
          ),
        );
      },
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
                'قائمة المبيعات',
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

  Widget _buildSalesList(List<Sale> sales) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sales.length,
      itemBuilder: (context, index) {
        final sale = sales[index];
        
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(50 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SaleItemCard(
                    sale: sale,
                    onTap: () => _showSaleDetails(sale),
                    onDelete: () => _deleteSale(sale),
                    onCancel: sale.status == 'نشط' 
                        ? () => _cancelSale(sale) 
                        : null,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModernFAB() {
    return Positioned(
      bottom: 20,
      left: 20,
      child: AnimatedBuilder(
        animation: _fabScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabScaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // FAB الثانوي - بيع سريع
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(
                    0,
                    _isFabExpanded ? 0 : 60,
                    0,
                  ),
                  child: AnimatedOpacity(
                    opacity: _isFabExpanded ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'بيع سريع',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton(
                          heroTag: 'quick_sale_fab',
                          onPressed: _showQuickSaleScreen,
                          backgroundColor: AppColors.accent,
                          child: const Icon(
                            Icons.flash_on,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // FAB الرئيسي
                FloatingActionButton.extended(
                  heroTag: 'main_sale_fab',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (_isFabExpanded) {
                      _showAddSaleScreen();
                    } else {
                      setState(() => _isFabExpanded = !_isFabExpanded);
                      Future.delayed(const Duration(seconds: 3), () {
                        if (mounted) {
                          setState(() => _isFabExpanded = false);
                        }
                      });
                    }
                  },
                  backgroundColor: AppColors.primary,
                  icon: AnimatedRotation(
                    turns: _isFabExpanded ? 0.125 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                  label: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _isFabExpanded ? 'إضافة بيع' : 'جديد',
                      key: ValueKey<bool>(_isFabExpanded),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Loading
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
            'جاري تحميل المبيعات...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(SalesError state) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
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
                Icons.error_outline,
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
              onPressed: _loadSales,
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
            // Empty State Animation
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
                      Icons.point_of_sale,
                      size: 70,
                      color: AppColors.textHint,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد مبيعات',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ابدأ بإضافة أول عملية بيع',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _showAddSaleScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة بيع'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _showQuickSaleScreen,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: BorderSide(color: AppColors.accent),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.flash_on),
                  label: const Text('بيع سريع'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد نتائج',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'جرب تغيير معايير البحث أو الفلاتر',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _filterType = 'الكل';
                  _searchQuery = '';
                  _searchController.clear();
                  _selectedDate = DateTime.now();
                });
                _loadSales();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة تعيين'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFiltersSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: SaleFilters(
          selectedFilter: _filterType,
          searchQuery: _searchQuery,
          onFilterChanged: (filter) {
            setState(() {
              _filterType = filter;
            });
            _loadSales();
            Navigator.pop(context);
          },
          onSearchChanged: (query) {
            setState(() {
              _searchQuery = query;
            });
          },
        ),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorMessage(String message) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.error,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// رسام الخلفية
class _SalesBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // دوائر الخلفية
    paint.color = AppColors.primary.withOpacity(0.03);
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      100,
      paint,
    );
    
    paint.color = AppColors.accent.withOpacity(0.02);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.6),
      120,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}