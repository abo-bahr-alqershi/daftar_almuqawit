/// شاشة التقارير الرئيسية
/// تعرض قائمة بأنواع التقارير المتاحة

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../navigation/route_names.dart';
import 'widgets/report_card.dart';

/// شاشة التقارير
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

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
            'التقارير',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              color: AppColors.textPrimary,
              onPressed: () {
                _showInfoDialog(context);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // مقدمة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.insights,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تقارير مفصلة',
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox(height: 4),
                          
                          Text(
                            'احصل على تحليل شامل لأعمالك',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // عنوان التقارير الدورية
              Text(
                'التقارير الدورية',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // التقرير اليومي
              ReportCard(
                title: 'التقرير اليومي',
                description: 'عرض مفصل لجميع العمليات والإحصائيات اليومية',
                icon: Icons.today,
                color: AppColors.primary,
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.dailyReport);
                },
              ),
              
              const SizedBox(height: 12),
              
              // التقرير الأسبوعي
              ReportCard(
                title: 'التقرير الأسبوعي',
                description: 'تحليل شامل لأداء الأسبوع مع المقارنات',
                icon: Icons.calendar_view_week,
                color: AppColors.info,
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.weeklyReport);
                },
              ),
              
              const SizedBox(height: 12),
              
              // التقرير الشهري
              ReportCard(
                title: 'التقرير الشهري',
                description: 'إحصائيات شاملة عن الشهر الحالي والأشهر السابقة',
                icon: Icons.calendar_today,
                color: AppColors.sales,
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.monthlyReport);
                },
              ),
              
              const SizedBox(height: 12),
              
              // التقرير السنوي
              ReportCard(
                title: 'التقرير السنوي',
                description: 'تقرير سنوي شامل مع تحليل الاتجاهات',
                icon: Icons.calendar_month,
                color: AppColors.success,
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.yearlyReport);
                },
              ),
              
              const SizedBox(height: 24),
              
              // عنوان التقارير المخصصة
              Text(
                'تقارير مخصصة',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // التقرير المخصص
              ReportCard(
                title: 'تقرير مخصص',
                description: 'أنشئ تقريرك الخاص باختيار الفترة الزمنية والمعايير',
                icon: Icons.tune,
                color: AppColors.accent,
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.customReport);
                },
              ),
              
              const SizedBox(height: 24),
              
              // عنوان التقارير التحليلية
              Text(
                'تقارير تحليلية',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // تحليل الربح
              ReportCard(
                title: 'تحليل الربح',
                description: 'تحليل مفصل لهوامش الربح والتكاليف',
                icon: Icons.trending_up,
                color: AppColors.purchases,
                onTap: () {
                  Navigator.pushNamed(context, '/profit-analysis');
                },
                isEnabled: true,
              ),
              
              const SizedBox(height: 12),
              
              // تقرير العملاء
              ReportCard(
                title: 'تقرير العملاء',
                description: 'تحليل سلوك العملاء وترتيبهم حسب المشتريات',
                icon: Icons.people,
                color: AppColors.debt,
                onTap: () {
                  Navigator.pushNamed(context, '/customers-report');
                },
                isEnabled: true,
              ),
              
              const SizedBox(height: 12),
              
              // تقرير المنتجات
              ReportCard(
                title: 'تقرير المنتجات',
                description: 'الأكثر مبيعاً والأقل مبيعاً وحركة المخزون',
                icon: Icons.inventory_2,
                color: AppColors.expense,
                onTap: () {
                  Navigator.pushNamed(context, '/products-report');
                },
                isEnabled: true,
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// عرض مربع حوار المعلومات
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.info,
              ),
              const SizedBox(width: 12),
              Text(
                'حول التقارير',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'توفر لك التقارير رؤية شاملة لأداء أعمالك:',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _InfoItem(
                icon: Icons.bar_chart,
                text: 'مخططات بيانية تفاعلية',
              ),
              _InfoItem(
                icon: Icons.print,
                text: 'إمكانية الطباعة والتصدير',
              ),
              _InfoItem(
                icon: Icons.share,
                text: 'مشاركة التقارير',
              ),
              _InfoItem(
                icon: Icons.filter_list,
                text: 'فلترة وترتيب متقدم',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'حسناً',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// عنصر معلومات
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
