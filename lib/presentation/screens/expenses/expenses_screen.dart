import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/expenses/expenses_bloc.dart';
import '../../blocs/expenses/expenses_event.dart';
import '../../blocs/expenses/expenses_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import './widgets/expense_card.dart';
import './widgets/expense_chart.dart';

/// شاشة المصروفات الرئيسية
/// 
/// تعرض قائمة بجميع المصروفات مع إمكانية الفلترة والبحث
class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'الكل';
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredExpenses = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadExpenses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadExpenses() {
    final today = DateTime.now().toString().split(' ')[0];
    final event = _selectedFilter == 'اليوم'
        ? LoadTodayExpenses(today)
        : LoadExpenses();
    context.read<ExpensesBloc>().add(event);
  }

  void _showSearch(List expenses) {
    showSearch(
      context: context,
      delegate: ExpenseSearchDelegate(expenses),
    );
  }

  void _filterExpenses(List expenses, String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredExpenses = expenses;
      });
    } else {
      setState(() {
        _filteredExpenses = expenses.where((expense) {
          final description = expense.description?.toLowerCase() ?? '';
          final category = expense.category?.toLowerCase() ?? '';
          final amount = expense.amount?.toString() ?? '';
          final searchLower = query.toLowerCase();
          
          return description.contains(searchLower) ||
              category.contains(searchLower) ||
              amount.contains(searchLower);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('المصروفات', style: AppTextStyles.title),
          backgroundColor: AppColors.danger,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                final state = context.read<ExpensesBloc>().state;
                if (state is ExpensesLoaded) {
                  _showSearch(state.expenses);
                }
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: (value) {
                setState(() {
                  _selectedFilter = value;
                });
                _loadExpenses();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'الكل', child: Text('الكل')),
                const PopupMenuItem(value: 'اليوم', child: Text('اليوم')),
                const PopupMenuItem(value: 'هذا الأسبوع', child: Text('هذا الأسبوع')),
                const PopupMenuItem(value: 'هذا الشهر', child: Text('هذا الشهر')),
              ],
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.textOnDark,
            tabs: const [
              Tab(text: 'القائمة'),
              Tab(text: 'الرسم البياني'),
            ],
          ),
        ),
        body: BlocBuilder<ExpensesBloc, ExpensesState>(
          builder: (context, state) {
            if (state is ExpensesLoading) {
              return const LoadingWidget(message: 'جاري تحميل المصروفات...');
            }

            if (state is ExpensesError) {
              return custom_error.ErrorWidget(
                message: state.message,
                onRetry: _loadExpenses,
              );
            }

            if (state is ExpensesLoaded) {
              if (state.expenses.isEmpty) {
                return EmptyWidget(
                  title: 'لا توجد مصروفات',
                  message: _getEmptyMessage(),
                  icon: Icons.receipt_long_outlined,
                );
              }

              return Column(
                children: [
                  _buildStatisticsCard(state.expenses),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildListView(state.expenses),
                        _buildChartView(state.expenses),
                      ],
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
            Navigator.pushNamed(context, '/add-expense');
          },
          backgroundColor: AppColors.danger,
          icon: const Icon(Icons.add),
          label: const Text('إضافة مصروف'),
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(List expenses) {
    final totalExpenses = expenses.length;
    final totalAmount = expenses.fold<double>(
      0,
      (sum, expense) => sum + (expense.amount ?? 0),
    );
    final todayExpenses = expenses.where((expense) {
      final today = DateTime.now().toString().split(' ')[0];
      return expense.date == today;
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
                'إجمالي المصروفات',
                '$totalExpenses',
                Icons.receipt_long,
              ),
              _buildStatItem(
                'اليوم',
                '$todayExpenses',
                Icons.today,
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
                  'إجمالي المبلغ',
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

  Widget _buildListView(List expenses) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadExpenses();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return ExpenseCard(
            expense: expense,
            onTap: () {
              // TODO: Navigate to expense details
            },
            onEdit: () {
              Navigator.pushNamed(
                context,
                '/edit-expense',
                arguments: expense,
              );
            },
            onDelete: () {
              _showDeleteConfirmation(expense);
            },
          );
        },
      ),
    );
  }

  Widget _buildChartView(List expenses) {
    final expensesByCategory = <String, double>{};
    for (final expense in expenses) {
      final category = expense.category ?? 'أخرى';
      expensesByCategory[category] = 
          (expensesByCategory[category] ?? 0) + (expense.amount ?? 0);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ExpenseChart(expensesByCategory: expensesByCategory),
    );
  }

  void _showDeleteConfirmation(dynamic expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المصروف'),
        content: Text('هل أنت متأكد من حذف المصروف "${expense.description}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ExpensesBloc>().add(DeleteExpenseEvent(expense.id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف المصروف'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  String _getEmptyMessage() {
    switch (_selectedFilter) {
      case 'اليوم':
        return 'لا توجد مصروفات لهذا اليوم';
      case 'هذا الأسبوع':
        return 'لا توجد مصروفات لهذا الأسبوع';
      case 'هذا الشهر':
        return 'لا توجد مصروفات لهذا الشهر';
      default:
        return 'لم يتم تسجيل أي مصروفات بعد';
    }
  }
}

/// مندوب البحث عن المصروفات
class ExpenseSearchDelegate extends SearchDelegate<dynamic> {
  final List expenses;

  ExpenseSearchDelegate(this.expenses);

  @override
  String get searchFieldLabel => 'ابحث عن مصروف...';

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
    final results = expenses.where((expense) {
      final description = expense.description?.toLowerCase() ?? '';
      final category = expense.category?.toLowerCase() ?? '';
      final amount = expense.amount?.toString() ?? '';
      final searchLower = query.toLowerCase();
      
      return description.contains(searchLower) ||
          category.contains(searchLower) ||
          amount.contains(searchLower);
    }).toList();

    if (results.isEmpty) {
      return const Center(
        child: Text('لا توجد نتائج'),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final expense = results[index];
          return ExpenseCard(
            expense: expense,
            onTap: () {
              close(context, expense);
            },
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = expenses.where((expense) {
      final description = expense.description?.toLowerCase() ?? '';
      final category = expense.category?.toLowerCase() ?? '';
      final searchLower = query.toLowerCase();
      
      return description.contains(searchLower) || category.contains(searchLower);
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        itemCount: suggestions.length > 5 ? 5 : suggestions.length,
        itemBuilder: (context, index) {
          final expense = suggestions[index];
          return ListTile(
            leading: const Icon(Icons.receipt_long, color: AppColors.danger),
            title: Text(expense.description ?? 'مصروف'),
            subtitle: Text('${expense.amount ?? 0} ريال - ${expense.category ?? "غير محدد"}'),
            onTap: () {
              query = expense.description ?? '';
              showResults(context);
            },
          );
        },
      ),
    );
  }
}
