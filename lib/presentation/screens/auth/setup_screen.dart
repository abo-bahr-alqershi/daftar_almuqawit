import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/common/app_button.dart';
import '../../navigation/route_names.dart';

/// شاشة الإعداد الأولي للتطبيق بعد التسجيل
/// تحتوي على 3 خطوات: الترحيب، معلومات العمل، والإعدادات
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  /// رقم الخطوة الحالية
  int _currentStep = 0;
  
  /// متحكم حقل اسم العمل
  final _businessNameController = TextEditingController();
  
  /// نوع العمل المختار
  String _selectedBusinessType = 'تجارة القات';
  
  /// تفعيل النسخ الاحتياطي
  bool _enableBackup = true;
  
  /// تفعيل المزامنة التلقائية
  bool _enableSync = true;

  @override
  void dispose() {
    _businessNameController.dispose();
    super.dispose();
  }

  /// الانتقال للخطوة التالية أو إنهاء الإعداد
  void _handleNext() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      // حفظ الإعدادات والانتقال للصفحة الرئيسية
      Navigator.of(context).pushNamedAndRemoveUntil(
        RouteNames.home,
        (route) => false,
      );
    }
  }

  /// الرجوع للخطوة السابقة
  void _handleBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: _currentStep > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: _handleBack,
                )
              : null,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // شريط التقدم
              Padding(
                padding: const EdgeInsets.all(24),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / 3,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              
              // محتوى الخطوة الحالية
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildCurrentStep(),
                ),
              ),
              
              // أزرار التنقل
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    AppButton.primary(
                      text: _currentStep < 2 ? 'التالي' : 'ابدأ الاستخدام',
                      onPressed: _handleNext,
                      fullWidth: true,
                      icon: _currentStep < 2 ? Icons.arrow_forward : Icons.check,
                    ),
                    if (_currentStep < 2) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            RouteNames.home,
                            (route) => false,
                          );
                        },
                        child: Text(
                          'تخطي',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء محتوى الخطوة الحالية
  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildBusinessInfoStep();
      case 2:
        return _buildSettingsStep();
      default:
        return const SizedBox.shrink();
    }
  }

  /// خطوة الترحيب وعرض الميزات
  Widget _buildWelcomeStep() {
    return Column(
      children: [
        const SizedBox(height: 40),
        
        // شعار التطبيق
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: const Icon(
            Icons.eco,
            size: 60,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // رسالة الترحيب
        Text(
          'مرحباً بك في دفتر المقاوت',
          style: AppTextStyles.h1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'نظام محاسبي متكامل لإدارة تجارة القات',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 48),
        
        // عرض الميزات الرئيسية
        _FeatureCard(
          icon: Icons.account_balance_wallet,
          title: 'إدارة المبيعات والمشتريات',
          description: 'تسجيل ومتابعة جميع عمليات البيع والشراء',
        ),
        const SizedBox(height: 16),
        _FeatureCard(
          icon: Icons.people,
          title: 'إدارة العملاء والموردين',
          description: 'متابعة الديون والمدفوعات بسهولة',
        ),
        const SizedBox(height: 16),
        _FeatureCard(
          icon: Icons.bar_chart,
          title: 'تقارير مفصلة',
          description: 'احصل على تقارير يومية وشهرية وسنوية',
        ),
      ],
    );
  }

  /// خطوة إدخال معلومات العمل
  Widget _buildBusinessInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        
        Text(
          'معلومات العمل',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'أخبرنا المزيد عن عملك',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // حقل اسم العمل
        TextField(
          controller: _businessNameController,
          decoration: InputDecoration(
            labelText: 'اسم العمل',
            hintText: 'مثال: مقاوت الجوهرة',
            prefixIcon: const Icon(Icons.business),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // نوع العمل
        Text(
          'نوع العمل',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // قائمة أنواع العمل
        ...[
          'تجارة القات',
          'تاجر جملة',
          'محل تجزئة',
          'أخرى',
        ].map((type) {
          return RadioListTile<String>(
            title: Text(type),
            value: type,
            groupValue: _selectedBusinessType,
            onChanged: (value) {
              setState(() {
                _selectedBusinessType = value!;
              });
            },
            activeColor: AppColors.primary,
          );
        }).toList(),
      ],
    );
  }

  /// خطوة إعدادات التطبيق
  Widget _buildSettingsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        
        Text(
          'الإعدادات الأولية',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'اختر الإعدادات المناسبة لك',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // إعداد النسخ الاحتياطي
        _SettingsTile(
          icon: Icons.cloud_upload,
          title: 'تفعيل النسخ الاحتياطي السحابي',
          subtitle: 'احفظ بياناتك بشكل آمن في السحابة',
          value: _enableBackup,
          onChanged: (value) {
            setState(() {
              _enableBackup = value;
            });
          },
        ),
        
        const SizedBox(height: 16),
        
        // إعداد المزامنة
        _SettingsTile(
          icon: Icons.sync,
          title: 'تفعيل المزامنة التلقائية',
          subtitle: 'مزامنة البيانات تلقائياً عند الاتصال بالإنترنت',
          value: _enableSync,
          onChanged: (value) {
            setState(() {
              _enableSync = value;
            });
          },
        ),
      ],
    );
  }
}

/// ويدجت لعرض ميزة من ميزات التطبيق
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ويدجت لعرض خيار إعداد مع مفتاح تبديل
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
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
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
