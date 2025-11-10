import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/home/dashboard_bloc.dart';
import '../../blocs/sync/sync_bloc.dart';
import '../../blocs/sync/sync_state.dart';
import '../../navigation/route_names.dart';
import '../../widgets/common/loading_widget.dart';
import 'widgets/menu_grid.dart';
import 'widgets/quick_stats_widget.dart';
import 'widgets/sync_indicator.dart';
import 'widgets/shortcuts_bar.dart';
import 'widgets/recent_activities.dart';

/// الشاشة الرئيسية للتطبيق
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'دفتر المقاوت',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'مرحباً بك',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
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
              icon: const Icon(Icons.notifications_outlined),
              color: AppColors.textPrimary,
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              color: AppColors.textPrimary,
              onPressed: () => Navigator.pushNamed(context, RouteNames.settings),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoading) {
                      return const LoadingWidget();
                    }
                    
                    if (state is DashboardLoaded) {
                      return QuickStatsWidget(
                        stats: state.dailyStats,
                      );
                    }
                    
                    return const SizedBox.shrink();
                  },
                ),
                
                const SizedBox(height: 24),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'اختصارات سريعة',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                ShortcutsBar(
                  onQuickSale: () => Navigator.pushNamed(context, RouteNames.sales),
                  onAddPurchase: () => Navigator.pushNamed(context, RouteNames.purchases),
                  onAddExpense: () => Navigator.pushNamed(context, RouteNames.expenses),
                  onViewReports: () => Navigator.pushNamed(context, RouteNames.statistics),
                ),
                
                const SizedBox(height: 24),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'القائمة الرئيسية',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                const MenuGrid(),
                
                const SizedBox(height: 24),
                
                const RecentActivities(
                  activities: [],
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
