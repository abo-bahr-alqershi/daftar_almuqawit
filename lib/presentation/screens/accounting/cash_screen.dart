import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../blocs/accounting/cash_management_bloc.dart';
import '../../blocs/accounting/cash_management_event.dart';
import '../../blocs/accounting/cash_management_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as app_error;
import '../../widgets/common/app_button.dart';
import 'widgets/cash_flow_widget.dart';

/// شاشة إدارة الصندوق النقدي
class CashScreen extends StatefulWidget {
  const CashScreen({super.key});

  @override
  State<CashScreen> createState() => _CashScreenState();
}

class _CashScreenState extends State<CashScreen> {
  DateTime _selectedDate = DateTime.now();
  String _filterType = 'اليوم';

  final List<String> _filterTypes = ['اليوم', 'الأسبوع', 'الشهر', 'السنة'];

  @override
  void initState() {
    super.initState();
    _loadCashData();
  }

  void _loadCashData() {
    context.read<CashManagementBloc>().add(
      LoadCashBalance(_selectedDate.toIso8601String().split('T')[0]),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() => _selectedDate = date);
      _loadCashData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('إدارة الصندوق', style: AppTextStyles.headlineMedium),
          backgroundColor: AppColors.primary,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _selectDate,
              tooltip: 'اختر تاريخ',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadCashData,
              tooltip: 'تحديث',
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              height: 50,
              color: AppColors.surface,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                ),
                itemCount: _filterTypes.length,
                itemBuilder: (context, index) {
                  final type = _filterTypes[index];
                  final isSelected = _filterType == type;
                  
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: AppDimensions.spaceS,
                    ),
                    child: FilterChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _filterType = type);
                        _loadCashData();
                      },
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: BlocConsumer<CashManagementBloc, CashManagementState>(
                listener: (context, state) {
                  if (state is CashManagementError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.danger,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is CashManagementLoading) {
                    return const LoadingWidget(message: 'جاري تحميل بيانات الصندوق...');
                  }

                  if (state is CashManagementError) {
                    return app_error.ErrorWidget(
                      message: state.message,
                      onRetry: _loadCashData,
                    );
                  }

                  if (state is CashBalanceLoaded) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildBalanceCard(state.balance),
                          
                          const SizedBox(height: AppDimensions.spaceL),

                          _buildSummaryCards(state),

                          const SizedBox(height: AppDimensions.spaceL),

                          CashFlowWidget(
                            income: state.totalIncome,
                            expenses: state.totalExpenses,
                            date: _selectedDate,
                          ),

                          const SizedBox(height: AppDimensions.spaceL),

                          _buildQuickActions(),
                        ],
                      ),
                    );
                  }

                  return Center(
                    child: Text(
                      'لا توجد بيانات',
                      style: AppTextStyles.bodyLarge,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    final isPositive = balance >= 0;
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [AppColors.success, AppColors.success.withOpacity(0.8)]
              : [AppColors.danger, AppColors.danger.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: (isPositive ? AppColors.success : AppColors.danger)
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isPositive ? Icons.account_balance_wallet : Icons.warning,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: AppDimensions.spaceM),
          Text(
            'رصيد الصندوق',
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceS),
          Text(
            '${balance.toStringAsFixed(2)} ريال',
            style: AppTextStyles.displaySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceS),
          Text(
            _selectedDate.toIso8601String().split('T')[0],
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(CashBalanceLoaded state) {
    return Row(
      children: [
        Expanded(
          child: _buildMiniCard(
            icon: Icons.arrow_downward,
            label: 'الإيرادات',
            value: state.totalIncome.toStringAsFixed(2),
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppDimensions.spaceM),
        Expanded(
          child: _buildMiniCard(
            icon: Icons.arrow_upward,
            label: 'المصروفات',
            value: state.totalExpenses.toStringAsFixed(2),
            color: AppColors.danger,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              '$value ريال',
              style: AppTextStyles.titleMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إجراءات سريعة',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: AppDimensions.spaceM),
            AppButton.secondary(
              text: 'إضافة قيد يومية',
              icon: Icons.add,
              onPressed: () {
                // TODO: Navigate to add journal entry
              },
              fullWidth: true,
            ),
            const SizedBox(height: AppDimensions.spaceS),
            AppButton.secondary(
              text: 'عرض كشف الحساب',
              icon: Icons.description,
              onPressed: () {
                // TODO: Navigate to account statement
              },
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
