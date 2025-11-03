/// الشاشة الرئيسية للتطبيق
/// تعرض القائمة الرئيسية وملخص اليوم والوصول السريع للوظائف

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

/// الشاشة الرئيسية
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('الصفحة الرئيسية', style: AppTextStyles.title),
          actions: [
            // أيقونة حالة المزامنة
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: () {
                // TODO: بدء المزامنة
              },
            ),
            // أيقونة الإشعارات
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // TODO: عرض الإشعارات
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ملخص اليوم
              _buildDailySummary(),
              const SizedBox(height: 24),
              
              // القائمة الرئيسية
              Text('القائمة الرئيسية', style: AppTextStyles.subtitle),
              const SizedBox(height: 16),
              _buildMainMenu(context),
              const SizedBox(height: 24),
              
              // الوصول السريع
              Text('وصول سريع', style: AppTextStyles.subtitle),
              const SizedBox(height: 16),
              _buildQuickAccess(context),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء بطاقة ملخص اليوم
  Widget _buildDailySummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ملخص اليوم', style: AppTextStyles.subtitle),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('المبيعات', '0', Icons.shopping_cart),
                _buildSummaryItem('المشتريات', '0', Icons.shopping_bag),
                _buildSummaryItem('الربح', '0', Icons.attach_money),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// بناء عنصر في ملخص اليوم
  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.title),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  /// بناء شبكة القائمة الرئيسية
  Widget _buildMainMenu(BuildContext context) {
    final menuItems = [
      {'title': 'بيع سريع', 'icon': Icons.point_of_sale, 'route': '/quick-sale'},
      {'title': 'المبيعات', 'icon': Icons.receipt_long, 'route': '/sales'},
      {'title': 'المشتريات', 'icon': Icons.shopping_basket, 'route': '/purchases'},
      {'title': 'العملاء', 'icon': Icons.people, 'route': '/customers'},
      {'title': 'الموردين', 'icon': Icons.local_shipping, 'route': '/suppliers'},
      {'title': 'الديون', 'icon': Icons.account_balance_wallet, 'route': '/debts'},
      {'title': 'المصروفات', 'icon': Icons.money_off, 'route': '/expenses'},
      {'title': 'التقارير', 'icon': Icons.bar_chart, 'route': '/reports'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuItem(
          context,
          item['title'] as String,
          item['icon'] as IconData,
          item['route'] as String,
        );
      },
    );
  }

  /// بناء عنصر في القائمة
  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: التنقل للشاشة المطلوبة
          // Navigator.pushNamed(context, route);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            Text(title, style: AppTextStyles.body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  /// بناء أزرار الوصول السريع
  Widget _buildQuickAccess(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: فتح شاشة البيع السريع
            },
            icon: const Icon(Icons.flash_on),
            label: const Text('بيع سريع'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: فتح شاشة التقارير
            },
            icon: const Icon(Icons.assessment),
            label: const Text('التقارير'),
          ),
        ),
      ],
    );
  }
}
