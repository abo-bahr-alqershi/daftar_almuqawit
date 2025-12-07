import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/qat_types_tutorial_service.dart';
import '../../../domain/entities/qat_type.dart';
import '../../blocs/qat_types/qat_types_bloc.dart';
import '../../blocs/qat_types/qat_types_event.dart';
import '../../blocs/qat_types/qat_types_state.dart';
import '../../navigation/route_names.dart';
import '../../widgets/common/confirm_dialog.dart';
import './widgets/qat_type_card.dart';

/// شاشة أنواع القات الرئيسية - تصميم راقي ونظيف
class QatTypesScreen extends StatefulWidget {
  const QatTypesScreen({super.key});

  @override
  State<QatTypesScreen> createState() => _QatTypesScreenState();
}

class _QatTypesScreenState extends State<QatTypesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  String _selectedFilter = 'الكل';
  final TextEditingController _searchController = TextEditingController();

  final GlobalKey _addButtonKey = GlobalKey();
  final GlobalKey _searchFieldKey = GlobalKey();
  final GlobalKey _filterButtonKey = GlobalKey();
  final GlobalKey _listViewKey = GlobalKey();
  final GlobalKey _firstItemKey = GlobalKey();

  bool _showTutorial = false;
  String? _tutorialOperation;

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
      context.read<QatTypesBloc>().add(LoadQatTypes());

      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['showTutorial'] == true) {
        setState(() {
          _showTutorial = true;
          _tutorialOperation = args['operation'];
        });
        if (_tutorialOperation != 'edit') {
          _startTutorial();
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    QatTypesTutorialService.dispose();
    super.dispose();
  }

  void _startTutorial() {
    if (!_showTutorial) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        QatTypesTutorialService.showMainTutorial(
          context: context,
          addButtonKey: _addButtonKey,
          searchFieldKey: _searchFieldKey,
          filterButtonKey: _filterButtonKey,
          listViewKey: _listViewKey,
          onNext: () {},
          scrollController: _scrollController,
        );
        setState(() => _showTutorial = false);
      }
    });
  }

  void _loadQatTypes() {
    if (_selectedFilter == 'الكل') {
      context.read<QatTypesBloc>().add(LoadQatTypes());
    } else {
      context.read<QatTypesBloc>().add(
        FilterQatTypesByQuality(_selectedFilter),
      );
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      _loadQatTypes();
    } else {
      context.read<QatTypesBloc>().add(SearchQatTypes(query));
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
                  child: BlocConsumer<QatTypesBloc, QatTypesState>(
                    listener: (context, state) {
                      if (state is QatTypeOperationSuccess) {
                        _showSnackBar(state.message, isError: false);
                      } else if (state is QatTypesError) {
                        _showSnackBar(state.message, isError: true);
                      }
                    },
                    builder: (context, state) {
                      if (state is QatTypesLoading) {
                        return _buildLoadingState();
                      }

                      if (state is QatTypesLoaded ||
                          state is QatTypesSearchResults) {
                        final qatTypes = state is QatTypesLoaded
                            ? state.qatTypes
                            : (state as QatTypesSearchResults).results;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            _buildStatsCard(qatTypes),
                            const SizedBox(height: 24),
                            _buildSectionHeader(
                              'أنواع القات',
                              Icons.grass_outlined,
                            ),
                            const SizedBox(height: 12),
                            _buildFilterChips(),
                            const SizedBox(height: 16),
                            if (qatTypes.isEmpty)
                              _buildEmptyState()
                            else
                              _buildQatTypesList(qatTypes),
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
                const Color(0xFF16A34A).withOpacity(0.05),
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
                        colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF16A34A).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.grass_rounded,
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
                          'أنواع القات',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        BlocBuilder<QatTypesBloc, QatTypesState>(
                          builder: (context, state) {
                            if (state is QatTypesLoaded) {
                              return Text(
                                '${state.qatTypes.length} نوع',
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
          key: _searchFieldKey,
          margin: const EdgeInsets.only(left: 8),
          child: _buildAppBarAction(
            icon: Icons.search,
            onTap: () => _showSearchDialog(),
          ),
        ),
        _buildAppBarAction(
          icon: Icons.refresh,
          onTap: () {
            HapticFeedback.mediumImpact();
            _loadQatTypes();
          },
        ),
        _buildAppBarAction(
          icon: Icons.help_outline,
          onTap: () {
            HapticFeedback.lightImpact();
            QatTypesTutorialService.showMainTutorial(
              context: context,
              addButtonKey: _addButtonKey,
              searchFieldKey: _searchFieldKey,
              filterButtonKey: _filterButtonKey,
              listViewKey: _listViewKey,
              scrollController: _scrollController,
              onNext: () {},
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
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF374151)),
      ),
    );
  }

  Widget _buildStatsCard(List<QatType> qatTypes) {
    final totalTypes = qatTypes.length;
    final withPrices = qatTypes.where((qt) {
      return qt.defaultBuyPrice != null && qt.defaultSellPrice != null;
    }).length;
    final avgBuyPrice =
        qatTypes
            .where((qt) => qt.defaultBuyPrice != null)
            .fold(0.0, (sum, qt) => sum + (qt.defaultBuyPrice ?? 0)) /
        (qatTypes.where((qt) => qt.defaultBuyPrice != null).length > 0
            ? qatTypes.where((qt) => qt.defaultBuyPrice != null).length
            : 1);

    return Container(
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
                colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF16A34A).withOpacity(0.3),
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
                          'إجمالي الأنواع',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$totalTypes نوع',
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
                  tween: Tween(begin: 0, end: avgBuyPrice),
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
                const SizedBox(height: 8),
                const Text(
                  'متوسط سعر الشراء',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
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
                  icon: Icons.price_check,
                  label: 'بأسعار محددة',
                  value: withPrices.toDouble(),
                  color: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSecondaryStatCard(
                  icon: Icons.grid_view,
                  label: 'أنواع متاحة',
                  value: totalTypes.toDouble(),
                  color: const Color(0xFF0EA5E9),
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
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
                animValue.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 18,
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
              color: const Color(0xFF16A34A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF16A34A)),
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
    final filters = ['الكل', 'ممتاز', 'جيد', 'عادي'];

    return SizedBox(
      key: _filterButtonKey,
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedFilter = filter);
              _loadQatTypes();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF16A34A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFE5E7EB),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF16A34A).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                filter,
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

  Widget _buildQatTypesList(List<QatType> qatTypes) {
    return ListView.separated(
      key: _listViewKey,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: qatTypes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final qatType = qatTypes[index];

        return TweenAnimationBuilder<double>(
          key: ValueKey(qatType.id),
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Container(
                key: index == 0 && _tutorialOperation == 'edit'
                    ? _firstItemKey
                    : null,
                child: QatTypeCard(
                  qatType: qatType,
                  onTap: () => _showQatTypeDetails(qatType),
                  onDelete: () => _deleteQatType(qatType),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF16A34A)),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(3, (index) => _buildShimmerCard()),
        ],
      ),
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
              color: const Color(0xFF16A34A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.grass_outlined,
              size: 40,
              color: Color(0xFF16A34A),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'لا توجد أنواع قات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ابدأ بإضافة نوع قات جديد',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _navigateToAdd(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'إضافة نوع',
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
        onTap: () => _navigateToAdd(context),
        child: Container(
          key: _addButtonKey,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF16A34A).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'نوع جديد',
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

  void _navigateToAdd(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, RouteNames.addQatType).then((_) {
      _loadQatTypes();
    });
  }

  void _showQatTypeDetails(QatType qatType) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      RouteNames.qatTypeDetails,
      arguments: qatType.id,
    ).then((_) => _loadQatTypes());
  }

  Future<void> _deleteQatType(QatType qatType) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'حذف النوع',
      message: 'هل أنت متأكد من حذف نوع "${qatType.name}"؟',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      isDangerous: true,
    );

    if (confirmed == true && qatType.id != null) {
      HapticFeedback.heavyImpact();
      context.read<QatTypesBloc>().add(DeleteQatTypeEvent(qatType.id!));
    }
  }

  void _showSearchDialog() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Color(0xFF16A34A),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'البحث عن نوع قات',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'أدخل اسم النوع...',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: _performSearch,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _performSearch('');
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'بحث',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
