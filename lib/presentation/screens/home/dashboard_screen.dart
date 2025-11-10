import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/home/dashboard_bloc.dart';
import '../../blocs/home/dashboard_event.dart';
import '../../blocs/home/dashboard_state.dart';
import '../../blocs/sync/sync_bloc.dart';
import '../../blocs/sync/sync_state.dart';
import '../../navigation/route_names.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import 'widgets/quick_stats_widget.dart';
import 'widgets/sync_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    context.read<DashboardBloc>().add(LoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text(
            'لوحة التحكم',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            BlocBuilder<SyncBloc, SyncState>(
              builder: (context, state) {
                return SyncIndicator(
                  isSyncing: state is SyncInProgress,
                  lastSyncTime: state is SyncSuccess ? DateTime.now() : null,
                  onTap: () {},
                );
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh),
              color: AppColors.textPrimary,
              onPressed: _loadDashboard,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: LoadingWidget());
            }

            if (state is DashboardError) {
              return Center(
                child: custom_error.AppErrorWidget(
                  message: state.message,
                  onRetry: _loadDashboard,
                ),
              );
            }

            if (state is DashboardLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  _loadDashboard();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      
                      QuickStatsWidget(stats: state.dailyStats),
                      
                      const SizedBox(height: 24),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'الإحصائيات التفصيلية',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildDetailedStats(state),
                      
                      const SizedBox(height: 24),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'الوصول السريع',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildQuickActions(),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDetailedStats(DashboardLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'المبيعات',
                  value: '${state.dailyStats.totalSales}',
                  subtitle: 'ريال',
                  icon: Icons.trending_up,
                  color: AppColors.sales,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'المشتريات',
                  value: '${state.dailyStats.totalPurchases}',
                  subtitle: 'ريال',
                  icon: Icons.shopping_cart,
                  color: AppColors.purchases,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'المصروفات',
                  value: '${state.dailyStats.totalExpenses}',
                  subtitle: 'ريال',
                  icon: Icons.payment,
                  color: AppColors.expense,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'الديون',
                  value: '${(state.dailyStats.newDebts + state.dailyStats.collectedDebts).toStringAsFixed(0)}',
                  subtitle: 'ريال',
                  icon: Icons.account_balance_wallet,
                  color: AppColors.debt,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
        children: [
          _QuickActionCard(
            icon: Icons.add_shopping_cart,
            label: 'بيع سريع',
            color: AppColors.sales,
            onTap: () => Navigator.pushNamed(context, RouteNames.sales),
          ),
          _QuickActionCard(
            icon: Icons.shopping_bag,
            label: 'شراء',
            color: AppColors.purchases,
            onTap: () => Navigator.pushNamed(context, RouteNames.purchases),
          ),
          _QuickActionCard(
            icon: Icons.person_add,
            label: 'عميل جديد',
            color: AppColors.primary,
            onTap: () => Navigator.pushNamed(context, RouteNames.customers),
          ),
          _QuickActionCard(
            icon: Icons.store,
            label: 'مورد جديد',
            color: AppColors.accent,
            onTap: () => Navigator.pushNamed(context, RouteNames.suppliers),
          ),
          _QuickActionCard(
            icon: Icons.receipt,
            label: 'مصروف',
            color: AppColors.expense,
            onTap: () => Navigator.pushNamed(context, RouteNames.expenses),
          ),
          _QuickActionCard(
            icon: Icons.bar_chart,
            label: 'التقارير',
            color: AppColors.info,
            onTap: () => Navigator.pushNamed(context, RouteNames.statistics),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
