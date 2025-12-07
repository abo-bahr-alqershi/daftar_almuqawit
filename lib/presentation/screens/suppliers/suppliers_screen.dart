import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/suppliers_management_tutorial_service.dart';
import '../../../domain/entities/supplier.dart';
import '../../blocs/suppliers/suppliers_bloc.dart';
import '../../blocs/suppliers/suppliers_event.dart';
import '../../blocs/suppliers/suppliers_state.dart';
import 'widgets/supplier_card.dart';
import 'widgets/supplier_search_bar.dart';
import 'add_supplier_screen.dart';
import 'supplier_details_screen.dart';
import 'suppliers_list_screen.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  String _searchQuery = '';
  String _filterType = 'الكل';

  final List<String> _filterTypes = [
    'الكل',
    'موثوق',
    'جيد',
    'متوسط',
    'ضعيف',
    'عليه دين',
  ];

  final GlobalKey _statsCardKey = GlobalKey();
  final GlobalKey _filterChipsKey = GlobalKey();
  final GlobalKey _suppliersListKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();
  final GlobalKey _fullListButtonKey = GlobalKey();
  final GlobalKey _searchButtonKey = GlobalKey();
  final GlobalKey _refreshButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SuppliersBloc>().add(LoadSuppliers());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: CustomScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  BlocBuilder<SuppliersBloc, SuppliersState>(
                    builder: (context, state) {
                      if (state is SuppliersLoaded) {
                        return _buildStatsSection(state.suppliers);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('تصنيف الموردين'),
                  const SizedBox(height: 12),
                  _buildFilterChips(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('قائمة الموردين'),
                  const SizedBox(height: 12),
                  BlocConsumer<SuppliersBloc, SuppliersState>(
                    listener: (context, state) {
                      if (state is SuppliersError) {
                        _showErrorSnackBar(state.message);
                      }
                    },
                    builder: (context, state) {
                      if (state is SuppliersLoading) {
                        return _buildLoadingState();
                      }
                      if (state is SuppliersError) {
                        return _buildErrorState(state);
                      }
                      if (state is SuppliersLoaded) {
                        final filtered = _filterSuppliers(state.suppliers);
                        return _buildSuppliersList(filtered);
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
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    final opacity = (_scrollOffset / 80).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white.withOpacity(opacity),
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'إدارة الموردين',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        BlocBuilder<SuppliersBloc, SuppliersState>(
                          builder: (context, state) {
                            if (state is SuppliersLoaded) {
                              return Text(
                                '${state.suppliers.length} مورد مسجل',
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
        _buildAppBarAction(
          key: _fullListButtonKey,
          icon: Icons.list_outlined,
          onTap: _navigateToFullList,
        ),
        _buildAppBarAction(
          key: _searchButtonKey,
          icon: Icons.search,
          onTap: () => _showSearchSheet(context),
        ),
        _buildAppBarAction(
          key: _refreshButtonKey,
          icon: Icons.refresh,
          onTap: () {
            HapticFeedback.lightImpact();
            context.read<SuppliersBloc>().add(LoadSuppliers());
          },
        ),
        _buildAppBarAction(icon: Icons.help_outline, onTap: _showTutorial),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildAppBarAction({
    GlobalKey? key,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Material(
        key: key,
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(icon, color: const Color(0xFF6B7280), size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildStatsSection(List<Supplier> suppliers) {
    final total = suppliers.length;
    final trusted = suppliers
        .where((s) => s.trustLevel == 'ممتاز' || s.trustLevel == 'جيد')
        .length;
    final withDebt = suppliers.where((s) => s.totalDebtToHim > 0).length;
    final totalPurchases = suppliers.fold(
      0.0,
      (sum, s) => sum + s.totalPurchases,
    );
    final totalDebt = suppliers.fold(0.0, (sum, s) => sum + s.totalDebtToHim);
    final avgRating = suppliers.isEmpty
        ? 0.0
        : suppliers.fold(0.0, (sum, s) => sum + s.qualityRating) /
              suppliers.length;

    return Container(
      key: _statsCardKey,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Main stats card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.25),
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
                    const Text(
                      'إجمالي الموردين',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFFCD34D),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            avgRating.toStringAsFixed(1),
                            style: const TextStyle(
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
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      total.toString(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                        'مورد',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildMiniStat(
                      'موثوق',
                      trusted.toString(),
                      Icons.verified_outlined,
                    ),
                    const SizedBox(width: 16),
                    _buildMiniStat(
                      'المشتريات',
                      '${_formatNumber(totalPurchases)} ر.ي',
                      Icons.shopping_cart_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Secondary stats
          Row(
            children: [
              Expanded(
                child: _buildSecondaryStatCard(
                  'له دين',
                  withDebt.toString(),
                  Icons.receipt_long_outlined,
                  const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSecondaryStatCard(
                  'إجمالي الديون',
                  '${_formatNumber(totalDebt)} ر.ي',
                  Icons.account_balance_wallet_outlined,
                  const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryStatCard(
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
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      key: _filterChipsKey,
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filterTypes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = _filterTypes[index];
          final isSelected = _filterType == type;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _filterType = type);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuppliersList(List<Supplier> suppliers) {
    if (suppliers.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: suppliers.asMap().entries.map((entry) {
          final index = entry.key;
          final supplier = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: index == 0
                ? Container(
                    key: _suppliersListKey,
                    child: SupplierCard(
                      supplier: supplier,
                      onTap: () => _showSupplierDetails(supplier),
                      onDelete: null,
                    ),
                  )
                : SupplierCard(
                    supplier: supplier,
                    onTap: () => _showSupplierDetails(supplier),
                    onDelete: null,
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 100,
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

  Widget _buildErrorState(SuppliersError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Color(0xFFDC2626),
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
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
              state.message,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.read<SuppliersBloc>().add(LoadSuppliers());
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('إعادة المحاولة'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6366F1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                color: Color(0xFF9CA3AF),
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _searchQuery.isEmpty ? 'لا يوجد موردين' : 'لا توجد نتائج',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ابدأ بإضافة موردين جدد',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      key: _fabKey,
      onPressed: _showAddSupplierScreen,
      backgroundColor: const Color(0xFF6366F1),
      elevation: 2,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }

  List<Supplier> _filterSuppliers(List<Supplier> suppliers) {
    var filtered = suppliers;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((s) {
        final query = _searchQuery.toLowerCase();
        return s.name.toLowerCase().contains(query) ||
            (s.phone?.contains(query) ?? false) ||
            (s.area?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (_filterType != 'الكل') {
      filtered = filtered.where((s) {
        switch (_filterType) {
          case 'موثوق':
            return s.trustLevel == 'ممتاز';
          case 'جيد':
            return s.trustLevel == 'جيد';
          case 'متوسط':
            return s.trustLevel == 'متوسط';
          case 'ضعيف':
            return s.trustLevel == 'ضعيف';
          case 'عليه دين':
            return s.totalDebtToHim > 0;
          default:
            return true;
        }
      }).toList();
    }

    filtered.sort((a, b) => b.totalPurchases.compareTo(a.totalPurchases));
    return filtered;
  }

  void _showAddSupplierScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSupplierScreen()),
    ).then((_) => context.read<SuppliersBloc>().add(LoadSuppliers()));
  }

  void _showSupplierDetails(Supplier supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupplierDetailsScreen(supplier: supplier),
      ),
    ).then((_) => context.read<SuppliersBloc>().add(LoadSuppliers()));
  }

  void _navigateToFullList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SuppliersListScreen()),
    ).then((_) => context.read<SuppliersBloc>().add(LoadSuppliers()));
  }

  void _showSearchSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
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
            SupplierSearchBar(
              onSearch: (query) {
                setState(() => _searchQuery = query);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTutorial() {
    HapticFeedback.lightImpact();
    SuppliersManagementTutorialService.showScreenTutorial(
      context: context,
      statsCardKey: _statsCardKey,
      filterChipsKey: _filterChipsKey,
      suppliersListKey: _suppliersListKey,
      fabKey: _fabKey,
      fullListButtonKey: _fullListButtonKey,
      searchButtonKey: _searchButtonKey,
      refreshButtonKey: _refreshButtonKey,
      scrollController: _scrollController,
      onFinish: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تمت جولة التعليمات'),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
