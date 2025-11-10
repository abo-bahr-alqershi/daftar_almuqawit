import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/debts/debts_bloc.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_widget.dart';
import './widgets/debt_card.dart';

/// شاشة الديون المتأخرة
/// 
/// تعرض قائمة بالديون التي تجاوزت تاريخ الاستحقاق
class OverdueDebtsScreen extends StatefulWidget {
  const OverdueDebtsScreen({super.key});

  @override
  State<OverdueDebtsScreen> createState() => _OverdueDebtsScreenState();
}

class _OverdueDebtsScreenState extends State<OverdueDebtsScreen> {
  @override
  void initState() {
    super.initState();
    _loadOverdueDebts();
  }

  void _loadOverdueDebts() {
    context.read<DebtsBloc>().add(const LoadOverdueDebts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الديون المتأخرة'),
        backgroundColor: AppColors.danger,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Send reminders to all
            },
          ),
        ],
      ),
      body: BlocBuilder<DebtsBloc, DebtsState>(
        builder: (context, state) {
          if (state is DebtsLoading) {
            return const LoadingWidget(message: 'جاري تحميل الديون المتأخرة...');
          }

          if (state is OverdueDebtsLoaded) {
            if (state.overdueDebts.isEmpty) {
              return const EmptyWidget(
                title: 'لا توجد ديون متأخرة',
                message: 'جميع الديون مسددة أو ضمن المواعيد',
                icon: Icons.check_circle_outline,
              );
            }

            final totalOverdueAmount = state.overdueDebts.fold<double>(
              0,
              (sum, debt) => sum + debt.remainingAmount,
            );

            return Column(
              children: [
                // إجمالي الديون المتأخرة
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.danger,
                        AppColors.danger.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إجمالي الديون المتأخرة',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textOnDark.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${totalOverdueAmount.toStringAsFixed(0)} ريال',
                            style: AppTextStyles.headlineLarge.copyWith(
                              color: AppColors.textOnDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.textOnDark.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${state.overdueDebts.length} دين',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textOnDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // قائمة الديون المتأخرة
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.overdueDebts.length,
                    itemBuilder: (context, index) {
                      final debt = state.overdueDebts[index];
                      final daysOverdue = DateTime.now().difference(debt.dueDate!).inDays;
                      
                      return DebtCard(
                        debt: debt,
                        isOverdue: true,
                        daysOverdue: daysOverdue,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/debt-details',
                            arguments: debt.id,
                          );
                        },
                        onPayment: () {
                          Navigator.pushNamed(
                            context,
                            '/debt-payment',
                            arguments: {
                              'debtId': debt.id,
                              'remainingAmount': debt.remainingAmount,
                            },
                          );
                        },
                        onReminder: () {
                          _sendReminder(debt.id);
                        },
                      );
                    },
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
          _sendRemindersToAll();
        },
        backgroundColor: AppColors.warning,
        icon: const Icon(Icons.notifications_active),
        label: const Text('إرسال تذكير للجميع'),
      ),
    );
  }

  void _sendReminder(String debtId) {
    context.read<DebtsBloc>().add(SendDebtReminder(debtId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال التذكير')),
    );
  }

  void _sendRemindersToAll() {
    // Implement send reminders to all overdue debts
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال التذكيرات لجميع العملاء')),
    );
  }
}
