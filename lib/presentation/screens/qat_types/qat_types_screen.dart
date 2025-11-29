import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/qat_type.dart';
import '../../blocs/qat_types/qat_types_bloc.dart';
import '../../blocs/qat_types/qat_types_event.dart';
import '../../blocs/qat_types/qat_types_state.dart';
import '../../navigation/route_names.dart';
import '../../widgets/common/confirm_dialog.dart';
import './widgets/qat_type_card.dart';
import '../../../core/services/qat_types_tutorial_service.dart';

/// شاشة أنواع القات الرئيسية - تصميم راقي هادئ
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

  // مفاتيح التعليمات التفاعلية
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
      context.read<QatTypesBloc>().add(LoadQatTypes());

      // التحقق من معاملات التعليمات
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
        setState(() {
          _showTutorial = false;
        });
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

                      BlocConsumer<QatTypesBloc, QatTypesState>(
                        listener: (context, state) {
                          if (state is QatTypeOperationSuccess) {
                            _showSuccessMessage(state.message);
                          } else if (state is QatTypesError) {
                            _showErrorMessage(state.message);
                          }
                        },
                        builder: (context, state) {
                          if (state is QatTypesLoading) {
                            return _buildShimmerStats();
                          }
                          if (state is QatTypesLoaded ||
                              state is QatTypesSearchResults) {
                            final qatTypes = state is QatTypesLoaded
                                ? state.qatTypes
                                : (state as QatTypesSearchResults).results;

                            return Column(
                              children: [
                                _buildStatsCard(qatTypes),
                                const SizedBox(height: 32),
                                _buildSectionTitle(
                                  'أنواع القات',
                                  Icons.grass_rounded,
                                ),
                                const SizedBox(height: 16),
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
          AppColors.primary.withOpacity(0.08),
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
                            colors: [AppColors.primary, AppColors.success],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.grass_rounded,
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
                              'أنواع القات',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'إدارة جميع أنواع القات',
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
      actions: [
        _buildIconButton(
          Icons.search_rounded,
          key: _searchFieldKey,
          onPressed: () => _showSearchDialog(),
        ),
        _buildIconButton(
          Icons.refresh_rounded,
          onPressed: () {
            HapticFeedback.lightImpact();
            _loadQatTypes();
          },
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: const Icon(
              Icons.help_outline,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          onPressed: () {
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
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildIconButton(IconData icon,
          {required VoidCallback onPressed, Key? key}) =>
      IconButton(
        key: key,
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
        onPressed: onPressed,
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
                AppColors.primary.withOpacity(0.1),
                AppColors.success.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
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
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.success],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
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
                                'إجمالي الأنواع',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$totalTypes نوع',
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
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1200),
                        tween: Tween(begin: 0, end: avgBuyPrice),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                value.toStringAsFixed(0),
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
                          );
                        },
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
                              Icons.show_chart_rounded,
                              size: 16,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'متوسط سعر الشراء',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 11,
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
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.7,
            children: [
              _buildStatItem(
                icon: Icons.price_check_rounded,
                label: 'بأسعار',
                value: withPrices.toDouble(),
                color: AppColors.success,
              ),
              _buildStatItem(
                icon: Icons.grid_view_rounded,
                label: 'أنواع متاحة',
                value: totalTypes.toDouble(),
                color: AppColors.info,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            tween: Tween(begin: 0, end: value),
            curve: Curves.easeOutCubic,
            builder: (context, animValue, child) {
              return Text(
                animValue.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 17,
                  color: color,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1.3,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['الكل', 'ممتاز', 'جيد', 'عادي'];

    return Container(
      key: _filterButtonKey,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.success],
                      )
                    : null,
                color: isSelected ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.border.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  letterSpacing: -0.3,
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
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final card = QatTypeCard(
          qatType: qatTypes[index],
          onTap: () => _showQatTypeDetails(qatTypes[index]),
          onDelete: () => _deleteQatType(qatTypes[index]),
        );

        if (index == 0 && _tutorialOperation == 'edit') {
          return Container(key: _firstItemKey, child: card);
        }

        return card;
      },
    );
  }

  Widget _buildShimmerStats() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    height: 200,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
    ),
    child: const Center(child: CircularProgressIndicator()),
  );

  Widget _buildEmptyState() => Container(
    padding: const EdgeInsets.all(40),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.grass_rounded,
              size: 60,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'لا توجد أنواع قات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ابدأ بإضافة أول نوع قات',
            style: TextStyle(fontSize: 14, color: AppColors.textHint),
          ),
        ],
      ),
    ),
  );

  Widget _buildFloatingActionButton(BuildContext context) => Positioned(
    bottom: 20,
    left: 20,
    child: FloatingActionButton.extended(
      key: _addButtonKey,
      onPressed: () => _navigateToAdd(context),
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'نوع جديد',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      elevation: 8,
    ),
  );

  void _navigateToAdd(BuildContext context) {
    HapticFeedback.lightImpact();
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
    ).then((_) {
      _loadQatTypes();
    });
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
      context.read<QatTypesBloc>().add(DeleteQatTypeEvent(qatType.id!));
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('البحث عن نوع قات'),
        content: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'أدخل اسم النوع...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: _performSearch,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              _performSearch('');
              Navigator.pop(context);
            },
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _StatsBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = Colors.white.withOpacity(0.05);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 60, paint);

    paint.color = Colors.white.withOpacity(0.03);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 80, paint);

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 5; i++) {
      final y = size.height * (i + 1) / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width * 0.3, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
