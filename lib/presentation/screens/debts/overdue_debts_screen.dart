import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../blocs/debts/debts_bloc.dart';
import '../../blocs/debts/debts_event.dart';
import '../../blocs/debts/debts_state.dart';
import './widgets/debt_card.dart';

class OverdueDebtsScreen extends StatefulWidget {
  const OverdueDebtsScreen({super.key});

  @override
  State<OverdueDebtsScreen> createState() => _OverdueDebtsScreenState();
}

class _OverdueDebtsScreenState extends State<OverdueDebtsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  String _selectedSort = 'التاريخ';

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
      context.read<DebtsBloc>().add(LoadOverdueDebts());
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
                      BlocBuilder<DebtsBloc, DebtsState>(
                        builder: (context, state) {
                          if (state is DebtsLoading) {
                            return _buildShimmerLoading();
                          }
                          if (state is OverdueDebtsLoaded) {
                            final sortedDebts = _sortDebts(state.overdueDebts);
                            return Column(
                              children: [
                                _buildOverdueStatsCard(state.overdueDebts),
                                const SizedBox(height: 32),
                                _buildSortingChips(),
                                const SizedBox(height: 20),
                                _buildDebtsList(sortedDebts),
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
          ],
        ),
        floatingActionButton: _buildFloatingActions(),
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 400,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.danger.withOpacity(0.08),
              AppColors.warning.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar(double topPadding) {
    final opacity = (_scrollOffset / 140).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.background.withOpacity(opacity),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_active_rounded,
                color: AppColors.danger,
                size: 20,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                _sendRemindersToAll();
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: EdgeInsets.only(bottom: 16, top: topPadding),
        title: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 200),
          child: Text(
            'الديون المتأخرة',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
        background: Container(
          padding: EdgeInsets.only(top: topPadding + 60, right: 20, left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedOpacity(
                opacity: 1 - opacity,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  'الديون المتأخرة',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverdueStatsCard(List overdueDebts) {
    final totalOverdue = overdueDebts.fold<double>(
      0.0,
      (sum, debt) => sum + (debt.remainingAmount ?? 0.0),
    );

    final mostOverdue = overdueDebts.isNotEmpty
        ? overdueDebts.reduce((curr, next) {
            final currDays = _getDaysOverdue(curr);
            final nextDays = _getDaysOverdue(next);
            return currDays > nextDays ? curr : next;
          })
        : null;

    final maxOverdueDays = mostOverdue != null
        ? _getDaysOverdue(mostOverdue)
        : 0;

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
              ),
            ),
        child: Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.danger, AppColors.warning],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.danger.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 12),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Stack(
            children: [
              CustomPaint(
                painter: _StatsBackgroundPainter(),
                size: Size.infinite,
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.warning_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$maxOverdueDays يوم',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      'إجمالي المتأخر',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Formatters.formatCurrency(totalOverdue),
                          style: AppTextStyles.displayMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 42,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            'ريال',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${overdueDebts.length} دين متأخر',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortingChips() {
    final sortOptions = ['التاريخ', 'المبلغ', 'الأحدث', 'الأقدم'];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sortOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final option = sortOptions[index];
          final isSelected = _selectedSort == option;
          final delay = 200 + (index * 100);

          return FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  (delay / 1200).clamp(0.0, 1.0),
                  ((delay + 300) / 1200).clamp(0.0, 1.0),
                  curve: Curves.easeOutCubic,
                ),
              ),
            ),
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        (delay / 1200).clamp(0.0, 1.0),
                        ((delay + 300) / 1200).clamp(0.0, 1.0),
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedSort = option;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [AppColors.danger, AppColors.warning],
                          )
                        : null,
                    color: isSelected ? null : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.danger
                          : AppColors.border.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    option,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDebtsList(List debts) {
    if (debts.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: debts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final debt = debts[index];
        final delay = 400 + (index * 100);

        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                (delay / 1200).clamp(0.0, 1.0),
                ((delay + 400) / 1200).clamp(0.0, 1.0),
                curve: Curves.easeOutCubic,
              ),
            ),
          ),
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      (delay / 1200).clamp(0.0, 1.0),
                      ((delay + 400) / 1200).clamp(0.0, 1.0),
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                ),
            child: DebtCard(
              debt: debt,
              // isOverdue: true, // DebtCard يحسبها تلقائياً
              // daysOverdue: _getDaysOverdue(debt), // DebtCard يحسبها تلقائياً
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pushNamed(
                  context,
                  '/debt-details',
                  arguments: debt.id,
                );
              },
              onPayTap: () {
                // تغيير من onPayment إلى onPayTap
                HapticFeedback.lightImpact();
                Navigator.pushNamed(
                  context,
                  '/debt-payment',
                  arguments: {
                    'debtId': debt.id,
                    'remainingAmount': debt.remainingAmount,
                  },
                );
              },
              onReminderTap: () {
                // تغيير من onReminder إلى onReminderTap
                HapticFeedback.lightImpact();
                _sendReminder(debt.id?.toString() ?? '0');
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.1),
                  AppColors.success.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              size: 64,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد ديون متأخرة',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جميع الديون مسددة أو ضمن المواعيد',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: [
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        const SizedBox(height: 32),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, __) => Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'reminder',
          onPressed: () {
            HapticFeedback.mediumImpact();
            _sendRemindersToAll();
          },
          backgroundColor: AppColors.warning,
          child: const Icon(Icons.notifications_active_rounded),
        ),
      ],
    );
  }

  int _getDaysOverdue(debt) {
    if (debt.dueDate == null) return 0;
    try {
      final dueDate = DateTime.parse(debt.dueDate);
      return DateTime.now().difference(dueDate).inDays;
    } catch (e) {
      return 0;
    }
  }

  List _sortDebts(List debts) {
    final sorted = List.from(debts);
    switch (_selectedSort) {
      case 'التاريخ':
        sorted.sort((a, b) {
          final aDays = _getDaysOverdue(a);
          final bDays = _getDaysOverdue(b);
          return bDays.compareTo(aDays);
        });
        break;
      case 'المبلغ':
        sorted.sort(
          (a, b) =>
              (b.remainingAmount ?? 0.0).compareTo(a.remainingAmount ?? 0.0),
        );
        break;
      case 'الأحدث':
        sorted.sort((a, b) {
          try {
            final aDate = DateTime.parse(a.createdAt ?? '');
            final bDate = DateTime.parse(b.createdAt ?? '');
            return bDate.compareTo(aDate);
          } catch (e) {
            return 0;
          }
        });
        break;
      case 'الأقدم':
        sorted.sort((a, b) {
          try {
            final aDate = DateTime.parse(a.createdAt ?? '');
            final bDate = DateTime.parse(b.createdAt ?? '');
            return aDate.compareTo(bDate);
          } catch (e) {
            return 0;
          }
        });
        break;
    }
    return sorted;
  }

  void _sendReminder(String debtId) {
    context.read<DebtsBloc>().add(SendDebtReminder(debtId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم إرسال التذكير'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _sendRemindersToAll() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم إرسال التذكيرات لجميع العملاء'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _StatsBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.7, 0);
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.3,
      size.width,
      size.height * 0.5,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);

    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.7),
      60,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.2),
      40,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
