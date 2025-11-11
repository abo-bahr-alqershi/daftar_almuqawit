import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import 'widgets/settings_tile.dart';
import 'backup_screen.dart';
import 'profile_screen.dart';
import 'language_screen.dart';
import 'theme_screen.dart';
import 'about_screen.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_event.dart';
import '../../blocs/settings/settings_state.dart';

/// شاشة الإعدادات الرئيسية
/// تعرض جميع خيارات الإعدادات المتاحة في التطبيق
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل الإعدادات عند فتح الشاشة
    context.read<SettingsBloc>().add(LoadSettings());
  }

  /// التنقل إلى شاشة فرعية
  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('الإعدادات', style: AppTextStyles.headlineMedium),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnDark,
          elevation: 0,
        ),
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            if (state is SettingsInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SettingsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.danger,
                    ),
                    const SizedBox(height: AppDimensions.spaceM),
                    Text(state.message, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppDimensions.spaceM),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<SettingsBloc>().add(LoadSettings()),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            final settingsState = state as SettingsLoaded;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.spaceM),

                  // قسم الحساب
                  _SectionHeader(title: 'الحساب'),
                  SettingsTile.navigation(
                    title: 'الملف الشخصي',
                    subtitle: 'إدارة معلومات حسابك',
                    icon: Icons.person,
                    iconColor: AppColors.primary,
                    onTap: () => _navigateTo(const ProfileScreen()),
                  ),

                  const SizedBox(height: AppDimensions.spaceL),

                  // قسم المظهر
                  _SectionHeader(title: 'المظهر'),
                  SettingsTile.navigation(
                    title: 'اللغة',
                    subtitle: 'العربية',
                    icon: Icons.language,
                    iconColor: AppColors.info,
                    onTap: () => _navigateTo(const LanguageScreen()),
                  ),
                  SettingsTile.navigation(
                    title: 'المظهر',
                    subtitle: 'فاتح، داكن، أو تلقائي',
                    icon: Icons.palette,
                    iconColor: AppColors.warning,
                    onTap: () => _navigateTo(const ThemeScreen()),
                  ),

                  const SizedBox(height: AppDimensions.spaceL),

                  // قسم الإشعارات
                  _SectionHeader(title: 'الإشعارات'),
                  SettingsTile.switchTile(
                    title: 'تفعيل الإشعارات',
                    subtitle: 'استقبال إشعارات التطبيق',
                    icon: Icons.notifications,
                    iconColor: AppColors.success,
                    value: settingsState.notificationsEnabled,
                    onChanged: (value) {
                      context.read<SettingsBloc>().add(
                        ToggleNotifications(value),
                      );
                    },
                  ),
                  SettingsTile.switchTile(
                    title: 'الصوت',
                    subtitle: 'تشغيل أصوات الإشعارات',
                    icon: Icons.volume_up,
                    iconColor: AppColors.info,
                    value: settingsState.soundEnabled,
                    onChanged: (value) {
                      context.read<SettingsBloc>().add(ToggleSound(value));
                    },
                  ),

                  const SizedBox(height: AppDimensions.spaceL),

                  // قسم البيانات
                  _SectionHeader(title: 'البيانات والمزامنة'),
                  SettingsTile.switchTile(
                    title: 'المزامنة التلقائية',
                    subtitle: 'مزامنة البيانات مع السحابة تلقائياً',
                    icon: Icons.sync,
                    iconColor: AppColors.primary,
                    value: settingsState.autoSyncEnabled,
                    onChanged: (value) {
                      context.read<SettingsBloc>().add(ToggleAutoSync(value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? 'تم تفعيل المزامنة التلقائية'
                                : 'تم تعطيل المزامنة التلقائية',
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    title: 'النسخ الاحتياطي',
                    subtitle: 'إدارة النسخ الاحتياطية',
                    icon: Icons.backup,
                    iconColor: AppColors.success,
                    onTap: () => _navigateTo(const BackupScreen()),
                  ),
                  SettingsTile(
                    title: 'تصدير البيانات',
                    subtitle: 'تصدير البيانات إلى ملف Excel',
                    icon: Icons.file_download,
                    iconColor: AppColors.info,
                    trailing: const Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('سيتم إضافة ميزة التصدير قريباً'),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                  ),
                  SettingsTile(
                    title: 'مسح ذاكرة التخزين المؤقت',
                    subtitle: 'حذف الملفات المؤقتة',
                    icon: Icons.cleaning_services,
                    iconColor: AppColors.warning,
                    trailing: const Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    onTap: () {
                      _showClearCacheDialog();
                    },
                  ),

                  const SizedBox(height: AppDimensions.spaceL),

                  // قسم الأمان
                  _SectionHeader(title: 'الأمان والخصوصية'),
                  SettingsTile(
                    title: 'تغيير كلمة المرور',
                    subtitle: 'تحديث كلمة مرور حسابك',
                    icon: Icons.lock,
                    iconColor: AppColors.danger,
                    trailing: const Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'سيتم إضافة ميزة تغيير كلمة المرور قريباً',
                          ),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                  ),
                  SettingsTile(
                    title: 'البصمة وFace ID',
                    subtitle: 'استخدام البيانات الحيوية',
                    icon: Icons.fingerprint,
                    iconColor: AppColors.primary,
                    trailing: const Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'سيتم إضافة ميزة البيانات الحيوية قريباً',
                          ),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppDimensions.spaceL),

                  // قسم حول التطبيق
                  _SectionHeader(title: 'حول'),
                  SettingsTile.navigation(
                    title: 'عن التطبيق',
                    subtitle: 'معلومات الإصدار والتراخيص',
                    icon: Icons.info,
                    iconColor: AppColors.info,
                    onTap: () => _navigateTo(const AboutScreen()),
                  ),
                  SettingsTile(
                    title: 'المساعدة والدعم',
                    subtitle: 'الأسئلة الشائعة والتواصل',
                    icon: Icons.help,
                    iconColor: AppColors.success,
                    trailing: const Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('سيتم إضافة قسم المساعدة قريباً'),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                  ),
                  SettingsTile(
                    title: 'تقييم التطبيق',
                    subtitle: 'شاركنا رأيك في التطبيق',
                    icon: Icons.star,
                    iconColor: AppColors.warning,
                    trailing: const Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('شكراً لدعمك! سيتم فتح صفحة التقييم'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    showDivider: false,
                  ),

                  const SizedBox(height: AppDimensions.spaceXL),

                  // زر تسجيل الخروج
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showLogoutDialog,
                        icon: const Icon(Icons.logout),
                        label: const Text('تسجيل الخروج'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingM,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spaceXL),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// عرض حوار تأكيد مسح ذاكرة التخزين المؤقت
  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          title: const Text('مسح ذاكرة التخزين المؤقت'),
          content: const Text('سيتم حذف جميع الملفات المؤقتة. هل أنت متأكد؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم مسح ذاكرة التخزين المؤقت بنجاح'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.warning),
              child: const Text('مسح'),
            ),
          ],
        ),
      ),
    );
  }

  /// عرض حوار تأكيد تسجيل الخروج
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تسجيل الخروج'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }
}

/// رأس القسم
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingL,
        AppDimensions.paddingM,
        AppDimensions.paddingL,
        AppDimensions.paddingS,
      ),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
