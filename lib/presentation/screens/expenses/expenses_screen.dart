import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/expense.dart';
import '../../blocs/expenses/expenses_bloc.dart';
import '../../blocs/expenses/expenses_event.dart';
import '../../blocs/expenses/expenses_state.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../navigation/route_names.dart';
import 'widgets/expense_card.dart';
import 'widgets/expense_chart.dart';

/// الشاشة الرئيسية لإدارة المصروفات - تصميم راقي هادئ
class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  String _selectedFilter = 'الكل';
  bool _showChart = false;

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
      context.read<ExpensesBloc>().add(LoadExpenses());
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

                      BlocConsumer<ExpensesBloc, ExpensesState>(
                        listener: (context, state) {
                          if (state is ExpenseOperationSuccess) {
                            _showSuccessMessage(state.message);
                          } else if (state is ExpensesError) {
                            _showErrorMessage(state.message);
                          }
                        },
                        builder: (context, state) {
                          if (state is ExpensesLoading) {
                            return _buildShimmerStats();
                          }
                          if (state is ExpensesLoaded) {
                            final filteredExpenses = _filterExpenses(
                              state.expenses,
                            );
                            return Column(
                              children: [
                                _buildStatsCard(filteredExpenses),
                                const SizedBox(height: 32),
                                _buildSectionTitle(
                                  _showChart
                                      ? 'التوزيع حسب الفئة'
                                      : 'قائمة المصروفات',
                                  _showChart
                                      ? Icons.pie_chart_rounded
                                      : Icons.receipt_long_rounded,
                                ),
                                const SizedBox(height: 16),
                                _buildFilterChips(),
                                const SizedBox(height: 16),
                                if (filteredExpenses.isEmpty)
                                  _buildEmptyState()
                                else if (_showChart)
                                  _buildChartView(filteredExpenses)
                                else
                                  _buildExpensesList(filteredExpenses),
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
          AppColors.expense.withOpacity(0.08),
          AppColors.danger.withOpacity(0.05),
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
                            colors: [AppColors.expense, AppColors.danger],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.expense.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
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
                              'المصروفات',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'إدارة المصروفات والنفقات',
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
          _showChart ? Icons.list_rounded : Icons.pie_chart_rounded,
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() => _showChart = !_showChart);
          },
        ),
        _buildIconButton(
          Icons.refresh_rounded,
          onPressed: () {
            HapticFeedback.lightImpact();
            context.read<ExpensesBloc>().add(LoadExpenses());
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildIconButton(
    IconData icon, {
    required VoidCallback onPressed,
    String? badge,
  }) => Stack(
    children: [
      IconButton(
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
      ),
      if (badge != null)
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.danger,
              shape: BoxShape.circle,
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
    ],
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
                AppColors.expense.withOpacity(0.1),
                AppColors.danger.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.expense),
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

  Widget _buildStatsCard(List<Expense> expenses) {
    final totalAmount = expenses.fold(
      0.0,
      (sum, expense) => sum + expense.amount,
    );
    final todayExpenses = expenses.where((expense) {
      final today = DateTime.now();
      final expenseDate = DateTime.parse(expense.date);
      return expenseDate.year == today.year &&
          expenseDate.month == today.month &&
          expenseDate.day == today.day;
    }).toList();
    final todayAmount = todayExpenses.fold(0.0, (sum, e) => sum + e.amount);

    final expensesByCategory = <String, double>{};
    for (final expense in expenses) {
      expensesByCategory[expense.category] =
          (expensesByCategory[expense.category] ?? 0) + expense.amount;
    }
    final topCategory = expensesByCategory.entries.isEmpty
        ? 'لا يوجد'
        : expensesByCategory.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;

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
                colors: [AppColors.expense, AppColors.danger],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.expense.withOpacity(0.4),
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
                                'إجمالي المصروفات',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${expenses.length} عملية',
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
                                    color: AppColors.warning,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.warning,
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
                        tween: Tween(begin: 0, end: totalAmount),
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
                          color: AppColors.warning.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.category_rounded,
                              size: 16,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'الأكثر: $topCategory',
                              style: const TextStyle(
                                color: AppColors.warning,
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
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.7,
            children: [
              _buildStatItem(
                icon: Icons.today_rounded,
                label: 'اليوم',
                value: todayAmount,
                color: AppColors.info,
              ),
              _buildStatItem(
                icon: Icons.receipt_rounded,
                label: 'عدد اليوم',
                value: todayExpenses.length.toDouble(),
                color: AppColors.warning,
                isCount: true,
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
    bool isCount = false,
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
                isCount
                    ? animValue.toStringAsFixed(0)
                    : '${animValue.toStringAsFixed(0)} ر.ي',
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
    final filters = ['الكل', 'اليوم', 'هذا الأسبوع', 'هذا الشهر'];

    return Container(
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
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [AppColors.expense, AppColors.danger],
                      )
                    : null,
                color: isSelected ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.expense
                      : AppColors.border.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.expense.withOpacity(0.3),
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

  Widget _buildExpensesList(List<Expense> expenses) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: expenses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return ExpenseCard(
          expense: expenses[index],
          onTap: () => _showExpenseDetails(expenses[index]),
          onDelete: () => _deleteExpense(expenses[index]),
        );
      },
    );
  }

  Widget _buildChartView(List<Expense> expenses) {
    final expensesByCategory = <String, double>{};
    for (final expense in expenses) {
      expensesByCategory[expense.category] =
          (expensesByCategory[expense.category] ?? 0) + expense.amount;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ExpenseChart(expensesByCategory: expensesByCategory),
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
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 60,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'لا توجد مصروفات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ابدأ بإضافة أول مصروف',
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
      onPressed: () => _navigateWithAnimation(context, RouteNames.addExpense),
      backgroundColor: AppColors.expense,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'مصروف جديد',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      elevation: 8,
    ),
  );

  List<Expense> _filterExpenses(List<Expense> expenses) {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'اليوم':
        return expenses.where((expense) {
          final expenseDate = DateTime.parse(expense.date);
          return expenseDate.year == now.year &&
              expenseDate.month == now.month &&
              expenseDate.day == now.day;
        }).toList();
      case 'هذا الأسبوع':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return expenses.where((expense) {
          final expenseDate = DateTime.parse(expense.date);
          return expenseDate.isAfter(
            weekStart.subtract(const Duration(days: 1)),
          );
        }).toList();
      case 'هذا الشهر':
        return expenses.where((expense) {
          final expenseDate = DateTime.parse(expense.date);
          return expenseDate.year == now.year && expenseDate.month == now.month;
        }).toList();
      default:
        return expenses;
    }
  }

  void _navigateWithAnimation(BuildContext context, String routeName) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, routeName).then((_) {
      context.read<ExpensesBloc>().add(LoadExpenses());
    });
  }

  void _showExpenseDetails(Expense expense) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      RouteNames.expenseDetails,
      arguments: expense,
    ).then((_) {
      context.read<ExpensesBloc>().add(LoadExpenses());
    });
  }

  Future<void> _deleteExpense(Expense expense) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'حذف المصروف',
      message: 'هل أنت متأكد من حذف هذا المصروف؟',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      isDangerous: true,
    );

    if (confirmed == true && expense.id != null) {
      context.read<ExpensesBloc>().add(DeleteExpenseEvent(expense.id!));
    }
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
