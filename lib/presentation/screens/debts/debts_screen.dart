import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/services/debts_tutorial_service.dart';
import '../../../domain/entities/debt.dart';
import '../../blocs/debts/debts_bloc.dart';
import '../../blocs/debts/debts_event.dart';
import '../../blocs/debts/debts_state.dart';
import '../../widgets/common/confirm_dialog.dart';
import './widgets/debt_card.dart';
import './widgets/debt_filters.dart';
import './add_debt_screen.dart';

/// شاشة الديون الرئيسية - تصميم راقي هادئ
class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  
  final GlobalKey _statsCardsKey = GlobalKey();
  final GlobalKey _filterChipsKey = GlobalKey();
  final GlobalKey _debtsListKey = GlobalKey();
  final GlobalKey _addDebtButtonKey = GlobalKey();
  final GlobalKey _filtersButtonKey = GlobalKey();

  String _selectedStatus = 'الكل';
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

    _loadDebts();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadDebts() {
    if (_selectedStatus == 'معلقة') {
      context.read<DebtsBloc>().add(LoadPendingDebts());
    } else if (_selectedStatus == 'متأخرة') {
      context.read<DebtsBloc>().add(LoadOverdueDebts());
    } else {
      context.read<DebtsBloc>().add(LoadDebts());
    }
  }

  List<Debt> _filterAndSortDebts(List<Debt> debts) {
    var filteredDebts = debts;

    if (_selectedStatus != 'الكل') {
      filteredDebts = debts.where((debt) {
        switch (_selectedStatus) {
          case 'معلقة':
            return debt.status == 'غير مسدد' || debt.status == 'مسدد جزئي';
          case 'متأخرة':
            if (debt.dueDate == null) return false;
            final dueDate = DateTime.parse(debt.dueDate!);
            return dueDate.isBefore(DateTime.now()) && debt.remainingAmount > 0;
          case 'مدفوعة':
            return debt.status == 'مسدد';
          default:
            return true;
        }
      }).toList();
    }

    filteredDebts.sort((a, b) {
      switch (_selectedSort) {
        case 'المبلغ':
          return b.originalAmount.compareTo(a.originalAmount);
        case 'العميل':
          return a.personName.compareTo(b.personName);
        case 'الاستحقاق':
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return DateTime.parse(a.dueDate!).compareTo(DateTime.parse(b.dueDate!));
        case 'التاريخ':
        default:
          return DateTime.parse(b.date).compareTo(DateTime.parse(a.date));
      }
    });

    return filteredDebts;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            _buildGradientBackground(),
            RefreshIndicator(
              onRefresh: () async {
                _loadDebts();
                await Future.delayed(const Duration(seconds: 1));
              },
              color: AppColors.danger,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(context),
                  BlocBuilder<DebtsBloc, DebtsState>(
                    builder: (context, state) {
                      if (state is DebtsLoading) {
                        return const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (state is DebtsError) {
                        return SliverFillRemaining(
                          child: _buildErrorState(state.message),
                        );
                      }

                      if (state is DebtsLoaded) {
                        final filteredDebts = _filterAndSortDebts(state.debts);

                        if (filteredDebts.isEmpty) {
                          return SliverFillRemaining(
                            child: _buildEmptyState(),
                          );
                        }

                        return SliverToBoxAdapter(
                          child: Column(
                            children: [
                              _buildStatsCards(state.debts),
                              const SizedBox(height: 8),
                              _buildFilterSection(),
                              const SizedBox(height: 8),
                              _buildDebtsList(filteredDebts),
                              const SizedBox(height: 80),
                            ],
                          ),
                        );
                      }

                      return const SliverFillRemaining(
                        child: Center(child: Text('لا توجد بيانات')),
                      );
                    },
                  ),
                ],
              ),
            ),
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      height: 400,
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
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final opacity = (_scrollOffset / 100).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColors.surface.withOpacity(opacity),
      elevation: opacity * 4,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: const Icon(Icons.arrow_back_rounded, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Container(
          key: _filtersButtonKey,
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.filter_list_rounded, size: 20),
            ),
            onPressed: () => _showFiltersDialog(),
          ),
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

            DebtsTutorialService.showScreenTutorial(
              context: context,
              statsCardsKey: _statsCardsKey,
              filterChipsKey: _filterChipsKey,
              debtsListKey: _debtsListKey,
              addDebtButtonKey: _addDebtButtonKey,
              filtersButtonKey: _filtersButtonKey,
              scrollController: _scrollController,
              onFinish: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('تمت جولة التعليمات لشاشة الديون'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(width: 8),
      ],
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
                            colors: [AppColors.danger, AppColors.warning],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.danger.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
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
                              'الديون',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'إدارة ومتابعة الديون',
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

  Widget _buildStatsCards(List<Debt> debts) {
    final totalDebts = debts.length;
    final overdueDebts = debts.where((d) {
      if (d.dueDate == null) return false;
      final dueDate = DateTime.parse(d.dueDate!);
      return dueDate.isBefore(DateTime.now()) && d.remainingAmount > 0;
    }).length;
    final totalAmount = debts.fold<double>(0, (sum, d) => sum + d.remainingAmount);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        key: _statsCardsKey,
        child: Row(
          children: [
          Expanded(
            child: _StatCard(
              title: 'إجمالي الديون',
              value: totalDebts.toString(),
              icon: Icons.list_alt_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'المتأخرة',
              value: overdueDebts.toString(),
              icon: Icons.warning_rounded,
              gradient: const LinearGradient(
                colors: [AppColors.danger, AppColors.warning],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'المبلغ المتبقي',
              value: Formatters.formatCurrency(totalAmount),
              icon: Icons.account_balance_wallet_rounded,
              gradient: const LinearGradient(
                colors: [AppColors.warning, Color(0xFFFF8F00)],
              ),
              isAmount: true,
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      key: _filterChipsKey,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'الكل',
                    isSelected: _selectedStatus == 'الكل',
                    onTap: () {
                      setState(() => _selectedStatus = 'الكل');
                      _loadDebts();
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'معلقة',
                    isSelected: _selectedStatus == 'معلقة',
                    onTap: () {
                      setState(() => _selectedStatus = 'معلقة');
                      _loadDebts();
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'متأخرة',
                    isSelected: _selectedStatus == 'متأخرة',
                    onTap: () {
                      setState(() => _selectedStatus = 'متأخرة');
                      _loadDebts();
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'مدفوعة',
                    isSelected: _selectedStatus == 'مدفوعة',
                    onTap: () {
                      setState(() => _selectedStatus = 'مدفوعة');
                      _loadDebts();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtsList(List<Debt> debts) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: debts.length,
      itemBuilder: (context, index) {
        final debt = debts[index];
        final card = DebtCard(
          debt: debt,
          onTap: () => _navigateToDetails(debt),
          onPayTap: () => _navigateToPayment(debt),
        );

        if (index == 0) {
          return Container(
            key: _debtsListKey,
            child: card,
          );
        }

        return card;
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
                  AppColors.warning.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 60,
              color: AppColors.danger.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد ديون',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedStatus == 'الكل'
                ? 'لم يتم تسجيل أي دين بعد'
                : 'لا توجد ديون $_selectedStatus',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: AppColors.danger,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.danger,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadDebts,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        key: _addDebtButtonKey,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.danger, AppColors.warning],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.danger.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToAdd(),
            borderRadius: BorderRadius.circular(16),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'إضافة دين جديد',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFiltersDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DebtFilters(
        selectedStatus: _selectedStatus,
        selectedSortBy: _selectedSort,
        onStatusChanged: (status) {
          setState(() => _selectedStatus = status);
          _loadDebts();
          Navigator.pop(context);
        },
        onSortChanged: (sort) {
          setState(() => _selectedSort = sort);
        },
      ),
    );
  }

  void _navigateToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddDebtScreen()),
    );
    if (result == true) {
      _loadDebts();
    }
  }

  void _navigateToDetails(Debt debt) async {
    // Navigate to details
  }

  void _navigateToPayment(Debt debt) async {
    // Navigate to payment
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final bool isAmount;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.isAmount = false,
  });

  @override
  Widget build(BuildContext context) {
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
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: isAmount ? 14 : 20,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.danger : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.danger : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
