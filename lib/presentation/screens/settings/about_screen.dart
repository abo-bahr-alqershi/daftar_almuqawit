import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import 'widgets/app_version_card.dart';

/// شاشة عن التطبيق
/// تعرض معلومات حول التطبيق والإصدار والمطورين
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('عن التطبيق', style: AppTextStyles.headlineMedium),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnDark,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // بطاقة الإصدار
              AppVersionCard(
                appName: 'دفتر المقاوت',
                version: '1.0.0',
                buildNumber: '1',
                buildDate: '2024-01-15',
                environment: 'Production',
                hasUpdate: false,
                onCheckUpdate: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('أنت تستخدم أحدث إصدار'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                onVisitWebsite: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('سيتم فتح الموقع الإلكتروني'),
                      backgroundColor: AppColors.info,
                    ),
                  );
                },
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // وصف التطبيق
              _InfoCard(
                icon: Icons.description,
                iconColor: AppColors.info,
                title: 'نبذة عن التطبيق',
                content:
                    'دفتر المقاوت هو نظام محاسبي متكامل مصمم خصيصاً لإدارة تجارة القات. يوفر التطبيق أدوات شاملة لتتبع المبيعات والمشتريات والديون والمصروفات، مع إمكانية المزامنة السحابية والنسخ الاحتياطي التلقائي.',
              ),

              const SizedBox(height: AppDimensions.spaceL),

              // الميزات الرئيسية
              _InfoCard(
                icon: Icons.star,
                iconColor: AppColors.warning,
                title: 'الميزات الرئيسية',
                content: '''
• إدارة المبيعات والمشتريات بسهولة
• تتبع الديون والمدفوعات
• تقارير وإحصائيات شاملة
• مزامنة سحابية تلقائية
• نسخ احتياطي آمن
• واجهة مستخدم سهلة وبديهية
• دعم كامل للغة العربية
                ''',
              ),

              const SizedBox(height: AppDimensions.spaceL),

              // المطورون
              _InfoCard(
                icon: Icons.code,
                iconColor: AppColors.primary,
                title: 'فريق التطوير',
                content:
                    'تم تطوير هذا التطبيق بواسطة فريق متخصص في تطوير التطبيقات المحاسبية. نحن ملتزمون بتوفير أفضل تجربة مستخدم ودعم فني مستمر.',
              ),

              const SizedBox(height: AppDimensions.spaceL),

              // معلومات الاتصال
              _InfoCard(
                icon: Icons.contact_support,
                iconColor: AppColors.success,
                title: 'التواصل والدعم',
                content: '''
البريد الإلكتروني: support@daftar-almuqawit.com
رقم الواتساب: +967 777 123 456
ساعات العمل: من 9 صباحاً إلى 5 مساءً

نحن هنا لمساعدتك! لا تتردد في التواصل معنا لأي استفسار أو مشكلة.
                ''',
              ),

              const SizedBox(height: AppDimensions.spaceL),

              // سياسة الخصوصية والشروط
              _ActionButton(
                icon: Icons.privacy_tip,
                label: 'سياسة الخصوصية',
                onPressed: () {
                  _showPrivacyPolicy(context);
                },
              ),

              const SizedBox(height: AppDimensions.spaceM),

              _ActionButton(
                icon: Icons.article,
                label: 'شروط الاستخدام',
                onPressed: () {
                  _showTermsOfService(context);
                },
              ),

              const SizedBox(height: AppDimensions.spaceM),

              _ActionButton(
                icon: Icons.gavel,
                label: 'التراخيص مفتوحة المصدر',
                onPressed: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'دفتر المقاوت',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2024 جميع الحقوق محفوظة',
                  );
                },
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // شكر وتقدير
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: AppColors.textOnDark,
                      size: 48,
                    ),
                    const SizedBox(height: AppDimensions.spaceM),
                    Text(
                      'شكراً لاستخدامك دفتر المقاوت',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.textOnDark,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.spaceS),
                    Text(
                      'نسعى دائماً لتحسين تجربتك',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textOnDark.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// عرض سياسة الخصوصية
  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('سياسة الخصوصية'),
          content: const SingleChildScrollView(
            child: Text(
              '''نحن نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية. يتم تخزين جميع البيانات بشكل آمن على جهازك والسحابة المشفرة.

1. جمع البيانات: نجمع فقط البيانات الضرورية لتشغيل التطبيق
2. استخدام البيانات: تستخدم بياناتك فقط لغرض إدارة حساباتك
3. مشاركة البيانات: لا نشارك بياناتك مع أي طرف ثالث
4. أمان البيانات: جميع البيانات مشفرة ومحمية

لمزيد من المعلومات، يرجى زيارة موقعنا الإلكتروني.''',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  /// عرض شروط الاستخدام
  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('شروط الاستخدام'),
          content: const SingleChildScrollView(
            child: Text(
              '''باستخدامك لتطبيق دفتر المقاوت، فإنك توافق على الشروط التالية:

1. الاستخدام المشروع: يجب استخدام التطبيق للأغراض المشروعة فقط
2. الدقة: أنت مسؤول عن دقة البيانات المدخلة
3. الأمان: يجب عليك حماية حسابك وبياناتك
4. التحديثات: نحتفظ بالحق في تحديث التطبيق
5. المسؤولية: نحن لسنا مسؤولين عن أي خسائر ناتجة عن الاستخدام

لمزيد من التفاصيل، يرجى زيارة موقعنا الإلكتروني.''',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة معلومات
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceM),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// زر إجراء
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingM,
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }
}
