import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../blocs/accounting/accounting_bloc.dart';
import '../../blocs/accounting/accounting_event.dart';
import '../../blocs/accounting/accounting_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as app_error;
import 'cash_screen.dart';
import 'journal_entries_screen.dart';

/// الشاشة الرئيسية للمحاسبة
class AccountingScreen extends StatefulWidget {
  const AccountingScreen({super.key});

  @override
  State<AccountingScreen> createState() => _AccountingScreenState();
}

class _AccountingScreenState extends State<AccountingScreen> {
  @override
  void initState() {
    super.initState();
    _loadAccountingData();
  }

  void _loadAccountingData() {
    context.read<AccountingBloc>().add(LoadAccounts());
  }

  void _navigateToCash() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CashScreen()),
    );
  }

  void _navigateToJournalEntries() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JournalEntriesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('المحاسبة', style: AppTextStyles.headlineMedium),
          backgroundColor: AppColors.primary,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadAccountingData,
              tooltip: 'تحديث',
            ),
          ],
        ),
        body: BlocConsumer<AccountingBloc, AccountingState>(
          listener: (context, state) {
            if (state is AccountingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.danger,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is AccountingLoading) {
              return const LoadingWidget(message: 'جاري تحميل البيانات المالية...');
            }

            if (state is AccountingError) {
              return app_error.ErrorWidget(
                message: state.message,
              );
            }

            if (state is AccountingLoaded) {
              return RefreshIndicator(
                onRefresh: () async => _loadAccountingData(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFinancialSummary(state),
                      
                      const SizedBox(height: AppDimensions.spaceL),
                      
                      Text(
                        'الأقسام المحاسبية',
                        style: AppTextStyles.headlineSmall,
                      ),
                      
                      const SizedBox(height: AppDimensions.spaceM),
                      
                      _buildModulesGrid(),
                      
                      const SizedBox(height: AppDimensions.spaceL),
                      
                      _buildQuickStats(state),
                    ],
                  ),
                ),
              );
            }

            return const Center(
              child: Text('لا توجد بيانات'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFinancialSummary(AccountingLoaded state) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_balance,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: AppDimensions.spaceM),
          Text(
            'الرصيد الإجمالي',
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceS),
          Text(
            '${state.balance.toStringAsFixed(2)} ريال',
            style: AppTextStyles.displaySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceL),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.arrow_downward,
                  label: 'الإيرادات',
                  value: state.totalIncome.toStringAsFixed(2),
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.arrow_upward,
                  label: 'المصروفات',
                  value: state.totalExpenses.toStringAsFixed(2),
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppDimensions.spaceS),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value ريال',
            style: AppTextStyles.titleSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesGrid() {
    final modules = [
      _ModuleItem(
        icon: Icons.account_balance_wallet,
        title: 'إدارة الصندوق',
        subtitle: 'عرض حركة النقدية',
        color: AppColors.success,
        onTap: _navigateToCash,
      ),
      _ModuleItem(
        icon: Icons.description,
        title: 'قيود اليومية',
        subtitle: 'إضافة وعرض القيود',
        color: AppColors.primary,
        onTap: _navigateToJournalEntries,
      ),
      _ModuleItem(
        icon: Icons.account_balance,
        title: 'ميزان المراجعة',
        subtitle: 'عرض الأرصدة',
        color: AppColors.info,
        onTap: () {
          Navigator.pushNamed(context, '/trial-balance');
        },
      ),
      _ModuleItem(
        icon: Icons.bar_chart,
        title: 'القوائم المالية',
        subtitle: 'الميزانية وقائمة الدخل',
        color: AppColors.warning,
        onTap: () {
          Navigator.pushNamed(context, '/financial-statements');
        },
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.spaceM,
        mainAxisSpacing: AppDimensions.spaceM,
        childAspectRatio: 1.1,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return _buildModuleCard(module);
      },
    );
  }

  Widget _buildModuleCard(_ModuleItem module) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: InkWell(
        onTap: module.onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: module.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Icon(
                  module.icon,
                  color: module.color,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceM),
              Flexible(
                child: Text(
                  module.title,
                  style: AppTextStyles.titleSmall,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceS),
              Flexible(
                child: Text(
                  module.subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(AccountingLoaded state) {
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
              'إحصائيات سريعة',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: AppDimensions.spaceM),
            _buildStatRow(
              icon: Icons.trending_up,
              label: 'صافي الربح',
              value: '${(state.totalIncome - state.totalExpenses).toStringAsFixed(2)} ريال',
              color: state.balance >= 0 ? AppColors.success : AppColors.danger,
            ),
            const Divider(height: 24),
            _buildStatRow(
              icon: Icons.percent,
              label: 'هامش الربح',
              value: state.totalIncome > 0
                  ? '${((state.totalIncome - state.totalExpenses) / state.totalIncome * 100).toStringAsFixed(1)}%'
                  : '0%',
              color: AppColors.info,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: AppDimensions.spaceM),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ModuleItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  _ModuleItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
