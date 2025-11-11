import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/debts/debts_bloc.dart';
import '../../blocs/debts/debts_event.dart';
import '../../blocs/debts/debts_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import './widgets/debt_card.dart';
import './widgets/debt_filters.dart';

/// شاشة الديون الرئيسية
/// 
/// تعرض قائمة بجميع الديون مع إمكانية الفلترة والبحث
class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  String _selectedFilter = 'الكل';
  String _selectedSortBy = 'التاريخ';

  @override
  void initState() {
    super.initState();
    _loadDebts();
  }

  void _loadDebts() {
    final event = _selectedFilter == 'معلقة'
        ? LoadPendingDebts()
        : _selectedFilter == 'متأخرة'
            ? LoadOverdueDebts()
            : LoadDebts();
    context.read<DebtsBloc>().add(event);
  }

  void _showSearch(List debts) {
    showSearch(
      context: context,
      delegate: DebtSearchDelegate(debts),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('الديون', style: AppTextStyles.title),
          backgroundColor: AppColors.danger,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                final state = context.read<DebtsBloc>().state;
                if (state is DebtsLoaded) {
                  _showSearch(state.debts);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilters,
            ),
          ],
        ),
        body: BlocBuilder<DebtsBloc, DebtsState>(
          builder: (context, state) {
            if (state is DebtsLoading) {
              return const LoadingWidget(message: 'جاري تحميل الديون...');
            }

            if (state is DebtsError) {
              return custom_error.ErrorWidget(
                message: state.message,
                onRetry: _loadDebts,
              );
            }

            if (state is DebtsLoaded) {
              if (state.debts.isEmpty) {
                return EmptyWidget(
                  title: 'لا توجد ديون',
                  message: _getEmptyMessage(),
                  icon: Icons.account_balance_wallet_outlined,
                );
              }

              return Column(
                children: [
                  // إحصائيات الديون
                  _buildStatisticsCard(state.debts),

                  // قائمة الديون
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        _loadDebts();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.debts.length,
                        itemBuilder: (context, index) {
                          final debt = state.debts[index];
                          final isOverdue = debt.dueDate != null &&
                              DateTime.parse(debt.dueDate!)
                                  .isBefore(DateTime.now()) &&
                              debt.remainingAmount > 0;
                          final daysOverdue = isOverdue
                              ? DateTime.now()
                                  .difference(DateTime.parse(debt.dueDate!))
                                  .inDays
                              : 0;

                          return DebtCard(
                            debt: debt,
                            isOverdue: isOverdue,
                            daysOverdue: daysOverdue,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/debt-details',
                                arguments: debt.id,
                              );
                            },
                            onPayment: debt.remainingAmount > 0
                                ? () {
                                    Navigator.pushNamed(
                                      context,
                                      '/debt-payment',
                                      arguments: {
                                        'debtId': debt.id.toString(),
                                        'remainingAmount':
                                            debt.remainingAmount,
                                      },
                                    );
                                  }
                                : null,
                            onReminder: debt.remainingAmount > 0 &&
                                    debt.customerPhone != null
                                ? () {
                                    _sendReminder(debt);
                                  }
                                : null,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            }

            return const Center(child: Text('حدث خطأ في تحميل البيانات'));
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, '/add-debt');
          },
          backgroundColor: AppColors.danger,
          icon: const Icon(Icons.add),
          label: const Text('إضافة دين'),
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(List debts) {
    final totalDebts = debts.length;
    final totalAmount = debts.fold<double>(
      0,
      (sum, debt) => sum + (debt.remainingAmount ?? 0),
    );
    final overdueDebts = debts.where((debt) {
      return debt.dueDate != null &&
          DateTime.parse(debt.dueDate!).isBefore(DateTime.now()) &&
          debt.remainingAmount > 0;
    }).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.danger,
            AppColors.danger.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                'إجمالي الديون',
                '$totalDebts',
                Icons.account_balance_wallet,
              ),
              _buildStatItem(
                'متأخرة',
                '$overdueDebts',
                Icons.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.textOnDark.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إجمالي المبلغ المتبقي',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textOnDark.withOpacity(0.9),
                  ),
                ),
                Text(
                  '${totalAmount.toStringAsFixed(0)} ريال',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textOnDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textOnDark, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.textOnDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textOnDark.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  void _showFilters() {
    showDebtFilters(
      context: context,
      selectedFilter: _selectedFilter,
      selectedSortBy: _selectedSortBy,
      onFilterChanged: (filter) {
        setState(() {
          _selectedFilter = filter;
        });
        _loadDebts();
      },
      onSortChanged: (sortBy) {
        setState(() {
          _selectedSortBy = sortBy;
        });
      },
    );
  }

  void _sendReminder(dynamic debt) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إرسال تذكير إلى ${debt.customerName}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  String _getEmptyMessage() {
    switch (_selectedFilter) {
      case 'معلقة':
        return 'لا توجد ديون معلقة حالياً';
      case 'متأخرة':
        return 'لا توجد ديون متأخرة';
      case 'مدفوعة':
        return 'لا توجد ديون مدفوعة';
      default:
        return 'لم يتم تسجيل أي ديون بعد';
    }
  }
}

/// مندوب البحث عن الديون
class DebtSearchDelegate extends SearchDelegate<dynamic> {
  final List debts;

  DebtSearchDelegate(this.debts);

  @override
  String get searchFieldLabel => 'ابحث عن دين...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_forward),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = debts.where((debt) {
      final personName = debt.personName?.toLowerCase() ?? '';
      final amount = debt.remainingAmount?.toString() ?? '';
      final status = debt.status?.toLowerCase() ?? '';
      final searchLower = query.toLowerCase();
      
      return personName.contains(searchLower) ||
          amount.contains(searchLower) ||
          status.contains(searchLower);
    }).toList();

    if (results.isEmpty) {
      return const Center(
        child: Text('لا توجد نتائج'),
      );
    }

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final debt = results[index];
          final isOverdue = debt.dueDate != null &&
              DateTime.parse(debt.dueDate!)
                  .isBefore(DateTime.now()) &&
              debt.remainingAmount > 0;
          final daysOverdue = isOverdue
              ? DateTime.now()
                  .difference(DateTime.parse(debt.dueDate!))
                  .inDays
              : 0;

          return DebtCard(
            debt: debt,
            isOverdue: isOverdue,
            daysOverdue: daysOverdue,
            onTap: () {
              close(context, debt);
            },
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = debts.where((debt) {
      final personName = debt.personName?.toLowerCase() ?? '';
      final searchLower = query.toLowerCase();
      
      return personName.contains(searchLower);
    }).toList();

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: ListView.builder(
        itemCount: suggestions.length > 5 ? 5 : suggestions.length,
        itemBuilder: (context, index) {
          final debt = suggestions[index];
          return ListTile(
            leading: const Icon(Icons.account_balance_wallet, color: AppColors.danger),
            title: Text(debt.personName ?? 'عميل'),
            subtitle: Text('${debt.remainingAmount ?? 0} ريال - ${debt.status ?? "غير محدد"}'),
            onTap: () {
              query = debt.personName ?? '';
              showResults(context);
            },
          );
        },
      ),
    );
  }
}
